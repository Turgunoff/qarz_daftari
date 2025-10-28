import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/datasources/debtor_local_datasource.dart';
import '../../data/repositories/debtor_repository_impl.dart';
import '../../domain/repositories/debtor_repository.dart';
import '../../domain/usecases/add_debtor.dart';
import '../../domain/usecases/delete_debtor.dart';
import '../../domain/usecases/get_all_debtors.dart';
import '../../domain/usecases/search_debtors.dart';
import '../../domain/usecases/update_debtor.dart';
import 'debtor_notifier.dart';

// Database Helper Provider
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

// Data Source Provider
final debtorLocalDataSourceProvider = Provider<DebtorLocalDataSource>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return DebtorLocalDataSourceImpl(databaseHelper);
});

// Repository Provider
final debtorRepositoryProvider = Provider<DebtorRepository>((ref) {
  final localDataSource = ref.watch(debtorLocalDataSourceProvider);
  return DebtorRepositoryImpl(localDataSource);
});

// Use Cases Providers
final getAllDebtorsUseCaseProvider = Provider<GetAllDebtors>((ref) {
  final repository = ref.watch(debtorRepositoryProvider);
  return GetAllDebtors(repository);
});

final addDebtorUseCaseProvider = Provider<AddDebtor>((ref) {
  final repository = ref.watch(debtorRepositoryProvider);
  return AddDebtor(repository);
});

final updateDebtorUseCaseProvider = Provider<UpdateDebtor>((ref) {
  final repository = ref.watch(debtorRepositoryProvider);
  return UpdateDebtor(repository);
});

final deleteDebtorUseCaseProvider = Provider<DeleteDebtor>((ref) {
  final repository = ref.watch(debtorRepositoryProvider);
  return DeleteDebtor(repository);
});

final searchDebtorsUseCaseProvider = Provider<SearchDebtors>((ref) {
  final repository = ref.watch(debtorRepositoryProvider);
  return SearchDebtors(repository);
});

// Main Debtor State Provider
final debtorProvider = StateNotifierProvider<DebtorNotifier, DebtorState>((ref) {
  return DebtorNotifier(
    getAllDebtors: ref.watch(getAllDebtorsUseCaseProvider),
    addDebtor: ref.watch(addDebtorUseCaseProvider),
    updateDebtor: ref.watch(updateDebtorUseCaseProvider),
    deleteDebtor: ref.watch(deleteDebtorUseCaseProvider),
    searchDebtors: ref.watch(searchDebtorsUseCaseProvider),
  );
});