import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/debt.dart';
import '../../domain/entities/payment.dart';
import '../../domain/usecases/add_debt.dart';
import '../../domain/usecases/add_payment.dart';
import '../../domain/usecases/delete_debt.dart';
import '../../domain/usecases/delete_payment.dart';
import '../../domain/usecases/get_debts.dart';
import '../../domain/usecases/get_debts_by_debtor.dart';
import '../../domain/usecases/get_payments.dart';
import '../../domain/usecases/update_debt.dart';

/// Debt State
class DebtState {
  final List<Debt> debts;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final int? selectedDebtorId;

  DebtState({
    this.debts = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.selectedDebtorId,
  });

  // Statistics
  int get totalDebts => debts.length;

  int get activeDebts => debts.where((d) => d.status == DebtStatus.active).length;

  int get paidDebts => debts.where((d) => d.status == DebtStatus.paid).length;

  int get overdueDebts => debts.where((d) => d.isOverdue).length;

  double get totalDebtAmount =>
      debts.fold(0.0, (sum, debt) => sum + debt.amount);

  double get totalPaidAmount {
    // This will be calculated from payments when needed
    return 0.0;
  }

  double get totalRemainingAmount {
    // For active and partial debts
    return debts
        .where((d) => d.status != DebtStatus.paid)
        .fold(0.0, (sum, debt) => sum + debt.amount);
  }

  DebtState copyWith({
    List<Debt>? debts,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    int? selectedDebtorId,
  }) {
    return DebtState(
      debts: debts ?? this.debts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      selectedDebtorId: selectedDebtorId ?? this.selectedDebtorId,
    );
  }

  DebtState clearMessages() {
    return copyWith(errorMessage: null, successMessage: null);
  }

  DebtState clearFilter() {
    return copyWith(selectedDebtorId: null);
  }
}

/// Debt Notifier
class DebtNotifier extends StateNotifier<DebtState> {
  final GetDebts getDebts;
  final GetDebtsByDebtor getDebtsByDebtor;
  final AddDebt addDebt;
  final UpdateDebt updateDebt;
  final DeleteDebt deleteDebt;
  final AddPayment addPayment;
  final GetPayments getPayments;
  final DeletePayment deletePayment;

  DebtNotifier({
    required this.getDebts,
    required this.getDebtsByDebtor,
    required this.addDebt,
    required this.updateDebt,
    required this.deleteDebt,
    required this.addPayment,
    required this.getPayments,
    required this.deletePayment,
  }) : super(DebtState());

  /// Load all debts
  Future<void> loadDebts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await getDebts();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (debts) => state = state.copyWith(debts: debts, isLoading: false),
    );
  }

  /// Load debts by debtor ID
  Future<void> loadDebtsByDebtor(int debtorId) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      selectedDebtorId: debtorId,
    );

    final result = await getDebtsByDebtor(debtorId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (debts) => state = state.copyWith(debts: debts, isLoading: false),
    );
  }

  /// Add new debt
  Future<bool> createDebt(Debt debt) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await addDebt(debt);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (id) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Qarz muvaffaqiyatli qo\'shildi',
        );
        // Reload debts
        if (state.selectedDebtorId != null) {
          loadDebtsByDebtor(state.selectedDebtorId!);
        } else {
          loadDebts();
        }
        return true;
      },
    );
  }

  /// Update existing debt
  Future<bool> modifyDebt(Debt debt) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await updateDebt(debt);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Qarz muvaffaqiyatli yangilandi',
        );
        // Reload debts
        if (state.selectedDebtorId != null) {
          loadDebtsByDebtor(state.selectedDebtorId!);
        } else {
          loadDebts();
        }
        return true;
      },
    );
  }

  /// Delete debt
  Future<bool> removeDebt(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await deleteDebt(id);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Qarz muvaffaqiyatli o\'chirildi',
        );
        // Reload debts
        if (state.selectedDebtorId != null) {
          loadDebtsByDebtor(state.selectedDebtorId!);
        } else {
          loadDebts();
        }
        return true;
      },
    );
  }

  /// Add payment to debt
  Future<bool> createPayment(Payment payment) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await addPayment(payment);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (id) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'To\'lov muvaffaqiyatli qo\'shildi',
        );
        // Reload debts to update status
        if (state.selectedDebtorId != null) {
          loadDebtsByDebtor(state.selectedDebtorId!);
        } else {
          loadDebts();
        }
        return true;
      },
    );
  }

  /// Delete payment
  Future<bool> removePayment(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await deletePayment(id);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'To\'lov muvaffaqiyatli o\'chirildi',
        );
        // Reload debts to update status
        if (state.selectedDebtorId != null) {
          loadDebtsByDebtor(state.selectedDebtorId!);
        } else {
          loadDebts();
        }
        return true;
      },
    );
  }

  /// Clear messages
  void clearMessages() {
    state = state.clearMessages();
  }

  /// Clear debtor filter
  void clearFilter() {
    state = state.clearFilter();
    loadDebts();
  }
}
