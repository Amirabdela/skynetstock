// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:convert';
import 'dart:html' as html;
import '../models/stock_item.dart';
import '../models/stock_transaction.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const _itemsKey = 'skystoc_items';
  static const _txKey = 'skystoc_transactions';
  static const _nextItemIdKey = 'skystoc_next_item_id';
  static const _nextTxIdKey = 'skystoc_next_tx_id';

  List<StockItem> _itemsCache = [];
  List<StockTransaction> _txCache = [];

  int _nextItemId() {
    final s = html.window.localStorage[_nextItemIdKey];
    final v = s == null ? 1 : int.tryParse(s) ?? 1;
    html.window.localStorage[_nextItemIdKey] = (v + 1).toString();
    return v;
  }

  int _nextTxId() {
    final s = html.window.localStorage[_nextTxIdKey];
    final v = s == null ? 1 : int.tryParse(s) ?? 1;
    html.window.localStorage[_nextTxIdKey] = (v + 1).toString();
    return v;
  }

  List<StockItem> _loadItems() {
    final s = html.window.localStorage[_itemsKey];
    if (s == null) return [];
    final list = json.decode(s) as List<dynamic>;
    return list.map((e) => StockItem.fromMap(Map<String, dynamic>.from(e as Map))).toList();
  }

  List<StockTransaction> _loadTx() {
    final s = html.window.localStorage[_txKey];
    if (s == null) return [];
    final list = json.decode(s) as List<dynamic>;
    return list.map((e) => StockTransaction.fromMap(Map<String, dynamic>.from(e as Map))).toList();
  }

  void _saveItems() {
    final s = json.encode(_itemsCache.map((e) => e.toMap()).toList());
    html.window.localStorage[_itemsKey] = s;
  }

  void _saveTx() {
    final s = json.encode(_txCache.map((e) => e.toMap()).toList());
    html.window.localStorage[_txKey] = s;
  }

  Future<int> insertItem(StockItem item) async {
    _itemsCache = _loadItems();
    final id = _nextItemId();
    item.id = id;
    _itemsCache.add(item);
    _saveItems();
    return id;
  }

  Future<List<StockItem>> getItems() async {
    _itemsCache = _loadItems();
    _itemsCache.sort((a, b) => a.name.compareTo(b.name));
    return _itemsCache;
  }

  Future<int> updateItem(StockItem item) async {
    _itemsCache = _loadItems();
    final idx = _itemsCache.indexWhere((e) => e.id == item.id);
    if (idx != -1) _itemsCache[idx] = item;
    _saveItems();
    return 1;
  }

  Future<int> insertTransaction(StockTransaction t) async {
    _txCache = _loadTx();
    final id = _nextTxId();
    t.id = id;
    _txCache.insert(0, t);
    _saveTx();
    return id;
  }

  Future<List<StockTransaction>> getTransactions() async {
    _txCache = _loadTx();
    _txCache.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return _txCache;
  }
}
import 'dart:convert';
import 'dart:html' as html;
import '../models/stock_item.dart';
import '../models/stock_transaction.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const _itemsKey = 'skystoc_items';
  static const _txKey = 'skystoc_transactions';
  static const _nextItemIdKey = 'skystoc_next_item_id';
  static const _nextTxIdKey = 'skystoc_next_tx_id';

  List<StockItem> _itemsCache = [];
  List<StockTransaction> _txCache = [];

  int _nextItemId() {
    final s = html.window.localStorage[_nextItemIdKey];
    final v = s == null ? 1 : int.tryParse(s) ?? 1;
    html.window.localStorage[_nextItemIdKey] = (v + 1).toString();
    return v;
  }

  int _nextTxId() {
    final s = html.window.localStorage[_nextTxIdKey];
    final v = s == null ? 1 : int.tryParse(s) ?? 1;
    html.window.localStorage[_nextTxIdKey] = (v + 1).toString();
    return v;
  }

  List<StockItem> _loadItems() {
    final s = html.window.localStorage[_itemsKey];
    if (s == null) return [];
    final list = json.decode(s) as List<dynamic>;
    return list.map((e) => StockItem.fromMap(Map<String, dynamic>.from(e as Map))).toList();
  }

  List<StockTransaction> _loadTx() {
    final s = html.window.localStorage[_txKey];
    if (s == null) return [];
    final list = json.decode(s) as List<dynamic>;
    return list.map((e) => StockTransaction.fromMap(Map<String, dynamic>.from(e as Map))).toList();
  }

  void _saveItems() {
    final s = json.encode(_itemsCache.map((e) => e.toMap()).toList());
    html.window.localStorage[_itemsKey] = s;
  }

  void _saveTx() {
    final s = json.encode(_txCache.map((e) => e.toMap()).toList());
    html.window.localStorage[_txKey] = s;
  }

  Future<int> insertItem(StockItem item) async {
    _itemsCache = _loadItems();
    final id = _nextItemId();
    item.id = id;
    _itemsCache.add(item);
    _saveItems();
    return id;
  }

  Future<List<StockItem>> getItems() async {
    _itemsCache = _loadItems();
    _itemsCache.sort((a, b) => a.name.compareTo(b.name));
    return _itemsCache;
  }

  Future<int> updateItem(StockItem item) async {
    _itemsCache = _loadItems();
    final idx = _itemsCache.indexWhere((e) => e.id == item.id);
    if (idx != -1) _itemsCache[idx] = item;
    _saveItems();
    return 1;
  }

  Future<int> insertTransaction(StockTransaction t) async {
    _txCache = _loadTx();
    final id = _nextTxId();
    t.id = id;
    _txCache.insert(0, t);
    _saveTx();
    return id;
  }

  Future<List<StockTransaction>> getTransactions() async {
    _txCache = _loadTx();
    _txCache.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return _txCache;
  }
}
