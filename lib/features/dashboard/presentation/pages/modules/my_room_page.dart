import 'package:flutter/material.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/glass_card.dart';
import 'package:another_home/core/theme/glass_background.dart';
import 'package:another_home/core/theme/glass_badge.dart';

class MyRoomPage extends StatelessWidget {
  const MyRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Room'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: GlassBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                width: double.infinity,
                height: 200,
                borderRadius: BorderRadius.circular(24),
                color: AppColors.surfaceElevated.withValues(alpha: 0.4),
                borderColor: AppColors.text.withValues(alpha: 0.12),
                boxShadow: [
                  BoxShadow(color: AppColors.cardGlow.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
                ],
                padding: EdgeInsets.zero,
                child: Image.network(
                  'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=800&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: AppColors.surface, child: const Icon(Icons.hotel, size: 64, color: AppColors.primary));
                  },
                ),
              ),
              const SizedBox(height: 28),
              GlassCard(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                borderRadius: BorderRadius.circular(24),
                color: AppColors.surface.withValues(alpha: 0.55),
                borderColor: AppColors.text.withValues(alpha: 0.12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.cyan, size: 22),
                            SizedBox(width: 10),
                            Text('Room Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text, letterSpacing: 0.2)),
                          ],
                        ),
                        GlassBadge(label: 'Active', color: AppColors.green),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColors.text.withValues(alpha: 0.1), thickness: 1),
                    ),
                    _buildRoomDetailRow('Hostel', 'Hostel A'),
                    _buildRoomDetailRow('Block', 'Block B - Second floor'),
                    _buildRoomDetailRow('Room Number', '1-A'),
                    _buildRoomDetailRow('Bed Number', 'Bed 1'),
                    _buildRoomDetailRow('Room Type', 'Double Occupancy'),
                    _buildRoomDetailRow('Allocation Date', '01/03/2024'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: BorderRadius.circular(14),
        color: AppColors.surfaceElevated.withValues(alpha: 0.35),
        borderColor: AppColors.text.withValues(alpha: 0.06),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.muted)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.text)),
          ],
        ),
      ),
    );
  }
}
