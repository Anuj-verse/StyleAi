import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/wardrobe_provider.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen>
    with SingleTickerProviderStateMixin {
  File? _image;
  String _selectedCategory = 'top';
  String _selectedColor = '#6C63FF';
  final List<String> _selectedOccasions = ['casual'];
  final List<String> _selectedSeasons = ['all'];
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animController;

  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Purple', 'hex': '#6C63FF', 'color': const Color(0xFF6C63FF)},
    {'name': 'Red', 'hex': '#FF5252', 'color': const Color(0xFFFF5252)},
    {'name': 'Blue', 'hex': '#4A90D9', 'color': const Color(0xFF4A90D9)},
    {'name': 'Green', 'hex': '#00E676', 'color': const Color(0xFF00E676)},
    {'name': 'Black', 'hex': '#333333', 'color': const Color(0xFF333333)},
    {'name': 'White', 'hex': '#F5F5F5', 'color': const Color(0xFFF5F5F5)},
    {'name': 'Pink', 'hex': '#FF6584', 'color': const Color(0xFFFF6584)},
    {'name': 'Orange', 'hex': '#FFAB40', 'color': const Color(0xFFFFAB40)},
    {'name': 'Navy', 'hex': '#1A1A3E', 'color': const Color(0xFF1A1A3E)},
    {'name': 'Brown', 'hex': '#8D6E63', 'color': const Color(0xFF8D6E63)},
    {'name': 'Yellow', 'hex': '#FFEB3B', 'color': const Color(0xFFFFEB3B)},
    {'name': 'Grey', 'hex': '#9E9E9E', 'color': const Color(0xFF9E9E9E)},
  ];

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
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _upload() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    final success = await ref.read(wardrobeProvider.notifier).uploadClothing(
          _image!.path,
          _selectedCategory,
          _selectedColor,
          _selectedOccasions,
          _selectedSeasons,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Clothing uploaded successfully!'),
            backgroundColor: AppTheme.success.withValues(alpha: 0.9),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Upload failed. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wardrobe = ref.watch(wardrobeProvider);

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
                        'Add to Wardrobe',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // ── Content ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FadeTransition(
                    opacity: _animController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // ── Image Picker ──
                        GestureDetector(
                          onTap: () => _showImageSourceDialog(),
                          child: Container(
                            width: double.infinity,
                            height: 240,
                            decoration: BoxDecoration(
                              color: AppTheme.cardDark,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: _image != null
                                    ? AppTheme.primaryColor.withValues(alpha: 0.5)
                                    : Colors.white12,
                                width: 2,
                              ),
                              image: _image != null
                                  ? DecorationImage(
                                      image: FileImage(_image!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _image == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Icon(
                                          Icons.add_a_photo_rounded,
                                          size: 32,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Tap to add photo',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Camera or Gallery',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Category ──
                        Text('Category',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          children: AppConstants.categories.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return ChoiceChip(
                              label: Text(
                                cat[0].toUpperCase() + cat.substring(1),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) =>
                                  setState(() => _selectedCategory = cat),
                              selectedColor: AppTheme.primaryColor,
                              backgroundColor: AppTheme.surfaceMid,
                              checkmarkColor: Colors.white,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // ── Color ──
                        Text('Color',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _colorOptions.map((opt) {
                            final isSelected = _selectedColor == opt['hex'];
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedColor = opt['hex']),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: opt['color'] as Color,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: (opt['color'] as Color)
                                                .withValues(alpha: 0.5),
                                            blurRadius: 10,
                                          )
                                        ]
                                      : null,
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check_rounded,
                                        color: Colors.white, size: 20)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // ── Occasion ──
                        Text('Occasion',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          children: AppConstants.occasions.map((occ) {
                            final isSelected =
                                _selectedOccasions.contains(occ);
                            return FilterChip(
                              label: Text(
                                occ[0].toUpperCase() + occ.substring(1),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (val) {
                                setState(() {
                                  if (val) {
                                    _selectedOccasions.add(occ);
                                  } else {
                                    _selectedOccasions.remove(occ);
                                  }
                                });
                              },
                              selectedColor: AppTheme.secondaryColor,
                              backgroundColor: AppTheme.surfaceMid,
                              checkmarkColor: Colors.white,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // ── Season ──
                        Text('Season',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          children: AppConstants.seasons.map((s) {
                            final isSelected = _selectedSeasons.contains(s);
                            return FilterChip(
                              label: Text(
                                s[0].toUpperCase() + s.substring(1),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (val) {
                                setState(() {
                                  if (val) {
                                    _selectedSeasons.add(s);
                                  } else {
                                    _selectedSeasons.remove(s);
                                  }
                                });
                              },
                              selectedColor: AppTheme.accentColor,
                              backgroundColor: AppTheme.surfaceMid,
                              checkmarkColor: Colors.white,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 36),

                        // ── Upload Button ──
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: wardrobe.isLoading ? null : _upload,
                              icon: wardrobe.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.cloud_upload_rounded),
                              label: Text(
                                wardrobe.isLoading
                                    ? 'Uploading...'
                                    : 'Upload to Wardrobe',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
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

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text('Choose Image Source',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildImageSourceOption(
                      Icons.camera_alt_rounded,
                      'Camera',
                      AppTheme.primaryColor,
                      () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildImageSourceOption(
                      Icons.photo_library_rounded,
                      'Gallery',
                      AppTheme.secondaryColor,
                      () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
