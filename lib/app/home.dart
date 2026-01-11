import 'package:flutter/material.dart';

import '../common/common.dart';
import '../widget/widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final topLevelModules = ModuleRegistry.topLevelModules;

    if (topLevelModules.isEmpty) {
      return const Scaffold(body: Center(child: Text("No modules enabled")));
    }

    if (_currentIndex >= topLevelModules.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: topLevelModules.map((f) => f.screen).toList(),
      ),
      bottomNavigationBar: _buildBottomNav(topLevelModules),
    );
  }

  Widget _buildBottomNav(List<Module> modules) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: modules.asMap().entries.map((entry) {
              final index = entry.key;
              final module = entry.value;
              final isSelected = index == _currentIndex;

              return _NavItem(
                icon: isSelected ? module.activeIcon : module.icon,
                label: module.label,
                isSelected: isSelected,
                onTap: () => setState(() => _currentIndex = index),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primary.withAlpha(40)
                : _isHovered
                ? AppTheme.surfaceLight
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.isSelected
                    ? AppTheme.primary
                    : _isHovered
                    ? AppTheme.textPrimary
                    : AppTheme.textMuted,
                size: 24,
              ),
              if (widget.isSelected) ...[
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: AppTypography.inter(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ).entranceX(slideX: -0.2, delay: 200.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
