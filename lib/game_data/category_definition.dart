class CategoryDefinition {
  final String id;
  final String name;
  final String description;

  
  CategoryDefinition({
    required this.id, 
    required this.name,
    required this.description,
  });
}

final List<CategoryDefinition> sampleCategories = [
  CategoryDefinition(id: 'event', name: 'Event', description: ''),
  CategoryDefinition(id: 'conspiracy', name: 'Conspiracy', description: ''), 
];