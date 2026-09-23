import 'package:flutter/material.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/glass_card.dart';
import 'package:another_home/core/theme/glass_button.dart';
import 'package:another_home/core/theme/glass_background.dart';
import 'package:another_home/core/theme/glass_badge.dart';
import 'package:another_home/core/di/service_locator.dart';
import 'package:another_home/core/network/dtos/finance_models.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Future<List<InvoiceModel>>? _invoicesFuture;
  String? _studentId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _invoicesFuture = _fetchInvoices();
  }

  Future<List<InvoiceModel>> _fetchInvoices() async {
    final studentId = await ServiceLocator.instance.secureStorageService.getStudentId();
    _studentId = studentId;
    if (studentId == null) return [];
    return ServiceLocator.instance.financeApiService.getInvoices(studentId);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
        return AppColors.green;
      case 'Overdue':
        return AppColors.red;
      default:
        return AppColors.orange;
    }
  }

  Future<void> _payInvoice(InvoiceModel invoice) async {
    final controller = TextEditingController();
    final reference = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Submit payment reference', style: TextStyle(color: AppColors.text)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.text),
          decoration: const InputDecoration(hintText: 'e.g. bank transfer slip number'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (reference == null || reference.isEmpty || !mounted) return;

    try {
      await ServiceLocator.instance.financeApiService.submitPayment(
        SubmitPaymentDto(invoiceId: invoice.invoiceId, amount: invoice.amount, referenceNumber: reference),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment submitted for review.')));
      setState(_load);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit payment: $e')));
    }
  }

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

  Widget _buildHistoryItem(InvoiceModel invoice) {
    final statusColor = _statusColor(invoice.status);
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
              Expanded(
                child: Row(
                  children: [
                    GlassCard(
                      width: 40,
                      height: 40,
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(20),
                      color: statusColor.withValues(alpha: 0.2),
                      borderColor: statusColor.withValues(alpha: 0.4),
                      child: Icon(invoice.status == 'Paid' ? Icons.check : Icons.hourglass_bottom, color: statusColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(invoice.description, style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Due ${invoice.dueDate}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Rs. ${invoice.amount.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  GlassBadge(label: invoice.status, color: statusColor),
                ],
              ),
            ],
          ),
          if (invoice.status != 'Paid') ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: GlassButton(
                onPressed: () => _payInvoice(invoice),
                width: 140,
                height: 40,
                color: AppColors.primary,
                child: const Text('Pay Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
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
        child: FutureBuilder<List<InvoiceModel>>(
          future: _invoicesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Failed to load payments: ${snapshot.error}', style: const TextStyle(color: AppColors.red)),
              );
            }
            if (_studentId == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    "You haven't been registered by your hostel warden yet, so there are no fee records to show.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              );
            }

            final invoices = snapshot.data ?? [];
            final pending = invoices.where((i) => i.status != 'Paid').toList();
            final paid = invoices.where((i) => i.status == 'Paid').toList();
            final totalPaid = paid.fold<double>(0, (sum, i) => sum + i.amount);
            final totalPending = pending.fold<double>(0, (sum, i) => sum + i.amount);
            final nextDue = pending.isNotEmpty ? pending.first : null;

            return SingleChildScrollView(
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
                        Text('Rs. ${totalPending.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.text, fontSize: 36, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 18),
                        Text(nextDue?.description ?? 'No pending dues', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                        if (nextDue != null) ...[
                          const SizedBox(height: 4),
                          Text('Due: ${nextDue.dueDate}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GlassButton(
                              onPressed: () => _payInvoice(nextDue),
                              width: 140,
                              height: 46,
                              color: AppColors.primary,
                              child: const Text('Pay Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildStatCard('Total Paid', 'Rs. ${totalPaid.toStringAsFixed(0)}', AppColors.green),
                      const SizedBox(width: 12),
                      _buildStatCard('Pending', 'Rs. ${totalPending.toStringAsFixed(0)}', AppColors.red),
                      const SizedBox(width: 12),
                      _buildStatCard('Invoices', '${paid.length} / ${invoices.length}', AppColors.text),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text('PAYMENT HISTORY', style: TextStyle(color: AppColors.muted, fontSize: 12, letterSpacing: 1.4, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  if (invoices.isEmpty)
                    const Text('No invoices yet.', style: TextStyle(color: AppColors.muted))
                  else
                    ...invoices.map(_buildHistoryItem),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
