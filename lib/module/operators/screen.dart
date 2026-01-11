import 'package:flutter/material.dart';

import '../../common/common.dart';
import '../../widget/widget.dart';
import '../power_set/power_set.dart';
import 'operators.dart';

class OperatorsScreen extends StatefulWidget {
  const OperatorsScreen({super.key});

  @override
  State<OperatorsScreen> createState() => _OperatorsScreenState();
}

class _OperatorsScreenState extends State<OperatorsScreen>
    with SingleTickerProviderStateMixin, DataLoadingMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  OperatorCategory? _selectedCategory;

  final List<({String label, OperatorCategory? category})> _tabs = [
    (label: 'All', category: null),
    (label: 'Create', category: OperatorCategory.creation),
    (label: 'Transform', category: OperatorCategory.transformation),
    (label: 'Filter', category: OperatorCategory.filtering),
    (label: 'Combine', category: OperatorCategory.combination),
    (label: 'Conditional', category: OperatorCategory.conditional),
    (label: 'Aggregate', category: OperatorCategory.aggregate),
    (label: 'Error', category: OperatorCategory.errorHandling),
    (label: 'Utility', category: OperatorCategory.utility),
    (label: 'Connectable', category: OperatorCategory.connectable),
    (label: 'Convert', category: OperatorCategory.conversion),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedCategory = _tabs[_tabController.index].category;
      });
    });
    _initData();
  }

  Future<void> _initData() async {
    loadData(() async {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<OperatorDefinition> get _filteredOperators {
    var operators = _selectedCategory == null
        ? Operators.all
        : Operators.byCategory(_selectedCategory!);

    if (_searchQuery.isNotEmpty) {
      operators = Operators.search(_searchQuery);
      if (_selectedCategory != null) {
        operators = operators
            .where((op) => op.category == _selectedCategory)
            .toList();
      }
    }

    return operators;
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
                    const SizedBox(height: 16),

                    _buildCategoryTabs(),
                    const SizedBox(height: 16),

                    Expanded(child: _buildOperatorsGrid()),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ModuleHeader(
      title: 'RxLab Operators',
      subtitle: 'Universal Reactive Extensions Reference',
      icon: Icons.timeline_rounded,
      gradientColors: const [AppTheme.primary, AppTheme.secondary],
      showBackButton: false,
      actions: [
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PowerSetScreen()),
          ),
          icon: const Icon(Icons.list_alt_rounded, size: 18),
          label: const Text('Power Set'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.surfaceLight,
            foregroundColor: AppTheme.textPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
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
            hintText: 'Search operators...',
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

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppTheme.textPrimary,
        unselectedLabelColor: AppTheme.textMuted,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(25),
        ),
        labelStyle: AppTypography.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: AppTypography.inter(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: _tabs.map((tab) {
          return Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(tab.label),
            ),
          );
        }).toList(),
      ),
    ).fadeIn().slideInY(begin: -0.2, end: 0);
  }

  Widget _buildOperatorsGrid() {
    final operators = _filteredOperators;

    if (operators.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text(
              'No operators found',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 280,
          childAspectRatio: 1.3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: operators.length,
        itemBuilder: (context, index) {
          final op = operators[index];
          return _OperatorCard(
            operator_: op,
            index: index,
            onTap: () => _openOperator(op),
          );
        },
      ),
    );
  }

  void _openOperator(OperatorDefinition op) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            OperatorDetailScreen(operator_: op),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _OperatorCard extends StatefulWidget {
  final OperatorDefinition operator_;
  final int index;
  final VoidCallback onTap;

  const _OperatorCard({
    required this.operator_,
    required this.index,
    required this.onTap,
  });

  @override
  State<_OperatorCard> createState() => _OperatorCardState();
}

class _OperatorCardState extends State<_OperatorCard> {
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
          transform: Matrix4.diagonal3Values(
            _isHovered ? 1.02 : 1.0,
            _isHovered ? 1.02 : 1.0,
            1.0,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? widget.operator_.categoryColor.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.05),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.operator_.categoryColor.withValues(
                        alpha: 0.2,
                      ),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.operator_.categoryColor.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.operator_.icon,
                        color: widget.operator_.categoryColor,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.operator_.category.displayName,
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                Text(
                  widget.operator_.name,
                  style: AppTypography.sourceCodePro(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  widget.operator_.description,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    ).entrance(delay: (50 * widget.index).ms);
  }
}
