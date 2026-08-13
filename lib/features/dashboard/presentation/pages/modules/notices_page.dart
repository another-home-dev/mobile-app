import 'package:flutter/material.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/glass_card.dart';
import 'package:another_home/core/theme/glass_background.dart';
import 'package:another_home/core/theme/glass_badge.dart';

class NoticesPage extends StatelessWidget {
  const NoticesPage({super.key});

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
        title: const Text('Notices'),
        centerTitle: true,
      ),
      body: GlassBackground(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildNoticeItem(
              'Urgent',
              AppColors.red,
              'Electricity supply interruption',
              'Electricity will be interrupted on 30th June 2026 from 8.00am to 5.00pm',
              '17 June 2026',
            ),
            _buildNoticeItem(
              'General',
              AppColors.cyan,
              'Dengue Advisory',
              'Take preventive methods to prevent from dengue - Use mosquito repellent',
              '14 June 2026',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeItem(String category, Color categoryColor, String title, String body, String date) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      color: AppColors.surface.withValues(alpha: 0.5),
      borderColor: categoryColor.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GlassBadge(label: category, color: categoryColor),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Text(date, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(color: AppColors.muted, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
