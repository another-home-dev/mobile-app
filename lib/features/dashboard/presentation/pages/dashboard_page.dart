import 'dart:async';

import 'package:flutter/material.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/initials_avatar.dart';
import 'package:another_home/core/theme/ui_components.dart';

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

/// Signed-in shell: a bottom navigation bar switching between Home, Room,
/// Payments, Alerts and Profile. Visitors, Maintenance and Notices open as
/// pushed screens from Home.
class DashboardPage extends StatefulWidget {
  final User user;

  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _homeTab = 0, _roomTab = 1, _paymentsTab = 2, _alertsTab = 3, _profileTab = 4;

  int _tab = _homeTab;
  late Future<StudentModel?> _studentFuture;
  late Future<DashboardSummary> _summaryFuture;
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

  void _selectTab(int index) {
    setState(() {
      // Opening an alert marks it read, so recount once the student leaves Alerts.
      if (_tab == _alertsTab && index != _alertsTab) {
        _unreadAlertsFuture = _countUnreadAlerts();
      }
      if (index == _homeTab && _tab != _homeTab) {
        _summaryFuture = ServiceLocator.instance.dashboardSummaryUseCase();
      }
      _tab = index;
    });
  }

  Future<void> _push(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) setState(() => _summaryFuture = ServiceLocator.instance.dashboardSummaryUseCase());
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = switch (_tab) {
      _roomTab => const MyRoomPage(),
      _paymentsTab => const PaymentPage(),
      _alertsTab => const AlertsPage(),
      _profileTab => ProfilePage(user: user),
      _ => _buildHome(),
    };

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: body,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: FutureBuilder<int>(
          future: _unreadAlertsFuture,
          builder: (context, snapshot) {
            final unread = snapshot.data ?? 0;
            return NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: _selectTab,
              destinations: [
                const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
                const NavigationDestination(icon: Icon(Icons.bed_outlined), selectedIcon: Icon(Icons.bed_rounded), label: 'Room'),
                const NavigationDestination(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: Icon(Icons.account_balance_wallet_rounded),
                  label: 'Payments',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: unread > 0,
                    label: Text('$unread'),
                    backgroundColor: AppColors.danger,
                    child: const Icon(Icons.notifications_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: unread > 0,
                    label: Text('$unread'),
                    backgroundColor: AppColors.danger,
                    child: const Icon(Icons.notifications_rounded),
                  ),
                  label: 'Alerts',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildHome() {
    final firstName = user.name.trim().split(RegExp(r'\s+')).first;
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          final summary = ServiceLocator.instance.dashboardSummaryUseCase();
          setState(() {
            _summaryFuture = summary;
            _unreadAlertsFuture = _countUnreadAlerts();
          });
          await summary.catchError((_) => const DashboardSummary(complaintsCount: 0, paymentStatus: 'N/A', pendingAmount: ''));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _selectTab(_profileTab),
                  child: InitialsAvatar(name: user.name, radius: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting,
                        style: const TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        firstName.isEmpty ? 'Welcome' : firstName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.ink, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4),
                      ),
                    ],
                  ),
                ),
                FutureBuilder<int>(
                  future: _unreadAlertsFuture,
                  builder: (context, snapshot) {
                    final unread = snapshot.data ?? 0;
                    return IconButton.outlined(
                      onPressed: () => _selectTab(_alertsTab),
                      tooltip: 'Alerts',
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(color: AppColors.border),
                        fixedSize: const Size(48, 48),
                      ),
                      icon: Badge(
                        isLabelVisible: unread > 0,
                        label: Text('$unread'),
                        backgroundColor: AppColors.danger,
                        child: const Icon(Icons.notifications_outlined, color: AppColors.ink),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 22),
            FutureBuilder<StudentModel?>(
              future: _studentFuture,
              builder: (context, snapshot) => _RoomHeroCard(
                student: snapshot.data,
                loading: snapshot.connectionState != ConnectionState.done,
                onTap: () => _selectTab(_roomTab),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<DashboardSummary>(
              future: _summaryFuture,
              builder: (context, snapshot) {
                final loading = snapshot.connectionState == ConnectionState.waiting;
                final summary = snapshot.data;
                return _PaymentStatusCard(
                  loading: loading,
                  status: summary?.paymentStatus,
                  detail: summary?.pendingAmount,
                  onTap: () => _selectTab(_paymentsTab),
                );
              },
            ),
            const SizedBox(height: 28),
            const SectionTitle('Quick actions'),
            _ActionRow(
              icon: Icons.group_add_rounded,
              color: AppColors.info,
              title: 'Visitor passes',
              subtitle: 'Request a pass for a guest',
              onTap: () => _push(const VisitorPage()),
            ),
            FutureBuilder<DashboardSummary>(
              future: _summaryFuture,
              builder: (context, snapshot) {
                final count = snapshot.data?.complaintsCount;
                return _ActionRow(
                  icon: Icons.handyman_rounded,
                  color: AppColors.warning,
                  title: 'Maintenance',
                  subtitle: count == null || count == 0
                      ? 'Report a problem in your room'
                      : '$count request${count == 1 ? '' : 's'} filed · Report a problem',
                  onTap: () => _push(const ComplaintPage()),
                );
              },
            ),
            _ActionRow(
              icon: Icons.campaign_rounded,
              color: AppColors.success,
              title: 'Notices',
              subtitle: 'Announcements from your warden',
              onTap: () => _push(const NoticesPage()),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomHeroCard extends StatelessWidget {
  final StudentModel? student;
  final bool loading;
  final VoidCallback onTap;

  const _RoomHeroCard({required this.student, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasRoom = student?.hasRoom == true;
    final String title;
    final String subtitle;
    if (loading) {
      title = 'Loading…';
      subtitle = 'Fetching your room';
    } else if (student == null) {
      title = 'Room unavailable';
      subtitle = "We couldn't load your details. Pull down to retry.";
    } else if (!hasRoom) {
      title = 'No room yet';
      subtitle = 'Your warden will allocate a room soon.';
    } else {
      title = 'Room ${student!.roomNumber}';
      subtitle = student!.buildingName ?? 'Tap to see room details';
    }

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [AppColors.primaryBright, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.22), blurRadius: 24, offset: const Offset(0, 6), spreadRadius: -6)],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'YOUR ROOM',
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            style: const TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(color: AppColors.white.withValues(alpha: 0.85), fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.bed_rounded, color: AppColors.ink, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    children: [
                      Text(
                        'View room details',
                        style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_rounded, color: AppColors.white, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentStatusCard extends StatelessWidget {
  final bool loading;
  final String? status;
  final String? detail;
  final VoidCallback onTap;

  const _PaymentStatusCard({required this.loading, required this.status, required this.detail, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      'Paid up' => AppColors.success,
      'Overdue' => AppColors.danger,
      'Due' => AppColors.warning,
      _ => AppColors.muted,
    };
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const IconTile(icon: Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hostel fees',
                  style: TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  loading ? 'Checking…' : (detail == null || detail!.isEmpty ? 'Unavailable' : detail!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.ink, fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!loading && status != null && status != 'N/A') StatusPill(label: status!, color: color),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppColors.faint),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionRow({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
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
                  style: const TextStyle(color: AppColors.ink, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.faint),
        ],
      ),
    );
  }
}
