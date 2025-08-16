import '../game_data/card_definition.dart';

class CreatureInPlay {
  final CardDefinition cardDefinition;
  int currentToughness;
  int currentAttack; // Added currentAttack property
  int damageTaken = 0;
  bool isTapped;
  bool hasSummoningSickness; // Added hasSummoningSickness property

  CreatureInPlay({
    required this.cardDefinition,
    this.isTapped = false, // Creatures typically enter the battlefield untapped
    this.hasSummoningSickness = true,
  }) : currentToughness = cardDefinition.defense ?? 0,
       currentAttack = cardDefinition.attack ?? 0;

  // Helper to get the effective toughness considering damage taken
  int get effectiveToughness => (cardDefinition.defense ?? 0) - damageTaken;
}