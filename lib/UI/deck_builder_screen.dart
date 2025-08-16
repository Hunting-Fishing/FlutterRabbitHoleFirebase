// lib/deck_builder_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/game_logic/deck_manager.dart';

class DeckBuilderScreen extends StatefulWidget {
  const DeckBuilderScreen({super.key});

  @override
  State<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final mgr = context.watch<DeckManager>();

    final issues = _validateDeck(mgr);
    final isValid = issues.isEmpty;

    final deckSize = mgr.currentDeck.length;
    const maxSize = DeckManager.maxDeckSize;

    return Scaffold(
      appBar: AppBar(
        title: Text('Deck Builder  •  $deckSize / $maxSize'),
        actions: [
          IconButton(
            tooltip: 'Clear Deck',
            onPressed: mgr.currentDeck.isEmpty
                ? null
                : () => _confirmClear(context, mgr),
            icon: const Icon(Icons.delete_sweep),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth >= 800;
          final content = [
            _InventoryPane(
              query: _query,
              onQuery: (q) => setState(() => _query = q),
            ),
            const VerticalDivider(width: 1),
            _DeckPane(),
          ];

          return Column(
            children: [
              if (!isValid)
                _ValidationBanner(issues: issues)
              else
                const _ValidationBanner(issues: []),
              Expanded(
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: content.map((w) => Expanded(child: w)).toList(),
                      )
                    : Column(
                        children: [
                          Expanded(child: content[0]),
                          const Divider(height: 1),
                          Expanded(child: content[2]),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _BottomBar(isValid: isValid),
    );
  }

  List<String> _validateDeck(DeckManager mgr) {
    final issues = <String>[];

    if (mgr.currentDeck.length != DeckManager.maxDeckSize) {
      issues.add(
          'Deck must have exactly ${DeckManager.maxDeckSize} cards (current: ${mgr.currentDeck.length}).');
    }

    // Copy limit checks
    final counts = <String, int>{};
    for (final c in mgr.currentDeck) {
      counts.update(c.id, (v) => v + 1, ifAbsent: () => 1);
    }
    for (final entry in counts.entries) {
      final card =
          mgr.currentDeck.firstWhere((e) => e.id == entry.key, orElse: () => mgr.inventory.firstWhere((e) => e.id == entry.key));
      final limit = card.isUnique
          ? DeckManager.maxCopiesUnique
          : DeckManager.maxCopiesNonUnique;
      if (entry.value > limit) {
        issues.add(
            'Too many copies of ${card.name} (have ${entry.value}, max $limit).');
      }
    }

    return issues;
    // Add faction rules / color identity later here if needed.
  }

  Future<void> _confirmClear(BuildContext context, DeckManager mgr) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Clear Deck?'),
            content:
                const Text('This will remove all cards from your current deck.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Clear'),
              ),
            ],
          ),
        ) ??
        false;
    if (ok) mgr.clearDeck();
  }
}

class _InventoryPane extends StatelessWidget {
  const _InventoryPane({required this.query, required this.onQuery});
  final String query;
  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context) {
    final mgr = context.watch<DeckManager>();

    final filtered = mgr.inventory
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PaneHeader(
          title: 'Inventory (${mgr.inventory.length})',
          trailing: Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: onQuery,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No cards match your search.'))
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final card = filtered[i];
                    final inDeck =
                        mgr.currentDeck.where((c) => c.id == card.id).length;

                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        child: Text(
                          card.isUnique ? 'U' : 'N',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      title: Text(card.name),
                      subtitle: Text(
                          card.isUnique ? 'Unique • in deck: $inDeck' : 'Copies: $inDeck'),
                      trailing: FilledButton.icon(
                        onPressed: () => mgr.addCardToDeck(card),
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _DeckPane extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mgr = context.watch<DeckManager>();

    // Group deck by card id
    final grouped = <String, _DeckEntry>{};
    for (final c in mgr.currentDeck) {
      grouped.putIfAbsent(c.id, () => _DeckEntry(card: c, count: 0));
      grouped[c.id] = grouped[c.id]!.copyWith(count: grouped[c.id]!.count + 1);
    }
    final entries = grouped.values.toList()
      ..sort((a, b) => a.card.name.compareTo(b.card.name));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PaneHeader(
          title: 'Current Deck (${mgr.currentDeck.length})',
          trailing: TextButton.icon(
            onPressed: mgr.currentDeck.isEmpty ? null : mgr.clearDeck,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear'),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: entries.isEmpty
              ? const Center(child: Text('No cards in deck yet.'))
              : ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final e = entries[i];
                    final limit = e.card.isUnique
                        ? DeckManager.maxCopiesUnique
                        : DeckManager.maxCopiesNonUnique;
                    final over = e.count > limit;

                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor:
                            over ? Colors.red.shade100 : Colors.blue.shade100,
                        child: Text('${e.count}'),
                      ),
                      title: Text(e.card.name),
                      subtitle: Text(
                        e.card.isUnique
                            ? 'Unique (max $limit)'
                            : 'Max copies: $limit',
                        style: TextStyle(
                          color: over ? Colors.red : null,
                        ),
                      ),
                      trailing: Wrap(
                        spacing: 6,
                        children: [
                          IconButton(
                            tooltip: 'Remove one',
                            onPressed: () => mgr.removeOneCopyFromDeck(e.card),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          IconButton(
                            tooltip: 'Remove all copies',
                            onPressed: () => mgr.removeAllCopiesFromDeck(e.card),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PaneHeader extends StatelessWidget {
  const _PaneHeader({required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.isValid});
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    final mgr = context.watch<DeckManager>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {
                // Add more demo cards on demand (useful during early development)
                mgr.addSampleCards();
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Add Samples'),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: isValid
                  ? () {
                      // TODO: Save to Firestore or local storage.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Deck saved!')),
                      );
                      Navigator.pop(context);
                    }
                  : null,
              icon: const Icon(Icons.save),
              label: const Text('Save Deck'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValidationBanner extends StatelessWidget {
  const _ValidationBanner({required this.issues});
  final List<String> issues;

  @override
  Widget build(BuildContext context) {
    if (issues.isEmpty) {
      return Container(
        width: double.infinity,
        color: Colors.green.shade50,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Deck is valid.'),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: Colors.red.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Deck Issues'),
            ],
          ),
          const SizedBox(height: 6),
          ...issues.map(
            (e) => Padding(
              padding: const EdgeInsets.only(left: 28, bottom: 2),
              child: Text('• $e'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeckEntry {
  final DeckCard card;
  final int count;
  _DeckEntry({required this.card, required this.count});
  _DeckEntry copyWith({DeckCard? card, int? count}) =>
      _DeckEntry(card: card ?? this.card, count: count ?? this.count);
}
