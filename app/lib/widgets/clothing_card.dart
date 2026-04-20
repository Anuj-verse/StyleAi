import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/clothing.dart';

class ClothingCard extends StatelessWidget {
  final Clothing clothing;
  final VoidCallback onDelete;
  final bool compact;

  const ClothingCard({
    super.key,
    required this.clothing,
    required this.onDelete,
    this.compact = false,
  });

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(clothing.color);
    final categoryIcons = {
      'top': Icons.checkroom_rounded,
      'bottom': Icons.straighten_rounded,
      'shoes': Icons.ice_skating_rounded,
      'accessories': Icons.watch_rounded,
    };

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  clothing.imageUrl.isNotEmpty
                      ? Image.network(
                          clothing.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, _) => _placeholder(color),
                        )
                      : _placeholder(color),

                  // Category badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            categoryIcons[clothing.category] ??
                                Icons.checkroom_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            clothing.category[0].toUpperCase() +
                                clothing.category.substring(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Delete button (not on compact)
                  if (!compact)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white70, size: 18),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info ──
            if (!compact)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Color dot
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.white24),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        clothing.occasions.map((o) =>
                            o[0].toUpperCase() + o.substring(1)).join(', '),
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Icon(Icons.checkroom_rounded,
            size: compact ? 32 : 48, color: color.withValues(alpha: 0.5)),
      ),
    );
  }
}
