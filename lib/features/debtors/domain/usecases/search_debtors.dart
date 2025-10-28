import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/debtor.dart';
import '../repositories/debtor_repository.dart';

class SearchDebtors {
  final DebtorRepository repository;

  SearchDebtors(this.repository);

  Future<Either<Failure, List<Debtor>>> call(String query) async {
    if (query.trim().isEmpty) {
      return const Right([]);
    }

    return await repository.searchDebtors(query);
  }
}
