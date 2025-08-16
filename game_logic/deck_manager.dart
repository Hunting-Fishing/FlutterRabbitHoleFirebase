import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

/// Lightweight card model for deckbuilding (renamed to avoid clash with Material `Card`)
class DeckCard {
  final String id;
  final String name;
  final bool isUnique; // true = max 1 copy, false = max 3 copies

  const DeckCard({
    required this.id,
    required this.name,
    this.isUnique = false,
  });
}

/// Manages player inventory and deckbuilding limits.
/// Now extends ChangeNotifier so UI can rebuild on changes.
class DeckManager extends ChangeNotifier {
  /// All cards the player owns (could come from Firestore in the future)
  final List<DeckCard> inventory = <DeckCard>[];

  /// The deck the player is currently editing
  final List<DeckCard> currentDeck = <DeckCard>[];

  /// Constraints
  static const int maxDeckSize = 30;
  static const int maxCopiesNonUnique = 3;
  static const int maxCopiesUnique = 1;

  // ----------------------- Public API -----------------------

  /// Add a card to the deck respecting size and copy limits.
  bool addCardToDeck(DeckCard card) {
    if (currentDeck.length >= maxDeckSize) {
      developer.log('Deck is full ($maxDeckSize).');
      return false;
    }

    final existingCopies =
        currentDeck.where((c) => c.id == card.id).length;

    if (card.isUnique && existingCopies >= maxCopiesUnique) {
      developer.log('Cannot add more than $maxCopiesUnique copy of unique card: ${card.name}');
      return false;
    }

    if (!card.isUnique && existingCopies >= maxCopiesNonUnique) {
      developer.log('Cannot add more than $maxCopiesNonUnique copies of: ${card.name}');
      return false;
    }

    currentDeck.add(card);
    developer.log('Added ${card.name} (now ${existingCopies + 1}) | Deck size: ${currentDeck.length}');
    notifyListeners();
    return true;
  }

  /// Remove a single copy of the card from the deck (if present).
  bool removeOneCopyFromDeck(DeckCard card) {
    final idx = currentDeck.indexWhere((c) => c.id == card.id);
    if (idx == -1) return false;
    final removed = currentDeck.removeAt(idx);
    developer.log('Removed one copy of ${removed.name} | Deck size: ${currentDeck.length}');
    notifyListeners();
    return true;
  }

  /// Remove ALL copies of a card from the deck.
  int removeAllCopiesFromDeck(DeckCard card) {
    final before = currentDeck.length;
    currentDeck.removeWhere((c) => c.id == card.id);
    final removedCount = before - currentDeck.length;
    if (removedCount > 0) {
      developer.log('Removed $removedCount copies of ${card.name} | Deck size: ${currentDeck.length}');
      notifyListeners();
    }
    return removedCount;
  }

  /// Clears the deck completely.
  void clearDeck() {
    currentDeck.clear();
    developer.log('Cleared deck.');
    notifyListeners();
  }

  /// Simple sample inventory for testing the deck builder.
  void addSampleCards() {
    inventory
      ..clear()
      ..addAll(const [
        DeckCard(id: 'gov-001', name: 'MK-Ultra Operative', isUnique: false),
        DeckCard(id: 'gov-002', name: 'Operation Mockingbird', isUnique: true),
        DeckCard(id: 'cult-001', name: 'Cult Recruiter', isUnique: false),
        DeckCard(id: 'mega-001', name: 'Black Budget', isUnique: false),
        DeckCard(id: 'und-001', name: 'Shadow Cloak', isUnique: true),
      ]);
    developer.log('Sample inventory added: ${inventory.length} cards.');
    notifyListeners();
  }
}
