import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/common.dart';
import '../../widget/widget.dart';
import 'concepts.dart';

class ConceptsScreen extends StatefulWidget {
  const ConceptsScreen({super.key});

  @override
  State<ConceptsScreen> createState() => _ConceptsScreenState();
}

class _ConceptsScreenState extends State<ConceptsScreen> with DataLoadingMixin {
  List<ConceptData> _concepts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    loadData(() async {
      _concepts = ConceptData.all;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.surfaceGradient),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(context)),
                    SliverToBoxAdapter(child: _buildLearningTools(context)),

                    SliverToBoxAdapter(child: _buildStreamVisualizer()),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                        child: Text(
                          'Core Concepts',
                          style: AppTypography.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              childAspectRatio: 1.5,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _ConceptCard(
                            concept: _concepts[index],
                            index: index,
                            onTap: () =>
                                _openConceptDetail(context, _concepts[index]),
                          ),
                          childCount: _concepts.length,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStreamVisualizer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.withAlpha(30), Colors.purple.withAlpha(30)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withAlpha(50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.stream, color: Colors.blue, size: 18),
                const SizedBox(width: 8),
                Text(
                  'What is a Stream?',
                  style: AppTypography.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 50,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 24,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  for (int i = 0; i < 4; i++)
                    _AnimatedMarble(delay: i * 400, index: i),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Values flow through time → apply operators → get transformed output',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    ).fadeIn(delay: 200.ms);
  }

  Widget _buildLearningTools(BuildContext context) {
    final tools = ModuleRegistry.learningTools;
    if (tools.isEmpty) return const SizedBox.shrink();

    final List<Widget> rows = [];
    for (int i = 0; i < tools.length; i += 3) {
      final chunk = tools.skip(i).take(3).toList();
      rows.add(
        Row(
          children: [
            ...chunk.map((tool) => _buildToolItem(context, tool)),

            if (chunk.length < 3)
              ...List.generate(
                3 - chunk.length,
                (_) => const Expanded(child: SizedBox.shrink()),
              ),
          ],
        ),
      );
      if (i + 3 < tools.length) {
        rows.add(const SizedBox(height: 12));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(children: rows),
    ).fadeIn(delay: 200.ms);
  }

  Widget _buildToolItem(BuildContext context, Module tool) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: _LearningToolCard(
          icon: tool.icon,
          label: tool.label,
          color: tool.color,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => tool.screen),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ModuleHeader(
      title: 'RxLab Concepts',
      subtitle: 'Master reactive programming concepts',
      icon: Icons.school_rounded,
      gradientColors: const [Colors.purple, Colors.blue],
      showBackButton: false,
    );
  }

  void _openConceptDetail(BuildContext context, ConceptData concept) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConceptDetailScreen(concept: concept),
      ),
    );
  }
}

class _AnimatedMarble extends StatefulWidget {
  final int delay;
  final int index;

  const _AnimatedMarble({required this.delay, required this.index});

  @override
  State<_AnimatedMarble> createState() => _AnimatedMarbleState();
}

class _AnimatedMarbleState extends State<_AnimatedMarble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  static const _colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];
  static const _labels = ['1', '2', '3', '4'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: _animation.value * (MediaQuery.of(context).size.width - 120),
          top: 10,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _colors[widget.index],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _colors[widget.index].withAlpha(100),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _labels[widget.index],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ConceptCard extends StatefulWidget {
  final ConceptData concept;
  final int index;
  final VoidCallback onTap;

  const _ConceptCard({
    required this.concept,
    required this.index,
    required this.onTap,
  });

  @override
  State<_ConceptCard> createState() => _ConceptCardState();
}

class _ConceptCardState extends State<_ConceptCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
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
            gradient: LinearGradient(
              colors: [
                widget.concept.colorValue.withAlpha(_isHovered ? 80 : 50),
                AppTheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.concept.colorValue.withAlpha(_isHovered ? 150 : 80),
              width: 1.5,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.concept.colorValue.withAlpha(40),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.concept.colorValue.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.concept.iconData,
                        color: widget.concept.colorValue,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: widget.concept.colorValue.withAlpha(
                        _isHovered ? 255 : 100,
                      ),
                      size: 16,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  widget.concept.title,
                  style: AppTypography.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.concept.subtitle,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    ).entrance();
  }
}

class ConceptDetailScreen extends StatelessWidget {
  final ConceptData concept;

  const ConceptDetailScreen({super.key, required this.concept});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.surfaceGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildAppBar(context)),
              SliverToBoxAdapter(child: _buildHeroSection(context)),
              SliverToBoxAdapter(child: _buildExplanationSection(context)),
              SliverToBoxAdapter(child: _buildKeyPointsSection(context)),
              if (concept.codeExample.isNotEmpty)
                SliverToBoxAdapter(child: _buildCodeSection(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return ModuleHeader(
      title: concept.title,
      subtitle: concept.subtitle,
      icon: concept.iconData,
      gradientColors: [concept.colorValue, concept.colorValue.withAlpha(200)],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              concept.colorValue.withAlpha(40),
              concept.colorValue.withAlpha(15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: concept.colorValue.withAlpha(60)),
        ),
        child: Column(
          children: [
            Icon(concept.iconData, color: concept.colorValue, size: 64),
            const SizedBox(height: 16),
            Text(
              concept.title,
              style: AppTypography.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              concept.subtitle,
              style: TextStyle(
                color: concept.colorValue,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).entrance(delay: 100.ms);
  }

  Widget _buildExplanationSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'What is it?',
                  style: AppTypography.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              concept.description,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    ).entrance(delay: 200.ms);
  }

  Widget _buildKeyPointsSection(BuildContext context) {
    if (concept.keyPoints.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Key Points',
                  style: AppTypography.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...concept.keyPoints.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: concept.colorValue.withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: TextStyle(
                            color: concept.colorValue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).entrance(delay: 300.ms);
  }

  Widget _buildCodeSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.code, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Code Example',
                  style: AppTypography.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: concept.codeExample.trim()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy, size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          'Copy',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                concept.codeExample.trim(),
                style: AppTypography.sourceCodePro(
                  color: const Color(0xFFE6EDF3),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    ).entrance(delay: 400.ms);
  }
}

class _LearningToolCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _LearningToolCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
