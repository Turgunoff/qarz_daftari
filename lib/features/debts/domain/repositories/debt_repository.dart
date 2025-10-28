import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/debt.dart';
import '../entities/payment.dart';

abstract class DebtRepository {
  Future<Either<Failure, List<Debt>>> getAllDebts();
  Future<Either<Failure, List<Debt>>> getDebtsByDebtorId(int debtorId);
  Future<Either<Failure, Debt>> getDebtById(int id);
  Future<Either<Failure, int>> addDebt(Debt debt);
  Future<Either<Failure, void>> updateDebt(Debt debt);
  Future<Either<Failure, void>> deleteDebt(int id);

  // Payment methods
  Future<Either<Failure, List<Payment>>> getPaymentsByDebtId(int debtId);
  Future<Either<Failure, int>> addPayment(Payment payment);
  Future<Either<Failure, void>> deletePayment(int id);
}
