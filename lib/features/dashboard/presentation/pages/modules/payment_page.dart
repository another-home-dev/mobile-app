import 'package:flutter/material.dart';
import 'package:another_home/core/theme/app_colors.dart';
import 'package:another_home/core/theme/ui_components.dart';
import 'package:another_home/core/di/service_locator.dart';
import 'package:another_home/core/errors/student_not_registered_exception.dart';
import 'package:another_home/core/network/dtos/finance_models.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Future<List<InvoiceModel>>? _invoicesFuture;
  bool _notRegistered = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _invoicesFuture = _fetchInvoices();
  }

  Future<List<InvoiceModel>> _fetchInvoices() async {
    try {
      final invoices = await ServiceLocator.instance.getInvoicesUseCase();
      _notRegistered = false;
      return invoices;
    } on StudentNotRegisteredException {
      _notRegistered = true;
      return [];
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
        return AppColors.success;
      case 'Overdue':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  Future<void> _payInvoice(InvoiceModel invoice) async {
    final controller = TextEditingController();
    final reference = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(sheetContext).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Submit payment',
              style: TextStyle(color: AppColors.ink, fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              '${invoice.description} · Rs. ${invoice.amount.toStringAsFixed(0)}',
              style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            const FieldLabel('Payment reference'),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'e.g. bank transfer slip number', prefixIcon: Icon(Icons.receipt_long_rounded)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your warden will verify the payment and mark the invoice as paid.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Submit for review',
              icon: Icons.send_rounded,
              onPressed: () => Navigator.pop(sheetContext, controller.text.trim()),
            ),
          ],
        ),
      ),
    );
    if (reference == null || reference.isEmpty || !mounted) return;

    try {
      await ServiceLocator.instance.submitPaymentUseCase(invoiceId: invoice.invoiceId, amount: invoice.amount, referenceNumber: reference);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment submitted for review.')));
      setState(_load);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit payment: $e')));
    }
  }

  Widget _buildStat(String label, String value, Color color) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoice(InvoiceModel invoice) {
    final statusColor = _statusColor(invoice.status);
    final paid = invoice.status == 'Paid';
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              IconTile(icon: paid ? Icons.check_circle_rounded : Icons.receipt_long_rounded, color: statusColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.ink, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text('Due ${invoice.dueDate}', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs. ${invoice.amount.toStringAsFixed(0)}',
                    style: const TextStyle(color: AppColors.ink, fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  StatusPill(label: invoice.status, color: statusColor),
                ],
              ),
            ],
          ),
          if (!paid) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _payInvoice(invoice),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                icon: const Icon(Icons.payments_rounded, size: 18),
                label: const Text('Pay this invoice'),
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
      appBar: AppBar(title: const Text('Payments')),
      body: FutureBuilder<List<InvoiceModel>>(
        future: _invoicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return MessageView.error(title: "Couldn't load payments", message: '${snapshot.error}', onAction: () => setState(_load));
          }
          if (_notRegistered) {
            return const MessageView(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No fee records yet',
              message: "You haven't been registered by your hostel warden yet, so there are no invoices to show.",
            );
          }

          final invoices = snapshot.data ?? [];
          final pending = invoices.where((i) => i.status != 'Paid').toList();
          final paid = invoices.where((i) => i.status == 'Paid').toList();
          final totalPaid = paid.fold<double>(0, (sum, i) => sum + i.amount);
          final totalPending = pending.fold<double>(0, (sum, i) => sum + i.amount);
          final nextDue = pending.isNotEmpty ? pending.first : null;

          return RefreshIndicator(
            onRefresh: () async {
              setState(_load);
              await _invoicesFuture;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'AMOUNT DUE',
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          StatusPill(
                            label: nextDue == null ? 'All paid' : (pending.any((i) => i.status == 'Overdue') ? 'Overdue' : 'Due'),
                            color: nextDue == null
                                ? AppColors.success
                                : (pending.any((i) => i.status == 'Overdue') ? AppColors.danger : AppColors.warning),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Rs. ${totalPending.toStringAsFixed(0)}',
                        style: const TextStyle(color: AppColors.white, fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextDue == null ? "You're all caught up." : 'Next: ${nextDue.description} · due ${nextDue.dueDate}',
                        style: TextStyle(color: AppColors.white.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      if (nextDue != null) ...[
                        const SizedBox(height: 18),
                        PrimaryButton(
                          label: 'Pay now',
                          icon: Icons.arrow_forward_rounded,
                          color: AppColors.accent,
                          foregroundColor: AppColors.ink,
                          onPressed: () => _payInvoice(nextDue),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildStat('Paid', 'Rs. ${totalPaid.toStringAsFixed(0)}', AppColors.success),
                    const SizedBox(width: 10),
                    _buildStat('Pending', 'Rs. ${totalPending.toStringAsFixed(0)}', AppColors.danger),
                    const SizedBox(width: 10),
                    _buildStat('Invoices', '${paid.length} / ${invoices.length}', AppColors.ink),
                  ],
                ),
                const SizedBox(height: 26),
                const SectionTitle('Payment history'),
                if (invoices.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No invoices yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                else
                  ...invoices.map(_buildInvoice),
              ],
            ),
          );
        },
      ),
    );
  }
}
