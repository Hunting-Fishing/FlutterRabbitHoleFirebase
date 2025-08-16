import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/game_logic/card_game_state_manager.dart';
import 'package:myapp/card_widget.dart'; // Import CardWidget

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  @override
  Widget build(BuildContext context) {
    final gameStateManager = Provider.of<CardGameStateManager>(context);

    // Find the opponent player
    final opponentPlayer = gameStateManager.players.firstWhere(
      (player) => player.id != gameStateManager.currentPlayer.id,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Battle'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space out the player areas
        children: [
          // Opponent's Info (usually at the top)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [ // Display opponent's stats
                Text('${opponentPlayer.id}: Life ${opponentPlayer.life}, Resources ${opponentPlayer.resources}'),
                Text('Hand: ${opponentPlayer.hand.length}'),
                Text('Deck: ${opponentPlayer.deck.length}'),
                Text('Grave: ${opponentPlayer.graveyard.length}'),


                Text('${opponentPlayer.id}: Life ${opponentPlayer.life}, Resources ${opponentPlayer.resources}'),
                // TODO: Add opponent's hand size, deck/graveyard size
              ],
            ),
          ),

          // Opponent's Play Area
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: opponentPlayer.playArea.length,
              itemBuilder: (context, index) {
                final creature = opponentPlayer.playArea[index];
                return CardWidget(
                  card: creature.cardDefinition,
                  isOnBattlefield: true,
                  creatureInPlay: creature,
                );
              },
            ),
          ),

          // Current Player's Hand
          SizedBox(
            height: 150, // Adjust height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: gameStateManager.currentPlayer.hand.length,
              itemBuilder: (context, index) {
                final card = gameStateManager.currentPlayer.hand[index];
                return CardWidget(
                  card: card,
                  isOnBattlefield: false, // It's in hand
                );
              },
            ),
          ),

          // Current Player's Play Area
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: gameStateManager.currentPlayer.playArea.length,
              itemBuilder: (context, index) {
                final creature = gameStateManager.currentPlayer.playArea[index];
                return CardWidget(
                  card: creature.cardDefinition,
                  isOnBattlefield: true,
                  creatureInPlay: creature,
                );
              },
            ),
          ),

          // Current Player's Info (usually at the bottom)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('${gameStateManager.currentPlayer.id}: Life ${gameStateManager.currentPlayer.life}, Resources ${gameStateManager.currentPlayer.resources}'),
                 // TODO: Add current player's hand, deck/graveyard size
              ],
            ),
          ),
           // TODO: Add UI for turn phase display and phase transition button
        ],
      ),
    );
  }
}