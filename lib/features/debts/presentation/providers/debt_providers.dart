import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/datasources/debt_local_datasource.dart';
import '../../data/repositories/debt_repository_impl.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../domain/usecases/add_debt.dart';
import '../../domain/usecases/add_payment.dart';
import '../../domain/usecases/delete_debt.dart';
import '../../domain/usecases/delete_payment.dart';
import '../../domain/usecases/get_debts.dart';
import '../../domain/usecases/get_debts_by_debtor.dart';
import '../../domain/usecases/get_payments.dart';
import '../../domain/usecases/update_debt.dart';
import 'debt_notifier.dart';

// Database Helper Provider
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

// Data Source Provider
final debtLocalDataSourceProvider = Provider<DebtLocalDataSource>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return DebtLocalDataSourceImpl(databaseHelper);
});

// Repository Provider
final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  final localDataSource = ref.watch(debtLocalDataSourceProvider);
  return DebtRepositoryImpl(localDataSource);
});

// Use Cases Providers
final getDebtsUseCaseProvider = Provider<GetDebts>((ref) {
  final repository = ref.watch(debtRepositoryProvider);
  return GetDebts(repository);
});

final getDebtsByDebtorUseCaseProvider = Provider<GetDebtsByDebtor>((ref) {
  final repository = ref.watch(debtRepositoryProvider);
  return GetDebtsByDebtor(repository);
});

final addDebtUseCaseProvider = Provider<AddDebt>((ref) {
  final repository = ref.watch(debtRepositoryProvider);
  return AddDebt(repository);
});

final updateDebtUseCaseProvider = Provider<UpdateDebt>((ref) {
  final repository = ref.watch(debtRepositoryProvider);
  return UpdateDebt(repository);
});

final deleteDebtUseCaseProvider = Provider<DeleteDebt>((ref) {
  final repository = ref.watch(debtRepositoryProvider);
  return DeleteDebt(repository);
});

final addPaymentUseCaseProvider = Provider<AddPayment>((ref) {
  final repository = ref.watch(debtRepositoryProvider);
  return AddPayment(repository);
});

final getPaymentsUseCaseProvider = Provider<GetPayments>((ref) {
  final repository = ref.watch(debtRepositoryProvider);
  return GetPayments(repository);
});

final deletePaymentUseCaseProvider = Provider<DeletePayment>((ref) {
  final repository = ref.watch(debtRepositoryProvider);
  return DeletePayment(repository);
});

// Main Debt State Provider
final debtProvider = StateNotifierProvider<DebtNotifier, DebtState>((ref) {
  return DebtNotifier(
    getDebts: ref.watch(getDebtsUseCaseProvider),
    getDebtsByDebtor: ref.watch(getDebtsByDebtorUseCaseProvider),
    addDebt: ref.watch(addDebtUseCaseProvider),
    updateDebt: ref.watch(updateDebtUseCaseProvider),
    deleteDebt: ref.watch(deleteDebtUseCaseProvider),
    addPayment: ref.watch(addPaymentUseCaseProvider),
    getPayments: ref.watch(getPaymentsUseCaseProvider),
    deletePayment: ref.watch(deletePaymentUseCaseProvider),
  );
});
