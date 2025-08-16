// lib/game_data/game_data_manager.dart
import 'package:myapp/game_data/card_definition.dart';

/// Simple in-memory card list for testing.
/// Swap this for your real data loader later.
class GameDataManager {
  static final List<CardDefinition> cards = [
    // --- Creatures ---
    CardDefinition(
      id: 'c-watcher-001',
      name: 'Watcher of the Vault',
      typeId: 'creature',
      cost: 2,
      attack: 2,
      defense: 2,
      abilities: const [],
    ),
    CardDefinition(
      id: 'c-mindspy-002',
      name: 'Mindspy Operative',
      typeId: 'creature',
      cost: 3,
      attack: 3,
      defense: 2,
      abilities: const [],
    ),
    CardDefinition(
      id: 'c-sentinel-003',
      name: 'Silent Sentinel',
      typeId: 'creature',
      cost: 4,
      attack: 4,
      defense: 4,
      abilities: const [],
    ),

    // --- Spells ---
    CardDefinition(
      id: 's-boost-101',
      name: 'Whispered Tactics',
      typeId: 'spell',
      cost: 1,
      abilities: const [CardAbilityType.attackBoost],
    ),
    CardDefinition(
      id: 's-shield-102',
      name: 'Hidden Shield',
      typeId: 'spell',
      cost: 1,
      abilities: const [CardAbilityType.defenseBoost],
    ),
    CardDefinition(
      id: 's-draw-103',
      name: 'Redacted Files',
      typeId: 'spell',
      cost: 1,
      abilities: const [CardAbilityType.drawCard],
    ),
    CardDefinition(
      id: 's-discard-104',
      name: 'Intercept Transmission',
      typeId: 'spell',
      cost: 2,
      abilities: const [CardAbilityType.discardOpponentCard],
    ),
    CardDefinition(
      id: 's-remove-105',
      name: 'Vanishing Act',
      typeId: 'spell',
      cost: 3,
      abilities: const [CardAbilityType.removeTargetCreatureFromPlay],
    ),
    CardDefinition(
      id: 's-eco-106',
      name: 'Resource Cache',
      typeId: 'spell',
      cost: 2,
      abilities: const [CardAbilityType.gainResources],
    ),
    CardDefinition(
      id: 's-heal-107',
      name: 'Field Medic',
      typeId: 'spell',
      cost: 2,
      abilities: const [CardAbilityType.heal],
    ),
    CardDefinition(
      id: 's-bolt-108',
      name: 'Blackout Pulse',
      typeId: 'spell',
      cost: 2,
      abilities: const [CardAbilityType.dealDamageX],
    ),
  ];
}
