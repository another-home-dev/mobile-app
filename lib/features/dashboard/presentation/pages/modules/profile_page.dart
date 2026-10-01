import 'package:flutter/material.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/ui_components.dart';
import 'package:another_home/core/theme/initials_avatar.dart';
import 'package:another_home/features/auth/domain/entities/user.dart';
import 'package:another_home/features/auth/presentation/pages/login_page.dart';
import 'package:another_home/core/di/service_locator.dart';
import 'package:another_home/core/network/dtos/accommodation_models.dart';
import 'package:another_home/core/network/api_exceptions.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<StudentModel?> _studentFuture;

  User get user => widget.user;

  @override
  void initState() {
    super.initState();
    _studentFuture = _loadStudent();
  }

  Future<StudentModel?> _loadStudent() async {
    try {
      return await ServiceLocator.instance.getCurrentStudentUseCase();
    } on NotFoundException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<StudentModel?>(
        future: _studentFuture,
        builder: (context, snapshot) {
          final student = snapshot.data;
          final loading = snapshot.connectionState != ConnectionState.done;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            children: [
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        InitialsAvatar(name: student?.name ?? user.name, radius: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student?.name ?? user.name,
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppColors.muted, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Flexible(
                          child: StatusPill(
                            label: loading ? 'Loading room…' : (student?.roomLabel ?? 'Room details unavailable'),
                            color: student?.hasRoom == true ? AppColors.primary : AppColors.muted,
                            icon: Icons.bed_rounded,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!loading && student != null)
                          StatusPill(
                            label: student.hasRoom ? 'Resident' : 'Awaiting room',
                            color: student.hasRoom ? AppColors.success : AppColors.warning,
                            icon: student.hasRoom ? Icons.verified_rounded : Icons.hourglass_empty_rounded,
                          ),
                      ],
                    ),
                    if (student != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showEditSheet(student),
                          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 46)),
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: const Text('Edit profile'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionTitle('Academic details'),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Column(
                  children: [
                    InfoRow(icon: Icons.badge_outlined, label: 'Student ID', value: student?.studentCode ?? 'Not registered yet'),
                    InfoRow(icon: Icons.account_balance_outlined, label: 'Faculty', value: _orNotSet(student?.faculty)),
                    InfoRow(icon: Icons.menu_book_outlined, label: 'Degree', value: _orNotSet(student?.degreeProgram)),
                    InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Academic year',
                      value: _orNotSet(student?.academicYear),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionTitle('Contact'),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                child: Column(
                  children: [
                    InfoRow(icon: Icons.phone_outlined, label: 'Mobile', value: _orNotSet(student?.contact)),
                    InfoRow(icon: Icons.credit_card_outlined, label: 'NIC', value: _orNotSet(student?.nic)),
                    InfoRow(icon: Icons.home_outlined, label: 'Address', value: _orNotSet(student?.address)),
                    InfoRow(icon: Icons.family_restroom_outlined, label: 'Guardian', value: _orNotSet(student?.guardianName)),
                    InfoRow(
                      icon: Icons.contact_phone_outlined,
                      label: 'Guardian contact',
                      value: _orNotSet(student?.guardianContact),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text('Log out'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _orNotSet(String? value) => (value == null || value.trim().isEmpty) ? 'Not set' : value;

  Future<void> _showEditSheet(StudentModel student) async {
    final fields = <String, (String label, String? value, TextInputType type)>{
      'name': ('Full Name', student.name, TextInputType.name),
      'contact': ('Mobile Number', student.contact, TextInputType.phone),
      'nic': ('National NIC', student.nic, TextInputType.text),
      'faculty': ('Faculty', student.faculty, TextInputType.text),
      'degreeProgram': ('Degree Program', student.degreeProgram, TextInputType.text),
      'academicYear': ('Academic Year', student.academicYear, TextInputType.text),
      'address': ('Home Address', student.address, TextInputType.streetAddress),
      'guardianName': ('Guardian Name', student.guardianName, TextInputType.name),
      'guardianContact': ('Guardian Contact', student.guardianContact, TextInputType.phone),
    };
    final controllers = {for (final e in fields.entries) e.key: TextEditingController(text: e.value.$2 ?? '')};
    final formKey = GlobalKey<FormState>();
    var saving = false;

    final updated = await showModalBottomSheet<StudentModel>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(color: AppColors.ink, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  for (final e in fields.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextFormField(
                        controller: controllers[e.key],
                        keyboardType: e.value.$3,
                        decoration: InputDecoration(labelText: e.value.$1),
                        validator: e.key == 'name' ? (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null : null,
                      ),
                    ),
                  const SizedBox(height: 8),
                  PrimaryButton(
                    label: 'Save changes',
                    loading: saving,
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      // Only send what actually changed.
                      final changes = <String, String>{
                        for (final e in fields.entries)
                          if (controllers[e.key]!.text.trim() != (e.value.$2 ?? '').trim()) e.key: controllers[e.key]!.text.trim(),
                      };
                      if (changes.isEmpty) {
                        Navigator.pop(sheetContext);
                        return;
                      }
                      setSheetState(() => saving = true);
                      try {
                        final result = await ServiceLocator.instance.updateStudentProfileUseCase(changes);
                        if (sheetContext.mounted) Navigator.pop(sheetContext, result);
                      } catch (e) {
                        setSheetState(() => saving = false);
                        if (sheetContext.mounted) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(SnackBar(content: Text('Could not save your profile: $e')));
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // The controllers aren't disposed here: the sheet is still animating closed and
    // its text fields still reference them. They're garbage-collected with it.
    if (updated != null && mounted) {
      setState(() => _studentFuture = Future.value(updated));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out of Another Home?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ServiceLocator.instance.logoutUseCase();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger, minimumSize: const Size(0, 44)),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}
