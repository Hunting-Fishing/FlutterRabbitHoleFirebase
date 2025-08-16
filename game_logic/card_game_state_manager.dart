// lib/game_logic/card_game_state_manager.dart
import 'dart:math';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:myapp/game_data/card_definition.dart';
import 'package:myapp/game_data/game_data_manager.dart';
import 'package:myapp/game_logic/creature_in_play.dart';
import 'package:myapp/game_logic/player.dart';

enum TurnPhase { start, main1, combat, main2, end }

class GameRules {
  static const int startingLife = 20;
  static const int startingResources = 0;
  static const int startingHandSize = 5;
  static const int handLimit = 7;
  static const bool tapAttackersOnDeclare = true;
  static const int resourceGainPerTurnStart = 1;
  static const bool summoningSicknessAffectsAttack = true;
}

class CardGameStateManager extends ChangeNotifier {
  bool isGameEnded = false;
  String? winningPlayerId;

  final List<CardDefinition> discardPile = [];

  List<Player> players = [];
  int currentPlayerIndex = 0;
  TurnPhase currentPhase = TurnPhase.start;

  final List<CreatureInPlay> _declaredAttackers = [];

  CardGameStateManager() {
    startGame();
  }

  Player get currentPlayer => players[currentPlayerIndex];
  Player get opponent => players[(currentPlayerIndex + 1) % players.length];

  void startGame() {
    _initializeGame(GameDataManager.cards);
    notifyListeners();
  }

  void _initializeGame(List<CardDefinition> allCards) {
    players = [Player(id: 'player1'), Player(id: 'player2')];

    for (final p in players) {
      p.deck = List<CardDefinition>.from(allCards)..shuffle(Random());
      p.life = GameRules.startingLife;
      p.resources = GameRules.startingResources;
      p.hand.clear();
      p.playArea.clear();
      p.graveyard.clear();
    }

    for (final p in players) {
      for (var i = 0; i < GameRules.startingHandSize; i++) {
        if (p.deck.isEmpty) break;
        p.hand.add(p.deck.removeAt(0));
      }
    }

    currentPlayerIndex = 0;
    currentPhase = TurnPhase.start;
    _startOfPhase();
  }

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
        for (final c in currentPlayer.playArea) {
          c.isTapped = false;
          c.hasSummoningSickness = false;
        }
        drawCard(currentPlayer);
        currentPlayer.resources += GameRules.resourceGainPerTurnStart;
        developer.log('${currentPlayer.id} +${GameRules.resourceGainPerTurnStart} resource => ${currentPlayer.resources}');
        break;
      case TurnPhase.main1:
      case TurnPhase.combat:
      case TurnPhase.main2:
      case TurnPhase.end:
        break;
    }
  }

  void _endTurnAndPass() {
    _declaredAttackers.clear();
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
  }

  void drawCard(Player player) {
    if (player.deck.isEmpty) {
      if (player.graveyard.isNotEmpty) {
        player.deck = List<CardDefinition>.from(player.graveyard)..shuffle(Random());
        player.graveyard.clear();
        developer.log("Shuffled ${player.id}'s graveyard into deck.");
      } else {
        developer.log('No cards left to draw for ${player.id}.');
        return;
      }
    }
    if (player.hand.length >= GameRules.handLimit) {
      developer.log('${player.id} hand full.');
      return;
    }
    player.hand.add(player.deck.removeAt(0));
    notifyListeners();
  }

  void playCard(Player player, CardDefinition card) {
    if (!player.hand.contains(card)) return;
    if (player.resources < card.cost) {
      developer.log('Not enough resources for ${card.name}.');
      return;
    }

    player.hand.remove(card);
    player.resources -= card.cost;

    if (card.isCreature) {
      player.playArea.add(
        CreatureInPlay(cardDefinition: card, hasSummoningSickness: true, isTapped: false),
      );
    } else {
      _resolveCardAbilities(player, card);
      player.graveyard.add(card);
    }
    notifyListeners();
  }

  void declareAllAttackers() {
    _declaredAttackers
      ..clear()
      ..addAll(currentPlayer.playArea.where((c) =>
          !c.hasSummoningSickness && (!GameRules.tapAttackersOnDeclare || !c.isTapped)));
    if (GameRules.tapAttackersOnDeclare) {
      for (final a in _declaredAttackers) {
        a.isTapped = true;
      }
    }
    notifyListeners();
  }

  void resolveCombat() {
    if (_declaredAttackers.isEmpty) {
      developer.log('No attackers declared.');
      return;
    }
    final attacker = currentPlayer;
    final defender = opponent;

    final defeatedAtk = <CreatureInPlay>[];
    final defeatedDef = <CreatureInPlay>[];

    final laneCount = max(attacker.playArea.length, defender.playArea.length);
    for (var i = 0; i < laneCount; i++) {
      final atk = i < attacker.playArea.length ? attacker.playArea[i] : null;
      final blk = i < defender.playArea.length ? defender.playArea[i] : null;

      if (atk == null || !_declaredAttackers.contains(atk) || atk.hasSummoningSickness) continue;

      if (blk == null) {
        defender.life -= atk.currentAttack;
        continue;
      }

      final atkPower = atk.cardDefinition.attack ?? 0;
      final blkPower = blk.cardDefinition.attack ?? 0;

      blk.currentToughness -= atkPower;
      atk.currentToughness -= blkPower;

      if (blk.currentToughness <= 0) defeatedDef.add(blk);
      if (atk.currentToughness <= 0) defeatedAtk.add(atk);
    }

    attacker.playArea.removeWhere((c) => defeatedAtk.contains(c));
    defender.playArea.removeWhere((c) => defeatedDef.contains(c));
    discardPile.addAll(defeatedAtk.map((c) => c.cardDefinition));
    discardPile.addAll(defeatedDef.map((c) => c.cardDefinition));
    _declaredAttackers.clear();

    final win = _checkWin();
    if (win != null) endGame(win);

    notifyListeners();
  }

  void _resolveCardAbilities(Player player, CardDefinition card) {
    for (final ability in card.abilities) {
      switch (ability) {
        case CardAbilityType.attackBoost:
          _buffFirstFriendly(player, attackDelta: 1);
          break;
        case CardAbilityType.defenseBoost:
          _buffFirstFriendly(player, defenseDelta: 1);
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
          opponentOf(player).life -= 3; // placeholder X=3
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
    if (losers.length > 1) return 'draw';
    if (losers.length == 1) {
      final losingId = losers.first.id;
      return players.firstWhere((p) => p.id != losingId).id;
    }
    return null;
  }

  void endGame(String winnerId) {
    isGameEnded = true;
    winningPlayerId = winnerId;
    developer.log('Game ended: ${winnerId == 'draw' ? 'Draw' : 'Winner: $winnerId'}');
  }
}
