// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:myapp/game_logic/card_game_state_manager.dart';
import 'package:myapp/game_logic/deck_manager.dart';

// Keep your existing screens if you navigate to them from the home screen.
// (Not used directly here, but fine to keep in your project.)
import 'package:myapp/deck_builder_screen.dart';
import 'package:myapp/simulation_game_screen.dart';

// IMPORTANT: your home file still lives at lib/home_page.dart,
// but it now defines GameHomeScreen. So we import it:
import 'package:myapp/home_page.dart'; // contains GameHomeScreen

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
            // Only call this if it's safe to run multiple times
            deckManager.addSampleCards();
            return deckManager;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Conspiracy Mobile Game',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
        // Use the upgraded screen that you pasted into home_page.dart
        home: const GameHomeScreen(),
        debugShowCheckedModeBanner: false,

        // Optional: named routes if you want to navigate with Navigator.pushNamed
        routes: {
          '/deck-builder': (_) => const DeckBuilderScreen(),
          '/simulation': (_) => const SimulationGameScreen(),
        },
      ),
    );
  }
}
