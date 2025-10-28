import 'package:equatable/equatable.dart';

class Debtor extends Equatable {
  final int? id;
  final String name;
  final String? phone;
  final String? address;
  final String? notes;
  final double totalDebt;
  final double totalPaid;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Debtor({
    this.id,
    required this.name,
    this.phone,
    this.address,
    this.notes,
    this.totalDebt = 0,
    this.totalPaid = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  double get remainingDebt => totalDebt - totalPaid;

  bool get hasDebt => remainingDebt > 0;

  double get paymentPercentage {
    if (totalDebt == 0) return 0;
    return (totalPaid / totalDebt) * 100;
  }

  Debtor copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? notes,
    double? totalDebt,
    double? totalPaid,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Debtor(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      totalDebt: totalDebt ?? this.totalDebt,
      totalPaid: totalPaid ?? this.totalPaid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    address,
    notes,
    totalDebt,
    totalPaid,
    createdAt,
    updatedAt,
  ];
}
