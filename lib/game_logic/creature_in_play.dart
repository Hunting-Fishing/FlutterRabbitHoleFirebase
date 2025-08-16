// lib/game_logic/creature_in_play.dart
import 'package:myapp/game_data/card_definition.dart';

/// A creature instance on the battlefield.
class CreatureInPlay {
  final CardDefinition cardDefinition;
  int currentAttack;
  int currentToughness;
  bool hasSummoningSickness;
  bool isTapped;

  CreatureInPlay({
    required this.cardDefinition,
    bool hasSummoningSickness = true,
    bool isTapped = false,
  })  : hasSummoningSickness = hasSummoningSickness,
        isTapped = isTapped,
        currentAttack = cardDefinition.attack ?? 0,
        currentToughness = cardDefinition.defense ?? 0;
}
