import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: AppConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  // ── Auth ──
  Future<Response> register(String name, String email, String password) async {
    return _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<Response> login(String email, String password) async {
    return _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> getMe() async {
    return _dio.get('/auth/me');
  }

  // ── Wardrobe ──
  Future<Response> uploadClothing(
    String filePath,
    String category,
    String color,
    List<String> occasions,
    List<String> seasons,
  ) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath, filename: 'clothing.jpg'),
      'category': category,
      'color': color,
      'occasions': occasions.join(','),
      'seasons': seasons.join(','),
    });
    return _dio.post('/clothes', data: formData);
  }

  Future<Response> getClothes({String? category}) async {
    final params = <String, dynamic>{};
    if (category != null) params['category'] = category;
    return _dio.get('/clothes', queryParameters: params);
  }

  Future<Response> deleteClothing(String id) async {
    return _dio.delete('/clothes/$id');
  }

  // ── Outfits ──
  Future<Response> generateOutfit({
    String? occasion,
    bool useWeather = false,
    double? lat,
    double? lng,
  }) async {
    return _dio.post('/outfits/generate', data: {
      'occasion': occasion,
      'useWeather': useWeather,
      'lat': lat,
      'lng': lng,
    });
  }

  Future<Response> aiGenerateOutfit({
    String? occasion,
    bool useWeather = false,
    double? lat,
    double? lng,
    String? userPrompt,
  }) async {
    // AI generation can take longer
    return _dio.post(
      '/outfits/ai-generate',
      data: {
        'occasion': occasion,
        'useWeather': useWeather,
        'lat': lat,
        'lng': lng,
        'userPrompt': userPrompt,
      },
      options: Options(
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
  }

  Future<Response> getOutfits() async {
    return _dio.get('/outfits');
  }

  Future<Response> saveOutfit(Map<String, dynamic> outfitData) async {
    return _dio.post('/outfits/save', data: outfitData);
  }

  Future<Response> deleteOutfit(String id) async {
    return _dio.delete('/outfits/$id');
  }

  // ── Weather ──
  Future<Response> getWeather(double lat, double lng) async {
    return _dio.get('/weather', queryParameters: {
      'lat': lat,
      'lng': lng,
    });
  }

  // ── Token management ──
  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: AppConstants.tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }
}
