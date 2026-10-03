import 'package:flutter/material.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/ui_components.dart';
import 'package:another_home/core/di/service_locator.dart';
import 'package:another_home/core/network/dtos/operations_models.dart';

class NoticesPage extends StatefulWidget {
  const NoticesPage({super.key});

  @override
  State<NoticesPage> createState() => _NoticesPageState();
}

class _NoticesPageState extends State<NoticesPage> {
  late Future<List<NoticeModel>> _noticesFuture;

  @override
  void initState() {
    super.initState();
    _noticesFuture = ServiceLocator.instance.getNoticesUseCase();
  }

  void _retry() => setState(() => _noticesFuture = ServiceLocator.instance.getNoticesUseCase());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notices')),
      body: FutureBuilder<List<NoticeModel>>(
        future: _noticesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return MessageView.error(title: "Couldn't load notices", message: '${snapshot.error}', onAction: _retry);
          }
          final notices = snapshot.data ?? [];
          if (notices.isEmpty) {
            return const MessageView(
              icon: Icons.campaign_outlined,
              title: 'No notices yet',
              message: 'Announcements from your hostel warden will appear here.',
              color: AppColors.success,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            itemCount: notices.length,
            itemBuilder: (context, i) => _buildNotice(notices[i]),
          );
        },
      ),
    );
  }

  Widget _buildNotice(NoticeModel notice) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconTile(icon: Icons.campaign_rounded, color: AppColors.success, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  notice.publishedBy,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                formatShortDate(notice.publishedAt),
                style: const TextStyle(color: AppColors.faint, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            notice.title,
            style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(notice.content, style: const TextStyle(color: AppColors.text, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
