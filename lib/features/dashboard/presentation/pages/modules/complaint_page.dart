import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/glass_card.dart';
import 'package:another_home/core/theme/glass_background.dart';
import 'package:another_home/core/theme/glass_badge.dart';
import 'package:another_home/core/di/service_locator.dart';
import '../../../../operations/presentation/bloc/complaint/complaint_bloc.dart';
import '../../../../operations/presentation/bloc/complaint/complaint_event.dart';
import '../../../../operations/presentation/bloc/complaint/complaint_state.dart';
import 'new_complaint_page.dart';

class ComplaintPage extends StatelessWidget {
  const ComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ComplaintBloc(
        getIncidentsUseCase: ServiceLocator.instance.getIncidentsUseCase,
        reportIncidentUseCase: ServiceLocator.instance.reportIncidentUseCase,
      )..add(const LoadComplaints()),
      child: const ComplaintView(),
    );
  }
}

class ComplaintView extends StatelessWidget {
  const ComplaintView({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'completed':
        return AppColors.green;
      case 'assigned':
        return AppColors.orange;
      case 'in progress':
        return AppColors.cyan;
      default:
        return AppColors.red;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'plumbing':
        return Icons.water_drop_outlined;
      case 'electrical':
        return Icons.lightbulb_outline;
      case 'furniture':
        return Icons.chair_outlined;
      default:
        return Icons.build_outlined;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
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
        title: const Text('Maintenance'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Builder(
              builder: (context) {
                return GlassCard(
                  width: 40,
                  height: 40,
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primary.withValues(alpha: 0.25),
                  borderColor: AppColors.primary.withValues(alpha: 0.4),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NewComplaintPage()),
                    );
                    if (result == true && context.mounted) {
                      context.read<ComplaintBloc>().add(const LoadComplaints());
                    }
                  },
                  child: const Icon(Icons.add, color: AppColors.text, size: 22),
                );
              }
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
                child: BlocBuilder<ComplaintBloc, ComplaintState>(
                  builder: (context, state) {
                    if (state is ComplaintLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    } else if (state is ComplaintFailure) {
                      return Center(
                        child: Text(
                          'Failed to load complaints: ${state.message}',
                          style: const TextStyle(color: AppColors.red),
                        ),
                      );
                    } else if (state is ComplaintLoadSuccess) {
                      final incidents = state.incidents;
                      if (incidents.isEmpty) {
                        return const Center(
                          child: Text(
                            'No complaints logged yet.',
                            style: TextStyle(color: AppColors.muted),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: incidents.length,
                        itemBuilder: (context, index) {
                          final incident = incidents[index];
                          return _buildComplaintCard(
                            title: incident.title.isNotEmpty ? incident.title : incident.description,
                            status: incident.status,
                            badgeColor: _getStatusColor(incident.status),
                            note: _formatDate(incident.createdAt),
                            icon: _getCategoryIcon(incident.category),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
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
