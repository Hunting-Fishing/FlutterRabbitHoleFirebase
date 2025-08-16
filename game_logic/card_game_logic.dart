import 'package:myapp/game_data/card_definition.dart';
import 'package:myapp/game_logic/player.dart'; // Assuming Player class is in this file

/// Represents the overall state of a card game.
class GameState {
  List<Player> players;
  int currentPlayerIndex;
  List<CardDefinition> deck; // Represents the shared deck (if applicable)
  // Add other game state properties as needed, e.g., stack, graveyard, etc.

  GameState({
    required this.players,
    required this.currentPlayerIndex,
    required this.deck,
  });

  Player get currentPlayer => players[currentPlayerIndex];
  Player get opponentPlayer => players[(currentPlayerIndex + 1) % players.length];

  // Method to advance to the next player's turn
  void nextTurn() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    // Add logic for start of turn, drawing cards, untapping creatures, etc.
  }

  // Method to draw a card
  void drawCard(Player player) {
    if (deck.isNotEmpty) {
      CardDefinition drawnCard = deck.removeAt(0); // Assuming deck is a list
      player.hand.add(drawnCard);
    } else {
      // Handle deck depletion (e.g., player loses)
    }
  }

  // Method to play a card from hand
  void playCard(Player player, CardDefinition card) {
    if (player.hand.contains(card)) {
      player.hand.remove(card);
      // Add logic for different card types (creature, spell, etc.)
    }
  }
}
/// Represents a creature card currently in a player's play area.
class CreatureInPlay {
  final CardDefinition card;
  int currentAttack;
  int currentDefense;
  bool hasSummoningSickness;

  CreatureInPlay({required this.card, required this.currentAttack, required this.currentDefense, this.hasSummoningSickness = true});
}