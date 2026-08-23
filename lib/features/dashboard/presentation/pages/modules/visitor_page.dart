import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/glass_card.dart';
import 'package:another_home/core/theme/glass_button.dart';
import 'package:another_home/core/theme/glass_background.dart';
import 'package:another_home/core/theme/glass_badge.dart';
import 'package:another_home/core/di/service_locator.dart';
import '../../../../operations/presentation/bloc/visitor/visitor_bloc.dart';
import '../../../../operations/presentation/bloc/visitor/visitor_event.dart';
import '../../../../operations/presentation/bloc/visitor/visitor_state.dart';

class VisitorPage extends StatelessWidget {
  const VisitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VisitorBloc(
        getVisitorsUseCase: ServiceLocator.instance.getVisitorsUseCase,
        requestVisitorUseCase: ServiceLocator.instance.requestVisitorUseCase,
      )..add(const LoadVisitors()),
      child: const VisitorView(),
    );
  }
}

class VisitorView extends StatelessWidget {
  const VisitorView({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.green;
      case 'pending':
        return AppColors.primary;
      case 'rejected':
        return AppColors.red;
      default:
        return AppColors.muted;
    }
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
        title: const Text('Visitors'),
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
                  color: AppColors.cyan.withValues(alpha: 0.25),
                  borderColor: AppColors.cyan.withValues(alpha: 0.4),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddVisitorPage()),
                    );
                    if (result == true && context.mounted) {
                      context.read<VisitorBloc>().add(const LoadVisitors());
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
        child: SafeArea(
          child: BlocBuilder<VisitorBloc, VisitorState>(
            builder: (context, state) {
              if (state is VisitorLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.cyan),
                );
              } else if (state is VisitorFailure) {
                return Center(
                  child: Text(
                    'Failed to load visitors: ${state.message}',
                    style: const TextStyle(color: AppColors.red),
                  ),
                );
              } else if (state is VisitorLoadSuccess) {
                final visitors = state.visitors;

                final approvedCount = visitors.where((v) => v.status.toLowerCase() == 'approved').length;
                final pendingCount = visitors.where((v) => v.status.toLowerCase() == 'pending').length;
                final rejectedCount = visitors.where((v) => v.status.toLowerCase() == 'rejected').length;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(child: _buildStatCard(approvedCount.toString(), 'Approved', AppColors.green)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard(pendingCount.toString(), 'Pending', AppColors.orange)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard(rejectedCount.toString(), 'Rejected', AppColors.red)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: visitors.isEmpty
                          ? const Center(
                              child: Text(
                                'No visitor requests yet.',
                                style: TextStyle(color: AppColors.muted),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              itemCount: visitors.length,
                              itemBuilder: (context, index) {
                                final visitor = visitors[index];
                                
                                // Try to extract NIC and Purpose from relation field if structured
                                String nic = 'N/A';
                                String purpose = visitor.relation;
                                if (visitor.relation.contains('NIC:')) {
                                  final parts = visitor.relation.split('|');
                                  if (parts.length == 2) {
                                    nic = parts[0].replaceAll('NIC:', '').trim();
                                    purpose = parts[1].replaceAll('Purpose:', '').trim();
                                  }
                                }

                                return _buildVisitorCard(
                                  name: visitor.visitorName,
                                  id: nic,
                                  date: visitor.expectedDate,
                                  time: 'Anytime',
                                  purpose: purpose,
                                  status: visitor.status,
                                  statusColor: _getStatusColor(visitor.status),
                                );
                              },
                            ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String count, String label, Color countColor) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      borderRadius: BorderRadius.circular(16),
      color: AppColors.surfaceElevated.withValues(alpha: 0.4),
      borderColor: countColor.withValues(alpha: 0.3),
      child: Column(
        children: [
          Text(count, style: TextStyle(color: countColor, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildVisitorCard({
    required String name,
    required String id,
    required String date,
    required String time,
    required String purpose,
    required String status,
    required Color statusColor,
  }) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      color: AppColors.surface.withValues(alpha: 0.5),
      borderColor: AppColors.text.withValues(alpha: 0.08),
      child: Column(
        children: [
          Row(
            children: [
              GlassCard(
                width: 48,
                height: 48,
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(24),
                color: AppColors.overlay,
                borderColor: AppColors.text.withValues(alpha: 0.1),
                child: const Icon(Icons.person_outline, color: AppColors.cyan, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('NIC: $id', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                  ],
                ),
              ),
              GlassBadge(label: status, color: statusColor),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconText(Icons.calendar_today_outlined, date),
              _buildIconText(Icons.access_time_outlined, time),
              _buildIconText(Icons.description_outlined, purpose),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.muted, size: 14),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      ],
    );
  }
}

class AddVisitorPage extends StatefulWidget {
  const AddVisitorPage({super.key});

  @override
  State<AddVisitorPage> createState() => _AddVisitorPageState();
}

class _AddVisitorPageState extends State<AddVisitorPage> {
  final _nameController = TextEditingController();
  final _nicController = TextEditingController();
  String _selectedPurpose = 'Personal Visit';

  @override
  void dispose() {
    _nameController.dispose();
    _nicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VisitorBloc(
        getVisitorsUseCase: ServiceLocator.instance.getVisitorsUseCase,
        requestVisitorUseCase: ServiceLocator.instance.requestVisitorUseCase,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.text),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Add New Visitor'),
        ),
        body: GlassBackground(
          child: BlocConsumer<VisitorBloc, VisitorState>(
            listener: (context, state) {
              if (state is VisitorSubmitSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Visitor pass requested successfully!')),
                );
                Navigator.pop(context, true);
              } else if (state is VisitorFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to submit visitor request: ${state.message}')),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is VisitorLoading;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Visitor details', style: TextStyle(color: AppColors.muted, fontSize: 14)),
                    const SizedBox(height: 24),
                    _buildLabel('Visitor Full Name'),
                    _buildTextField(_nameController, 'Enter guest name', enabled: !isLoading),
                    const SizedBox(height: 24),
                    _buildLabel('NIC'),
                    _buildTextField(_nicController, 'Enter guest identification number', enabled: !isLoading),
                    const SizedBox(height: 24),
                    _buildLabel('Visit Purpose'),
                    _buildDropdownField(enabled: !isLoading),
                    const SizedBox(height: 32),
                    if (isLoading)
                      const Center(
                        child: CircularProgressIndicator(color: AppColors.cyan),
                      )
                    else
                      GlassButton(
                        onPressed: () {
                          final name = _nameController.text.trim();
                          final nic = _nicController.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter visitor name')),
                            );
                            return;
                          }
                          if (nic.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter NIC')),
                            );
                            return;
                          }

                          // Format the relation parameter with NIC & Purpose
                          final relation = 'NIC: $nic | Purpose: $_selectedPurpose';
                          
                          // Format today's date as YYYY-MM-DD
                          final now = DateTime.now();
                          final expectedDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

                          context.read<VisitorBloc>().add(
                                SubmitVisitorRequest(
                                  studentId: '230001A', // Map to student Id
                                  visitorName: name,
                                  relation: relation,
                                  expectedDate: expectedDate,
                                ),
                              );
                        },
                        color: AppColors.primary,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Submit details', style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.check_circle_outline, size: 18),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: const TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {required bool enabled}) {
    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      color: AppColors.surfaceElevated.withValues(alpha: 0.4),
      borderColor: AppColors.primary.withValues(alpha: 0.2),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: const TextStyle(color: AppColors.text),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.muted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField({required bool enabled}) {
    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      color: AppColors.surfaceElevated.withValues(alpha: 0.4),
      borderColor: AppColors.primary.withValues(alpha: 0.2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedPurpose,
        dropdownColor: AppColors.surfaceElevated,
        decoration: const InputDecoration(border: InputBorder.none),
        hint: const Text('Select purpose', style: TextStyle(color: AppColors.muted)),
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.cyan),
        style: const TextStyle(color: AppColors.text),
        items: ['Personal Visit', 'Family Visit', 'Academic Connection']
            .map((value) => DropdownMenuItem<String>(value: value, child: Text(value)))
            .toList(),
        onChanged: enabled
            ? (value) {
                if (value != null) {
                  setState(() {
                    _selectedPurpose = value;
                  });
                }
              }
            : null,
      ),
    );
  }
}
