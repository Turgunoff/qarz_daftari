import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/debt.dart';
import '../repositories/debt_repository.dart';

class GetDebtsByDebtor {
  final DebtRepository repository;

  GetDebtsByDebtor(this.repository);

  Future<Either<Failure, List<Debt>>> call(int debtorId) async {
    // Validation
    if (debtorId <= 0) {
      return const Left(ValidationFailure('Noto\'g\'ri qarzdor ID'));
    }

    return await repository.getDebtsByDebtorId(debtorId);
  }
}
