import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../common/common.dart';
import '../../operators/operators.dart';
import 'decision_tree.dart';

class DecisionTreeFinder extends StatefulWidget {
  final DecisionTreeNode root;

  const DecisionTreeFinder({super.key, required this.root});

  @override
  State<DecisionTreeFinder> createState() => _DecisionTreeFinderState();
}

class _DecisionTreeFinderState extends State<DecisionTreeFinder> {
  late DecisionTreeNode _currentDecision;
  final List<DecisionTreeNode> _decisionHistory = [];

  @override
  void initState() {
    super.initState();
    _currentDecision = widget.root;
  }

  void _selectOption(DecisionTreeNode node) {
    setState(() {
      _decisionHistory.add(_currentDecision);
      _currentDecision = node;
    });
  }

  void _resetDecision() {
    setState(() {
      _currentDecision = widget.root;
      _decisionHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('interactive'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_decisionHistory.isNotEmpty) ...[
            _buildHistoryTrail(),
            const SizedBox(height: 24),
          ],
          _buildDecisionNode(_currentDecision),
        ],
      ),
    );
  }

  Widget _buildHistoryTrail() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'YOUR PATH',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textMuted,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _resetDecision,
                child: Text(
                  'RESET',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < _decisionHistory.length; i++) ...[
                  _buildHistoryNode(_decisionHistory[i], i),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppTheme.textMuted,
                  ),
                ],
                _buildHistoryNode(
                  _currentDecision,
                  _decisionHistory.length,
                  isActive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildHistoryNode(
    DecisionTreeNode node,
    int index, {
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: isActive
          ? null
          : () {
              setState(() {
                _decisionHistory.removeRange(index, _decisionHistory.length);
                _currentDecision = node;
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? AppTheme.primary
                : AppTheme.textMuted.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          node.question.length > 20
              ? '${node.question.substring(0, 17)}...'
              : node.question,
          style: TextStyle(
            color: isActive ? Colors.white : AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDecisionNode(DecisionTreeNode node) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: AppTheme.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            node.question,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
        Container(
          width: 2,
          height: 40,
          color: AppTheme.primary.withValues(alpha: 0.5),
        ).animate().scaleY(begin: 0, end: 1, duration: 300.ms),
        if (node.isResult)
          _buildResultCard(node)
        else ...[
          Container(
            height: 2,
            width: 100,
            color: AppTheme.primary.withValues(alpha: 0.3),
          ).animate().scaleX(begin: 0, end: 1, duration: 300.ms),
          const SizedBox(height: 20),
          ...?node.options?.map((opt) => _buildOptionCard(opt)),
        ],
      ],
    );
  }

  Widget _buildOptionCard(DecisionTreeNode node) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            child: Container(
              width: 1,
              height: 20,
              color: AppTheme.primary.withValues(alpha: 0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: InkWell(
              onTap: () => _selectOption(node),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        node.question,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: AppTheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildResultCard(DecisionTreeNode node) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.2),
            AppTheme.secondary.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.stars, color: AppTheme.primary, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            'RECOMMENDED OPERATOR',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            node.operator!,
            style: GoogleFonts.sourceCodePro(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            node.description ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              final opName = node.operator!;
              final definition = Operators.all.firstWhere(
                (op) => op.name.toLowerCase() == opName.toLowerCase(),
                orElse: () => Operators.all.firstWhere(
                  (op) => op.name.toLowerCase().contains(opName.toLowerCase()),
                  orElse: () => Operators.all.first,
                ),
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OperatorDetailScreen(operator_: definition),
                ),
              );
            },
            icon: const Icon(Icons.rocket_launch),
            label: const Text('Go to Operator'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }
}
