import 'package:flutter/material.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/glass_card.dart';
import 'package:another_home/core/theme/glass_button.dart';
import 'package:another_home/core/theme/glass_background.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Join Another Home',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 30,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your details to create an account',
                  style: TextStyle(color: AppColors.muted, fontSize: 14),
                ),
                const SizedBox(height: 28),
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  borderRadius: BorderRadius.circular(28),
                  color: AppColors.surface.withValues(alpha: 0.55),
                  borderColor: AppColors.text.withValues(alpha: 0.12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('FULL NAME'),
                      _buildTextField(hintText: 'Ahmad Razin Abdullah', icon: Icons.person_outline),
                      const SizedBox(height: 20),
                      _buildLabel('UOM-MAIL'),
                      _buildTextField(hintText: 'p12345@siswa.um.edu.my', icon: Icons.mail_outline),
                      const SizedBox(height: 20),
                      _buildLabel('PASSWORD'),
                      _buildTextField(hintText: 'Min. 8 characters', icon: Icons.lock_outline, obscureText: true),
                      const SizedBox(height: 32),
                      GlassButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Account created successfully')),
                          );
                          Navigator.pop(context);
                        },
                        color: AppColors.primary,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
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

  Widget _buildLabel(String labelText) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        labelText,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      color: AppColors.surfaceElevated.withValues(alpha: 0.4),
      borderColor: AppColors.text.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            Icon(icon, color: AppColors.cyan, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                obscureText: obscureText,
                style: const TextStyle(color: AppColors.text, fontSize: 14),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(color: AppColors.muted),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
