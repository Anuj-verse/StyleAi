import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class WeatherData {
  final double temp;
  final String description;
  final String icon;
  final String main; // Clear, Rain, Snow, Clouds, etc.
  final double feelsLike;
  final int humidity;

  WeatherData({
    required this.temp,
    required this.description,
    required this.icon,
    required this.main,
    required this.feelsLike,
    required this.humidity,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weather = json['weather']?[0] ?? {};
    final main = json['main'] ?? {};
    return WeatherData(
      temp: (main['temp'] ?? 0).toDouble(),
      description: weather['description'] ?? '',
      icon: weather['icon'] ?? '01d',
      main: weather['main'] ?? 'Clear',
      feelsLike: (main['feels_like'] ?? 0).toDouble(),
      humidity: main['humidity'] ?? 0,
    );
  }

  String get suggestion {
    if (temp > 30) return 'Light & breathable clothes recommended';
    if (temp > 20) return 'Comfortable weather — anything works!';
    if (temp > 10) return 'Layer up with a light jacket';
    return 'Bundle up! It\'s cold outside';
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
}

class WeatherState {
  final WeatherData? weather;
  final bool isLoading;
  final String? error;

  WeatherState({this.weather, this.isLoading = false, this.error});

  WeatherState copyWith({
    WeatherData? weather,
    bool? isLoading,
    String? error,
  }) {
    return WeatherState(
      weather: weather ?? this.weather,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WeatherNotifier extends StateNotifier<WeatherState> {
  final ApiService _api = ApiService();

  WeatherNotifier() : super(WeatherState());

  Future<void> loadWeather(double lat, double lng) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.getWeather(lat, lng);
      final weather = WeatherData.fromJson(response.data);
      state = state.copyWith(weather: weather, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not fetch weather',
      );
    }
  }
}

final weatherProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier();
});
