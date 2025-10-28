import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/debtor.dart';
import '../repositories/debtor_repository.dart';

class UpdateDebtor {
  final DebtorRepository repository;

  UpdateDebtor(this.repository);

  Future<Either<Failure, void>> call(Debtor debtor) async {
    if (debtor.id == null) {
      return const Left(ValidationFailure('Qarzdor ID topilmadi'));
    }

    if (debtor.name.trim().isEmpty) {
      return const Left(ValidationFailure('Ism kiritilishi shart'));
    }

    return await repository.updateDebtor(debtor);
  }
}
