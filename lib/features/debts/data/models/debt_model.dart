import '../../domain/entities/debt.dart';

class DebtModel extends Debt {
  const DebtModel({
    super.id,
    required super.debtorId,
    required super.amount,
    required super.description,
    required super.debtDate,
    super.dueDate,
    super.status,
    super.currency,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'] as int?,
      debtorId: json['debtor_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      debtDate: DateTime.parse(json['debt_date'] as String),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      status: _statusFromString(json['status'] as String),
      currency: json['currency'] as String? ?? 'UZS',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'debtor_id': debtorId,
      'amount': amount,
      'description': description,
      'debt_date': debtDate.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'status': _statusToString(status),
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DebtModel.fromEntity(Debt debt) {
    return DebtModel(
      id: debt.id,
      debtorId: debt.debtorId,
      amount: debt.amount,
      description: debt.description,
      debtDate: debt.debtDate,
      dueDate: debt.dueDate,
      status: debt.status,
      currency: debt.currency,
      createdAt: debt.createdAt,
      updatedAt: debt.updatedAt,
    );
  }

  static DebtStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return DebtStatus.active;
      case 'partial':
        return DebtStatus.partial;
      case 'paid':
        return DebtStatus.paid;
      case 'overdue':
        return DebtStatus.overdue;
      default:
        return DebtStatus.active;
    }
  }

  static String _statusToString(DebtStatus status) {
    switch (status) {
      case DebtStatus.active:
        return 'active';
      case DebtStatus.partial:
        return 'partial';
      case DebtStatus.paid:
        return 'paid';
      case DebtStatus.overdue:
        return 'overdue';
    }
  }
}
