import 'package:flutter/material.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/glass_card.dart';
import 'package:another_home/core/theme/glass_background.dart';
import 'package:another_home/core/theme/glass_badge.dart';
import 'new_complaint_page.dart';

class ComplaintPage extends StatelessWidget {
  const ComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Maintenance'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GlassCard(
              width: 40,
              height: 40,
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primary.withValues(alpha: 0.25),
              borderColor: AppColors.primary.withValues(alpha: 0.4),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewComplaintPage()),
                );
              },
              child: const Icon(Icons.add, color: AppColors.text, size: 22),
            ),
          ),
        ],
      ),
      body: GlassBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildComplaintCard(
                      title: 'Ceiling fan not working',
                      status: 'In Progress',
                      badgeColor: AppColors.red,
                      note: '18 Jul 2026',
                      icon: Icons.lightbulb_outline,
                    ),
                    _buildComplaintCard(
                      title: 'Leaking pipe under sink',
                      status: 'Assigned',
                      badgeColor: AppColors.orange,
                      note: '15 Jul 2026',
                      icon: Icons.water_drop_outlined,
                    ),
                    _buildComplaintCard(
                      title: 'Broken study chair',
                      status: 'Completed',
                      badgeColor: AppColors.green,
                      note: '10 Jul 2026',
                      icon: Icons.chair_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintCard({
    required String title,
    required String status,
    required Color badgeColor,
    required String note,
    required IconData icon,
  }) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(20),
      color: AppColors.surface.withValues(alpha: 0.5),
      borderColor: AppColors.text.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlassCard(
                width: 44,
                height: 44,
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(14),
                color: badgeColor.withValues(alpha: 0.2),
                borderColor: badgeColor.withValues(alpha: 0.4),
                child: Icon(icon, color: badgeColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title, style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              GlassBadge(label: status, color: badgeColor),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.access_time_outlined, color: AppColors.muted, size: 14),
              const SizedBox(width: 6),
              Text(note, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
