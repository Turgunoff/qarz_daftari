import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/debt.dart';
import '../repositories/debt_repository.dart';

class GetDebts {
  final DebtRepository repository;

  GetDebts(this.repository);

  Future<Either<Failure, List<Debt>>> call() async {
    return await repository.getAllDebts();
  }
}
