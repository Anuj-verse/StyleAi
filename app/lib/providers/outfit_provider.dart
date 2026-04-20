import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/outfit.dart';
import '../services/api_service.dart';

class OutfitState {
  final List<Outfit> generatedOutfits;
  final List<Outfit> savedOutfits;
  final bool isLoading;
  final bool isGenerating;
  final String? error;
  final String? selectedOccasion;
  final bool useWeather;
  final bool useAI;
  final String? aiTips;
  final String? missingPieces;
  final String? generationMode; // 'rule-based' or 'ai'

  OutfitState({
    this.generatedOutfits = const [],
    this.savedOutfits = const [],
    this.isLoading = false,
    this.isGenerating = false,
    this.error,
    this.selectedOccasion,
    this.useWeather = false,
    this.useAI = true,
    this.aiTips,
    this.missingPieces,
    this.generationMode,
  });

  OutfitState copyWith({
    List<Outfit>? generatedOutfits,
    List<Outfit>? savedOutfits,
    bool? isLoading,
    bool? isGenerating,
    String? error,
    String? selectedOccasion,
    bool? useWeather,
    bool? useAI,
    String? aiTips,
    String? missingPieces,
    String? generationMode,
  }) {
    return OutfitState(
      generatedOutfits: generatedOutfits ?? this.generatedOutfits,
      savedOutfits: savedOutfits ?? this.savedOutfits,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error,
      selectedOccasion: selectedOccasion ?? this.selectedOccasion,
      useWeather: useWeather ?? this.useWeather,
      useAI: useAI ?? this.useAI,
      aiTips: aiTips ?? this.aiTips,
      missingPieces: missingPieces ?? this.missingPieces,
      generationMode: generationMode ?? this.generationMode,
    );
  }
}

class OutfitNotifier extends StateNotifier<OutfitState> {
  final ApiService _api = ApiService();

  OutfitNotifier() : super(OutfitState());

  Future<void> generateOutfits({
    String? occasion,
    bool useWeather = false,
    bool useAI = false,
    double? lat,
    double? lng,
    String? userPrompt,
  }) async {
    state = state.copyWith(
      isGenerating: true,
      error: null,
      aiTips: null,
      missingPieces: null,
    );

    try {
      if (useAI) {
        // 🤖 AI-powered generation
        final response = await _api.aiGenerateOutfit(
          occasion: occasion,
          useWeather: useWeather,
          lat: lat,
          lng: lng,
          userPrompt: userPrompt,
        );
        final List<dynamic> data = response.data['outfits'] ?? [];
        final outfits = data.map((j) => Outfit.fromJson(j)).toList();
        state = state.copyWith(
          generatedOutfits: outfits,
          isGenerating: false,
          aiTips: response.data['aiTips'],
          missingPieces: response.data['missingPieces'],
          generationMode: 'ai',
        );
      } else {
        // 📐 Rule-based generation
        final response = await _api.generateOutfit(
          occasion: occasion,
          useWeather: useWeather,
          lat: lat,
          lng: lng,
        );
        final List<dynamic> data = response.data['outfits'] ?? [];
        final outfits = data.map((j) => Outfit.fromJson(j)).toList();
        state = state.copyWith(
          generatedOutfits: outfits,
          isGenerating: false,
          generationMode: 'rule-based',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: 'Failed to generate outfits: ${e.toString().contains('Gemini') ? e.toString() : 'Try again'}',
      );
    }
  }

  Future<void> loadSavedOutfits() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.getOutfits();
      final List<dynamic> data = response.data['outfits'] ?? [];
      final outfits = data.map((j) => Outfit.fromJson(j)).toList();
      state = state.copyWith(savedOutfits: outfits, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load outfits',
      );
    }
  }

  Future<void> saveOutfit(Outfit outfit) async {
    try {
      await _api.saveOutfit(outfit.toJson());
      await loadSavedOutfits();
    } catch (e) {
      state = state.copyWith(error: 'Failed to save outfit');
    }
  }

  Future<void> deleteOutfit(String id) async {
    try {
      await _api.deleteOutfit(id);
      state = state.copyWith(
        savedOutfits: state.savedOutfits.where((o) => o.id != id).toList(),
      );
    } catch (_) {}
  }

  void setOccasion(String? occasion) {
    state = state.copyWith(selectedOccasion: occasion);
  }

  void toggleWeather(bool value) {
    state = state.copyWith(useWeather: value);
  }

  void toggleAI(bool value) {
    state = state.copyWith(useAI: value);
  }
}

final outfitProvider =
    StateNotifierProvider<OutfitNotifier, OutfitState>((ref) {
  return OutfitNotifier();
});
