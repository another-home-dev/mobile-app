import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/ui_components.dart';
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
        return AppColors.success;
      case 'assigned':
        return AppColors.info;
      case 'in progress':
        return AppColors.primary;
      default:
        return AppColors.warning;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'plumbing':
        return Icons.water_drop_rounded;
      case 'electrical':
        return Icons.bolt_rounded;
      case 'furniture':
        return Icons.chair_rounded;
      default:
        return Icons.handyman_rounded;
    }
  }

  Future<void> _openNew(BuildContext context) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const NewComplaintPage()));
    if (result == true && context.mounted) {
      context.read<ComplaintBloc>().add(const LoadComplaints());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNew(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Report an issue', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocBuilder<ComplaintBloc, ComplaintState>(
        builder: (context, state) {
          if (state is ComplaintLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ComplaintFailure) {
            return MessageView.error(
              title: "Couldn't load your requests",
              message: state.message,
              onAction: () => context.read<ComplaintBloc>().add(const LoadComplaints()),
            );
          } else if (state is ComplaintLoadSuccess) {
            final incidents = state.incidents;
            if (incidents.isEmpty) {
              return const MessageView(
                icon: Icons.handyman_outlined,
                title: 'No requests yet',
                message: 'Something broken in your room? Tap "Report an issue" and the maintenance team will be notified.',
                color: AppColors.warning,
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<ComplaintBloc>().add(const LoadComplaints()),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                itemCount: incidents.length,
                itemBuilder: (context, index) {
                  final incident = incidents[index];
                  return _buildComplaintCard(
                    title: incident.title.isNotEmpty ? incident.title : incident.description,
                    category: incident.category,
                    status: incident.status,
                    color: _getStatusColor(incident.status),
                    date: formatShortDate(incident.createdAt),
                    icon: _getCategoryIcon(incident.category),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildComplaintCard({
    required String title,
    required String category,
    required String status,
    required Color color,
    required String date,
    required IconData icon,
  }) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconTile(icon: icon, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.ink, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${category.isEmpty ? 'General' : category[0].toUpperCase() + category.substring(1)} · $date',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusPill(label: status, color: color),
        ],
      ),
    );
  }
}
