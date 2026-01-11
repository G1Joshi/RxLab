import 'package:flutter/material.dart';

import '../common/common.dart';
import 'widget.dart';

class ModuleHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color>? gradientColors;
  final Color? gradientColor;
  final List<Widget>? actions;
  final bool showBackButton;

  const ModuleHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.gradientColors,
    this.gradientColor,
    this.actions,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors =
        gradientColors ??
        (gradientColor != null
            ? [gradientColor!, gradientColor!.withAlpha(200)]
            : [AppTheme.primary, AppTheme.secondary]);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (showBackButton) ...[
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.surfaceLight,
                foregroundColor: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ).scaleIn(begin: Offset.zero),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          if (actions != null) ...[const SizedBox(width: 12), ...actions!],
        ],
      ),
    ).entrance(slideY: -0.1);
  }
}
