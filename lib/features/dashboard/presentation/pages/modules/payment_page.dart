import 'package:flutter/material.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/glass_card.dart';
import 'package:another_home/core/theme/glass_button.dart';
import 'package:another_home/core/theme/glass_background.dart';
import 'package:another_home/core/theme/glass_badge.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  Widget _buildStatCard(String label, String value, Color valueColor) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        borderRadius: BorderRadius.circular(18),
        color: AppColors.surfaceElevated.withValues(alpha: 0.45),
        borderColor: valueColor.withValues(alpha: 0.25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String month, String txn, String amount, String status, String date) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      color: AppColors.surface.withValues(alpha: 0.5),
      borderColor: AppColors.text.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GlassCard(
                    width: 40,
                    height: 40,
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.green.withValues(alpha: 0.2),
                    borderColor: AppColors.green.withValues(alpha: 0.4),
                    child: const Icon(Icons.check, color: AppColors.green, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(month, style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(txn, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(amount, style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  GlassBadge(label: status, color: AppColors.green),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: AppColors.muted),
              const SizedBox(width: 8),
              Text(date, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Payments'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
      ),
      body: GlassBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('Fee management & history', style: TextStyle(color: AppColors.muted, fontSize: 14)),
              const SizedBox(height: 24),
              GlassCard(
                padding: const EdgeInsets.all(24),
                borderRadius: BorderRadius.circular(28),
                color: AppColors.primaryDeep.withValues(alpha: 0.5),
                borderColor: AppColors.primary.withValues(alpha: 0.4),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 10)),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('AMOUNT DUE', style: TextStyle(color: AppColors.muted, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                        GlassCard(
                          padding: const EdgeInsets.all(12),
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.primary.withValues(alpha: 0.3),
                          borderColor: AppColors.primary.withValues(alpha: 0.5),
                          child: const Icon(Icons.credit_card, color: AppColors.cyan, size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text('Rs. 7,500', style: TextStyle(color: AppColors.text, fontSize: 36, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 18),
                    const Text('June 2026 Hostel Fee', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text('Due: 31 July 2026', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GlassButton(
                        onPressed: () {},
                        width: 140,
                        height: 46,
                        color: AppColors.primary,
                        child: const Text('Pay Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildStatCard('Total Paid', 'Rs. 22,500', AppColors.green),
                  const SizedBox(width: 12),
                  _buildStatCard('Pending', 'Rs. 7,500', AppColors.red),
                  const SizedBox(width: 12),
                  _buildStatCard('Months', '3 / 4', AppColors.text),
                ],
              ),
              const SizedBox(height: 28),
              const Text('PAYMENT HISTORY', style: TextStyle(color: AppColors.muted, fontSize: 12, letterSpacing: 1.4, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              _buildHistoryItem('May 2026', 'TXN-2026-0520', 'Rs. 7,500', 'Paid', 'Paid on 20 May 2026'),
              _buildHistoryItem('April 2026', 'TXN-2026-0418', 'Rs. 7,500', 'Paid', 'Paid on 18 Apr 2026'),
              _buildHistoryItem('March 2026', 'TXN-2026-0322', 'Rs. 7,500', 'Paid', 'Paid on 22 Mar 2026'),
            ],
          ),
        ),
      ),
    );
  }
}
