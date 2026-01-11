import 'dart:async';

import 'package:flutter/material.dart';

import '../common/common.dart';
import '../widget/widget.dart';
import 'app.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() {
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              AppTheme.primary.withValues(alpha: 0.1),
              AppTheme.background,
            ],
            center: Alignment.center,
            radius: 1.0,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                  .scaleIn(
                    duration: 1000.ms,
                    curve: Curves.elasticOut,
                    begin: const Offset(0.5, 0.5),
                  )
                  .apply(AppAnimations.shimmer),

              const SizedBox(height: 48),

              Text(
                'RxLab',
                style: AppTypography.outfit(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: 2,
                ),
              ).entrance(delay: 400.ms, slideY: 0.2),

              const SizedBox(height: 32),

              Text(
                'THE REACTIVE PROGRAMMING LAB',
                style: AppTypography.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary,
                  letterSpacing: 4,
                ),
              ).fadeIn(delay: 800.ms, duration: 800.ms),

              const SizedBox(height: 64),

              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primary.withValues(alpha: 0.5),
                  ),
                ),
              ).fadeIn(delay: 1200.ms),
            ],
          ),
        ),
      ),
    );
  }
}
