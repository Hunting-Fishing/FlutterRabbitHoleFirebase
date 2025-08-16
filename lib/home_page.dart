import 'package:flutter/material.dart';

import 'package:myapp/card_game_screen.dart'; // Assuming CardGameScreen is for the TCG
import 'package:myapp/simulation_game_screen.dart'; // Assuming Simulation Game Screen is for the Simulation Game

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/conspiracy_background.png',
            fit: BoxFit.cover,
          ),
          Positioned.fill( // Use Positioned.fill to center the Column vertically and horizontally
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center the column content vertically
                crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons horizontally
                children: [
                  Text(
                    'Conspiracy Game Home',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 40), // Spacing between title and buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0), // Add horizontal padding to buttons
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CardGameScreen()), // Navigate to TCG screen
                        );
                      },
                      child: const Text('Trading Card Game'),
                    ),
                  ),
                  SizedBox(height: 20), // Spacing between buttons
                  Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SimulationGameScreen()), // Navigate to Simulation Game screen
                        );
                      },
                      child: const Text('Simulation Game'),
                    ),
                  ),
                  SizedBox(height: 40), // Spacing before Coming Soon section
                  Text(
                    'Coming Soon:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10), // Spacing for Coming Soon items
                  Text(
                    'Campaign Mode',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                   Text(
                    'Multiplayer',
                    textAlign: TextAlign.center,
                     style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  // Add more Text widgets for other planned modes as needed
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}