import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/theme/app_spacing.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    // Navigate to Dashboard after 2 seconds
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        context.router.replace(const DashboardRoute());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customColors = context.customColors;
    final customTypography = context.customTypography;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 140.w,
                      height: 140.w,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: customColors.surfaceLow,
                        border: Border.all(color: customColors.glassStroke, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.15),
                            blurRadius: 24.r,
                            spreadRadius: 2.r,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/expendly_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    AppSpacing.gapContainer,
                    Text(
                      'Expendly',
                      style: (textTheme.headlineLarge ?? const TextStyle()).copyWith(
                        color: colorScheme.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    AppSpacing.gapTight,
                    Text(
                      'MODERN FISCAL CORE',
                      style: customTypography.labelMediumMono.copyWith(
                        color: colorScheme.outline,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
