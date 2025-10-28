import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/debtor_repository.dart';

class DeleteDebtor {
  final DebtorRepository repository;

  DeleteDebtor(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteDebtor(id);
  }
}
