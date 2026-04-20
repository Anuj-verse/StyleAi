import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/outfit.dart';

class OutfitCard extends StatelessWidget {
  final Outfit outfit;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;
  final bool showAIInsights;

  const OutfitCard({
    super.key,
    required this.outfit,
    this.onSave,
    this.onDelete,
    this.showAIInsights = false,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: showAIInsights
              ? AppTheme.primaryColor.withValues(alpha: 0.25)
              : Colors.white10,
        ),
        boxShadow: [
          BoxShadow(
            color: showAIInsights
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: showAIInsights
                          ? const LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFFFF6584)])
                          : AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      showAIInsights
                          ? Icons.psychology_rounded
                          : Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        showAIInsights ? 'AI Suggestion' : 'Outfit Suggestion',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      if (outfit.occasion != null)
                        Text(
                          outfit.occasion![0].toUpperCase() +
                              outfit.occasion!.substring(1),
                          style: TextStyle(
                              color: AppTheme.primaryColor, fontSize: 12),
                        ),
                    ],
                  ),
                ],
              ),
              if (outfit.score > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.success.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${(outfit.score * 100).toInt()}% match',
                    style: TextStyle(
                      color: AppTheme.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Outfit Items Row ──
          Row(
            children: [
              if (outfit.top != null)
                Expanded(child: _buildItemSlot(context, 'Top', outfit.top!)),
              if (outfit.bottom != null) ...[
                const SizedBox(width: 10),
                Expanded(
                    child:
                        _buildItemSlot(context, 'Bottom', outfit.bottom!)),
              ],
              if (outfit.shoes != null) ...[
                const SizedBox(width: 10),
                Expanded(
                    child: _buildItemSlot(context, 'Shoes', outfit.shoes!)),
              ],
              if (outfit.accessory != null) ...[
                const SizedBox(width: 10),
                Expanded(
                    child: _buildItemSlot(
                        context, 'Extra', outfit.accessory!)),
              ],
            ],
          ),

          // ── AI Reasoning ──
          if (showAIInsights && outfit.reasoning != null && outfit.reasoning!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.psychology_rounded,
                      color: AppTheme.primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      outfit.reasoning!,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── AI Styling Tip ──
          if (showAIInsights && outfit.stylingTip != null && outfit.stylingTip!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.accentColor.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.tips_and_updates_rounded,
                      color: AppTheme.accentColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      outfit.stylingTip!,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // ── Actions ──
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onDelete != null)
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline_rounded,
                      color: AppTheme.error, size: 18),
                  label: Text('Remove',
                      style:
                          TextStyle(color: AppTheme.error, fontSize: 13)),
                ),
              const Spacer(),
              if (onSave != null)
                ElevatedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.favorite_rounded, size: 18),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemSlot(BuildContext context, String label, dynamic item) {
    final color = _parseColor(item.color);
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            item.imageUrl.isNotEmpty
                ? Image.network(item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, _) => _colorPlaceholder(color))
                : _colorPlaceholder(color),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorPlaceholder(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.4),
            color.withValues(alpha: 0.15)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(Icons.checkroom_rounded,
          color: color.withValues(alpha: 0.4), size: 28),
    );
  }
}
