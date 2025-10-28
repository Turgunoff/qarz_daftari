import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/debt.dart';
import '../repositories/debt_repository.dart';

class AddDebt {
  final DebtRepository repository;

  AddDebt(this.repository);

  Future<Either<Failure, int>> call(Debt debt) async {
    // Validation
    if (debt.amount <= 0) {
      return const Left(ValidationFailure('Qarz miqdori 0 dan katta bo\'lishi kerak'));
    }

    if (debt.description.trim().isEmpty) {
      return const Left(ValidationFailure('Qarz tavsifi kiritilishi shart'));
    }

    if (debt.description.trim().length < 3) {
      return const Left(
        ValidationFailure('Qarz tavsifi kamida 3 ta harfdan iborat bo\'lishi kerak'),
      );
    }

    if (debt.debtorId <= 0) {
      return const Left(ValidationFailure('Noto\'g\'ri qarzdor ID'));
    }

    return await repository.addDebt(debt);
  }
}
