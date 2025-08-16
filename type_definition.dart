class TypeDefinition {
  final String id;
  final String name;
  final String description;

  TypeDefinition({
    required this.id,
    required this.name,
 required this.description,
  });

  
}

final List<TypeDefinition> sampleTypes = [
  TypeDefinition(id: 'creature', name: 'Creature', description: ''),
  TypeDefinition(id: 'scheme', name: 'Scheme', description: ''),
];