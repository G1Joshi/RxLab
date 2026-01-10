import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../common/common.dart';
import 'marbles.dart';

class MarbleDiagram extends StatefulWidget {
  final OperatorDefinition operator_;
  final List<MarbleStream>? customInputs;
  final bool isInteractive;
  final VoidCallback? onReset;

  const MarbleDiagram({
    super.key,
    required this.operator_,
    this.customInputs,
    this.isInteractive = true,
    this.onReset,
  });

  @override
  State<MarbleDiagram> createState() => _MarbleDiagramState();
}

class _MarbleDiagramState extends State<MarbleDiagram>
    with SingleTickerProviderStateMixin {
  late List<MarbleStream> _inputStreams;
  late MarbleStream _outputStream;
  late AnimationController _animationController;
  bool _showOutput = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeStreams();
    _animationController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 3000),
          )
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && _isPlaying) {
              _animationController.forward(from: 0);
            }
          })
          ..addListener(() {
            if (_isPlaying) setState(() {});
          });
    _playEntranceAnimation();
  }

  @override
  void didUpdateWidget(MarbleDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.operator_.name != widget.operator_.name ||
        oldWidget.customInputs != widget.customInputs) {
      _initializeStreams();
      if (_isPlaying) {
        _startAnimation();
      } else {
        _playEntranceAnimation();
      }
    }
  }

  void _initializeStreams() {
    _inputStreams =
        widget.customInputs ??
        widget.operator_.defaultInputs.map((s) => s.copyWith()).toList();
    _outputStream = widget.operator_.execute(_inputStreams);
  }

  void _playEntranceAnimation() {
    setState(() {
      _showOutput = false;
      _isPlaying = false;
    });
    _animationController.reset();
    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && !_isPlaying) {
        setState(() => _showOutput = true);
      }
    });
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startAnimation();
      } else {
        _animationController.stop();
      }
    });
  }

  void _startAnimation() {
    setState(() => _showOutput = true);
    _animationController.forward(from: 0);
  }

  void _handleInputChanged(int index, MarbleStream newStream) {
    setState(() {
      _inputStreams[index] = newStream;
      _outputStream = widget.operator_.execute(_inputStreams);
      _showOutput = true;
    });
  }

  void _reset() {
    setState(() {
      _isPlaying = false;
      _showOutput = false;
      _animationController.reset();
      _initializeStreams();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _playEntranceAnimation();
      }
    });
    widget.onReset?.call();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.glassDecoration,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),

          ..._buildInputStreams(),

          _buildOperatorIndicator(),

          _buildOutputStream(),

          const SizedBox(height: 16),

          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.operator_.categoryColor.withAlpha(80),
                widget.operator_.categoryColor.withAlpha(30),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.operator_.categoryColor.withAlpha(80),
            ),
          ),
          child: Icon(
            widget.operator_.icon,
            color: widget.operator_.categoryColor,
            size: 24,
          ),
        ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.operator_.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                widget.operator_.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),

        if (widget.isInteractive) ...[
          IconButton(
            onPressed: _togglePlay,
            icon: Icon(
              _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
              size: 28,
            ),
            tooltip: _isPlaying ? 'Stop' : 'Play',
            style: IconButton.styleFrom(
              backgroundColor: _isPlaying
                  ? Colors.red.withAlpha(30)
                  : AppTheme.surfaceLight,
              foregroundColor: _isPlaying ? Colors.red : AppTheme.accent,
            ),
          ),
          const SizedBox(width: 12),

          IconButton(
            onPressed: _reset,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset',
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.surfaceLight,
              foregroundColor: AppTheme.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildInputStreams() {
    return _inputStreams.asMap().entries.map((entry) {
      final index = entry.key;
      final stream = entry.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: MarbleTimeline(
          key: ValueKey('input_$index'),
          stream: stream,
          label: _inputStreams.length > 1 ? 'Input ${index + 1}' : 'Input',
          isInteractive: widget.isInteractive,
          showAnimation: true,
          animationValue: _isPlaying ? _animationController.value : null,
          onStreamChanged: (newStream) => _handleInputChanged(index, newStream),
        ),
      );
    }).toList();
  }

  Widget _buildOperatorIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    widget.operator_.categoryColor.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.operator_.categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.operator_.categoryColor.withValues(
                      alpha: 0.4,
                    ),
                  ),
                ),
                child: Text(
                  widget.operator_.name,
                  style: TextStyle(
                    color: widget.operator_.categoryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 400.ms, duration: 300.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                delay: 400.ms,
                duration: 300.ms,
                curve: Curves.easeOutBack,
              ),
          Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.operator_.categoryColor.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputStream() {
    return AnimatedOpacity(
      opacity: _showOutput ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: MarbleTimeline(
        key: const ValueKey('output'),
        stream: _outputStream,
        label: 'Output',
        isInteractive: false,
        showAnimation: _showOutput,
        animationValue: _isPlaying ? _animationController.value : null,
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Drag marbles to change timing', Icons.touch_app),
        const SizedBox(width: 24),
        _buildLegendItem(
          'Click Replay to see animation',
          Icons.play_circle_outline,
        ),
      ],
    ).animate().fadeIn(delay: 1000.ms, duration: 400.ms);
  }

  Widget _buildLegendItem(String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.textMuted),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      ],
    );
  }
}
