import 'dart:math';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import 'package:myapp/game_data/card_definition.dart';
import 'package:myapp/game_data/game_data_manager.dart';
import 'package:myapp/game_logic/creature_in_play.dart';
import 'package:myapp/game_logic/player.dart';

/// Phases used by the UI
enum TurnPhase { start, main1, combat, main2, end }

class CardGameStateManager extends ChangeNotifier {
  bool isGameEnded = false;
  String? winningPlayerId;

  final List<CardDefinition> discardPile = []; // Shared discard pile? Or per-player?

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

  // ----------------------------------------------------------------------------
  // Game lifecycle
  // ----------------------------------------------------------------------------

  void startGame() {
    // Use your game data source; it already has proper CardDefinitions
    _initializeGame(GameDataManager.cards);
    notifyListeners();
  }

  void _initializeGame(List<CardDefinition> allCards) {
    // Create 2 players
    players = [
      Player(id: 'player1'),
      Player(id: 'player2'),
    ];

    // Init player state
    for (final p in players) {
      // Assuming allCards contains the full set of cards available in the game.
      // You'll need logic here to build each player's starting deck.
      // For now, we'll just give each player a copy of all cards and shuffle.
      // TODO: Implement actual deck loading based on player's chosen deck.
      p.deck = List.from(allCards)..shuffle(Random());
      p.life = 20;
      // p.score = 20; // if other parts still read `score` as HP - Removed score as life is used now.
      p.resources = 20;
      p.hand.clear();
      p.playArea.clear();
      p.graveyard.clear();
    }

    for (final p in players) {
      // Deal 5 from player's own deck
      for (var i = 0; i < 5; i++) {
        if (p.deck.isEmpty) break;
 p.hand.add(p.deck.removeAt(0));
      }
    }

    currentPlayerIndex = 0;
    currentPhase = TurnPhase.start;
    _startOfPhase();
  }

  // ----------------------------------------------------------------------------
  // Public API used by the UI
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

  void toggleCreatureTapped(CreatureInPlay creature) {
    creature.isTapped = !creature.isTapped;
    notifyListeners();
  }

  void declareAttackers(List<CreatureInPlay> attackers) {
    _declaredAttackers
      ..clear()
      ..addAll(attackers);

    // Tap attackers on declare
    for (final a in _declaredAttackers) {
      a.isTapped = true;
    }
    notifyListeners();
  }

  void drawCard(Player player) {
    // Shared deck flow
    if (player.deck.isEmpty) {
 if (player.graveyard.isNotEmpty) {
        deck = List.from(discardPile)..shuffle(Random());
        discardPile.clear();
        developer.log('Shuffled discard pile into deck.');
      } else {
        developer.log('No cards left to draw.');
        return;
      }
    }

    const handLimit = 7;
    if (player.hand.length >= handLimit) {
      developer.log('${player.id} hand full.');
      return;
    }

 player.hand.add(player.deck.removeAt(0));
    notifyListeners();
  }

  void playCard(Player player, CardDefinition card) {
    if (!player.hand.contains(card)) {
      developer.log('Card not in ${player.id} hand: ${card.name}');
      return;
    }
    if (player.resources < card.cost) {
      developer.log('Not enough resources for ${card.name}.');
      return;
    }

    player.hand.remove(card);
    player.resources -= card.cost;

    if (card.typeId.toLowerCase() == 'creature') {
      player.playArea.add(
        CreatureInPlay(
          cardDefinition: card,
          hasSummoningSickness: true,
          isTapped: false,
        ),
      );
    } else {
      // Spell effect resolution (basic examples)
      _resolveCardAbilities(player, card);
      // Then send the spell to graveyard
      player.graveyard.add(card);
    }

    notifyListeners();
  }

  /// Simple simultaneous combat:
  /// attackers pair by lane index; if no blocker, damage to player.
  void resolveCombat() {
    if (_declaredAttackers.isEmpty) {
      developer.log('No attackers declared.');
      return;
    }

    final attacker = currentPlayer;
    final defender = players[(currentPlayerIndex + 1) % players.length];

    final toGraveAtk = <CardDefinition>[];
    final toGraveDef = <CardDefinition>[];

    final laneCount = _max(attacker.playArea.length, defender.playArea.length);

    for (var i = 0; i < laneCount; i++) {
      final atk = i < attacker.playArea.length ? attacker.playArea[i] : null;
      final blk = i < defender.playArea.length ? defender.playArea[i] : null;

      // must be one of the declared attackers and not summoning sick
      if (atk == null ||
          !_declaredAttackers.contains(atk) ||
          atk.hasSummoningSickness) {
        continue;
      }

      if (blk == null) {
        defender.life -= atk.currentAttack;
        continue;
      }

      // trade damage
      blk.currentToughness -= atk.cardDefinition.attack; // Corrected to use attack from CardDefinition
      atk.currentToughness -= blk.cardDefinition.attack; // Corrected to use attack from CardDefinition

 if (blk.currentToughness <= 0) toGraveDef.add(blk.cardDefinition);
 if (atk.currentToughness <= 0) toGraveAtk.add(atk.cardDefinition);
    }

    attacker.playArea.removeWhere((c) => toGraveAtk.contains(c.cardDefinition));
    defender.playArea.removeWhere((c) => toGraveDef.contains(c.cardDefinition));
    discardPile.addAll(toGraveAtk);
    discardPile.addAll(toGraveDef);

    _declaredAttackers.clear();

    final win = _checkWin();
    if (win != null) endGame(win);

    notifyListeners();
  }

  // ----------------------------------------------------------------------------
  // Internals
  // ----------------------------------------------------------------------------

  void _startOfPhase() {
    switch (currentPhase) {
      case TurnPhase.start:
        // Untap & remove summoning sickness
        for (final c in currentPlayer.playArea) {
          c.isTapped = false;
          c.hasSummoningSickness = false;
        }
        drawCard(currentPlayer);
        currentPlayer.resources += 1; // Gain 1 resource at start of turn
        developer.log('${currentPlayer.id} gained 1 resource. New resources: ${currentPlayer.resources}');
        break;
      case TurnPhase.main1:
      case TurnPhase.combat:
      case TurnPhase.main2:
      case TurnPhase.end:
        break;
    }
  }

  void _endTurnAndPass() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
  }

  void _resolveCardAbilities(Player player, CardDefinition card) {
    for (final ability in card.abilities) {
      switch (ability) {
 case CardAbilityType.attackBoost:
          // +1/+0 to the first creature you control
 try {
 final target = player.playArea.firstWhere((_) => true); // Find the first creature
            target.currentAttack += 1;
 } catch (e) { // Catch the StateError if no creature is found
            // No creature found, do nothing or log
            developer.log('No creature to target with attackBoost');
          }
 break;

 case CardAbilityType.defenseBoost:
          final target2 = player.playArea.firstWhere(
            (_) => true, // Find the first creature
 );
 try {
 target2.currentToughness += 1;
 } catch (e) { // Catch the StateError if no creature is found
            // No creature found, do nothing or log
            developer.log('No creature to target with defenseBoost');
          }
 break;

 case CardAbilityType.drawCard:
          drawCard(player);
          break;

 case CardAbilityType.discardOpponentCard:
          final opp = players.firstWhere((p) => p.id != player.id);
          if (opp.hand.isNotEmpty) {
            final i = Random().nextInt(opp.hand.length);
            discardPile.add(opp.hand.removeAt(i));
          }
          break;
 case CardAbilityType.removeTargetCreatureFromPlay:
          final opp2 = players.firstWhere((p) => p.id != player.id);
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
          // player.score += 5; // keep both in sync if score is used elsewhere - Removed score as life is used now.
          break;
 case CardAbilityType.dealDamageX:
 // TODO: Implement dealDamageX logic
 break;
      }
    }
  }

  String? _checkWin() {
    final playersAtZeroOrLessLife = players.where((p) => p.life <= 0).toList();

    if (playersAtZeroOrLessLife.length > 1) {
      // More than one player at 0 or less life - it's a draw
      return 'draw';
    } else if (playersAtZeroOrLessLife.length == 1) {
      // Exactly one player is at 0 or less life - the other player wins
      final losingPlayerId = playersAtZeroOrLessLife.first.id;
      return players.firstWhere((p) => p.id != losingPlayerId).id;
    }
    // No player is at 0 or less life
    for (final p in players) { // Corrected loop variable
      if (p.life <= 0) {
        return players.firstWhere((o) => o.id != p.id).id;
      }
    }
    return null;
  }

  void endGame(String winnerId) {
    isGameEnded = true;
    winningPlayerId = winnerId;
    developer.log('Game ended. Result: ${winnerId == 'draw' ? 'Draw' : 'Winner: $winnerId'}');
  }

  int _max(int a, int b) => a > b ? a : b;
}
