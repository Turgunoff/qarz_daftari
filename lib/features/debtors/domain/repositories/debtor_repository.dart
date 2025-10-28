import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/debtor.dart';

abstract class DebtorRepository {
  Future<Either<Failure, List<Debtor>>> getAllDebtors();
  Future<Either<Failure, Debtor>> getDebtorById(int id);
  Future<Either<Failure, int>> addDebtor(Debtor debtor);
  Future<Either<Failure, void>> updateDebtor(Debtor debtor);
  Future<Either<Failure, void>> deleteDebtor(int id);
  Future<Either<Failure, List<Debtor>>> searchDebtors(String query);
}
