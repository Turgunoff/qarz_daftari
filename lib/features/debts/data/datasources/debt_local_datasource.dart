import 'package:sqflite/sqflite.dart' as sqflite;
import '../../../../core/database/database_helper.dart';
import '../models/debt_model.dart';
import '../models/payment_model.dart';

/// Debt datasource uchun maxsus exception
class DebtDatabaseException implements Exception {
  final String message;

  const DebtDatabaseException(this.message);

  @override
  String toString() => message;
}

/// Debt Local Data Source - Abstract class
abstract class DebtLocalDataSource {
  /// Barcha qarzlarni olish
  Future<List<DebtModel>> getAllDebts();

  /// Qarzdor ID bo'yicha qarzlarni olish
  Future<List<DebtModel>> getDebtsByDebtorId(int debtorId);

  /// ID bo'yicha qarzni olish
  Future<DebtModel> getDebtById(int id);

  /// Yangi qarz qo'shish
  Future<int> addDebt(DebtModel debt);

  /// Qarzni yangilash
  Future<void> updateDebt(DebtModel debt);

  /// Qarzni o'chirish
  Future<void> deleteDebt(int id);

  // Payment methods
  /// Qarz ID bo'yicha to'lovlarni olish
  Future<List<PaymentModel>> getPaymentsByDebtId(int debtId);

  /// Yangi to'lov qo'shish
  Future<int> addPayment(PaymentModel payment);

  /// To'lovni o'chirish
  Future<void> deletePayment(int id);
}

/// Debt Local Data Source Implementation
class DebtLocalDataSourceImpl implements DebtLocalDataSource {
  final DatabaseHelper databaseHelper;

  DebtLocalDataSourceImpl(this.databaseHelper);

  @override
  Future<List<DebtModel>> getAllDebts() async {
    try {
      final db = await databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'debts',
        orderBy: 'debt_date DESC',
      );

      if (maps.isEmpty) {
        return [];
      }

      return maps.map((map) => DebtModel.fromJson(map)).toList();
    } on DatabaseException catch (e) {
      throw DebtDatabaseException(
        'Qarzlarni yuklashda xatolik: ${e.toString()}',
      );
    } catch (e) {
      throw DebtDatabaseException(
        'Qarzlarni yuklashda kutilmagan xatolik: $e',
      );
    }
  }

  @override
  Future<List<DebtModel>> getDebtsByDebtorId(int debtorId) async {
    try {
      final db = await databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'debts',
        where: 'debtor_id = ?',
        whereArgs: [debtorId],
        orderBy: 'debt_date DESC',
      );

      if (maps.isEmpty) {
        return [];
      }

      return maps.map((map) => DebtModel.fromJson(map)).toList();
    } on sqflite.DatabaseException catch (e) {
      throw DebtDatabaseException(
        'Qarzlarni yuklashda xatolik: ${e.toString()}',
      );
    } catch (e) {
      throw DebtDatabaseException(
        'Qarzlarni yuklashda kutilmagan xatolik: $e',
      );
    }
  }

  @override
  Future<DebtModel> getDebtById(int id) async {
    try {
      final db = await databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'debts',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        throw DebtDatabaseException('ID: $id bo\'lgan qarz topilmadi');
      }

      return DebtModel.fromJson(maps.first);
    } on DebtDatabaseException {
      rethrow;
    } on sqflite.DatabaseException catch (e) {
      throw DebtDatabaseException(
        'Qarzni yuklashda xatolik: ${e.toString()}',
      );
    } catch (e) {
      throw DebtDatabaseException(
        'Qarzni yuklashda kutilmagan xatolik: $e',
      );
    }
  }

  @override
  Future<int> addDebt(DebtModel debt) async {
    final db = await databaseHelper.database;

    try {
      // Start transaction
      return await db.transaction((txn) async {
        // Validate debt data
        if (debt.amount <= 0) {
          throw DebtDatabaseException(
            'Qarz miqdori 0 dan katta bo\'lishi kerak',
          );
        }

        if (debt.description.trim().isEmpty) {
          throw DebtDatabaseException(
            'Qarz tavsifi bo\'sh bo\'lishi mumkin emas',
          );
        }

        // Check if debtor exists
        final List<Map<String, dynamic>> debtorCheck = await txn.query(
          'debtors',
          where: 'id = ?',
          whereArgs: [debt.debtorId],
          limit: 1,
        );

        if (debtorCheck.isEmpty) {
          throw DebtDatabaseException('Qarzdor topilmadi');
        }

        final Map<String, dynamic> data = debt.toJson();
        data.remove('id');

        // Insert debt
        final int debtId = await txn.insert(
          'debts',
          data,
          conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
        );

        if (debtId <= 0) {
          throw DebtDatabaseException('Qarz qo\'shishda xatolik yuz berdi');
        }

        // Update debtor totals
        final double currentDebt = debtorCheck.first['total_debt'] as double;
        await txn.update(
          'debtors',
          {
            'total_debt': currentDebt + debt.amount,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [debt.debtorId],
        );

        return debtId;
      });
    } on DebtDatabaseException {
      rethrow;
    } on sqflite.DatabaseException catch (e) {
      throw DebtDatabaseException(
        'Qarz qo\'shishda xatolik: ${e.toString()}',
      );
    } catch (e) {
      throw DebtDatabaseException(
        'Qarz qo\'shishda kutilmagan xatolik: $e',
      );
    }
  }

  @override
  Future<void> updateDebt(DebtModel debt) async {
    final db = await databaseHelper.database;

    try {
      // Start transaction
      await db.transaction((txn) async {
        // Validate
        if (debt.id == null || debt.id! <= 0) {
          throw DebtDatabaseException('Noto\'g\'ri qarz ID');
        }

        if (debt.amount <= 0) {
          throw DebtDatabaseException(
            'Qarz miqdori 0 dan katta bo\'lishi kerak',
          );
        }

        if (debt.description.trim().isEmpty) {
          throw DebtDatabaseException(
            'Qarz tavsifi bo\'sh bo\'lishi mumkin emas',
          );
        }

        // Get old debt to calculate difference
        final List<Map<String, dynamic>> oldDebtMaps = await txn.query(
          'debts',
          where: 'id = ?',
          whereArgs: [debt.id],
          limit: 1,
        );

        if (oldDebtMaps.isEmpty) {
          throw DebtDatabaseException(
            'ID: ${debt.id} bo\'lgan qarz topilmadi',
          );
        }

        final double oldAmount = oldDebtMaps.first['amount'] as double;
        final double amountDifference = debt.amount - oldAmount;

        // Update debt
        final int count = await txn.update(
          'debts',
          debt.toJson(),
          where: 'id = ?',
          whereArgs: [debt.id],
        );

        if (count == 0) {
          throw DebtDatabaseException(
            'ID: ${debt.id} bo\'lgan qarz topilmadi',
          );
        }

        // Update debtor totals if amount changed
        if (amountDifference != 0) {
          final List<Map<String, dynamic>> debtorMaps = await txn.query(
            'debtors',
            where: 'id = ?',
            whereArgs: [debt.debtorId],
            limit: 1,
          );

          if (debtorMaps.isNotEmpty) {
            final double currentDebt = debtorMaps.first['total_debt'] as double;
            await txn.update(
              'debtors',
              {
                'total_debt': currentDebt + amountDifference,
                'updated_at': DateTime.now().toIso8601String(),
              },
              where: 'id = ?',
              whereArgs: [debt.debtorId],
            );
          }
        }
      });
    } on DebtDatabaseException {
      rethrow;
    } on sqflite.DatabaseException catch (e) {
      throw DebtDatabaseException(
        'Qarzni yangilashda xatolik: ${e.toString()}',
      );
    } catch (e) {
      throw DebtDatabaseException(
        'Qarzni yangilashda kutilmagan xatolik: $e',
      );
    }
  }

  @override
  Future<void> deleteDebt(int id) async {
    final db = await databaseHelper.database;

    try {
      // Start transaction
      await db.transaction((txn) async {
        if (id <= 0) {
          throw DebtDatabaseException('Noto\'g\'ri qarz ID');
        }

        // Get debt info before deletion
        final List<Map<String, dynamic>> debtMaps = await txn.query(
          'debts',
          where: 'id = ?',
          whereArgs: [id],
          limit: 1,
        );

        if (debtMaps.isEmpty) {
          throw DebtDatabaseException('ID: $id bo\'lgan qarz topilmadi');
        }

        final int debtorId = debtMaps.first['debtor_id'] as int;
        final double debtAmount = debtMaps.first['amount'] as double;

        // Get total payments for this debt
        final List<Map<String, dynamic>> paymentMaps = await txn.rawQuery(
          'SELECT SUM(amount) as total FROM payments WHERE debt_id = ?',
          [id],
        );

        final double totalPaid = (paymentMaps.first['total'] as double?) ?? 0.0;

        // Delete debt (payments will be deleted automatically due to CASCADE)
        final int count = await txn.delete(
          'debts',
          where: 'id = ?',
          whereArgs: [id],
        );

        if (count == 0) {
          throw DebtDatabaseException('ID: $id bo\'lgan qarz topilmadi');
        }

        // Update debtor totals
        final List<Map<String, dynamic>> debtorMaps = await txn.query(
          'debtors',
          where: 'id = ?',
          whereArgs: [debtorId],
          limit: 1,
        );

        if (debtorMaps.isNotEmpty) {
          final double currentDebt = debtorMaps.first['total_debt'] as double;
          final double currentPaid = debtorMaps.first['total_paid'] as double;

          await txn.update(
            'debtors',
            {
              'total_debt': currentDebt - debtAmount,
              'total_paid': currentPaid - totalPaid,
              'updated_at': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [debtorId],
          );
        }
      });
    } on DebtDatabaseException {
      rethrow;
    } on sqflite.DatabaseException catch (e) {
      throw DebtDatabaseException(
        'Qarzni o\'chirishda xatolik: ${e.toString()}',
      );
    } catch (e) {
      throw DebtDatabaseException(
        'Qarzni o\'chirishda kutilmagan xatolik: $e',
      );
    }
  }

  @override
  Future<List<PaymentModel>> getPaymentsByDebtId(int debtId) async {
    try {
      final db = await databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'payments',
        where: 'debt_id = ?',
        whereArgs: [debtId],
        orderBy: 'payment_date DESC',
      );

      if (maps.isEmpty) {
        return [];
      }

      return maps.map((map) => PaymentModel.fromJson(map)).toList();
    } on sqflite.DatabaseException catch (e) {
      throw DebtDatabaseException(
        'To\'lovlarni yuklashda xatolik: ${e.toString()}',
      );
    } catch (e) {
      throw DebtDatabaseException(
        'To\'lovlarni yuklashda kutilmagan xatolik: $e',
      );
    }
  }

  @override
  Future<int> addPayment(PaymentModel payment) async {
    final db = await databaseHelper.database;

    try {
      // Start transaction
      return await db.transaction((txn) async {
        // Validate payment data
        if (payment.amount <= 0) {
          throw DebtDatabaseException(
            'To\'lov miqdori 0 dan katta bo\'lishi kerak',
          );
        }

        // Get debt info
        final List<Map<String, dynamic>> debtMaps = await txn.query(
          'debts',
          where: 'id = ?',
          whereArgs: [payment.debtId],
          limit: 1,
        );

        if (debtMaps.isEmpty) {
          throw DebtDatabaseException('Qarz topilmadi');
        }

        final int debtorId = debtMaps.first['debtor_id'] as int;
        final double debtAmount = debtMaps.first['amount'] as double;

        // Get total payments for this debt
        final List<Map<String, dynamic>> totalPaymentMaps = await txn.rawQuery(
          'SELECT SUM(amount) as total FROM payments WHERE debt_id = ?',
          [payment.debtId],
        );

        final double totalPaid = (totalPaymentMaps.first['total'] as double?) ?? 0.0;

        // Check if payment exceeds debt
        if (totalPaid + payment.amount > debtAmount) {
          throw DebtDatabaseException(
            'To\'lov miqdori qoldiq qarzdan oshib ketmasligi kerak',
          );
        }

        final Map<String, dynamic> data = payment.toJson();
        data.remove('id');

        // Insert payment
        final int paymentId = await txn.insert(
          'payments',
          data,
          conflictAlgorithm: sqflite.ConflictAlgorithm.abort,
        );

        if (paymentId <= 0) {
          throw DebtDatabaseException('To\'lov qo\'shishda xatolik yuz berdi');
        }

        // Update debtor totals
        final List<Map<String, dynamic>> debtorMaps = await txn.query(
          'debtors',
          where: 'id = ?',
          whereArgs: [debtorId],
          limit: 1,
        );

        if (debtorMaps.isNotEmpty) {
          final double currentPaid = debtorMaps.first['total_paid'] as double;
          await txn.update(
            'debtors',
            {
              'total_paid': currentPaid + payment.amount,
              'updated_at': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [debtorId],
          );
        }

        // Update debt status
        final double newTotalPaid = totalPaid + payment.amount;
        String newStatus;
        if (newTotalPaid >= debtAmount) {
          newStatus = 'paid';
        } else if (newTotalPaid > 0) {
          newStatus = 'partial';
        } else {
          newStatus = debtMaps.first['status'] as String;
        }

        await txn.update(
          'debts',
          {
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [payment.debtId],
        );

        return paymentId;
      });
    } on DebtDatabaseException {
      rethrow;
    } on sqflite.DatabaseException catch (e) {
      throw DebtDatabaseException(
        'To\'lov qo\'shishda xatolik: ${e.toString()}',
      );
    } catch (e) {
      throw DebtDatabaseException(
        'To\'lov qo\'shishda kutilmagan xatolik: $e',
      );
    }
  }

  @override
  Future<void> deletePayment(int id) async {
    final db = await databaseHelper.database;

    try {
      // Start transaction
      await db.transaction((txn) async {
        if (id <= 0) {
          throw DebtDatabaseException('Noto\'g\'ri to\'lov ID');
        }

        // Get payment info before deletion
        final List<Map<String, dynamic>> paymentMaps = await txn.query(
          'payments',
          where: 'id = ?',
          whereArgs: [id],
          limit: 1,
        );

        if (paymentMaps.isEmpty) {
          throw DebtDatabaseException('ID: $id bo\'lgan to\'lov topilmadi');
        }

        final int debtId = paymentMaps.first['debt_id'] as int;
        final double paymentAmount = paymentMaps.first['amount'] as double;

        // Get debt info
        final List<Map<String, dynamic>> debtMaps = await txn.query(
          'debts',
          where: 'id = ?',
          whereArgs: [debtId],
          limit: 1,
        );

        if (debtMaps.isEmpty) {
          throw DebtDatabaseException('Qarz topilmadi');
        }

        final int debtorId = debtMaps.first['debtor_id'] as int;
        final double debtAmount = debtMaps.first['amount'] as double;

        // Delete payment
        final int count = await txn.delete(
          'payments',
          where: 'id = ?',
          whereArgs: [id],
        );

        if (count == 0) {
          throw DebtDatabaseException('ID: $id bo\'lgan to\'lov topilmadi');
        }

        // Get new total payments
        final List<Map<String, dynamic>> totalPaymentMaps = await txn.rawQuery(
          'SELECT SUM(amount) as total FROM payments WHERE debt_id = ?',
          [debtId],
        );

        final double newTotalPaid = (totalPaymentMaps.first['total'] as double?) ?? 0.0;

        // Update debtor totals
        final List<Map<String, dynamic>> debtorMaps = await txn.query(
          'debtors',
          where: 'id = ?',
          whereArgs: [debtorId],
          limit: 1,
        );

        if (debtorMaps.isNotEmpty) {
          final double currentPaid = debtorMaps.first['total_paid'] as double;
          await txn.update(
            'debtors',
            {
              'total_paid': currentPaid - paymentAmount,
              'updated_at': DateTime.now().toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [debtorId],
          );
        }

        // Update debt status
        String newStatus;
        if (newTotalPaid >= debtAmount) {
          newStatus = 'paid';
        } else if (newTotalPaid > 0) {
          newStatus = 'partial';
        } else {
          newStatus = 'active';
        }

        await txn.update(
          'debts',
          {
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [debtId],
        );
      });
    } on DebtDatabaseException {
      rethrow;
    } on sqflite.DatabaseException catch (e) {
      throw DebtDatabaseException(
        'To\'lovni o\'chirishda xatolik: ${e.toString()}',
      );
    } catch (e) {
      throw DebtDatabaseException(
        'To\'lovni o\'chirishda kutilmagan xatolik: $e',
      );
    }
  }
}
