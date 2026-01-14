import 'package:flutter/material.dart';
import '../models/stock_item.dart';
import '../models/stock_transaction.dart';
import '../services/database_service.dart';

class StockProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<StockItem> items = [];
  List<StockTransaction> transactions = [];

  Future<void> loadAll() async {
    items = await _db.getItems();
    transactions = await _db.getTransactions();
    notifyListeners();
  }

  /// Seed the database with sample items (idempotent when called on empty DB)
  Future<void> seedSampleData() async {
    final samples = <Map<String, dynamic>>[
      {'name': 'Hammer', 'brand': 'Acme', 'quantity': 12, 'threshold': 3},
      {
        'name': 'Screwdriver',
        'brand': 'BoltCorp',
        'quantity': 25,
        'threshold': 5,
      },
      {'name': 'Wrench', 'brand': 'ToolWorks', 'quantity': 8, 'threshold': 2},
      {'name': 'Pliers', 'brand': 'GripIt', 'quantity': 15, 'threshold': 4},
      {
        'name': 'Tape Measure',
        'brand': 'MeasurePro',
        'quantity': 30,
        'threshold': 10,
      },
      {
        'name': 'Drill Bit Set',
        'brand': 'DrillMaster',
        'quantity': 20,
        'threshold': 5,
      },
      {
        'name': 'Circular Saw',
        'brand': 'CutRight',
        'quantity': 5,
        'threshold': 1,
      },
      {
        'name': 'Nails Box',
        'brand': 'FastenIt',
        'quantity': 200,
        'threshold': 50,
      },
      {
        'name': 'Screws Box',
        'brand': 'FastenIt',
        'quantity': 500,
        'threshold': 100,
      },
      {
        'name': 'Sandpaper Pack',
        'brand': 'SmoothFinish',
        'quantity': 40,
        'threshold': 10,
      },
    ];
    for (final s in samples) {
      await addItem(
        s['name'] as String,
        s['quantity'] as int,
        s['brand'] as String?,
        s['threshold'] as int,
      );
    }
    await loadAll();
  }

  /// If the database is empty, seed it with sample data.
  /// Returns true if seeding was performed.
  Future<bool> seedIfEmpty() async {
    await loadAll();
    if (items.isEmpty) {
      await seedSampleData();
      return true;
    }
    return false;
  }

  Future<void> addItem(
    String name,
    int quantity, [
    String? brand,
    int threshold = 0,
  ]) async {
    final item = StockItem(
      name: name,
      quantity: quantity,
      brand: brand,
      threshold: threshold,
    );
    final id = await _db.insertItem(item);
    item.id = id;
    items.add(item);
    if (quantity != 0) {
      final t = StockTransaction(
        itemId: id,
        delta: quantity,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        note: 'Initial',
      );
      await _db.insertTransaction(t);
      transactions.insert(0, t);
    }
    notifyListeners();
  }

  Future<void> updateItem(StockItem item) async {
    await _db.updateItem(item);
    final idx = items.indexWhere((i) => i.id == item.id);
    if (idx != -1) items[idx] = item;
    notifyListeners();
  }

  Future<void> deleteItem(int itemId) async {
    await _db.deleteItem(itemId);
    items.removeWhere((i) => i.id == itemId);
    transactions.removeWhere((t) => t.itemId == itemId);
    notifyListeners();
  }

  Future<Map<String, dynamic>> exportData() async {
    return await _db.exportData();
  }

  Future<void> importData(Map<String, dynamic> data) async {
    await _db.importData(data);
    await loadAll();
  }

  Future<void> _applyTransaction(int itemId, int delta, String? note) async {
    final item = items.firstWhere((i) => i.id == itemId);
    item.quantity += delta;
    await _db.updateItem(item);
    final t = StockTransaction(
      itemId: itemId,
      delta: delta,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      note: note,
    );
    final tId = await _db.insertTransaction(t);
    t.id = tId;
    transactions.insert(0, t);
    notifyListeners();
  }

  Future<void> stockIn(int itemId, int amount, [String? note]) async {
    if (amount <= 0) return;
    await _applyTransaction(itemId, amount, note ?? 'Stock In');
  }

  Future<void> stockOut(int itemId, int amount, [String? note]) async {
    if (amount <= 0) return;
    await _applyTransaction(itemId, -amount, note ?? 'Stock Out');
  }

  /// Set an item's quantity to an exact value by applying the needed delta
  Future<void> setQuantity(int itemId, int newQuantity, [String? note]) async {
    final item = items.firstWhere((i) => i.id == itemId);
    final delta = newQuantity - item.quantity;
    if (delta == 0) return;
    await _applyTransaction(itemId, delta, note ?? 'Set Quantity');
  }

  /// Returns the most recent transaction for an item, or null.
  StockTransaction? lastTransactionFor(int itemId) {
    for (final t in transactions) {
      if (t.itemId == itemId) return t;
    }
    return null;
  }
}
