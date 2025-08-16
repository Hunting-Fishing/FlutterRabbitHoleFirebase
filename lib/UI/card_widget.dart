import 'package:flutter/material.dart';
import 'package:myapp/game_data/card_definition.dart';
import 'package:myapp/game_logic/creature_in_play.dart'; // Import CreatureInPlay

// card_widget.dart
class CardWidget extends StatelessWidget {
  final CardDefinition card;
  final bool isOnBattlefield;
  final ValueChanged<dynamic>? onTapCard;
  final bool isSelectedForAttack;
  final bool isTapped;
  final CreatureInPlay? creatureInPlay;

  const CardWidget({
    super.key,
    required this.card,
    this.isOnBattlefield = false,
    this.onTapCard,
    this.isSelectedForAttack = false,
    this.isTapped = false,
    this.creatureInPlay,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the object to use for onTap
    final tapObject = isOnBattlefield ? creatureInPlay : card;

    return Container(
      width: 100, // Placeholder width
      height: 160, // Increased height for better text display
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelectedForAttack ? Colors.greenAccent : Colors.black,
          width: isSelectedForAttack ? 2.0 : 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white, // Placeholder card background
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1.0,
            blurRadius: 3.0,
            offset: Offset(2, 2), // changes position of shadow
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTapCard != null ? () => onTapCard!(tapObject) : null,
        child: Transform.rotate(
          angle: isTapped ? 1.5708 : 0, // Rotate 90 degrees (pi/2 radians) based on isTapped
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card Name and Cost
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Card Name
                    Expanded(
                      child: Text(
                        card.name,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Card Cost
                    Text(
                      card.cost.toString(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
              ),
              // Artwork Area
              Expanded(
                child: Container( // Added a container to give the image a constrained space
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  clipBehavior: Clip.antiAlias, // Clip the image to the rounded corners
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0), // Slightly rounded corners for artwork area
                  ),                  child: card.artworkUrl != null
                      ? Image.asset(
                          card.artworkUrl!,
                          fit: BoxFit.cover,
                          // loadingBuilder is not a parameter for Image.asset.
                          // If using network images, this would be appropriate.
                          /*loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.progress,
                              ),
                            );
                          },
                          */
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, color: Colors.red, size: 50);
                          },
                        )
                      : Center( // Placeholder if artworkUrl is null
                          child: Text(
                            'No Artwork',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                          ),
                        ),
                ),
              ),

              // Text Box (Rules/Abilities/Description)
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Container(
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Center(
                    child: Text(
                      card.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ),
              // Power/Toughness
              if (card.typeId == 'creature')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                  child: Text(
                    isOnBattlefield && creatureInPlay != null
                        ? '${creatureInPlay!.currentAttack}/${creatureInPlay!.currentToughness}'
                        : '${card.attack}/${card.defense}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
