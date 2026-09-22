import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/glass_card.dart';
import 'package:another_home/core/theme/glass_button.dart';
import 'package:another_home/core/theme/glass_background.dart';

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
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: GlassBackground(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'ANOTHER HOME',
                      style: TextStyle(
                        color: AppColors.cyan,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 32,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sign in with your student account, or create one if this is your first time.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted.withValues(alpha: 0.9), fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    BlocListener<LoginBloc, LoginState>(
                      listener: (context, state) {
                        if (state is LoginSuccess) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => DashboardPage(user: state.user)),
                          );
                        }
                      },
                      child: GlassCard(
                        padding: const EdgeInsets.all(24),
                        borderRadius: BorderRadius.circular(28),
                        color: AppColors.surface.withValues(alpha: 0.55),
                        borderColor: AppColors.text.withValues(alpha: 0.12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            BlocBuilder<LoginBloc, LoginState>(
                              builder: (context, state) {
                                if (state is LoginFailure) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      state.message,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: AppColors.red),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            BlocBuilder<LoginBloc, LoginState>(
                              builder: (context, state) {
                                return GlassButton(
                                  onPressed: () {
                                    if (state is LoginLoading) return;
                                    context.read<LoginBloc>().add(const LoginSubmitted());
                                  },
                                  color: AppColors.primary,
                                  child: state is LoginLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: AppColors.text,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.login_rounded, size: 18),
                                            SizedBox(width: 8),
                                            Text(
                                              'Continue with Asgardeo',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                );
                              },
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
    );
  }
}
