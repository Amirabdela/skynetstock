class StockItem {
  int? id;
  String name;
  int quantity;
  String? brand;
  int threshold;

  StockItem({
    this.id,
    required this.name,
    this.quantity = 0,
    this.brand,
    this.threshold = 0,
  });

  factory StockItem.fromMap(Map<String, dynamic> m) => StockItem(
    id: m['id'] as int?,
    name: m['name'] as String,
    quantity: m['quantity'] as int? ?? 0,
    brand: m['brand'] as String?,
    threshold: m['threshold'] as int? ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'brand': brand,
    'threshold': threshold,
  };
}
