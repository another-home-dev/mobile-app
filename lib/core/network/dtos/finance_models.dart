class SubmitPaymentDto {
  final String invoiceId;
  final double amountPaid;
  final String referenceNumber;

  const SubmitPaymentDto({
    required this.invoiceId,
    required this.amountPaid,
    required this.referenceNumber,
  });

  Map<String, dynamic> toJson() => {
        'invoiceId': invoiceId,
        'amountPaid': amountPaid,
        'referenceNumber': referenceNumber,
      };
}

class InvoiceModel {
  final String id;
  final String studentId;
  final double amount;
  final String dueDate;
  final String status; // e.g. PENDING, PAID, OVERDUE
  final String description;
  final String? referenceNumber;
  final DateTime? paidAt;
  final DateTime createdAt;

  const InvoiceModel({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.description,
    this.referenceNumber,
    this.paidAt,
    required this.createdAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
        id: json['id'] as String,
        studentId: json['studentId'] as String,
        amount: (json['amount'] as num).toDouble(),
        dueDate: json['dueDate'] as String,
        status: json['status'] as String,
        description: json['description'] as String,
        referenceNumber: json['referenceNumber'] as String?,
        paidAt: json['paidAt'] != null
            ? DateTime.parse(json['paidAt'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
