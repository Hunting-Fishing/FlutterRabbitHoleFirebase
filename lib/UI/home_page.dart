game_home_screen// lib/ui/screens/game_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/game_data/card_definition.dart';
import 'package:myapp/game_logic/creature_in_play.dart';
import 'package:myapp/game_logic/card_game_state_manager.dart';

class GameHomeScreen extends StatelessWidget {
  const GameHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gm = context.watch<CardGameStateManager>();
    final cp = gm.currentPlayer;
    final op = gm.opponent;

    return Scaffold(
      appBar: AppBar(
        title: Text('Phase: ${gm.currentPhase.name.toUpperCase()}  |  Turn: ${gm.currentPlayerIndex + 1}'),
        actions: [
          TextButton(
            onPressed: () => gm.nextPhase(),
            child: const Text('Next Phase', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          _playerBar('Opponent', op.life, op.resources, isOpponent: true),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _sectionTitle('Opponent Board'),
                _boardRow(op.playArea),

                const SizedBox(height: 12),
                _sectionTitle('Your Board'),
                _boardRow(cp.playArea),

                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => gm.drawCard(cp),
                      icon: const Icon(Icons.download),
                      label: const Text('Draw'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        final idx = cp.hand.indexWhere((c) => c.isCreature);
                        if (idx != -1) gm.playCard(cp, cp.hand[idx]);
                      },
                      icon: const Icon(Icons.pets),
                      label: const Text('Play Creature'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        final idx = cp.hand.indexWhere((c) => !c.isCreature);
                        if (idx != -1) gm.playCard(cp, cp.hand[idx]);
                      },
                      icon: const Icon(Icons.auto_fix_high),
                      label: const Text('Cast Spell'),
                    ),
                    ElevatedButton.icon(
                      onPressed: gm.declareAllAttackers,
                      icon: const Icon(Icons.sports_martial_arts),
                      label: const Text('Declare Attackers'),
                    ),
                    ElevatedButton.icon(
                      onPressed: gm.resolveCombat,
                      icon: const Icon(Icons.flash_on),
                      label: const Text('Resolve Combat'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                _sectionTitle('Your Hand'),
                _handGrid(cp.hand, onTap: (card) => gm.playCard(cp, card)),
              ],
            ),
          ),
          const Divider(height: 1),
          _playerBar('You', cp.life, cp.resources),
        ],
      ),
    );
  }

  Widget _playerBar(String name, int life, int resources, {bool isOpponent = false}) {
    return Container(
      color: isOpponent ? Colors.black12 : Colors.deepPurple.withOpacity(0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          const Icon(Icons.favorite, size: 18),
          const SizedBox(width: 4),
          Text('$life'),
          const SizedBox(width: 16),
          const Icon(Icons.diamond, size: 18),
          const SizedBox(width: 4),
          Text('$resources'),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _boardRow(List<CreatureInPlay> creatures) {
    if (creatures.isEmpty) {
      return const Text('— empty —', style: TextStyle(color: Colors.black54));
    }
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: creatures.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = creatures[i];
          return _creatureCard(c);
        },
      ),
    );
  }

  Widget _creatureCard(CreatureInPlay c) {
    return SizedBox(
      width: 100,
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            Expanded(child: _artwork(c.cardDefinition)),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                '${c.cardDefinition.name}\n${c.currentAttack}/${c.currentToughness}${c.hasSummoningSickness ? ' (SS)' : ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _handGrid(List<CardDefinition> hand, {required void Function(CardDefinition) onTap}) {
    if (hand.isEmpty) return const Text('— empty —', style: TextStyle(color: Colors.black54));
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: hand.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, childAspectRatio: 0.7, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemBuilder: (context, index) {
        final card = hand[index];
        return InkWell(
          onTap: () => onTap(card),
          child: Card(
            elevation: 2,
            child: Column(
              children: [
                Expanded(child: _artwork(card)),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(card.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('${card.typeId} • Cost ${card.cost}', style: const TextStyle(fontSize: 10)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _artwork(CardDefinition card) {
    final path = card.imagePath;
    if (path.isEmpty) return _artworkPlaceholder(card);
    final isUrl = path.startsWith('http://') || path.startsWith('https://');
    return isUrl
        ? Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _artworkPlaceholder(card))
        : Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _artworkPlaceholder(card));
  }

  Widget _artworkPlaceholder(CardDefinition card) {
    return Container(
      color: Colors.black12,
      child: Center(
        child: Text(
          card.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ),
    );
  }
}
