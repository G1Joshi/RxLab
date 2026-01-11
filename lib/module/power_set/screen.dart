import 'package:flutter/material.dart';

import '../../common/common.dart';
import '../../widget/widget.dart';
import '../operators/operators.dart';
import 'power_set.dart';

class PowerSetScreen extends StatefulWidget {
  const PowerSetScreen({super.key});

  @override
  State<PowerSetScreen> createState() => _PowerSetScreenState();
}

class _PowerSetScreenState extends State<PowerSetScreen> with DataLoadingMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedLetter;

  static const _alphabet = '#ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    loadData(() async {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PowerSetOperator> get _filteredOperators {
    var ops = PowerSets.all;

    if (_searchQuery.isNotEmpty) {
      ops = PowerSets.search(_searchQuery);
    }

    if (_selectedLetter != null) {
      ops = ops.where((op) {
        final firstChar = op.name.isNotEmpty ? op.name[0].toUpperCase() : '';
        if (_selectedLetter == '#') {
          return !RegExp(r'[A-Z]').hasMatch(firstChar);
        }
        return firstChar == _selectedLetter;
      }).toList();
    }

    return ops;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.surfaceGradient),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 12),
                    _buildAlphabetBar(),
                    const SizedBox(height: 12),
                    Expanded(child: _buildOperatorsList()),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ModuleHeader(
      title: 'Power Set',
      subtitle: '${PowerSets.all.length} Operators • A-Z Index',
      icon: Icons.list_alt_rounded,
      gradientColors: const [AppTheme.primary, AppTheme.secondary],
      showBackButton: true,
    );
  }

  Widget _buildAlphabetBar() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _alphabet.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildLetterChip('All', _selectedLetter == null, () {
              setState(() => _selectedLetter = null);
            });
          }
          final letter = _alphabet[index - 1];
          final hasTerms = PowerSets.all.any((op) {
            final firstChar = op.name.isNotEmpty
                ? op.name[0].toUpperCase()
                : '';
            if (letter == '#') return !RegExp(r'[A-Z]').hasMatch(firstChar);
            return firstChar == letter;
          });

          return _buildLetterChip(letter, _selectedLetter == letter, () {
            setState(() => _selectedLetter = letter);
          }, isEnabled: hasTerms);
        },
      ),
    ).fadeIn();
  }

  Widget _buildLetterChip(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        width: label == 'All' ? 50 : 32,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : isEnabled
              ? AppTheme.surfaceLight.withValues(alpha: 0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? null
              : Border.all(
                  color: isEnabled
                      ? AppTheme.primary.withValues(alpha: 0.2)
                      : AppTheme.textMuted.withValues(alpha: 0.1),
                ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : isEnabled
                  ? AppTheme.textPrimary
                  : AppTheme.textMuted.withValues(alpha: 0.3),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: AppTheme.glassDecoration,
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search 400+ operators...',
            prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: AppTheme.textMuted),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ).fadeIn().slideInY(begin: -0.2, end: 0),
    );
  }

  Widget _buildOperatorsList() {
    final operators = _filteredOperators;

    if (operators.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text(
              'No operators found',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ],
        ),
      ).fadeIn();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: operators.length,
      itemBuilder: (context, index) {
        final op = operators[index];
        final isAvailable = Operators.all.any(
          (o) => o.name.toLowerCase() == op.name.toLowerCase(),
        );
        return _buildOperatorCard(op, isAvailable, index);
      },
    ).fadeIn();
  }

  Widget _buildOperatorCard(PowerSetOperator op, bool isCore, int index) {
    final color = op.color != null
        ? Utils.getColor(op.color)
        : (isCore
              ? AppTheme.primary
              : AppTheme.textMuted.withValues(alpha: 0.1));
    final icon = op.icon != null ? Utils.getIcon(op.icon) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(color),
      child: ListTile(
        onTap: isCore ? () => _navigateToOperator(op.name) : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: icon != null
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              )
            : null,
        title: Text(
          op.name,
          style: AppTypography.outfit(
            fontSize: 18,
            fontWeight: isCore ? FontWeight.bold : FontWeight.normal,
            color: isCore
                ? (op.color != null ? color : AppTheme.primary)
                : AppTheme.textPrimary,
          ),
        ),
        subtitle: op.description != null
            ? Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  op.description!,
                  style: AppTypography.inter(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              )
            : null,
        trailing: isCore
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Text(
                  'CORE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 1,
                  ),
                ),
              )
            : null,
      ),
    ).entrance(delay: Duration(milliseconds: index % 10 * 30));
  }

  void _navigateToOperator(String name) {
    final operatorDef = Operators.all.firstWhere(
      (o) => o.name.toLowerCase() == name.toLowerCase(),
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OperatorDetailScreen(operator_: operatorDef),
      ),
    );
  }
}
