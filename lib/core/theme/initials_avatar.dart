import 'package:flutter/material.dart';
import 'app_colors.dart';

/// A circle showing the person's initials, e.g. "Kasun Perera" -> "KP".
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double radius;

  const InitialsAvatar({super.key, required this.name, this.radius = 24});

  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'[\s._@-]+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.35),
      child: Text(
        initialsOf(name),
        style: TextStyle(color: AppColors.text, fontSize: radius * 0.7, fontWeight: FontWeight.bold),
      ),
    );
  }
}
