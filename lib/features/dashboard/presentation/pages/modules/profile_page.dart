import 'package:flutter/material.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/glass_card.dart';
import 'package:another_home/core/theme/glass_background.dart';
import 'package:another_home/core/theme/glass_badge.dart';
import 'package:another_home/core/theme/glass_button.dart';
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
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Student Profile'),
        centerTitle: true,
      ),
      body: GlassBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Avatar & Profile Header
              GlassCard(
                padding: const EdgeInsets.all(22),
                borderRadius: BorderRadius.circular(28),
                color: AppColors.surface.withValues(alpha: 0.55),
                borderColor: AppColors.cyan.withValues(alpha: 0.25),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.8), width: 2),
                        boxShadow: [
                          BoxShadow(color: AppColors.cyan.withValues(alpha: 0.35), blurRadius: 16),
                        ],
                      ),
                      child: InitialsAvatar(name: user.name, radius: 44),
                    ),
                    const SizedBox(height: 14),
                    FutureBuilder<StudentModel?>(
                      future: _studentFuture,
                      builder: (context, snapshot) {
                        final student = snapshot.data;
                        final loading = snapshot.connectionState != ConnectionState.done;
                        return Column(
                          children: [
                            Text(
                              student?.name ?? user.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: const TextStyle(color: AppColors.muted, fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                GlassBadge(
                                  label: loading ? 'Loading room…' : (student?.roomLabel ?? 'Room details unavailable'),
                                  color: student?.hasRoom == true ? AppColors.cyan : AppColors.muted,
                                  icon: Icons.roofing_outlined,
                                ),
                                if (!loading && student != null)
                                  GlassBadge(
                                    label: student.hasRoom ? 'Resident' : 'Awaiting room',
                                    color: student.hasRoom ? AppColors.green : AppColors.muted,
                                    icon: student.hasRoom ? Icons.check_circle_outline : Icons.hourglass_empty,
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Academic Information Card
              FutureBuilder<StudentModel?>(
                future: _studentFuture,
                builder: (context, snapshot) {
                  final student = snapshot.data;
                  return Column(
                    children: [
                      _buildSectionHeader('ACADEMIC & HOSTEL DETAILS'),
                      const SizedBox(height: 10),
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(24),
                        color: AppColors.surfaceElevated.withValues(alpha: 0.45),
                        borderColor: AppColors.text.withValues(alpha: 0.08),
                        child: Column(
                          children: [
                            _buildInfoRow(Icons.badge_outlined, 'Student ID', student?.studentCode ?? 'Not registered yet'),
                            _buildInfoRow(Icons.school_outlined, 'Faculty', _orNotSet(student?.faculty)),
                            _buildInfoRow(Icons.menu_book_outlined, 'Degree Program', _orNotSet(student?.degreeProgram)),
                            _buildInfoRow(Icons.calendar_today_outlined, 'Academic Year', _orNotSet(student?.academicYear)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionHeader('CONTACT'),
                      const SizedBox(height: 10),
                      GlassCard(
                        padding: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(24),
                        color: AppColors.surfaceElevated.withValues(alpha: 0.45),
                        borderColor: AppColors.text.withValues(alpha: 0.08),
                        child: Column(
                          children: [
                            _buildInfoRow(Icons.phone_outlined, 'Mobile Number', _orNotSet(student?.contact)),
                            _buildInfoRow(Icons.credit_card_outlined, 'National NIC', _orNotSet(student?.nic)),
                            _buildInfoRow(Icons.home_outlined, 'Home Address', _orNotSet(student?.address)),
                            _buildInfoRow(Icons.family_restroom_outlined, 'Guardian', _orNotSet(student?.guardianName)),
                            _buildInfoRow(Icons.contact_phone_outlined, 'Guardian Contact', _orNotSet(student?.guardianContact)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 8),

              FutureBuilder<StudentModel?>(
                future: _studentFuture,
                builder: (context, snapshot) {
                  final student = snapshot.data;
                  if (student == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassButton(
                      onPressed: () => _showEditSheet(student),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_outlined, color: AppColors.text, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Edit Profile',
                            style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Log Out Button
              GlassButton(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                color: AppColors.red,
                borderColor: AppColors.red.withValues(alpha: 0.5),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: AppColors.text, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
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
    final controllers = {
      for (final e in fields.entries) e.key: TextEditingController(text: e.value.$2 ?? ''),
    };
    final formKey = GlobalKey<FormState>();
    var saving = false;

    final updated = await showModalBottomSheet<StudentModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  for (final e in fields.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextFormField(
                        controller: controllers[e.key],
                        keyboardType: e.value.$3,
                        style: const TextStyle(color: AppColors.text),
                        decoration: InputDecoration(
                          labelText: e.value.$1,
                          labelStyle: const TextStyle(color: AppColors.muted),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: e.key == 'name'
                            ? (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null
                            : null,
                      ),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            // Only send what actually changed.
                            final changes = <String, String>{
                              for (final e in fields.entries)
                                if (controllers[e.key]!.text.trim() != (e.value.$2 ?? '').trim())
                                  e.key: controllers[e.key]!.text.trim(),
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
                                ScaffoldMessenger.of(sheetContext).showSnackBar(
                                  SnackBar(content: Text('Could not save your profile: $e')),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      saving ? 'Saving…' : 'Save Changes',
                      style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
                    ),
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

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.cyan.withValues(alpha: 0.15),
            borderColor: AppColors.cyan.withValues(alpha: 0.3),
            child: Icon(icon, color: AppColors.cyan, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Log Out', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out of Another Home?', style: TextStyle(color: AppColors.muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ServiceLocator.instance.logoutUseCase();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Log Out', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
