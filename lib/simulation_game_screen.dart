import 'package:flutter/material.dart';

class SimulationGameScreen extends StatelessWidget {
  const SimulationGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulation Game'),
      ),
      body: Row(
        children: [
          // Simulation Display Area (e.g., Map)
          Expanded(
 child: Container(
 color: Colors.blueGrey[200], // Placeholder for the map/simulation visual
              padding: const EdgeInsets.all(8.0),
 child: const Column(
 mainAxisAlignment: MainAxisAlignment.start,
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [
 Text(
                  'Simulation Display Area (Map)',
 style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
 ),
 // Add more widgets here for the simulation map/visual
 ],
              ),
            ),
          ),
          // Statistics and Controls Area
          Container(
            width: screenWidth * 0.3, // 30% of screen width for stats/controls
 color: Colors.orange[200], // Placeholder for stats or controls
            padding: const EdgeInsets.all(8.0),
 child: const Column( // Corrected syntax here
 crossAxisAlignment: CrossAxisAlignment.start,
 children: <Widget>[
 Text('Stats and Controls', style: TextStyle(fontSize: 16.0)),
 ],
 ),
 ), // This parenthesis closes the second Container
          Container(
            height: screenHeight * 0.25, // 25% of screen height
            color: Colors.orange[200], // Placeholder for stats or controls
          ),
        ],
      ),
    );
  }
}