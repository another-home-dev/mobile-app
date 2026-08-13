import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class GlassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? color;
  final Color? borderColor;
  final Color? textColor;
  final double height;
  final double? width;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? boxShadow;

  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.borderColor,
    this.textColor,
    this.height = 54,
    this.width,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);
    final buttonColor = color ?? AppColors.primary;
    final border = borderColor ?? AppColors.text.withValues(alpha: 0.2);

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: buttonColor.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: radius as BorderRadius,
              splashColor: AppColors.text.withValues(alpha: 0.15),
              highlightColor: AppColors.text.withValues(alpha: 0.08),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(color: border, width: 1.2),
                  gradient: LinearGradient(
                    colors: [
                      buttonColor.withValues(alpha: 0.85),
                      buttonColor.withValues(alpha: 0.65),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: textColor ?? AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
