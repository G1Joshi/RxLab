import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppAnimations {
  static Animate shimmer(Animate animate) => animate.shimmer(
    duration: 1500.ms,
    color: Colors.white.withValues(alpha: 0.1),
  );

  static Animate glow(Animate animate, Color color) => animate.custom(
    duration: 2000.ms,
    builder: (context, value, child) => Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2 * value),
            blurRadius: 10 * value,
            spreadRadius: 2 * value,
          ),
        ],
      ),
      child: child,
    ),
  );
}

extension AppDurationExtensions on int {
  Duration get ms => Duration(milliseconds: this);
  Duration get seconds => Duration(seconds: this);
}

extension AppAnimationExtensions on Widget {
  Animate fadeIn({
    Duration? duration,
    Duration? delay,
    Curve curve = Curves.easeOut,
  }) {
    return animate(
      delay: delay,
    ).fadeIn(duration: duration ?? 400.ms, curve: curve);
  }

  Animate slideInY({
    double begin = 0.1,
    double end = 0.0,
    Duration? duration,
    Duration? delay,
    Curve curve = Curves.easeOutCubic,
  }) {
    return animate(delay: delay).slideY(
      begin: begin,
      end: end,
      duration: duration ?? 400.ms,
      curve: curve,
    );
  }

  Animate slideInX({
    double begin = 0.1,
    double end = 0.0,
    Duration? duration,
    Duration? delay,
    Curve curve = Curves.easeOutCubic,
  }) {
    return animate(delay: delay).slideX(
      begin: begin,
      end: end,
      duration: duration ?? 400.ms,
      curve: curve,
    );
  }

  Animate scaleIn({
    Offset begin = const Offset(0.9, 0.9),
    Offset end = const Offset(1.0, 1.0),
    Duration? duration,
    Duration? delay,
    Curve curve = Curves.elasticOut,
  }) {
    return animate(
      delay: delay,
    ).scale(begin: begin, end: end, duration: duration ?? 500.ms, curve: curve);
  }

  Animate entrance({Duration? delay, double slideY = 0.1}) {
    return animate(delay: delay)
        .fadeIn(duration: 400.ms)
        .slideY(begin: slideY, end: 0, curve: Curves.easeOutCubic);
  }

  Animate entranceX({Duration? delay, double slideX = 0.1}) {
    return animate(delay: delay)
        .fadeIn(duration: 400.ms)
        .slideX(begin: slideX, end: 0, curve: Curves.easeOutCubic);
  }

  Animate scaleInY({
    double begin = 0.0,
    double end = 1.0,
    Duration? duration,
    Duration? delay,
    Curve curve = Curves.easeOut,
  }) {
    return animate(delay: delay)
        .scaleY(
          begin: begin,
          end: end,
          duration: duration ?? 400.ms,
          curve: curve,
        )
        .fadeIn(duration: duration ?? 400.ms);
  }

  Animate scaleInX({
    double begin = 0.0,
    double end = 1.0,
    Duration? duration,
    Duration? delay,
    Curve curve = Curves.easeOut,
  }) {
    return animate(delay: delay)
        .scaleX(
          begin: begin,
          end: end,
          duration: duration ?? 400.ms,
          curve: curve,
        )
        .fadeIn(duration: duration ?? 400.ms);
  }
}

extension AppAnimateExtensions on Animate {
  Animate apply(Animate Function(Animate) effect) => effect(this);
}
