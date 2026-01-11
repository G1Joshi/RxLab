import 'package:flutter/material.dart';

import '../../../common/common.dart';
import '../../../widget/widget.dart';
import '../../operators/operators.dart';
import 'lab.dart';

class LabScreen extends StatefulWidget {
  final bool showHeader;
  const LabScreen({super.key, this.showHeader = true});

  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen>
    with SingleTickerProviderStateMixin {
  late StreamChain _chain;
  late AnimationController _animationController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _chain = StreamChain(
      source: MarbleStream.fromValues([1, 2, 3], label: 'Source'),
    );
    _animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 3000),
        )..addListener(() {
          if (_isPlaying) setState(() {});
        });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _animationController.forward(from: 0);
      } else {
        _animationController.stop();
      }
    });
  }

  void _reset() {
    setState(() {
      _isPlaying = false;
      _animationController.reset();
      _chain = StreamChain(
        source: MarbleStream.fromValues([1, 2, 3], label: 'Source'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final workspace = Column(
      children: [
        if (widget.showHeader) _buildHeader(),
        Expanded(
          child: _chain.steps.isEmpty ? _buildEmptyState() : _buildWorkspace(),
        ),
        _buildAddOperatorBar(),
      ],
    );

    if (!widget.showHeader) return workspace;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.surfaceGradient),
        child: SafeArea(child: workspace),
      ),
    );
  }

  Widget _buildHeader() {
    return ModuleHeader(
      title: 'RxLab Stream Lab',
      subtitle: 'Chain operators and visualize flow',
      icon: Icons.science_rounded,
      actions: [
        IconButton(
          onPressed: _togglePlay,
          icon: Icon(
            _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.surfaceLight,
            foregroundColor: _isPlaying ? Colors.red : AppTheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _reset,
          icon: const Icon(Icons.refresh_rounded),
          style: IconButton.styleFrom(backgroundColor: AppTheme.surfaceLight),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.gesture_outlined,
            size: 80,
            color: AppTheme.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 24),
          Text(
            'Your lab is empty',
            style: AppTypography.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add an operator below to start chaining',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ],
      ),
    ).fadeIn();
  }

  Widget _buildWorkspace() {
    final allStreams = _chain.allStreams;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildStreamVisual(allStreams[0], "SOURCE", isSource: true),

        for (int i = 0; i < _chain.steps.length; i++) ...[
          _buildOperatorJoint(_chain.steps[i], i),
          _buildStreamVisual(allStreams[i + 1], "STEP ${i + 1}"),
        ],
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStreamVisual(
    MarbleStream stream,
    String label, {
    bool isSource = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: MarbleTimeline(
        stream: stream,
        label: label,
        isInteractive: isSource,
        showAnimation: true,
        animationValue: _isPlaying ? _animationController.value : null,
        onStreamChanged: isSource
            ? (newStream) {
                setState(() {
                  _chain = StreamChain(source: newStream, steps: _chain.steps);
                });
              }
            : null,
      ),
    );
  }

  Widget _buildOperatorJoint(ChainStep step, int index) {
    final op = step.operator;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 2,
              height: 40,
              color: op.categoryColor.withValues(alpha: 0.2),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: op.categoryColor.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: op.categoryColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(op.icon, size: 16, color: op.categoryColor),
                  const SizedBox(width: 8),
                  Text(
                    op.name,
                    style: TextStyle(
                      color: op.categoryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _chain = _chain.removeStep(index)),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: AppTheme.textMuted,
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

  Widget _buildAddOperatorBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ADD OPERATOR',
            style: AppTypography.inter(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppTheme.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var op in Operators.essential) _buildOperatorChip(op),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorChip(OperatorDefinition op) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _chain = _chain.addStep(op);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Icon(op.icon, color: op.categoryColor, size: 20),
            const SizedBox(height: 4),
            Text(
              op.name,
              style: TextStyle(fontSize: 11, color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
