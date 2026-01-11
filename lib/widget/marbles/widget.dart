import 'package:flutter/material.dart';

import '../../common/common.dart';
import '../widget.dart';

class MarbleWidget extends StatefulWidget {
  final MarbleItem marble;
  final double size;
  final bool isDraggable;
  final bool isAnimated;
  final bool showLabel;
  final VoidCallback? onTap;
  final ValueChanged<double>? onTimeChanged;

  const MarbleWidget({
    super.key,
    required this.marble,
    this.size = 40,
    this.isDraggable = false,
    this.isAnimated = true,
    this.showLabel = true,
    this.onTap,
    this.onTimeChanged,
  });

  @override
  State<MarbleWidget> createState() => _MarbleWidgetState();
}

class _MarbleWidgetState extends State<MarbleWidget>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  final bool _isDragging = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.marble.isError) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.marble.displayColor;
    final content = _buildMarbleContent(color);

    if (widget.isAnimated) {
      return content.scaleIn(begin: Offset.zero);
    }

    return content;
  }

  Widget _buildMarbleContent(Color color) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isDraggable
          ? SystemMouseCursors.grab
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final pulseScale = widget.marble.isError
                ? 1 + (_pulseController.value * 0.1)
                : 1.0;
            return Transform.scale(
              scale: (_isHovered || _isDragging ? 1.15 : 1.0) * pulseScale,
              child: child,
            );
          },
          child: _buildMarble(color),
        ),
      ),
    );
  }

  Widget _buildMarble(Color color) {
    if (widget.marble.isComplete) {
      return Container(
        width: widget.size * 0.5,
        height: widget.size,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: AppTheme.textMuted, width: 3),
          ),
        ),
      );
    }

    if (widget.marble.isError) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.red, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.5),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Icon(Icons.close, color: Colors.red, size: widget.size * 0.5),
        ),
      );
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.9),
            color,
            color.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.5, 1.0],
          center: const Alignment(-0.3, -0.3),
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: _isHovered ? 0.6 : 0.4),
            blurRadius: _isHovered ? 16 : 8,
            spreadRadius: _isHovered ? 2 : 0,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: widget.showLabel
          ? Center(
              child: Text(
                _formatValue(widget.marble.value),
                style: TextStyle(
                  color: _getContrastColor(color),
                  fontWeight: FontWeight.bold,
                  fontSize: widget.size * 0.35,
                ),
              ),
            )
          : null,
    );
  }

  String _formatValue(dynamic value) {
    if (value is String && value.length > 3) {
      return '${value.substring(0, 2)}…';
    }
    return value.toString();
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

class DraggableMarble extends StatefulWidget {
  final MarbleItem marble;
  final double size;
  final double timelineWidth;
  final ValueChanged<double> onTimeChanged;

  const DraggableMarble({
    super.key,
    required this.marble,
    required this.timelineWidth,
    required this.onTimeChanged,
    this.size = 40,
  });

  @override
  State<DraggableMarble> createState() => _DraggableMarbleState();
}

class _DraggableMarbleState extends State<DraggableMarble> {
  late double _currentTime;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentTime = widget.marble.time;
  }

  @override
  void didUpdateWidget(DraggableMarble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.marble.time != widget.marble.time && !_isDragging) {
      _currentTime = widget.marble.time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: (_currentTime * widget.timelineWidth) - (widget.size / 2),
      child: GestureDetector(
        onHorizontalDragStart: (_) {
          setState(() => _isDragging = true);
        },
        onHorizontalDragUpdate: (details) {
          final newTime =
              ((_currentTime * widget.timelineWidth) + details.delta.dx) /
              widget.timelineWidth;
          final clampedTime = newTime.clamp(0.05, 0.95);
          setState(() {
            _currentTime = clampedTime;
          });

          widget.onTimeChanged(clampedTime);
        },
        onHorizontalDragEnd: (_) {
          setState(() => _isDragging = false);

          widget.onTimeChanged(_currentTime);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          transform: Matrix4.diagonal3Values(
            _isDragging ? 1.2 : 1.0,
            _isDragging ? 1.2 : 1.0,
            1.0,
          ),
          child: MarbleWidget(
            marble: widget.marble.copyWith(time: _currentTime),
            size: widget.size,
            isDraggable: true,
            isAnimated: false,
          ),
        ),
      ),
    );
  }
}
