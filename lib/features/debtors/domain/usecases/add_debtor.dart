import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/debtor.dart';
import '../repositories/debtor_repository.dart';

class AddDebtor {
  final DebtorRepository repository;

  AddDebtor(this.repository);

  Future<Either<Failure, int>> call(Debtor debtor) async {
    // Validation
    if (debtor.name.trim().isEmpty) {
      return const Left(ValidationFailure('Ism kiritilishi shart'));
    }

    if (debtor.name.length < 2) {
      return const Left(
        ValidationFailure('Ism kamida 2 ta harfdan iborat bo\'lishi kerak'),
      );
    }

    return await repository.addDebtor(debtor);
  }
}
