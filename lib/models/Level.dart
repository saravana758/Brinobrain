class Level {
  final String id;
  final String name;

  Level({required this.id, required this.name});

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'],
      name: json['name'],
    );
  }
}
