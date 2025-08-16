import 'package:myapp/game_data/card_definition.dart';
import 'package:myapp/game_logic/creature_in_play.dart';

/// Represents a player in the card game.
class Player {
  final String id;
  List<CardDefinition> deck; // Added deck
  List<CardDefinition> hand;
  List<CreatureInPlay> playArea; // Changed type to List<CreatureInPlay>
  List<CreatureInPlay> graveyard; // Added graveyard
  int resources;
  int life;


  Player({
    required this.id,
    List<CardDefinition>? hand,
    List<CreatureInPlay>? playArea, // Changed type to List<CreatureInPlay>
    this.resources = 0,
    this.life = 20, // Initialized life to 20
    List<CardDefinition>? deck, // Added deck to constructor
    List<CreatureInPlay>? graveyard, // Added graveyard to constructor
  })  : hand = hand ?? [], // Initialized hand
        playArea = playArea ?? [], // Initialized playArea
        deck = deck ?? [], // Initialized deck
        graveyard = graveyard ?? []; // Initialized graveyard
}