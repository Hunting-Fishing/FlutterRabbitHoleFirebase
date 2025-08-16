import 'dart:math';

// Basic outline for Simulation Game Logic

// Represents the overall state of the simulation
enum EventType {
  increaseSpread,
  decreaseSpread,
  // Add other event types as needed
}

// Represents a player action in the simulation
class PlayerAction {
  String type;
  PlayerAction({required this.type});
}

// Represents the overall state of the simulation
class SimulationState {
  // Properties for simulation state
  List<String> areas = []; // Represents the simulation map/area
  Map<String, double> conspiracySpread = {}; // Conspiracy spread data (area to spread level)
  Map<String, dynamic> statistics = {}; // Simulation statistics (stat name to value)
  List<Event> upcomingEvents = []; // List of upcoming events
  List<PlayerAction> possiblePlayerActions = []; // List of possible player actions

  // Method to initialize the simulation
  void initializeSimulation() {
    // Set up initial simulation state, starting point for conspiracy
    areas = ['Area A', 'Area B', 'Area C', 'Area D'];

    // Initialize conspiracy spread to 0 in all areas
    for (var area in areas) {
      conspiracySpread[area] = 0.0;
    }
    conspiracySpread['Area A'] = 0.1; // Set a starting point for the conspiracy
  }

  // Method to handle spreading the conspiracy
  // Method to handle spreading the conspiracy
  void spreadConspiracy() {
    final random = Random();
    final Map<String, double> nextConspiracySpread = Map.from(conspiracySpread);
    const spreadThreshold = 0.3;
    const spreadFactor = 0.1;
    const randomFactor = 0.05;

    // Simple adjacency: Assuming areas are connected in a linear fashion for now
    // Area A <-> Area B <-> Area C <-> Area D
    final adjacency = {
      'Area A': ['Area B'],
      'Area B': ['Area A', 'Area C'],
      'Area C': ['Area B', 'Area D'],
      'Area D': ['Area C'],
    };

    for (var area in areas) {
      if (conspiracySpread[area]! > spreadThreshold) {
        for (var neighbor in adjacency[area]!) {
          nextConspiracySpread[neighbor] = (nextConspiracySpread[neighbor]! + spreadFactor + (random.nextDouble() * randomFactor)).clamp(0.0, 1.0);
        }
      }
    }
    conspiracySpread = nextConspiracySpread;
  }

  // Method to handle game events
  void handleEvent(Event event) {
    switch (event.type) {
 case EventType.increaseSpread:
 if (event.targetArea == null) {
          // Increase spread in all areas
 for (var area in areas) {
 conspiracySpread[area] = (conspiracySpread[area]! + event.effectValue).clamp(0.0, 1.0);
 }
        } else if (conspiracySpread.containsKey(event.targetArea)) {
          // Increase spread in a specific area
 conspiracySpread[event.targetArea!] = (conspiracySpread[event.targetArea!]! + event.effectValue).clamp(0.0, 1.0);
        }
      case EventType.decreaseSpread:
 if (conspiracySpread.containsKey(event.targetArea)) {
 conspiracySpread[event.targetArea!] = (conspiracySpread[event.targetArea!]! - event.effectValue).clamp(0.0, 1.0);
 }
    }
  }

  // Method to check for win/loss conditions
  bool checkWinLoss() {
    // Calculate average conspiracy spread
    double totalSpread = conspiracySpread.values.fold(0.0, (sum, spread) => sum + spread);
    double averageSpread = totalSpread / areas.length;

    // Win condition: average spread drops below a threshold
    if (averageSpread < 0.05) {
      return true; // Player wins
    }

    // Loss condition: average spread exceeds a threshold
    if (averageSpread > 0.8) {
      return true; // Player loses
    }

    return false; // Game continues
  }

  // Method to handle player actions (e.g., investing in research, deploying agents)
  void handlePlayerAction(SimulationPlayer player, PlayerAction action) {
    switch (action.type) {
      case 'invest':
        if (player.resources >= 10) {
          player.resources -= 10;
          player.researchProgress += 0.1;
        }
        break;
    }
  }
}

// Represents the player's status and resources in the simulation
class SimulationPlayer {
  // TODO: Add properties for resources, research progress, etc.
  int resources = 0;
  double researchProgress = 0.0;
  int agentsDeployed = 0;
}

// Represents a single event that can occur in the simulation
class Event {
  EventType type;
  String description;
  String? targetArea; // Null if the event affects all areas
  double effectValue;

  Event({required this.type, required this.description, this.targetArea, required this.effectValue});
}