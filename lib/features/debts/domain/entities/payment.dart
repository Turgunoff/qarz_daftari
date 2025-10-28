import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final int? id;
  final int debtId;
  final double amount;
  final DateTime paymentDate;
  final String? note;
  final DateTime createdAt;

  const Payment({
    this.id,
    required this.debtId,
    required this.amount,
    required this.paymentDate,
    this.note,
    required this.createdAt,
  });

  Payment copyWith({
    int? id,
    int? debtId,
    double? amount,
    DateTime? paymentDate,
    String? note,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        debtId,
        amount,
        paymentDate,
        note,
        createdAt,
      ];
}
