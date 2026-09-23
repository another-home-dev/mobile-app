import 'package:flutter/material.dart';
import 'package:another_home/core/utils/role_utils.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:another_home/core/di/service_locator.dart';
import 'package:another_home/core/services/secure_storage_service.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/glass_background.dart';
import 'package:another_home/features/auth/domain/entities/user.dart';
import 'package:another_home/features/auth/presentation/pages/login_page.dart';
import 'package:another_home/features/dashboard/presentation/pages/dashboard_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    // Artificial small delay for a smooth transition experience
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final secureStorage = ServiceLocator.instance.secureStorageService;
    final apiClient = ServiceLocator.instance.apiClient;

    try {
      final accessToken = await secureStorage.getAccessToken();
      final idToken = await secureStorage.getIdToken();

      if (accessToken != null && idToken != null) {
        final isExpired = SecureStorageService.isTokenExpired(accessToken);

        if (!isExpired) {
          // Attach token to ApiClient
          apiClient.setToken(accessToken);

          // Fetch user profile live from Asgardeo's UserInfo endpoint
          final liveProfile = await ServiceLocator.instance.authApiService.fetchUserProfile();
          
          final String userId;
          final String email;
          final String name;
          final String? role;

          if (liveProfile != null) {
            userId = liveProfile['sub'] as String? ?? 'unknown';
            email = liveProfile['email'] as String? ?? '';
            name = liveProfile['name'] as String? ?? liveProfile['given_name'] as String? ?? email.split('@').first;
            role = resolveAppRole(liveProfile['roles']);
          } else {
            // Fallback: decode claims from OIDC id_token if UserInfo endpoint is unreachable
            final decoded = JwtDecoder.decode(idToken);
            userId = decoded['sub'] as String? ?? 'unknown';
            email = decoded['email'] as String? ?? '';
            
            String tempName = decoded['name'] as String? ?? '';
            if (tempName.isEmpty) {
              final givenName = decoded['given_name'] as String? ?? '';
              final familyName = decoded['family_name'] as String? ?? '';
              if (givenName.isNotEmpty || familyName.isNotEmpty) {
                tempName = '$givenName $familyName'.trim();
              } else {
                tempName = email.split('@').first;
              }
            }
            name = tempName;
            role = resolveAppRole(decoded['roles']);
          }

          // This app is for students only — a warden/super-admin token (or one with
          // no role claim at all) should never land on the student dashboard.
          if (role != 'student') {
            await secureStorage.clearAll();
          } else {
            final user = User(
              id: userId,
              name: name,
              email: email,
              role: role,
            );

            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => DashboardPage(user: user)),
            );
            return;
          }
        }
      }
    } catch (_) {
      // In case of error (e.g. storage corrupted), default to login
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: GlassBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ANOTHER HOME',
                style: TextStyle(
                  color: AppColors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 28,
                  fontFamily: 'serif',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.cyan,
                  strokeWidth: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
