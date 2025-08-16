// lib/game_logic/card_game_state_manager.dart
import 'dart:math';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import 'package:myapp/game_data/card_definition.dart';
import 'package:myapp/game_data/game_data_manager.dart';
import 'package:myapp/game_logic/creature_in_play.dart';
import 'package:myapp/game_logic/player.dart';

/// High-level turn phases for the UI and rules engine
enum TurnPhase { start, main1, combat, main2, end }

/// Tunables (easy to tweak for balance/playtests)
class GameRules {
  static const int startingLife = 20;
  static const int startingResources = 0;
  static const int startingHandSize = 5;
  static const int handLimit = 7;
  static const bool tapAttackersOnDeclare = true;
  static const int resourceGainPerTurnStart = 1;
  static const bool summoningSicknessAffectsAttack = true;
}

/// Core state manager for the TCG-lite loop
class CardGameStateManager extends ChangeNotifier {
  // ----------------------------------------------------------------------------
  // Public state
  // ----------------------------------------------------------------------------
  bool isGameEnded = false;
  String? winningPlayerId;

  /// Shared discard pile:
  /// Keep this if you want a visible "global discard" for spells/creatures.
  /// (Creatures in play die => their `cardDefinition` is added here.)
  final List<CardDefinition> discardPile = [];

  /// Two players
  List<Player> players = [];
  int currentPlayerIndex = 0;

  TurnPhase currentPhase = TurnPhase.start;

  /// Attackers confirmed during combat
  final List<CreatureInPlay> _declaredAttackers = [];

  CardGameStateManager() {
    startGame();
  }

  Player get currentPlayer => players[currentPlayerIndex];
  Player get opponent => players[(currentPlayerIndex + 1) % players.length];

  // ----------------------------------------------------------------------------
  // Game lifecycle
  // ----------------------------------------------------------------------------

  /// (Re)starts a fresh game with data from GameDataManager
  void startGame() {
    _initializeGame(GameDataManager.cards);
    notifyListeners();
  }

  void _initializeGame(List<CardDefinition> allCards) {
    // Create 2 players
    players = [
      Player(id: 'player1'),
      Player(id: 'player2'),
    ];

    // Initialize player state
    for (final p in players) {
      // TODO: Replace with real deckbuilding/import once you have it.
      p.deck = List<CardDefinition>.from(allCards)..shuffle(Random());
      p.life = GameRules.startingLife;
      p.resources = GameRules.startingResources;
      p.hand.clear();
      p.playArea.clear(); // List<CreatureInPlay>
      p.graveyard.clear(); // List<CardDefinition>
    }

    // Draw opening hands
    for (final p in players) {
      _drawOpeningHand(p, GameRules.startingHandSize);
    }

    currentPlayerIndex = 0;
    currentPhase = TurnPhase.start;
    _startOfPhase();
  }

  void _drawOpeningHand(Player player, int count) {
    for (var i = 0; i < count; i++) {
      if (player.deck.isEmpty) break;
      player.hand.add(player.deck.removeAt(0));
    }
  }

  // ----------------------------------------------------------------------------
  // Turn & Phase flow
  // ----------------------------------------------------------------------------

  void nextPhase() {
    switch (currentPhase) {
      case TurnPhase.start:
        currentPhase = TurnPhase.main1;
        break;
      case TurnPhase.main1:
        currentPhase = TurnPhase.combat;
        break;
      case TurnPhase.combat:
        currentPhase = TurnPhase.main2;
        break;
      case TurnPhase.main2:
        currentPhase = TurnPhase.end;
        break;
      case TurnPhase.end:
        _endTurnAndPass();
        currentPhase = TurnPhase.start;
        break;
    }
    _startOfPhase();
    notifyListeners();
  }

  void _startOfPhase() {
    switch (currentPhase) {
      case TurnPhase.start:
        // Untap & remove summoning sickness for current player
        for (final c in currentPlayer.playArea) {
          c.isTapped = false;
          c.hasSummoningSickness = false;
        }

        // Draw and gain resource
        drawCard(currentPlayer);

        currentPlayer.resources += GameRules.resourceGainPerTurnStart;
        developer.log(
          '${currentPlayer.id} +${GameRules.resourceGainPerTurnStart} resource => ${currentPlayer.resources}',
        );
        break;

      case TurnPhase.main1:
      case TurnPhase.combat:
      case TurnPhase.main2:
      case TurnPhase.end:
        // No automatic effects by default
        break;
    }
  }

  void _endTurnAndPass() {
    _declaredAttackers.clear(); // Clean up combat selections
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
  }

  // ----------------------------------------------------------------------------
  // Public API used by the UI
  // ----------------------------------------------------------------------------

  void toggleCreatureTapped(CreatureInPlay creature) {
    creature.isTapped = !creature.isTapped;
    notifyListeners();
  }

  /// Declare attackers (must be your creatures, not summoning sick if attacking)
  void declareAttackers(List<CreatureInPlay> attackers) {
    _declaredAttackers
      ..clear()
      ..addAll(
        attackers.where((a) =>
            currentPlayer.playArea.contains(a) &&
            (!GameRules.summoningSicknessAffectsAttack || !a.hasSummoningSickness)),
      );

    if (GameRules.tapAttackersOnDeclare) {
      for (final a in _declaredAttackers) {
        a.isTapped = true;
      }
    }

    notifyListeners();
  }

  /// Draw a card; reshuffle from the player's own graveyard if needed
  void drawCard(Player player) {
    if (player.deck.isEmpty) {
      if (player.graveyard.isNotEmpty) {
        player.deck = List<CardDefinition>.from(player.graveyard)..shuffle(Random());
        player.graveyard.clear();
        developer.log("Shuffled ${player.id}'s graveyard back into the deck.");
      } else {
        developer.log('No cards left to draw for ${player.id}.');
        return;
      }
    }

    if (player.hand.length >= GameRules.handLimit) {
      developer.log('${player.id} hand full (limit ${GameRules.handLimit}).');
      return;
    }

    player.hand.add(player.deck.removeAt(0));
    notifyListeners();
  }

  /// Play a card from hand; creatures enter play, spells resolve then go to graveyard
  void playCard(Player player, CardDefinition card) {
    if (!player.hand.contains(card)) {
      developer.log('Card not in ${player.id} hand: ${card.name}');
      return;
    }
    if (player.resources < (card.cost)) {
      developer.log('Not enough resources for ${card.name}.');
      return;
    }

    player.hand.remove(card);
    player.resources -= card.cost;

    final type = card.typeId.toLowerCase();
    if (type == 'creature') {
      player.playArea.add(
        CreatureInPlay(
          cardDefinition: card,
          hasSummoningSickness: true,
          isTapped: false,
        ),
      );
    } else {
      _resolveCardAbilities(player, card);
      // send spells to graveyard after resolution
      player.graveyard.add(card);
    }

    notifyListeners();
  }

  /// Simple lane-based simultaneous combat
  void resolveCombat() {
    if (_declaredAttackers.isEmpty) {
      developer.log('No attackers declared.');
      return;
    }

    final attacker = currentPlayer;
    final defender = opponent;

    final defeatedAtk = <CreatureInPlay>[];
    final defeatedDef = <CreatureInPlay>[];

    final laneCount = _max(attacker.playArea.length, defender.playArea.length);

    for (var i = 0; i < laneCount; i++) {
      final atk = i < attacker.playArea.length ? attacker.playArea[i] : null;
      final blk = i < defender.playArea.length ? defender.playArea[i] : null;

      // attacker must be declared & legal
      if (atk == null || !_declaredAttackers.contains(atk) || atk.hasSummoningSickness) {
        continue;
      }

      if (blk == null) {
        defender.life -= atk.currentAttack;
        continue;
      }

      // Simultaneous damage using each creature's base/current attack
      final atkPower = atk.cardDefinition.attack ?? 0;
      final blkPower = blk.cardDefinition.attack ?? 0;

      blk.currentToughness -= atkPower;
      atk.currentToughness -= blkPower;

      if (blk.currentToughness <= 0) defeatedDef.add(blk);
      if (atk.currentToughness <= 0) defeatedAtk.add(atk);
    }

    // Remove defeated creatures from play
    attacker.playArea.removeWhere((c) => defeatedAtk.contains(c));
    defender.playArea.removeWhere((c) => defeatedDef.contains(c));

    // Their card backs go to global discard (or swap to per-player graveyard if desired)
    discardPile.addAll(defeatedAtk.map((c) => c.cardDefinition));
    discardPile.addAll(defeatedDef.map((c) => c.cardDefinition));

    _declaredAttackers.clear();

    final win = _checkWin();
    if (win != null) {
      endGame(win);
    }

    notifyListeners();
  }

  // ----------------------------------------------------------------------------
  // Internals: abilities, win checks, helpers
  // ----------------------------------------------------------------------------

  void _resolveCardAbilities(Player player, CardDefinition card) {
    for (final ability in card.abilities) {
      switch (ability) {
        case CardAbilityType.attackBoost:
          _buffFirstFriendly(player, attackDelta: 1, defenseDelta: 0);
          break;

        case CardAbilityType.defenseBoost:
          _buffFirstFriendly(player, attackDelta: 0, defenseDelta: 1);
          break;

        case CardAbilityType.drawCard:
          drawCard(player);
          break;

        case CardAbilityType.discardOpponentCard:
          final opp = opponentOf(player);
          if (opp.hand.isNotEmpty) {
            final i = Random().nextInt(opp.hand.length);
            final removed = opp.hand.removeAt(i);
            discardPile.add(removed);
          }
          break;

        case CardAbilityType.removeTargetCreatureFromPlay:
          final opp2 = opponentOf(player);
          if (opp2.playArea.isNotEmpty) {
            final removed = opp2.playArea.removeAt(0);
            discardPile.add(removed.cardDefinition);
          }
          break;

        case CardAbilityType.gainResources:
          player.resources += 10;
          break;

        case CardAbilityType.heal:
          player.life += 5;
          break;

        case CardAbilityType.dealDamageX:
          // Example placeholder: deal 3 to opponent hero (replace X with card.value or similar)
          opponentOf(player).life -= 3;
          break;
      }
    }
  }

  void _buffFirstFriendly(Player player, {int attackDelta = 0, int defenseDelta = 0}) {
    if (player.playArea.isEmpty) {
      developer.log('No friendly creature to buff.');
      return;
    }
    final target = player.playArea.first;
    if (attackDelta != 0) target.currentAttack += attackDelta;
    if (defenseDelta != 0) target.currentToughness += defenseDelta;
  }

  Player opponentOf(Player p) =>
      players.firstWhere((x) => !identical(x, p), orElse: () => opponent);

  String? _checkWin() {
    final losers = players.where((p) => p.life <= 0).toList();

    if (losers.length > 1) {
      return 'draw';
    } else if (losers.length == 1) {
      final losingId = losers.first.id;
      return players.firstWhere((p) => p.id != losingId).id;
    }
    return null;
  }

  void endGame(String winnerId) {
    isGameEnded = true;
    winningPlayerId = winnerId;
    developer.log('Game ended. Result: ${winnerId == 'draw' ? 'Draw' : 'Winner: $winnerId'}');
  }

  int _max(int a, int b) => a > b ? a : b;

  // ----------------------------------------------------------------------------
  // Convenience helpers for UI/testing
  // ----------------------------------------------------------------------------

  /// Converts a card in hand to a creature directly (used by debug buttons / tests)
  void playFirstCreatureInHand(Player player) {
    final idx = player.hand.indexWhere((c) => c.typeId.toLowerCase() == 'creature');
    if (idx == -1) {
      developer.log('No creature in hand for ${player.id}.');
      return;
    }
    final card = player.hand[idx];
    playCard(player, card);
  }

  /// Declares all eligible friendly creatures as attackers (quick test helper)
  void declareAllAttackers() {
    declareAttackers(
      currentPlayer.playArea.where((c) => !c.hasSummoningSickness).toList(),
    );
  }
}
