import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/debtor.dart';
import '../repositories/debtor_repository.dart';

class GetAllDebtors {
  final DebtorRepository repository;

  GetAllDebtors(this.repository);

  Future<Either<Failure, List<Debtor>>> call() async {
    return await repository.getAllDebtors();
  }
}
