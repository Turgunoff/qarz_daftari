import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/debtor_model.dart';

/// Debtor datasource uchun maxsus exception
class DebtorDatabaseException implements Exception {
  final String message;

  const DebtorDatabaseException(this.message);

  @override
  String toString() => message;
}

/// Debtor Local Data Source - Abstract class
abstract class DebtorLocalDataSource {
  /// Barcha qarzdorlarni olish
  Future<List<DebtorModel>> getAllDebtors();

  /// ID bo'yicha qarzdorni olish
  Future<DebtorModel> getDebtorById(int id);

  /// Yangi qarzdor qo'shish
  Future<int> addDebtor(DebtorModel debtor);

  /// Qarzdorni yangilash
  Future<void> updateDebtor(DebtorModel debtor);

  /// Qarzdorni o'chirish
  Future<void> deleteDebtor(int id);

  /// Qarzdorlarni qidirish
  Future<List<DebtorModel>> searchDebtors(String query);

  /// Qarzdorning umumiy qarzini yangilash
  Future<void> updateDebtorTotals(
    int debtorId,
    double totalDebt,
    double totalPaid,
  );
}

/// Debtor Local Data Source Implementation
class DebtorLocalDataSourceImpl implements DebtorLocalDataSource {
  final DatabaseHelper databaseHelper;

  DebtorLocalDataSourceImpl(this.databaseHelper);

  @override
  Future<List<DebtorModel>> getAllDebtors() async {
    try {
      final db = await databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'debtors',
        orderBy: 'name COLLATE NOCASE ASC',
      );

      if (maps.isEmpty) {
        return [];
      }

      return maps.map((map) => DebtorModel.fromJson(map)).toList();
    } on DatabaseException catch (e) {
      throw DebtorDatabaseException(
        'Qarzdorlarni yuklashda xatolik: ${e.toString()}',
      );
    } catch (e) {
      throw DebtorDatabaseException(
        'Qarzdorlarni yuklashda kutilmagan xatolik: $e',
      );
    }
  }

  @override
  Future<DebtorModel> getDebtorById(int id) async {
    try {
      final db = await databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'debtors',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        throw DebtorDatabaseException('ID: $id bo\'lgan qarzdor topilmadi');
      }

      return DebtorModel.fromJson(maps.first);
    } on DebtorDatabaseException {
      rethrow;
    } on DatabaseException catch (e) {
      throw DebtorDatabaseException(
        'Qarzdorni yuklashda xatolik: ${e.toString()}',
      );
    } catch (e) {
      throw DebtorDatabaseException(
        'Qarzdorni yuklashda kutilmagan xatolik: $e',
      );
    }
  }

  @override
  Future<int> addDebtor(DebtorModel debtor) async {
    try {
      final db = await databaseHelper.database;

      // Validate debtor data
      if (debtor.name.trim().isEmpty) {
        throw DebtorDatabaseException(
          'Qarzdor ismi bo\'sh bo\'lishi mumkin emas',
        );
      }

      final Map<String, dynamic> data = debtor.toJson();

      // Remove id from insert data
      data.remove('id');

      final int id = await db.insert(
        'debtors',
        data,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      if (id <= 0) {
        throw DebtorDatabaseException('Qarzdor qo\'shishda xatolik yuz berdi');
      }

      return id;
    } on DebtorDatabaseException {
      rethrow;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw DebtorDatabaseException('Bu qarzdor allaqachon mavjud');
      }
      throw DebtorDatabaseException(
        'Qarzdor qo\'shishda xatolik: ${e.toString()}',
      );
    } catch (e) {
      throw DebtorDatabaseException(
        'Qarzdor qo\'shishda kutilmagan xatolik: $e',
      );
    }
  }

  @override
  Future<void> updateDebtor(DebtorModel debtor) async {
    try {
      final db = await databaseHelper.database;

      // Validate
      if (debtor.id == null || debtor.id! <= 0) {
        throw DebtorDatabaseException('Noto\'g\'ri qarzdor ID');
      }

      if (debtor.name.trim().isEmpty) {
        throw DebtorDatabaseException(
          'Qarzdor ismi bo\'sh bo\'lishi mumkin emas',
        );
      }

      final int count = await db.update(
        'debtors',
        debtor.toJson(),
        where: 'id = ?',
        whereArgs: [debtor.id],
      );

      if (count == 0) {
        throw DebtorDatabaseException(
          'ID: ${debtor.id} bo\'lgan qarzdor topilmadi',
        );
      }
    } on DebtorDatabaseException {
      rethrow;
    } on DatabaseException catch (e) {
      throw DebtorDatabaseException(
        'Qarzdorni yangilashda xatolik: ${e.toString()}',
      );
    } catch (e) {
      throw DebtorDatabaseException(
        'Qarzdorni yangilashda kutilmagan xatolik: $e',
      );
    }
  }

  @override
  Future<void> deleteDebtor(int id) async {
    try {
      final db = await databaseHelper.database;

      if (id <= 0) {
        throw DebtorDatabaseException('Noto\'g\'ri qarzdor ID');
      }

      // Check if debtor has active debts
      final List<Map<String, dynamic>> debts = await db.query(
        'debts',
        where: 'debtor_id = ? AND status != ?',
        whereArgs: [id, 'paid'],
        limit: 1,
      );

      if (debts.isNotEmpty) {
        throw DebtorDatabaseException(
          'Bu qarzdorni o\'chirish mumkin emas, chunki faol qarzlari mavjud',
        );
      }

      final int count = await db.delete(
        'debtors',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw DebtorDatabaseException('ID: $id bo\'lgan qarzdor topilmadi');
      }
    } on DebtorDatabaseException {
      rethrow;
    } on DatabaseException catch (e) {
      throw DebtorDatabaseException(
        'Qarzdorni o\'chirishda xatolik: ${e.toString()}',
      );
    } catch (e) {
      throw DebtorDatabaseException(
        'Qarzdorni o\'chirishda kutilmagan xatolik: $e',
      );
    }
  }

  @override
  Future<List<DebtorModel>> searchDebtors(String query) async {
    try {
      final db = await databaseHelper.database;

      if (query.trim().isEmpty) {
        return [];
      }

      final String searchQuery = '%${query.trim()}%';

      final List<Map<String, dynamic>> maps = await db.query(
        'debtors',
        where: 'name LIKE ? OR phone LIKE ? OR address LIKE ?',
        whereArgs: [searchQuery, searchQuery, searchQuery],
        orderBy: 'name COLLATE NOCASE ASC',
      );

      if (maps.isEmpty) {
        return [];
      }

      return maps.map((map) => DebtorModel.fromJson(map)).toList();
    } on DatabaseException catch (e) {
      throw DebtorDatabaseException('Qidirishda xatolik: ${e.toString()}');
    } catch (e) {
      throw DebtorDatabaseException('Qidirishda kutilmagan xatolik: $e');
    }
  }

  @override
  Future<void> updateDebtorTotals(
    int debtorId,
    double totalDebt,
    double totalPaid,
  ) async {
    try {
      final db = await databaseHelper.database;

      if (debtorId <= 0) {
        throw DebtorDatabaseException('Noto\'g\'ri qarzdor ID');
      }

      if (totalDebt < 0 || totalPaid < 0) {
        throw DebtorDatabaseException(
          'Qarz va to\'lov manfiy bo\'lishi mumkin emas',
        );
      }

      final int count = await db.update(
        'debtors',
        {
          'total_debt': totalDebt,
          'total_paid': totalPaid,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [debtorId],
      );

      if (count == 0) {
        throw DebtorDatabaseException(
          'ID: $debtorId bo\'lgan qarzdor topilmadi',
        );
      }
    } on DebtorDatabaseException {
      rethrow;
    } on DatabaseException catch (e) {
      throw DebtorDatabaseException(
        'Qarzdor jami summalarini yangilashda xatolik: ${e.toString()}',
      );
    } catch (e) {
      throw DebtorDatabaseException(
        'Qarzdor jami summalarini yangilashda kutilmagan xatolik: $e',
      );
    }
  }
}

/// Extension for checking unique constraint errors
extension DatabaseExceptionX on DatabaseException {
  bool isUniqueConstraintError() {
    return toString().toLowerCase().contains('unique');
  }
}
