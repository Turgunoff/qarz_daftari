import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/payment.dart';
import '../repositories/debt_repository.dart';

class AddPayment {
  final DebtRepository repository;

  AddPayment(this.repository);

  Future<Either<Failure, int>> call(Payment payment) async {
    // Validation
    if (payment.amount <= 0) {
      return const Left(ValidationFailure('To\'lov miqdori 0 dan katta bo\'lishi kerak'));
    }

    if (payment.debtId <= 0) {
      return const Left(ValidationFailure('Noto\'g\'ri qarz ID'));
    }

    return await repository.addPayment(payment);
  }
}
