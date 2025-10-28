import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/payment.dart';
import '../repositories/debt_repository.dart';

class GetPayments {
  final DebtRepository repository;

  GetPayments(this.repository);

  Future<Either<Failure, List<Payment>>> call(int debtId) async {
    // Validation
    if (debtId <= 0) {
      return const Left(ValidationFailure('Noto\'g\'ri qarz ID'));
    }

    return await repository.getPaymentsByDebtId(debtId);
  }
}
