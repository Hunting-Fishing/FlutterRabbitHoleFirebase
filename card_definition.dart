// lib/game_data/card_definition.dart

/// Abilities cards can have.
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

enum CardRarity { common, rare, epic, legendary }
enum CardFaction { underground, media, gov }

/// Immutable definition of a card (for deck/hand/graveyard).
class CardDefinition {
  // Identity
  final String id;
  final String name;

  // Gameplay
  final String typeId; // 'creature' or 'spell'
  final int cost;
  final int? attack;   // creatures only
  final int? defense;  // creatures only
  final List<CardAbilityType> abilities;

  // Metadata
  final String description;
  final String categoryId;
  final String classId;
  final CardRarity rarity;
  final CardFaction faction;
  final List<String> tags;

  // Artwork (asset path or URL)
  final String imagePath;

  const CardDefinition({
    required this.id,
    required this.name,
    required this.typeId,
    required this.cost,
    this.attack,
    this.defense,
    this.abilities = const [],
    this.description = '',
    this.categoryId = '',
    this.classId = '',
    this.rarity = CardRarity.common,
    this.faction = CardFaction.gov,
    this.tags = const [],
    this.imagePath = '',
  });

  bool get isCreature => typeId.toLowerCase() == 'creature';

  /// Back-compat for any old UI that used `artworkUrl`.
  String get artworkUrl => imagePath;

  bool get hasImage => imagePath.isNotEmpty;
}
