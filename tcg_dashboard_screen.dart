import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:myapp/inventory_screen.dart';
import 'package:myapp/battle_screen.dart';
import 'package:myapp/campaign_screen.dart';

class TcgDashboardScreen extends StatelessWidget {
  const TcgDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TCG Dashboard"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InventoryScreen()),
                );
             },
              child: const Text("Inventory"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (kDebugMode) print("Battle button pressed!");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BattleScreen()),
                );
             },
              child: const Text("Battle"),            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (kDebugMode) {
                  print("Unlock More button pressed!");
                }
              },
              child: const Text("Unlock More"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
 context,
 MaterialPageRoute(builder: (context) => const CampaignScreen()),
 );
              },
              child: const Text("Campaign Mode"),
            ),
          ],
        ),
      ),
    );
  }
}