import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/debtor.dart';
import '../../domain/repositories/debtor_repository.dart';
import '../datasources/debtor_local_datasource.dart';
import '../models/debtor_model.dart';

class DebtorRepositoryImpl implements DebtorRepository {
  final DebtorLocalDataSource localDataSource;

  DebtorRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Debtor>>> getAllDebtors() async {
    try {
      final debtors = await localDataSource.getAllDebtors();
      return Right(debtors);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Kutilmagan xatolik: $e'));
    }
  }

  @override
  Future<Either<Failure, Debtor>> getDebtorById(int id) async {
    try {
      final debtor = await localDataSource.getDebtorById(id);
      return Right(debtor);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Kutilmagan xatolik: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> addDebtor(Debtor debtor) async {
    try {
      final debtorModel = DebtorModel.fromEntity(debtor);
      final id = await localDataSource.addDebtor(debtorModel);
      return Right(id);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Kutilmagan xatolik: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateDebtor(Debtor debtor) async {
    try {
      final debtorModel = DebtorModel.fromEntity(debtor);
      await localDataSource.updateDebtor(debtorModel);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Kutilmagan xatolik: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDebtor(int id) async {
    try {
      await localDataSource.deleteDebtor(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Kutilmagan xatolik: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Debtor>>> searchDebtors(String query) async {
    try {
      final debtors = await localDataSource.searchDebtors(query);
      return Right(debtors);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Kutilmagan xatolik: $e'));
    }
  }
}
