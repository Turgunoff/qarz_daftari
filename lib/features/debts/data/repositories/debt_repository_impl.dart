import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/debt.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/debt_repository.dart';
import '../datasources/debt_local_datasource.dart';
import '../models/debt_model.dart';
import '../models/payment_model.dart';

class DebtRepositoryImpl implements DebtRepository {
  final DebtLocalDataSource localDataSource;

  DebtRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Debt>>> getAllDebts() async {
    try {
      final debts = await localDataSource.getAllDebts();
      return Right(debts);
    } on DebtDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Kutilmagan xatolik: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Debt>>> getDebtsByDebtorId(int debtorId) async {
    try {
      final debts = await localDataSource.getDebtsByDebtorId(debtorId);
      return Right(debts);
    } on DebtDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Kutilmagan xatolik: $e'));
    }
  }

  @override
  Future<Either<Failure, Debt>> getDebtById(int id) async {
    try {
      final debt = await localDataSource.getDebtById(id);
      return Right(debt);
    } on DebtDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Kutilmagan xatolik: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> addDebt(Debt debt) async {
    try {
      final debtModel = DebtModel.fromEntity(debt);
      final id = await localDataSource.addDebt(debtModel);
      return Right(id);
    } on DebtDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Kutilmagan xatolik: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateDebt(Debt debt) async {
    try {
      final debtModel = DebtModel.fromEntity(debt);
      await localDataSource.updateDebt(debtModel);
      return const Right(null);
    } on DebtDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Kutilmagan xatolik: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDebt(int id) async {
    try {
      await localDataSource.deleteDebt(id);
      return const Right(null);
    } on DebtDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Kutilmagan xatolik: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Payment>>> getPaymentsByDebtId(int debtId) async {
    try {
      final payments = await localDataSource.getPaymentsByDebtId(debtId);
      return Right(payments);
    } on DebtDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Kutilmagan xatolik: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> addPayment(Payment payment) async {
    try {
      final paymentModel = PaymentModel.fromEntity(payment);
      final id = await localDataSource.addPayment(paymentModel);
      return Right(id);
    } on DebtDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Kutilmagan xatolik: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePayment(int id) async {
    try {
      await localDataSource.deletePayment(id);
      return const Right(null);
    } on DebtDatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Kutilmagan xatolik: $e'));
    }
  }
}
