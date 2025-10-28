import 'package:equatable/equatable.dart';

enum DebtStatus { active, partial, paid, overdue }

class Debt extends Equatable {
  final int? id;
  final int debtorId;
  final double amount;
  final String description;
  final DateTime debtDate;
  final DateTime? dueDate;
  final DebtStatus status;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Debt({
    this.id,
    required this.debtorId,
    required this.amount,
    required this.description,
    required this.debtDate,
    this.dueDate,
    this.status = DebtStatus.active,
    this.currency = 'UZS',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOverdue {
    if (dueDate == null || status == DebtStatus.paid) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  int get daysUntilDue {
    if (dueDate == null) return 0;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  Debt copyWith({
    int? id,
    int? debtorId,
    double? amount,
    String? description,
    DateTime? debtDate,
    DateTime? dueDate,
    DebtStatus? status,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Debt(
      id: id ?? this.id,
      debtorId: debtorId ?? this.debtorId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      debtDate: debtDate ?? this.debtDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        debtorId,
        amount,
        description,
        debtDate,
        dueDate,
        status,
        currency,
        createdAt,
        updatedAt,
      ];
}
