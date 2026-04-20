class Clothing {
  final String id;
  final String imageUrl;
  final String category; // top, bottom, shoes, accessories
  final String color;
  final List<String> occasions; // casual, formal, party, gym
  final List<String> seasons; // summer, winter, rainy, all
  final DateTime createdAt;

  Clothing({
    required this.id,
    required this.imageUrl,
    required this.category,
    required this.color,
    required this.occasions,
    required this.seasons,
    required this.createdAt,
  });

  factory Clothing.fromJson(Map<String, dynamic> json) {
    return Clothing(
      id: json['_id'] ?? json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'top',
      color: json['color'] ?? '#FFFFFF',
      occasions: List<String>.from(json['occasions'] ?? ['casual']),
      seasons: List<String>.from(json['seasons'] ?? ['all']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'color': color,
      'occasions': occasions,
      'seasons': seasons,
    };
  }
}
