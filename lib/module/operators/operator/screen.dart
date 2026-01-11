import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../common/common.dart';
import '../../../widget/widget.dart';
import '../operators.dart';

class OperatorDetailScreen extends StatefulWidget {
  final OperatorDefinition operator_;

  const OperatorDetailScreen({super.key, required this.operator_});

  @override
  State<OperatorDetailScreen> createState() => _OperatorDetailScreenState();
}

class _OperatorDetailScreenState extends State<OperatorDetailScreen> {
  bool _showCode = false;
  bool _codeCopied = false;

  List<OperatorDefinition> get _relatedOperators {
    return Operators.byCategory(
      widget.operator_.category,
    ).where((op) => op.name != widget.operator_.name).take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.surfaceGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MarbleDiagram(
                            operator_: widget.operator_,
                            isInteractive: true,
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 32),

                      _buildDescriptionSection(),

                      const SizedBox(height: 24),

                      _buildCodeSection(),

                      const SizedBox(height: 24),

                      if (_relatedOperators.isNotEmpty)
                        _buildRelatedOperators(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedOperators() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Operators',
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _relatedOperators
              .map(
                (op) => GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OperatorDetailScreen(operator_: op),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: op.categoryColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: op.categoryColor.withAlpha(60)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(op.icon, size: 14, color: op.categoryColor),
                        const SizedBox(width: 6),
                        Text(
                          op.name,
                          style: TextStyle(
                            color: op.categoryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.surfaceLight,
              foregroundColor: AppTheme.textPrimary,
            ),
          ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.5, end: 0),
          const SizedBox(width: 16),

          Expanded(
            child:
                Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.operator_.name,
                          style: GoogleFonts.sourceCodePro(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          widget.operator_.category.displayName,
                          style: TextStyle(
                            color: widget.operator_.categoryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 300.ms)
                    .slideX(begin: -0.2, end: 0),
          ),

          Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.operator_.categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.operator_.categoryColor.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                child: Icon(
                  widget.operator_.icon,
                  color: widget.operator_.categoryColor,
                ),
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 300.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glassDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'How it works',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.operator_.detailedDescription ??
                    widget.operator_.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildCodeSection() {
    return Container(
          decoration: AppTheme.glassDecoration,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () => setState(() => _showCode = !_showCode),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.code_rounded,
                        color: AppTheme.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Universal Rx Pseudocode',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppTheme.textPrimary),
                      ),
                      const Spacer(),
                      AnimatedRotation(
                        turns: _showCode ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.expand_more,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1117),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton.icon(
                          onPressed: _copyCode,
                          icon: Icon(
                            _codeCopied ? Icons.check : Icons.copy,
                            size: 16,
                          ),
                          label: Text(_codeCopied ? 'Copied!' : 'Copy'),
                          style: TextButton.styleFrom(
                            foregroundColor: _codeCopied
                                ? Colors.green
                                : AppTheme.textMuted,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      SelectableText(
                        widget.operator_.codeExample.trim(),
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 14,
                          color: const Color(0xFFE6EDF3),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                crossFadeState: _showCode
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 300.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  void _copyCode() async {
    await Clipboard.setData(
      ClipboardData(text: widget.operator_.codeExample.trim()),
    );
    setState(() => _codeCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _codeCopied = false);
      }
    });
  }
}
