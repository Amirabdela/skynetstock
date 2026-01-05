import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/stock_item.dart';
import '../models/stock_transaction.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'skystoc.db');
    _db = await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        brand TEXT,
        threshold INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        delta INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        note TEXT,
        FOREIGN KEY(item_id) REFERENCES items(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE items ADD COLUMN brand TEXT');
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE items ADD COLUMN threshold INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  Future<int> deleteItem(int id) async {
    final database = await db;
    await database.delete(
      'transactions',
      where: 'item_id = ?',
      whereArgs: [id],
    );
    return await database.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>> exportData() async {
    final database = await db;
    final itemsRows = await database.query('items');
    final txRows = await database.query('transactions');
    return {'items': itemsRows, 'transactions': txRows};
  }

  Future<void> importData(Map<String, dynamic> data) async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('items');
      final items = (data['items'] as List).cast<Map<String, dynamic>>();
      for (final it in items) {
        final map = Map<String, dynamic>.from(it);
        await txn.insert('items', map);
      }
      final txs = (data['transactions'] as List).cast<Map<String, dynamic>>();
      for (final t in txs) {
        final map = Map<String, dynamic>.from(t);
        await txn.insert('transactions', map);
      }
    });
  }

  Future<int> insertItem(StockItem item) async {
    final database = await db;
    return await database.insert('items', item.toMap());
  }

  Future<List<StockItem>> getItems() async {
    final database = await db;
    final rows = await database.query('items', orderBy: 'name');
    return rows.map((r) => StockItem.fromMap(r)).toList();
  }

  Future<int> updateItem(StockItem item) async {
    final database = await db;
    return await database.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> insertTransaction(StockTransaction t) async {
    final database = await db;
    return await database.insert('transactions', t.toMap());
  }

  Future<List<StockTransaction>> getTransactions() async {
    final database = await db;
    final rows = await database.query(
      'transactions',
      orderBy: 'timestamp DESC',
    );
    return rows.map((r) => StockTransaction.fromMap(r)).toList();
  }
}
