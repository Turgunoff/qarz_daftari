import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('qarz_daftari.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    // Qarzdorlar jadvali
    await db.execute('''
      CREATE TABLE debtors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        notes TEXT,
        total_debt REAL NOT NULL DEFAULT 0,
        total_paid REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Qarzlar jadvali
    await db.execute('''
      CREATE TABLE debts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        debtor_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        debt_date TEXT NOT NULL,
        due_date TEXT,
        status TEXT NOT NULL,
        currency TEXT NOT NULL DEFAULT 'UZS',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (debtor_id) REFERENCES debtors (id) ON DELETE CASCADE
      )
    ''');

    // To'lovlar jadvali
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        debt_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        payment_date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (debt_id) REFERENCES debts (id) ON DELETE CASCADE
      )
    ''');

    // Indekslar
    await db.execute('CREATE INDEX idx_debtor_id ON debts(debtor_id)');
    await db.execute('CREATE INDEX idx_debt_id ON payments(debt_id)');
    await db.execute('CREATE INDEX idx_debt_status ON debts(status)');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  // Debug: Delete database
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'qarz_daftari.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
