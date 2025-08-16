// lib/game_data/card_definition.dart

/// Abilities your cards can have.
/// Make sure every ability used in the manager exists here.
enum CardAbilityType {
  attackBoost,
  defenseBoost,
  drawCard,
  discardOpponentCard,
  removeTargetCreatureFromPlay,
  gainResources,
  heal,
  dealDamageX,
}

/// Core, immutable definition of a card.
/// Use this for hand/deck/graveyard data (not for creatures in play).
class CardDefinition {
  final String id;          // unique-ish identifier
  final String name;        // display name
  final String typeId;      // e.g. 'creature', 'spell'
  final int cost;           // resource cost to play

  /// For creatures only (null for non-creature card types)
  final int? attack;
  final int? defense;

  /// Keyword/active abilities this card provides when cast/played
  final List<CardAbilityType> abilities;

  const CardDefinition({
    required this.id,
    required this.name,
    required this.typeId,
    required this.cost,
    this.attack,
    this.defense,
    this.abilities = const [],
  });

  bool get isCreature => typeId.toLowerCase() == 'creature';
}
