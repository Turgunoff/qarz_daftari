import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/debtor.dart';
import '../../domain/usecases/add_debtor.dart';
import '../../domain/usecases/delete_debtor.dart';
import '../../domain/usecases/get_all_debtors.dart';
import '../../domain/usecases/search_debtors.dart';
import '../../domain/usecases/update_debtor.dart';

/// Debtor State
class DebtorState {
  final List<Debtor> debtors;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final DebtorFilter currentFilter;

  DebtorState({
    this.debtors = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.currentFilter = DebtorFilter.all,
  });

  // Statistics
  int get totalDebtors => debtors.length;

  int get debtorsWithDebt => debtors.where((d) => d.hasDebt).length;

  double get totalDebtAmount =>
      debtors.fold(0.0, (sum, debtor) => sum + debtor.totalDebt);

  double get totalPaidAmount =>
      debtors.fold(0.0, (sum, debtor) => sum + debtor.totalPaid);

  double get totalRemainingAmount =>
      debtors.fold(0.0, (sum, debtor) => sum + debtor.remainingDebt);

  DebtorState copyWith({
    List<Debtor>? debtors,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    DebtorFilter? currentFilter,
  }) {
    return DebtorState(
      debtors: debtors ?? this.debtors,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }

  DebtorState clearMessages() {
    return copyWith(errorMessage: null, successMessage: null);
  }
}

/// Debtor Filter
enum DebtorFilter { all, withDebt, noDebt }

/// Debtor Notifier
class DebtorNotifier extends StateNotifier<DebtorState> {
  final GetAllDebtors getAllDebtors;
  final AddDebtor addDebtor;
  final UpdateDebtor updateDebtor;
  final DeleteDebtor deleteDebtor;
  final SearchDebtors searchDebtors;

  DebtorNotifier({
    required this.getAllDebtors,
    required this.addDebtor,
    required this.updateDebtor,
    required this.deleteDebtor,
    required this.searchDebtors,
  }) : super(DebtorState());

  /// Load all debtors
  Future<void> loadDebtors() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await getAllDebtors();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (debtors) => state = state.copyWith(debtors: debtors, isLoading: false),
    );
  }

  /// Add new debtor
  Future<bool> createDebtor(Debtor debtor) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await addDebtor(debtor);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (id) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Qarzdor muvaffaqiyatli qo\'shildi',
        );
        loadDebtors(); // Reload list
        return true;
      },
    );
  }

  /// Update existing debtor
  Future<bool> modifyDebtor(Debtor debtor) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await updateDebtor(debtor);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Qarzdor muvaffaqiyatli yangilandi',
        );
        loadDebtors(); // Reload list
        return true;
      },
    );
  }

  /// Delete debtor
  Future<bool> removeDebtor(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await deleteDebtor(id);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Qarzdor muvaffaqiyatli o\'chirildi',
        );
        loadDebtors(); // Reload list
        return true;
      },
    );
  }

  /// Search debtors
  Future<void> searchDebtorsByQuery(String query) async {
    if (query.trim().isEmpty) {
      loadDebtors();
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await searchDebtors(query);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (debtors) => state = state.copyWith(debtors: debtors, isLoading: false),
    );
  }

  /// Filter debtors
  void filterDebtors(DebtorFilter filter) {
    state = state.copyWith(currentFilter: filter);
  }

  /// Get filtered debtors
  List<Debtor> get filteredDebtors {
    switch (state.currentFilter) {
      case DebtorFilter.withDebt:
        return state.debtors.where((d) => d.hasDebt).toList();
      case DebtorFilter.noDebt:
        return state.debtors.where((d) => !d.hasDebt).toList();
      case DebtorFilter.all:
      default:
        return state.debtors;
    }
  }

  /// Clear messages
  void clearMessages() {
    state = state.clearMessages();
  }
}
