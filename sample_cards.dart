import 'card_definition.dart';

final List<CardDefinition> sampleCards = [
  // Card 1: Basic Henchman (Creature)
  CardDefinition(
    id: 'card_001',
    name: 'Basic Henchman',
    description: 'A loyal, if not very bright, minion.',
    attack: 5,
    defense: 3,
    cost: 1,
    abilities: [],
    categoryId: 'event', // Using sample category ID
    classId: 'illuminati', // Using sample class ID
    typeId: 'creature', // Using sample type ID
    rarity: CardRarity.common, // Placeholder rarity
    faction: CardFaction.underground, // Placeholder faction
    tags: ['henchman', 'basic'], // Placeholder tags
  ),

  // Card 2: Whispers in the Dark (Spell)
  CardDefinition(
    id: 'card_002',
    name: 'Whispers in the Dark',
    description: 'Spread misinformation and sow discord.',
    attack: 0,
    defense: 0,
    cost: 2,
    abilities: [CardAbilityType.drawCard, CardAbilityType.discardOpponentCard],
    categoryId: 'conspiracy', // Using sample category ID
    classId: 'grey_aliens', // Using sample class ID
    typeId: 'scheme', // Using sample type ID
    rarity: CardRarity.rare, // Placeholder rarity
    faction: CardFaction.media, // Placeholder faction
    tags: ['misinformation', 'debuff'], // Placeholder tags
  ),


  // Card 3: Alien Abduction (Spell)
  CardDefinition(
    id: 'card_003',
    name: 'Alien Abduction',
    description: 'Remove a creature from the field.',
    attack: 0,
    defense: 0,
    cost: 3,
    abilities: [CardAbilityType.removeTargetCreatureFromPlay],
    categoryId: 'event', // Using sample category ID
    classId: 'grey_aliens', // Using sample class ID
    typeId: 'scheme', // Using sample type ID
    rarity: CardRarity.epic, // Placeholder rarity
    faction: CardFaction.gov, // Placeholder faction
    tags: ['removal', 'control'], // Placeholder tags
  ), // Removed the extra comma here

];