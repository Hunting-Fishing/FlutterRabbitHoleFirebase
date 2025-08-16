// lib/game_logic/player.dart
import 'package:myapp/game_data/card_definition.dart';
import 'package:myapp/game_logic/creature_in_play.dart';

/// Minimal player state used by the game manager.
class Player {
  final String id;

  int life = 20;
  int resources = 0;

  /// Zones
  List<CardDefinition> deck = [];
  List<CardDefinition> hand = [];
  List<CreatureInPlay> playArea = [];     // battlefield creatures
  List<CardDefinition> graveyard = [];    // spent spells + dead creature cardbacks

  Player({required this.id});
}
