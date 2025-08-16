// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:myapp/game_logic/card_game_state_manager.dart';
import 'package:myapp/game_logic/deck_manager.dart';
import 'package:myapp/deck_builder_screen.dart';
import 'package:myapp/simulation_game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CardGameStateManager>(
          create: (_) => CardGameStateManager(),
        ),
        ChangeNotifierProvider<DeckManager>(
          create: (_) {
            final deckManager = DeckManager();
            // Only call this if it exists and is idempotent
            deckManager.addSampleCards();
            return deckManager;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Conspiracy Mobile Game',
        theme: ThemeData(useMaterial3: true),
        home: const MyHomePage(title: 'Rabbit Hole'),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image. Ensure the file exists.
          Image.asset('assets/images/Dashboard.png', fit: BoxFit.cover),

          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.psychology, size: 30),
                    const SizedBox(width: 8),
                    Text(
                      'Conspiracy Fragments: 0',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SimulationGameScreen()),
                    );
                  },
                  child: const Text('Simulation Game'),
                ),

                const SizedBox(height: 24),
                Text('Coming Soon:', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                const Text('Game Mode 2'),
                const Text('Game Mode 3'),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DeckBuilderScreen()),
                    );
                  },
                  child: const Text('Deck Builder'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
