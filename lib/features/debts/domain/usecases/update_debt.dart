import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/debt.dart';
import '../repositories/debt_repository.dart';

class UpdateDebt {
  final DebtRepository repository;

  UpdateDebt(this.repository);

  Future<Either<Failure, void>> call(Debt debt) async {
    // Validation
    if (debt.id == null || debt.id! <= 0) {
      return const Left(ValidationFailure('Noto\'g\'ri qarz ID'));
    }

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

    return await repository.updateDebt(debt);
  }
}
