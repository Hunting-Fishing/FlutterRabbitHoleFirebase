import 'package:flutter/material.dart';
import 'package:myapp/game_data/card_definition.dart';
import 'package:myapp/game_logic/creature_in_play.dart';
import 'package:myapp/widgets/discard_pile_widget.dart';
import 'package:myapp/widgets/game_board_widget.dart';
import 'package:myapp/widgets/player_hand_widget.dart';
import 'package:myapp/card_widget.dart';

class Player {
  final String id;

  int life = 20;
  int score = 20; // if other code still reads score as hp
  int resources = 0;

  final List<CardDefinition> hand = [];
  final List<CreatureInPlay> playArea = [];
  final List<CardDefinition> graveyard = [];
  final List<CardDefinition> deck = [];
  final List<CardDefinition> equippedItems = [];

  Player({required this.id});
}

class CardGameScreen extends StatelessWidget {
  const CardGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder data for demonstration
    final List<CardDefinition> playerHand = List.generate(
      5,
      (index) => CardDefinition(
        id: 'card_$index',
        name: 'Placeholder Card $index',
        description: 'This is a placeholder card.',
        // TODO: Replace with actual values based on your game data
        typeId: index % 2 == 0 ? 'creature' : 'spell',
        categoryId: 'conspiracy', // Using a single category for placeholders
        classId: index % 3 == 0 ? 'illuminati' : index % 3 == 1 ? 'shadow' : 'neutral', // Varied classes
        attack: index % 2 == 0 ? index + 1 : null, // Attack only for creatures
        defense: index % 2 == 0 ? index + 2 : null, // Defense only for creatures
        cost: index + 1, // Varied costs
        abilities: [], // Placeholder
        rarity: index % 4 == 0 ? CardRarity.legendary : index % 3 == 0 ? CardRarity.epic : index % 2 == 0 ? CardRarity.rare : CardRarity.common, // Varied rarities
        faction: index % 5 == 0 ? CardFaction.gov : index % 5 == 1 ? CardFaction.media : index % 5 == 2 ? CardFaction.megacorp : index % 5 == 3 ? CardFaction.cult : CardFaction.underground, // Varied factions
        tags: ['placeholder'], // Placeholder tags

      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conspiracy Card Game'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GameBoardWidget(),
 ),
            child: GameBoardWidget(),
          ),
          PlayerHandWidget(
            cards: playerHand.map((cardDef) => CardWidget(
 card: cardDef, // Use onTapCard instead of onTap
 onTapCard: (tappedObject) {
                // TODO: Implement card tap logic
               },)).toList()),
          DiscardPileWidget(cardCount: 10),
        ],
      ),
    );
  }
}
