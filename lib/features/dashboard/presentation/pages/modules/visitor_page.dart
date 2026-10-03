import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/initials_avatar.dart';
import 'package:another_home/core/theme/ui_components.dart';
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
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.danger;
      default:
        return AppColors.muted;
    }
  }

  Future<void> _openNew(BuildContext context) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVisitorPage()));
    if (result == true && context.mounted) {
      context.read<VisitorBloc>().add(const LoadVisitors());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visitors')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNew(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('New visitor', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocBuilder<VisitorBloc, VisitorState>(
        builder: (context, state) {
          if (state is VisitorLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VisitorFailure) {
            return MessageView.error(
              title: "Couldn't load visitors",
              message: state.message,
              onAction: () => context.read<VisitorBloc>().add(const LoadVisitors()),
            );
          } else if (state is VisitorLoadSuccess) {
            final visitors = state.visitors;
            int count(String s) => visitors.where((v) => v.status.toLowerCase() == s).length;

            return RefreshIndicator(
              onRefresh: () async => context.read<VisitorBloc>().add(const LoadVisitors()),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                children: [
                  Row(
                    children: [
                      _buildStat(count('approved'), 'Approved', AppColors.success),
                      const SizedBox(width: 10),
                      _buildStat(count('pending'), 'Pending', AppColors.warning),
                      const SizedBox(width: 10),
                      _buildStat(count('rejected'), 'Rejected', AppColors.danger),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle('Your requests'),
                  if (visitors.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: MessageView(
                        icon: Icons.group_outlined,
                        title: 'No visitor requests yet',
                        message: 'Expecting a guest? Tap "New visitor" to request a pass from your warden.',
                        color: AppColors.info,
                      ),
                    )
                  else
                    ...visitors.map(
                      (visitor) => _buildVisitorCard(
                        name: visitor.visitorName,
                        contact: visitor.visitorContact,
                        date: visitor.expectedDate,
                        time: visitor.visitTime.isEmpty ? 'Anytime' : visitor.visitTime,
                        purpose: visitor.relation,
                        status: visitor.status,
                        statusColor: _getStatusColor(visitor.status),
                      ),
                    ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStat(int count, String label, Color color) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorCard({
    required String name,
    required String contact,
    required String date,
    required String time,
    required String purpose,
    required String status,
    required Color statusColor,
  }) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              InitialsAvatar(name: name, radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: AppColors.ink, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    if (contact.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(contact, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                    ],
                  ],
                ),
              ),
              StatusPill(label: status, color: statusColor),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                _buildIconText(Icons.event_rounded, date),
                const SizedBox(width: 14),
                _buildIconText(Icons.schedule_rounded, time),
                const SizedBox(width: 14),
                Expanded(child: _buildIconText(Icons.label_outline_rounded, purpose.isEmpty ? '—' : purpose)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.muted, size: 16),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
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
  static const _purposes = {
    'Personal Visit': Icons.person_rounded,
    'Family Visit': Icons.family_restroom_rounded,
    'Academic Connection': Icons.school_rounded,
  };

  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  String _selectedPurpose = 'Personal Visit';
  DateTime _visitDate = DateTime.now();
  String? _roomId;

  @override
  void initState() {
    super.initState();
    ServiceLocator.instance.accommodationRepository.currentRoomId().then((id) {
      if (mounted) setState(() => _roomId = id);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: today.add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _visitDate = picked);
  }

  void _submit(BuildContext context) {
    final name = _nameController.text.trim();
    final contact = _contactController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter visitor name')));
      return;
    }
    if (contact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a contact number')));
      return;
    }
    if (_roomId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('You need a room assigned before requesting a visitor. Contact your hostel warden.')));
      return;
    }

    final d = _visitDate;
    final visitDate = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    context.read<VisitorBloc>().add(
      SubmitVisitorRequest(
        roomId: _roomId!,
        visitorName: name,
        visitorContact: contact,
        purpose: _selectedPurpose,
        visitDate: visitDate,
        visitTime: 'Anytime',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VisitorBloc(
        getVisitorsUseCase: ServiceLocator.instance.getVisitorsUseCase,
        requestVisitorUseCase: ServiceLocator.instance.requestVisitorUseCase,
      ),
      child: BlocConsumer<VisitorBloc, VisitorState>(
        listener: (context, state) {
          if (state is VisitorSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visitor pass requested successfully!')));
            Navigator.pop(context, true);
          } else if (state is VisitorFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit visitor request: ${state.message}')));
          }
        },
        builder: (context, state) {
          final isLoading = state is VisitorLoading;

          return Scaffold(
            appBar: AppBar(title: const Text('New visitor')),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 12 + MediaQuery.of(context).viewInsets.bottom),
                child: PrimaryButton(
                  label: 'Request pass',
                  icon: Icons.check_circle_rounded,
                  loading: isLoading,
                  onPressed: () => _submit(context),
                ),
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                const Text(
                  'Your warden reviews each request. You\'ll get an alert once it is approved.',
                  style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.45),
                ),
                const SizedBox(height: 20),
                const FieldLabel('Visitor full name'),
                TextField(
                  controller: _nameController,
                  enabled: !isLoading,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: 'Enter guest name', prefixIcon: Icon(Icons.person_outline_rounded)),
                ),
                const SizedBox(height: 18),
                const FieldLabel('Contact number'),
                TextField(
                  controller: _contactController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: 'Enter guest contact number', prefixIcon: Icon(Icons.phone_outlined)),
                ),
                const SizedBox(height: 18),
                const FieldLabel('Visit date'),
                AppCard(
                  onTap: isLoading ? null : _pickDate,
                  radius: 14,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded, color: AppColors.muted),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          formatShortDate(_visitDate),
                          style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                      const Text(
                        'Change',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const FieldLabel('Purpose of visit'),
                ..._purposes.entries.map((e) {
                  final selected = _selectedPurpose == e.key;
                  return AppCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    radius: 14,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    color: selected ? AppColors.primarySoft : AppColors.surface,
                    borderColor: selected ? AppColors.primary : AppColors.border,
                    onTap: isLoading ? null : () => setState(() => _selectedPurpose = e.key),
                    child: Row(
                      children: [
                        Icon(e.value, color: selected ? AppColors.primary : AppColors.muted),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            e.key,
                            style: TextStyle(color: AppColors.ink, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, fontSize: 15),
                          ),
                        ),
                        Icon(
                          selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                          color: selected ? AppColors.primary : AppColors.faint,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
