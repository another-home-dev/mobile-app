import 'dart:async';

import 'package:flutter/material.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/glass_card.dart';
import 'package:another_home/core/theme/glass_background.dart';
import 'package:another_home/core/theme/glass_badge.dart';
import 'package:another_home/core/theme/initials_avatar.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/dtos/accommodation_models.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/dashboard_summary.dart';
import 'modules/my_room_page.dart';
import 'modules/payment_page.dart';
import 'modules/visitor_page.dart';
import 'modules/complaint_page.dart';
import 'modules/notices_page.dart';
import 'modules/profile_page.dart';
import 'modules/alerts_page.dart';

class DashboardPage extends StatefulWidget {
  final User user;

  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final Future<StudentModel?> _studentFuture;
  late final Future<DashboardSummary> _summaryFuture;
  late Future<int> _unreadAlertsFuture;

  User get user => widget.user;

  @override
  void initState() {
    super.initState();
    _studentFuture = _loadStudent();
    // The summary reads the student id from storage, so wait until it's saved.
    _summaryFuture = _studentFuture.then((_) => ServiceLocator.instance.dashboardSummaryUseCase());
    _unreadAlertsFuture = _studentFuture.then((_) => _countUnreadAlerts());
  }

  Future<int> _countUnreadAlerts() async {
    try {
      final alerts = await ServiceLocator.instance.getAlertsUseCase();
      return alerts.where((a) => !a.isRead).length;
    } catch (_) {
      return 0;
    }
  }

  /// Re-fetches the unread count after the student visits the Alerts page,
  /// where opening an alert marks it as read.
  Future<void> _openAlerts() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertsPage()));
    if (mounted) setState(() => _unreadAlertsFuture = _countUnreadAlerts());
  }

  /// Resolves (and on first login creates) this student's record, and stores its
  /// id for the payment and complaint screens. Returns null if it can't be loaded.
  Future<StudentModel?> _loadStudent() async {
    try {
      final student = await ServiceLocator.instance.getCurrentStudentUseCase();
      // Registers this device for push (visitor approvals, resolved maintenance
      // tickets, payment reminders/receipts). Uses the same id the backend's
      // notifyUser() calls already target, so existing events reach this device
      // with no other change. No-op if Firebase isn't configured on this build.
      unawaited(ServiceLocator.instance.pushNotificationService.init(student.id));
      return student;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: GlassCard(
              padding: const EdgeInsets.all(18),
              borderRadius: BorderRadius.circular(28),
              blur: 24,
              color: AppColors.surface.withValues(alpha: 0.5),
              borderColor: AppColors.text.withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(color: AppColors.cardGlow.withValues(alpha: 0.3), blurRadius: 30, offset: const Offset(0, 18)),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Good morning,', style: TextStyle(color: AppColors.muted, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(
                              'Welcome, ${user.name} 👋',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRoomPage())),
                              child: FutureBuilder<StudentModel?>(
                                future: _studentFuture,
                                builder: (context, snapshot) {
                                  final student = snapshot.data;
                                  final String label;
                                  if (snapshot.connectionState != ConnectionState.done) {
                                    label = 'Loading room…';
                                  } else if (student == null) {
                                    label = 'Room details unavailable';
                                  } else {
                                    label = student.roomLabel;
                                  }
                                  return GlassBadge(
                                    label: label,
                                    color: student?.hasRoom == true ? AppColors.cyan : AppColors.muted,
                                    icon: Icons.location_on_outlined,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(user: user))),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.6), width: 1.5),
                            boxShadow: [
                              BoxShadow(color: AppColors.cyan.withValues(alpha: 0.3), blurRadius: 12),
                            ],
                          ),
                          child: InitialsAvatar(name: user.name),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FutureBuilder<DashboardSummary>(
                    future: _summaryFuture,
                    builder: (context, snapshot) {
                      final summary = snapshot.data;
                      final isLoading = snapshot.connectionState == ConnectionState.waiting;
                      return Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              icon: Icons.build_outlined,
                              iconColor: AppColors.orange,
                              title: 'Complaints',
                              mainText: isLoading ? '—' : (summary?.complaintsCount.toString() ?? '0'),
                              subText: 'Filed by you',
                              subTextColor: AppColors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              icon: Icons.credit_card_outlined,
                              iconColor: AppColors.red,
                              title: 'Payment',
                              mainText: isLoading ? '—' : (summary?.paymentStatus ?? 'N/A'),
                              subText: isLoading ? '' : (summary?.pendingAmount ?? ''),
                              subTextColor: AppColors.red,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  const Text('QUICK ACTIONS', style: TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 14),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildQuickActionBtn(context, Icons.meeting_room_outlined, 'My Room', AppColors.primary, const MyRoomPage())),
                          const SizedBox(width: 10),
                          Expanded(child: _buildQuickActionBtn(context, Icons.payment_outlined, 'Payment', AppColors.primary, const PaymentPage())),
                          const SizedBox(width: 10),
                          Expanded(child: _buildQuickActionBtn(context, Icons.people_outline, 'Visitor', AppColors.cyan, const VisitorPage())),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildQuickActionBtn(context, Icons.build_outlined, 'Maintenance', AppColors.orange, const ComplaintPage())),
                          const SizedBox(width: 10),
                          Expanded(child: _buildQuickActionBtn(context, Icons.notifications_none_outlined, 'Notices', AppColors.green, const NoticesPage())),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: GlassCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        color: AppColors.surfaceElevated.withValues(alpha: 0.85),
        borderColor: AppColors.text.withValues(alpha: 0.1),
        boxShadow: [
          BoxShadow(color: AppColors.cardGlow.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, -6)),
        ],
        child: SizedBox(
          height: 74,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                Icons.home_filled,
                'Home',
                isActive: true,
              ),
              _buildNavItem(
                context,
                Icons.meeting_room_outlined,
                'Rooms',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRoomPage())),
              ),
              _buildNavItem(
                context,
                Icons.credit_card_outlined,
                'Payments',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentPage())),
              ),
              FutureBuilder<int>(
                future: _unreadAlertsFuture,
                builder: (context, snapshot) => _buildNavItem(
                  context,
                  Icons.notifications_none_outlined,
                  'Alerts',
                  badgeCount: snapshot.data ?? 0,
                  onTap: _openAlerts,
                ),
              ),
              _buildNavItem(
                context,
                Icons.person_outline,
                'Profile',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(user: user))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String mainText,
    required String subText,
    required Color subTextColor,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(20),
      color: AppColors.surfaceElevated.withValues(alpha: 0.45),
      borderColor: AppColors.text.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlassCard(
                padding: const EdgeInsets.all(7),
                borderRadius: BorderRadius.circular(12),
                color: iconColor.withValues(alpha: 0.2),
                borderColor: iconColor.withValues(alpha: 0.3),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            mainText,
            style: const TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          GlassBadge(
            label: subText,
            color: subTextColor,
            fontSize: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBtn(BuildContext context, IconData icon, String label, Color bgColor, Widget targetScreen) {
    return GlassCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      borderRadius: BorderRadius.circular(18),
      color: bgColor.withValues(alpha: 0.15),
      borderColor: bgColor.withValues(alpha: 0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.text, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label, {
    bool isActive = false,
    int badgeCount = 0,
    VoidCallback? onTap,
  }) {
    final color = isActive ? AppColors.primary : AppColors.muted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 24),
                if (badgeCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                      child: Text(badgeCount.toString(), style: const TextStyle(color: AppColors.text, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
