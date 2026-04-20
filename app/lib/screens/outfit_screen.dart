import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/outfit_provider.dart';
import '../widgets/outfit_card.dart';

class OutfitScreen extends ConsumerStatefulWidget {
  const OutfitScreen({super.key});

  @override
  ConsumerState<OutfitScreen> createState() => _OutfitScreenState();
}

class _OutfitScreenState extends ConsumerState<OutfitScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedOccasion;
  bool _useWeather = false;
  bool _useAI = true;
  final _promptController = TextEditingController();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _generate() {
    ref.read(outfitProvider.notifier).generateOutfits(
          occasion: _selectedOccasion,
          useWeather: _useWeather,
          useAI: _useAI,
          lat: 28.6139,
          lng: 77.2090,
          userPrompt:
              _promptController.text.trim().isEmpty ? null : _promptController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final outfitState = ref.watch(outfitProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── App Bar ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        _useAI ? '🤖 AI Outfit Generator' : 'Outfit Generator',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FadeTransition(
                    opacity: _animController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // ── AI Mode Toggle ──
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceMid.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _useAI = false),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      gradient: !_useAI ? AppTheme.cardGradient : null,
                                      borderRadius: BorderRadius.circular(12),
                                      border: !_useAI
                                          ? Border.all(color: Colors.white12)
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.tune_rounded,
                                          size: 18,
                                          color: !_useAI
                                              ? Colors.white
                                              : Colors.white38,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Rule-Based',
                                          style: TextStyle(
                                            color: !_useAI
                                                ? Colors.white
                                                : Colors.white38,
                                            fontWeight: !_useAI
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _useAI = true),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      gradient: _useAI
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFF6C63FF),
                                                Color(0xFFFF6584)
                                              ],
                                            )
                                          : null,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: _useAI
                                          ? [
                                              BoxShadow(
                                                color: AppTheme.primaryColor
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.auto_awesome_rounded,
                                          size: 18,
                                          color: _useAI
                                              ? Colors.white
                                              : Colors.white38,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'AI Powered',
                                          style: TextStyle(
                                            color: _useAI
                                                ? Colors.white
                                                : Colors.white38,
                                            fontWeight: _useAI
                                                ? FontWeight.w700
                                                : FontWeight.normal,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── AI Prompt Input (only in AI mode) ──
                        if (_useAI) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor.withValues(alpha: 0.08),
                                  AppTheme.secondaryColor.withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.accentGradient,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.chat_rounded,
                                          color: Colors.white, size: 16),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Tell the AI what you need',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _promptController,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    hintText:
                                        'e.g. "Something cool for a first date" or "Professional look for an interview"',
                                    hintStyle: TextStyle(
                                        color: Colors.white24, fontSize: 13),
                                    filled: true,
                                    fillColor:
                                        AppTheme.surfaceDark.withValues(alpha: 0.5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.all(14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ── Filters Card ──
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppTheme.cardGradient,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.tune_rounded,
                                      color: AppTheme.primaryColor),
                                  const SizedBox(width: 10),
                                  Text('Filters',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Occasion filter
                              Text('Occasion',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildOccasionChip('All', null),
                                  ...AppConstants.occasions.map((occ) =>
                                      _buildOccasionChip(
                                          occ[0].toUpperCase() +
                                              occ.substring(1),
                                          occ)),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Weather toggle
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _useWeather
                                      ? AppTheme.accentColor
                                          .withValues(alpha: 0.1)
                                      : Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _useWeather
                                        ? AppTheme.accentColor
                                            .withValues(alpha: 0.3)
                                        : Colors.white12,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.wb_sunny_rounded,
                                      color: _useWeather
                                          ? AppTheme.accentColor
                                          : Colors.white38,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Weather-based',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'Filter by current weather',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: _useWeather,
                                      onChanged: (v) =>
                                          setState(() => _useWeather = v),
                                      activeTrackColor: AppTheme.accentColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Generate Button ──
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: _useAI
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF6C63FF),
                                        Color(0xFFFF6584),
                                        Color(0xFFFF8A65),
                                      ],
                                    )
                                  : AppTheme.accentGradient,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed:
                                  outfitState.isGenerating ? null : _generate,
                              icon: outfitState.isGenerating
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      _useAI
                                          ? Icons.auto_awesome_rounded
                                          : Icons.shuffle_rounded,
                                      size: 24),
                              label: Text(
                                outfitState.isGenerating
                                    ? (_useAI
                                        ? '🤖 AI is thinking...'
                                        : 'Generating...')
                                    : (_useAI
                                        ? '🤖 Generate with AI'
                                        : '✨ Generate Outfits'),
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── AI Tips Card ──
                        if (outfitState.aiTips != null &&
                            outfitState.aiTips!.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor.withValues(alpha: 0.12),
                                  AppTheme.secondaryColor.withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.primaryColor.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.accentGradient,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.lightbulb_rounded,
                                          color: Colors.white, size: 18),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'AI Styling Tips',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  outfitState.aiTips!,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                                if (outfitState.missingPieces != null &&
                                    outfitState.missingPieces!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.warning.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.warning.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.shopping_bag_rounded,
                                            color: AppTheme.warning, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            outfitState.missingPieces!,
                                            style: TextStyle(
                                              color: AppTheme.warning,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // ── Results ──
                        if (outfitState.generatedOutfits.isNotEmpty) ...[
                          Row(
                            children: [
                              Text(
                                outfitState.generationMode == 'ai'
                                    ? '🤖 AI Outfits'
                                    : 'Generated Outfits',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: outfitState.generationMode == 'ai'
                                      ? AppTheme.secondaryColor
                                      : AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${outfitState.generatedOutfits.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...outfitState.generatedOutfits.map(
                            (outfit) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: OutfitCard(
                                outfit: outfit,
                                showAIInsights: outfitState.generationMode == 'ai',
                                onSave: () {
                                  ref
                                      .read(outfitProvider.notifier)
                                      .saveOutfit(outfit);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('💾 Outfit saved!')),
                                  );
                                },
                              ),
                            ),
                          ),
                        ] else if (!outfitState.isGenerating) ...[
                          const SizedBox(height: 40),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  _useAI
                                      ? Icons.psychology_rounded
                                      : Icons.auto_awesome_outlined,
                                  size: 72,
                                  color: Colors.white.withValues(alpha: 0.16),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _useAI
                                      ? 'AI Ready to Style You'
                                      : 'Ready to style?',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(color: Colors.white30),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _useAI
                                      ? 'Gemini AI will analyze your wardrobe images'
                                      : 'Set your filters and tap Generate',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.20)),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (outfitState.error != null)
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppTheme.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.error_outline,
                                    color: AppTheme.error),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Text(outfitState.error!,
                                        style: TextStyle(
                                            color: AppTheme.error))),
                              ],
                            ),
                          ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOccasionChip(String label, String? value) {
    final isSelected = _selectedOccasion == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedOccasion = value),
      selectedColor: AppTheme.primaryColor,
      backgroundColor: AppTheme.surfaceMid,
      checkmarkColor: Colors.white,
    );
  }
}
