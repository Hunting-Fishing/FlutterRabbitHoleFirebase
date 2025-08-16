// lib/game_logic/creature_in_play.dart
import 'package:myapp/game_data/card_definition.dart';

/// A creature instance on the battlefield, created from a CardDefinition.
/// Tracks mutable battle stats (attack/toughness), tapping, and summoning sickness.
class CreatureInPlay {
  final CardDefinition cardDefinition;

  /// Mutable in-battle stats (start from base card stats and can change)
  int currentAttack;
  int currentToughness;

  /// State flags
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
