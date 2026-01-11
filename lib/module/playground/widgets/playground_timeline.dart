import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../common/common.dart';
import '../../../widget/widget.dart';
import '../playground.dart';

class PlaygroundTimeline extends StatelessWidget {
  final List<PlaygroundStreamEvent> events;
  final VoidCallback? onClear;

  const PlaygroundTimeline({super.key, required this.events, this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: AppTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.timeline, color: AppTheme.accent, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Timeline',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (events.isNotEmpty && onClear != null)
                  GestureDetector(
                    onTap: onClear,
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 60,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    height: 2,
                    width: double.infinity,
                    color: AppTheme.textMuted.withValues(alpha: 0.2),
                  ),
                ),
                if (events.isEmpty)
                  Center(
                    child: Text(
                      'Waiting for events...',
                      style: TextStyle(
                        color: AppTheme.textMuted.withValues(alpha: 0.5),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final event = events[events.length - 1 - index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Center(child: _buildEventMarble(event, index)),
                      );
                    },
                  ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildEventMarble(PlaygroundStreamEvent event, int index) {
    if (event.type == PlaygroundEventType.complete) {
      return Container(
        height: 40,
        width: 4,
        decoration: BoxDecoration(
          color: AppTheme.textPrimary,
          borderRadius: BorderRadius.circular(2),
        ),
      ).animate().fadeIn().scaleY();
    }

    final marbleItem = MarbleItem(
      value: event.value,
      time: 0,
      color: _getColorForValue(event.value),
      isError: event.type == PlaygroundEventType.error,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MarbleWidget(
          marble: marbleItem,
          size: 36,
          isAnimated: true,
          showLabel: true,
        ),
        const SizedBox(height: 4),
        Text(
          _formatTime(event.time),
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 10,
            fontFamily: GoogleFonts.sourceCodePro().fontFamily,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.second}:${time.millisecond.toString().padLeft(3, '0')}';
  }

  Color _getColorForValue(String value) {
    final hash = value.codeUnits.fold(0, (p, c) => p + c);
    return AppTheme.getMarbleColor(hash);
  }
}
