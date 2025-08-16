import 'package:flutter/material.dart';

class UnlockScreen extends StatelessWidget {
  const UnlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unlock More'),
      ),
      body: const Center(
        child: Text('Unlock More Screen'),
      ),
    );
  }
}