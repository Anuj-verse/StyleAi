import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/clothing.dart';
import '../services/api_service.dart';

class WardrobeState {
  final List<Clothing> items;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;

  WardrobeState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
  });

  WardrobeState copyWith({
    List<Clothing>? items,
    bool? isLoading,
    String? error,
    String? selectedCategory,
  }) {
    return WardrobeState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  List<Clothing> get filteredItems {
    if (selectedCategory == null || selectedCategory == 'all') return items;
    return items.where((i) => i.category == selectedCategory).toList();
  }

  int get topCount => items.where((i) => i.category == 'top').length;
  int get bottomCount => items.where((i) => i.category == 'bottom').length;
  int get shoesCount => items.where((i) => i.category == 'shoes').length;
  int get accessoryCount =>
      items.where((i) => i.category == 'accessories').length;
}

class WardrobeNotifier extends StateNotifier<WardrobeState> {
  final ApiService _api = ApiService();

  WardrobeNotifier() : super(WardrobeState());

  Future<void> loadClothes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.getClothes();
      final List<dynamic> data = response.data['clothes'] ?? [];
      final items = data.map((j) => Clothing.fromJson(j)).toList();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load wardrobe',
      );
    }
  }

  Future<bool> uploadClothing(
    String filePath,
    String category,
    String color,
    List<String> occasions,
    List<String> seasons,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _api.uploadClothing(filePath, category, color, occasions, seasons);
      await loadClothes(); // Refresh list
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to upload',
      );
      return false;
    }
  }

  Future<void> deleteClothing(String id) async {
    try {
      await _api.deleteClothing(id);
      state = state.copyWith(
        items: state.items.where((i) => i.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete');
    }
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category ?? 'all');
  }
}

final wardrobeProvider =
    StateNotifierProvider<WardrobeNotifier, WardrobeState>((ref) {
  return WardrobeNotifier();
});
