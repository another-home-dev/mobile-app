import '../../utils/json_utils.dart';

class SubmitPaymentDto {
  final String invoiceId;
  final double amount;
  final String? referenceNumber;

  const SubmitPaymentDto({
    required this.invoiceId,
    required this.amount,
    this.referenceNumber,
  });

  Map<String, dynamic> toJson() => {
        'invoiceId': invoiceId,
        'amount': amount,
        if (referenceNumber != null) 'referenceNumber': referenceNumber,
      };
}

class InvoiceModel {
  final String invoiceId;
  final String studentId;
  final double amount;
  final String dueDate;
  final String status; // Pending, Paid, or Overdue (computed server-side)
  final String description;
  final DateTime? paidAt;
  final DateTime createdAt;

  const InvoiceModel({
    required this.invoiceId,
    required this.studentId,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.description,
    this.paidAt,
    required this.createdAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
        invoiceId: json['invoiceId'] as String,
        studentId: json['studentId'] as String,
        amount: parseJsonDouble(json['amount']),
        dueDate: json['dueDate'] as String,
        status: json['status'] as String,
        description: json['description'] as String,
        paidAt: json['paidAt'] != null
            ? DateTime.parse(json['paidAt'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
