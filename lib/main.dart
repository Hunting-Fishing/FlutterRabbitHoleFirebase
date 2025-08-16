// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:myapp/game_logic/card_game_state_manager.dart';
import 'package:myapp/game_logic/deck_manager.dart';
import 'package:myapp/game_logic/deck_manager.dart'; // Import DeckManager
import 'package:myapp/deck_builder_screen.dart';
import 'package:myapp/simulation_game_screen.dart'; // If you already have this, keep it. If not, use the stub provided below.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // MyApp is already StatelessWidget, which is immutable if all fields are final.
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
            deckManager.addSampleCards(); // Assuming addSampleCards exists and is needed for initial setup
            return deckManager;
          }),
      ],
      child: MaterialApp(
        title: 'Conspiracy Mobile Game',
        theme: ThemeData(
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image (ensure it's listed in pubspec.yaml assets)
          Image.asset(
            'assets/images/Dashboard.png',
            fit: BoxFit.cover,
          ),

          // Foreground content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.psychology, size: 30.0),
                    const SizedBox(width: 8),
                    Text(
                      'Conspiracy Fragments: 0',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // Simulation Game button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SimulationGameScreen(),
                      ),
                    );
                  },
                  child: const Text('Simulation Game'),
                ),

                const SizedBox(height: 24.0),
                Text(
                  'Coming Soon:',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12.0),
                const Text('Game Mode 2'),
                const Text('Game Mode 3'),

                const SizedBox(height: 24.0),

                // Deck Builder Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
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
