class StockItem {
  int? id;
  String name;
  int quantity;
  StockItem({this.id, required this.name, this.quantity = 0});

  factory StockItem.fromMap(Map<String, dynamic> m) => StockItem(
    id: m['id'] as int?,
    name: m['name'] as String,
    quantity: m['quantity'] as int? ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'quantity': quantity,
  };
}
