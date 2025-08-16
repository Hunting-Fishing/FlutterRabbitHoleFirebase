import 'package:flutter/material.dart';

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campaign Mode"),
      ),
      body: const Center(
        child: Text("Campaign Mode Screen - Skill Tree Placeholder"),
      ),
    );
  }
}