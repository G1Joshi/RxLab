import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../common/models.dart';
import '../../common/theme.dart';
import 'widget.dart';

class MarbleTimeline extends StatefulWidget {
  final MarbleStream stream;
  final String? label;
  final bool isInteractive;
  final bool showAnimation;
  final double? animationValue;
  final ValueChanged<MarbleStream>? onStreamChanged;
  final double height;

  const MarbleTimeline({
    super.key,
    required this.stream,
    this.label,
    this.isInteractive = false,
    this.showAnimation = true,
    this.animationValue,
    this.onStreamChanged,
    this.height = 80,
  });

  @override
  State<MarbleTimeline> createState() => _MarbleTimelineState();
}

class _MarbleTimelineState extends State<MarbleTimeline> {
  late List<MarbleItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.stream.items);
  }

  @override
  void didUpdateWidget(MarbleTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
      _items = List.from(widget.stream.items);
    }
  }

  void _handleTimeChanged(int index, double newTime) {
    setState(() {
      _items[index] = _items[index].copyWith(time: newTime);
    });
    widget.onStreamChanged?.call(widget.stream.copyWith(items: _items));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final timelineWidth = constraints.maxWidth - 60;

        return Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.label != null || widget.stream.label.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    widget.label ?? widget.stream.label,
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  clipBehavior: Clip.none,
                  children: [
                    _buildTimelineLine(timelineWidth),

                    ..._buildMarbles(timelineWidth),

                    if (widget.stream.isComplete)
                      _buildCompletionMarker(timelineWidth),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineLine(double width) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
              width: width + 40,
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.timelineColor.withAlpha(80),
                    AppTheme.timelineColor,
                    AppTheme.timelineColor,
                    AppTheme.timelineArrow,
                  ],
                  stops: const [0.0, 0.05, 0.9, 1.0],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: -6,
                    child: CustomPaint(
                      size: const Size(12, 15),
                      painter: _ArrowPainter(color: AppTheme.timelineArrow),
                    ),
                  ),
                ],
              ),
            )
            .animate(target: widget.showAnimation ? 1 : 0)
            .scaleX(
              begin: 0,
              end: 1,
              duration: 600.ms,
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerLeft,
            ),

        if (widget.animationValue != null)
          Positioned(
            left: widget.animationValue! * width,
            child: Container(
              width: 3,
              height: widget.height * 0.6,
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withAlpha(100),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildMarbles(double timelineWidth) {
    final sortedItems = _items.toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    return sortedItems.asMap().entries.map((entry) {
      final index = _items.indexOf(entry.value);
      final marble = entry.value;

      if (widget.isInteractive) {
        return DraggableMarble(
          key: ValueKey('marble_${marble.value}_$index'),
          marble: marble,
          timelineWidth: timelineWidth,
          onTimeChanged: (newTime) => _handleTimeChanged(index, newTime),
        );
      }

      final isPastPlayhead =
          widget.animationValue != null &&
          widget.animationValue! >= marble.time;

      return Positioned(
        left: (marble.time * timelineWidth) - 20,
        child:
            MarbleWidget(
                  key: ValueKey('marble_${marble.value}_$index'),
                  marble: marble,
                  isAnimated: widget.showAnimation,
                )
                .animate(target: isPastPlayhead ? 1 : 0)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.2, 1.2),
                  duration: 200.ms,
                  curve: Curves.elasticOut,
                )
                .animate(
                  delay: Duration(milliseconds: 200 + (entry.key * 100)),
                  target: widget.showAnimation ? 1 : 0,
                )
                .slideX(
                  begin: -0.5,
                  end: 0,
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                ),
      );
    }).toList();
  }

  Widget _buildCompletionMarker(double timelineWidth) {
    return Positioned(
      left: timelineWidth - 10,
      child:
          Container(
                width: 3,
                height: 30,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
              .animate(target: widget.showAnimation ? 1 : 0)
              .fadeIn(delay: 800.ms, duration: 300.ms)
              .scaleY(
                begin: 0,
                end: 1,
                delay: 800.ms,
                duration: 300.ms,
                curve: Curves.easeOutBack,
              ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;

  _ArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}
