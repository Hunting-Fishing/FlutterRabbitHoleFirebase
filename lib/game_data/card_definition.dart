enum CardAbilityType {
  attackBoost,
  defenseBoost, // Kept the more complete definition
  dealDamageX,
  heal,
  drawCard,
  discardOpponentCard,
  removeTargetCreatureFromPlay,
  gainResources,
}

enum CardRarity { common, rare, epic, legendary }

enum CardFaction { gov, media, megacorp, cult, underground }

class CardDefinition {
  final String id;
  final String name; // e.g., "Goblin Grunt"
  final String description;
  final int? attack; // e.g., 2 (for creatures) - Made nullable
  final int? defense; // e.g., 3 (for creatures) - Made nullable, renamed from toughness
  final int cost;
  final List<CardAbilityType> abilities;
  final CardRarity rarity; // Added rarity field
  final CardFaction? faction; // Added faction field, made nullable
  final List<String> tags; // Added tags field
  final String classId; // Reference to ClassDefinition
  final String typeId; // Reference to TypeDefinition
  final String categoryId; // Reference to CategoryDefinition
  final String? artworkUrl; // Optional for card art
  bool isTapped; // Tapped state for permanents

  CardDefinition({
    required this.id,
    required this.name,
    required this.description,
    this.attack, // Made nullable
    this.defense, // Made nullable, renamed from toughness
    required this.cost,
    required this.abilities,
    required this.categoryId,
    required this.classId,
    required this.typeId,
    this.artworkUrl,
    this.isTapped = false, // Default to not tapped
    required this.rarity, // Made required
    this.faction, // Made nullable
    this.tags = const [], // Added with default empty list
  });
}