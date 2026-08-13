import 'package:flutter/material.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/glass_card.dart';
import 'package:another_home/core/theme/glass_button.dart';
import 'package:another_home/core/theme/glass_background.dart';
import 'package:another_home/core/theme/glass_badge.dart';

class VisitorPage extends StatelessWidget {
  const VisitorPage({super.key});

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
        title: const Text('Visitors'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GlassCard(
              width: 40,
              height: 40,
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(12),
              color: AppColors.cyan.withValues(alpha: 0.25),
              borderColor: AppColors.cyan.withValues(alpha: 0.4),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVisitorPage()));
              },
              child: const Icon(Icons.add, color: AppColors.text, size: 22),
            ),
          ),
        ],
      ),
      body: GlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard('1', 'Approved', AppColors.green)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('1', 'Pending', AppColors.orange)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('1', 'Rejected', AppColors.red)),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _buildVisitorCard(name: 'Ravi Perera', id: '9876543210V', date: '20 Jul 2026', time: '10:00 AM', purpose: 'Family Visit', status: 'Approved', statusColor: AppColors.green),
                      _buildVisitorCard(name: 'Nimasha Silva', id: '0023456789V', date: '22 Jul 2026', time: '02:00 PM', purpose: 'Academic Con...', status: 'Pending', statusColor: AppColors.primary),
                      _buildVisitorCard(name: 'Kasun Jayawardena', id: '9945678901V', date: '12 Jul 2026', time: '11:30 AM', purpose: 'Personal Visit', status: 'Rejected', statusColor: AppColors.red),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String count, String label, Color countColor) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      borderRadius: BorderRadius.circular(16),
      color: AppColors.surfaceElevated.withValues(alpha: 0.4),
      borderColor: countColor.withValues(alpha: 0.3),
      child: Column(
        children: [
          Text(count, style: TextStyle(color: countColor, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildVisitorCard({required String name, required String id, required String date, required String time, required String purpose, required String status, required Color statusColor}) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      color: AppColors.surface.withValues(alpha: 0.5),
      borderColor: AppColors.text.withValues(alpha: 0.08),
      child: Column(
        children: [
          Row(
            children: [
              GlassCard(
                width: 48,
                height: 48,
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(24),
                color: AppColors.overlay,
                borderColor: AppColors.text.withValues(alpha: 0.1),
                child: const Icon(Icons.person_outline, color: AppColors.cyan, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(id, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                  ],
                ),
              ),
              GlassBadge(label: status, color: statusColor),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconText(Icons.calendar_today_outlined, date),
              _buildIconText(Icons.access_time_outlined, time),
              _buildIconText(Icons.description_outlined, purpose),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.muted, size: 14),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      ],
    );
  }
}

class AddVisitorPage extends StatelessWidget {
  const AddVisitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.text), onPressed: () => Navigator.pop(context)),
        title: const Text('Add New Visitor'),
      ),
      body: GlassBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Visitor details', style: TextStyle(color: AppColors.muted, fontSize: 14)),
              const SizedBox(height: 24),
              _buildLabel('Visitor Full Name'),
              _buildTextField('Enter guest name'),
              const SizedBox(height: 24),
              _buildLabel('NIC'),
              _buildTextField('Enter guest identification number'),
              const SizedBox(height: 24),
              _buildLabel('Visit Purpose'),
              _buildDropdownField(),
              const SizedBox(height: 32),
              GlassButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                color: AppColors.primary,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Submit details', style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.check_circle_outline, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: const TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  Widget _buildTextField(String hint) {
    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      color: AppColors.surfaceElevated.withValues(alpha: 0.4),
      borderColor: AppColors.primary.withValues(alpha: 0.2),
      child: TextField(
        style: const TextStyle(color: AppColors.text),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.muted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return GlassCard(
      borderRadius: BorderRadius.circular(16),
      color: AppColors.surfaceElevated.withValues(alpha: 0.4),
      borderColor: AppColors.primary.withValues(alpha: 0.2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: DropdownButtonFormField<String>(
        dropdownColor: AppColors.surfaceElevated,
        decoration: const InputDecoration(border: InputBorder.none),
        hint: const Text('Select purpose', style: TextStyle(color: AppColors.muted)),
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.cyan),
        style: const TextStyle(color: AppColors.text),
        items: ['Personal Visit', 'Family Visit', 'Academic Connection']
            .map((value) => DropdownMenuItem<String>(value: value, child: Text(value)))
            .toList(),
        onChanged: (value) {},
      ),
    );
  }
}
