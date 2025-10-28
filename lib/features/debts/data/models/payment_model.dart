import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    super.id,
    required super.debtId,
    required super.amount,
    required super.paymentDate,
    super.note,
    required super.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int?,
      debtId: json['debt_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['payment_date'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'debt_id': debtId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PaymentModel.fromEntity(Payment payment) {
    return PaymentModel(
      id: payment.id,
      debtId: payment.debtId,
      amount: payment.amount,
      paymentDate: payment.paymentDate,
      note: payment.note,
      createdAt: payment.createdAt,
    );
  }
}
