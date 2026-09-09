class Activity {
  final String id;
  final String userId;
  final String name;
  final String color;
  final int position;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Activity({
    required this.id,
    required this.userId,
    required this.name,
    required this.color,
    required this.position,
    required this.archived,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      position: json['position'] as int,
      archived: json['archived'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'color': color,
      'position': position,
      'archived': archived,
    };
  }

  Activity copyWith({
    String? name,
    String? color,
    int? position,
    bool? archived,
  }) {
    return Activity(
      id: id,
      userId: userId,
      name: name ?? this.name,
      color: color ?? this.color,
      position: position ?? this.position,
      archived: archived ?? this.archived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
