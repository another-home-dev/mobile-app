import 'package:flutter/material.dart';
import 'app_colors.dart';

class GlassBackground extends StatelessWidget {
  final Widget child;

  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main base background
        Positioned.fill(
          child: Container(
            color: AppColors.bg,
          ),
        ),
        // Ambient Glowing Orb 1 - Top Left (Primary Deep / Cyan)
        Positioned(
          top: -80,
          left: -60,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.cyan.withValues(alpha: 0.22),
                  AppColors.primaryDeep.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
                radius: 0.7,
              ),
            ),
          ),
        ),
        // Ambient Glowing Orb 2 - Top Right (Primary Accent Blue)
        Positioned(
          top: 100,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.25),
                  AppColors.primaryDeep.withValues(alpha: 0.10),
                  Colors.transparent,
                ],
                radius: 0.7,
              ),
            ),
          ),
        ),
        // Ambient Glowing Orb 3 - Bottom Center (Deep Blue / Purple glow)
        Positioned(
          bottom: -100,
          left: 40,
          child: Container(
            width: 360,
            height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryDeep.withValues(alpha: 0.4),
                  AppColors.cyan.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
                radius: 0.8,
              ),
            ),
          ),
        ),
        // Foreground Content
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}
