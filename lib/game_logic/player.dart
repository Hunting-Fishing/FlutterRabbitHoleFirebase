// lib/game_logic/player.dart
import 'package:myapp/game_data/card_definition.dart';
import 'package:myapp/game_logic/creature_in_play.dart';

class Player {
  final String id;
  int life = 20;
  int resources = 0;

  List<CardDefinition> deck = [];
  List<CardDefinition> hand = [];
  List<CreatureInPlay> playArea = [];
  List<CardDefinition> graveyard = [];

  Player({required this.id});
}
