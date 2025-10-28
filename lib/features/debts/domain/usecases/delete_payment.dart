import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/debt_repository.dart';

class DeletePayment {
  final DebtRepository repository;

  DeletePayment(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    // Validation
    if (id <= 0) {
      return const Left(ValidationFailure('Noto\'g\'ri to\'lov ID'));
    }

    return await repository.deletePayment(id);
  }
}
