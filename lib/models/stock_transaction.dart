class StockTransaction {
  int? id;
  int itemId;
  int delta; 
  int timestamp;
  String? note;

  StockTransaction({
    this.id,
    required this.itemId,
    required this.delta,
    required this.timestamp,
    this.note,
  });

  factory StockTransaction.fromMap(Map<String, dynamic> m) => StockTransaction(
    id: m['id'] as int?,
    itemId: m['item_id'] as int,
    delta: m['delta'] as int,
    timestamp: m['timestamp'] as int,
    note: m['note'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'item_id': itemId,
    'delta': delta,
    'timestamp': timestamp,
    'note': note,
  };
}
