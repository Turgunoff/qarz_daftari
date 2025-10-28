import '../../domain/entities/debtor.dart';

class DebtorModel extends Debtor {
  const DebtorModel({
    super.id,
    required super.name,
    super.phone,
    super.address,
    super.notes,
    super.totalDebt,
    super.totalPaid,
    required super.createdAt,
    required super.updatedAt,
  });

  // From JSON
  factory DebtorModel.fromJson(Map<String, dynamic> json) {
    return DebtorModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      totalDebt: (json['total_debt'] as num?)?.toDouble() ?? 0,
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'notes': notes,
      'total_debt': totalDebt,
      'total_paid': totalPaid,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // From Entity
  factory DebtorModel.fromEntity(Debtor debtor) {
    return DebtorModel(
      id: debtor.id,
      name: debtor.name,
      phone: debtor.phone,
      address: debtor.address,
      notes: debtor.notes,
      totalDebt: debtor.totalDebt,
      totalPaid: debtor.totalPaid,
      createdAt: debtor.createdAt,
      updatedAt: debtor.updatedAt,
    );
  }
}
