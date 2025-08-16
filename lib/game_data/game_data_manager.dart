import 'package:myapp/game_data/category_definition.dart';
import 'package:myapp/game_data/class_definition.dart';
import 'package:myapp/game_data/type_definition.dart';
import 'package:myapp/game_data/card_definition.dart';
import 'package:myapp/game_data/sample_cards.dart';

// Assuming sampleCategories, sampleClasses, sampleTypes, and sampleCards
// are defined in their respective files and are accessible.

class GameDataManager {
  static final List<CategoryDefinition> categories = sampleCategories;
  static final List<ClassDefinition> classes = sampleClasses;
  static final List<TypeDefinition> types = sampleTypes;
  // You would add sample cards here once defined
  static final List<CardDefinition> cards = sampleCards;

  // Private constructor to prevent instantiation
  GameDataManager._privateConstructor();
}