class AppConstants {
  // ── API Configuration ──
  // Change this to your backend URL
  // For Linux Desktop/Web use: localhost or 127.0.0.1
  // For Android emulator use: 10.0.2.2
  static const String baseUrl = 'http://127.0.0.1:3000/api';

  // ── Storage Keys ──
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // ── Categories ──
  static const List<String> categories = [
    'top',
    'bottom',
    'shoes',
    'accessories',
  ];

  static const List<String> occasions = [
    'casual',
    'formal',
    'party',
    'gym',
  ];

  static const List<String> seasons = [
    'summer',
    'winter',
    'rainy',
    'all',
  ];

  // ── Category Icons ──
  static const Map<String, int> categoryIcons = {
    'top': 0xf06b7,       // Icons.checkroom
    'bottom': 0xf0612,    // roughly maps to clothing
    'shoes': 0xf06bc,     // Icons.ice_skating (shoe-like)
    'accessories': 0xe6c4, // Icons.watch
  };

  // ── Colors for categories ──
  static const Map<String, int> categoryColors = {
    'top': 0xFF6C63FF,
    'bottom': 0xFFFF6584,
    'shoes': 0xFF00D9FF,
    'accessories': 0xFFFFAB40,
  };

  // ── Weather ──
  static const String weatherApiKey = 'YOUR_API_KEY'; // Replace with real key
  static const String weatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';
}
