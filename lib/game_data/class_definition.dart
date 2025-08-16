class ClassDefinition {
  final String id;
  final String name;
  final String description;
  final String? iconPath;

  ClassDefinition({
    required this.id,
    required this.name,
    required this.description,
    this.iconPath,
  });
}

final List<ClassDefinition> sampleClasses = [];