import 'package:flutter/material.dart';
import 'package:myapp/UI/card_widget.dart';

class PlayerHandWidget extends StatelessWidget {
  final List<CardWidget> cards;

  const PlayerHandWidget({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150, // Adjust height as needed
      color: Colors.blueGrey[800], // Placeholder background color
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: cards[index],
          );
        },
      ),
    );
  }
}