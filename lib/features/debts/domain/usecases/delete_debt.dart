import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/debt_repository.dart';

class DeleteDebt {
  final DebtRepository repository;

  DeleteDebt(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    // Validation
    if (id <= 0) {
      return const Left(ValidationFailure('Noto\'g\'ri qarz ID'));
    }

    return await repository.deleteDebt(id);
  }
}
