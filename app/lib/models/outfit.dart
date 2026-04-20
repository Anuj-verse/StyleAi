import 'clothing.dart';

class Outfit {
  final String id;
  final List<Clothing> items;
  final String? occasion;
  final String? weather;
  final bool isFavorite;
  final double score;
  final String? reasoning;
  final String? stylingTip;
  final DateTime createdAt;

  Outfit({
    required this.id,
    required this.items,
    this.occasion,
    this.weather,
    this.isFavorite = false,
    this.score = 0.0,
    this.reasoning,
    this.stylingTip,
    required this.createdAt,
  });

  Clothing? get top => items.where((i) => i.category == 'top').firstOrNull;
  Clothing? get bottom => items.where((i) => i.category == 'bottom').firstOrNull;
  Clothing? get shoes => items.where((i) => i.category == 'shoes').firstOrNull;
  Clothing? get accessory =>
      items.where((i) => i.category == 'accessories').firstOrNull;

  factory Outfit.fromJson(Map<String, dynamic> json) {
    return Outfit(
      id: json['_id'] ?? json['id'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => i is Map<String, dynamic>
                  ? Clothing.fromJson(i)
                  : Clothing(
                      id: i.toString(),
                      imageUrl: '',
                      category: '',
                      color: '',
                      occasions: [],
                      seasons: [],
                      createdAt: DateTime.now()))
              .toList() ??
          [],
      occasion: json['occasion'],
      weather: json['weather'],
      isFavorite: json['isFavorite'] ?? false,
      score: (json['score'] ?? 0).toDouble(),
      reasoning: json['reasoning'],
      stylingTip: json['stylingTip'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((i) => i.id).toList(),
      'occasion': occasion,
      'weather': weather,
      'isFavorite': isFavorite,
    };
  }
}
