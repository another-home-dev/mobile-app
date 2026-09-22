import 'package:flutter/material.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/glass_card.dart';
import 'package:another_home/core/theme/glass_background.dart';
import 'package:another_home/core/theme/glass_badge.dart';
import 'package:another_home/core/theme/glass_button.dart';
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
  late final Future<StudentModel?> _studentFuture;

  User get user => widget.user;

  @override
  void initState() {
    super.initState();
    _studentFuture = _loadStudent();
  }

  Future<StudentModel?> _loadStudent() async {
    try {
      return await ServiceLocator.instance.accommodationApiService.getCurrentStudent();
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
                    Stack(
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
                          child: const CircleAvatar(
                            radius: 44,
                            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?auto=format&fit=crop&w=200&q=80'),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GlassCard(
                            padding: const EdgeInsets.all(6),
                            borderRadius: BorderRadius.circular(16),
                            color: AppColors.primary,
                            borderColor: AppColors.text.withValues(alpha: 0.2),
                            child: const Icon(Icons.camera_alt_outlined, color: AppColors.text, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user.name,
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GlassBadge(label: 'Room 1-A • Hostel A', color: AppColors.cyan, icon: Icons.roofing_outlined),
                        SizedBox(width: 8),
                        GlassBadge(label: 'Resident', color: AppColors.green, icon: Icons.check_circle_outline),
                      ],
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
                            _buildInfoRow(Icons.school_outlined, 'Faculty', student?.faculty ?? 'Not set'),
                            _buildInfoRow(Icons.menu_book_outlined, 'Degree Program', student?.degreeProgram ?? 'Not set'),
                            _buildInfoRow(Icons.calendar_today_outlined, 'Academic Year', student?.academicYear ?? 'Not set'),
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
                            _buildInfoRow(Icons.phone_outlined, 'Mobile Number', student?.contact ?? 'Not available'),
                            _buildInfoRow(Icons.credit_card_outlined, 'National NIC', student?.nic ?? 'Not set'),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 8),

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
              await ServiceLocator.instance.authApiService.logout();
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
