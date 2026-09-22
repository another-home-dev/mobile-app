import 'package:flutter/material.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/glass_card.dart';
import 'package:another_home/core/theme/glass_background.dart';
import 'package:another_home/core/theme/glass_badge.dart';
import 'package:another_home/core/di/service_locator.dart';
import 'package:another_home/core/network/dtos/operations_models.dart';

class NoticesPage extends StatefulWidget {
  const NoticesPage({super.key});

  @override
  State<NoticesPage> createState() => _NoticesPageState();
}

class _NoticesPageState extends State<NoticesPage> {
  late final Future<List<NoticeModel>> _noticesFuture;

  @override
  void initState() {
    super.initState();
    _noticesFuture = ServiceLocator.instance.getNoticesUseCase();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

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
        child: FutureBuilder<List<NoticeModel>>(
          future: _noticesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load notices: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.red),
                ),
              );
            }
            final notices = snapshot.data ?? [];
            if (notices.isEmpty) {
              return const Center(
                child: Text(
                  'No notices published yet.',
                  style: TextStyle(color: AppColors.muted),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(24),
              children: notices
                  .map((notice) => _buildNoticeItem(notice))
                  .toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoticeItem(NoticeModel notice) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      color: AppColors.surface.withValues(alpha: 0.5),
      borderColor: AppColors.primary.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GlassBadge(label: notice.publishedBy, color: AppColors.cyan),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Text(_formatDate(notice.publishedAt), style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            notice.title,
            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            notice.content,
            style: const TextStyle(color: AppColors.muted, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
