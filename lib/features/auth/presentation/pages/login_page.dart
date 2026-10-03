import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/ui_components.dart';

import '../../../../core/di/service_locator.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(ServiceLocator.instance.loginUseCase),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DashboardPage(user: state.user)));
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.bg,
          body: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _BrandHeader(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome home',
                                style: TextStyle(color: AppColors.ink, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Sign in with your student account, or create one if this is your first time.',
                                style: TextStyle(color: AppColors.muted, fontSize: 15, height: 1.45),
                              ),
                              const SizedBox(height: 24),
                              const _Feature(
                                icon: Icons.payments_rounded,
                                color: AppColors.success,
                                text: 'Pay hostel fees and track invoices',
                              ),
                              const _Feature(
                                icon: Icons.group_add_rounded,
                                color: AppColors.info,
                                text: 'Request visitor passes in seconds',
                              ),
                              const _Feature(
                                icon: Icons.handyman_rounded,
                                color: AppColors.warning,
                                text: 'Report and follow maintenance issues',
                              ),
                              const Spacer(),
                              const SizedBox(height: 24),
                              BlocBuilder<LoginBloc, LoginState>(
                                builder: (context, state) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      if (state is LoginFailure)
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 14),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(color: AppColors.dangerSoft, borderRadius: BorderRadius.circular(12)),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  state.message,
                                                  style: const TextStyle(
                                                    color: AppColors.danger,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      PrimaryButton(
                                        label: 'Continue with Asgardeo',
                                        icon: Icons.login_rounded,
                                        loading: state is LoginLoading,
                                        onPressed: () => context.read<LoginBloc>().add(const LoginSubmitted()),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              const Center(
                                child: Text(
                                  'Secure sign-in powered by WSO2 Asgardeo',
                                  style: TextStyle(color: AppColors.faint, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 36, 24, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBright, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 10))],
            ),
            child: Image.asset('assets/images/logo.png', width: 72, height: 72),
          ),
          const SizedBox(height: 18),
          const Text(
            'Another Home',
            style: TextStyle(color: AppColors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.4),
          ),
          const SizedBox(height: 4),
          Text(
            'Smart hostel living for students',
            style: TextStyle(color: AppColors.white.withValues(alpha: 0.85), fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _Feature({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          IconTile(icon: icon, color: color, size: 38),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
