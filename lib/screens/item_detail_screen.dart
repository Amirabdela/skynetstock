import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../models/stock_item.dart';
import '../models/stock_transaction.dart';
import '../widgets/gradient_app_bar.dart';

class ItemDetailScreen extends StatelessWidget {
  final StockItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<StockProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Get fresh item data
    final currentItem = prov.items.firstWhere(
      (i) => i.id == item.id,
      orElse: () => item,
    );
    
    // Get transactions for this item
    final itemTransactions = prov.transactions
        .where((t) => t.itemId == item.id)
        .toList();

    final isLowStock = currentItem.threshold > 0 && 
        currentItem.quantity <= currentItem.threshold;
    final isOutOfStock = currentItem.quantity == 0;

    return Scaffold(
      appBar: GradientAppBar(
        title: currentItem.name,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context, currentItem, prov),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, currentItem, prov),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Quantity Display
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOutOfStock
                            ? Colors.grey.shade300
                            : isLowStock
                                ? Colors.orange.shade100
                                : Colors.green.shade100,
                        border: Border.all(
                          color: isOutOfStock
                              ? Colors.grey
                              : isLowStock
                                  ? Colors.orange
                                  : Colors.green,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentItem.quantity.toString(),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: isOutOfStock
                                    ? Colors.grey.shade700
                                    : isLowStock
                                        ? Colors.orange.shade700
                                        : Colors.green.shade700,
                              ),
                            ),
                            Text(
                              'units',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Status Chips
                    Wrap(
                      spacing: 8,
                      children: [
                        if (currentItem.brand != null && currentItem.brand!.isNotEmpty)
                          Chip(
                            avatar: const Icon(Icons.business, size: 18),
                            label: Text(currentItem.brand!),
                          ),
                        if (isOutOfStock)
                          Chip(
                            avatar: const Icon(Icons.error, size: 18, color: Colors.red),
                            label: const Text('Out of Stock'),
                            backgroundColor: Colors.red.shade50,
                          )
                        else if (isLowStock)
                          Chip(
                            avatar: const Icon(Icons.warning, size: 18, color: Colors.orange),
                            label: const Text('Low Stock'),
                            backgroundColor: Colors.orange.shade50,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Quick Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ActionButton(
                          icon: Icons.remove,
                          label: 'Stock Out',
                          color: Colors.red,
                          onPressed: () => _showStockDialog(context, currentItem, prov, false),
                        ),
                        _ActionButton(
                          icon: Icons.add,
                          label: 'Stock In',
                          color: Colors.green,
                          onPressed: () => _showStockDialog(context, currentItem, prov, true),
                        ),
                        _ActionButton(
                          icon: Icons.edit_note,
                          label: 'Set Qty',
                          color: Colors.blue,
                          onPressed: () => _showSetQuantityDialog(context, currentItem, prov),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Item Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow('Name', currentItem.name),
                    _DetailRow('Brand', currentItem.brand ?? 'Not set'),
                    _DetailRow('Current Quantity', '${currentItem.quantity} units'),
                    _DetailRow('Reorder Threshold', currentItem.threshold > 0 
                        ? '${currentItem.threshold} units' 
                        : 'Not set'),
                    if (currentItem.threshold > 0)
                      _DetailRow('Status', isOutOfStock 
                          ? 'Out of Stock' 
                          : isLowStock 
                              ? 'Low Stock - Reorder needed' 
                              : 'In Stock'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Transaction History
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transaction History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${itemTransactions.length} transactions',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (itemTransactions.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No transactions yet',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: itemTransactions.take(10).length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final tx = itemTransactions[i];
                          return _TransactionTile(transaction: tx);
                        },
                      ),
                    if (itemTransactions.length > 10)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Center(
                          child: Text(
                            '+ ${itemTransactions.length - 10} more transactions',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStockDialog(
    BuildContext ctx,
    StockItem item,
    StockProvider prov,
    bool isIn,
  ) async {
    final formKey = GlobalKey<FormState>();
    int amount = 0;
    String? note;
    
    await showDialog<void>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(isIn ? 'Stock In' : 'Stock Out'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Amount',
                  helperText: isIn ? null : 'Max: ${item.quantity}',
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
                validator: (v) {
                  if (v == null || int.tryParse(v) == null || int.parse(v) <= 0) {
                    return 'Enter positive number';
                  }
                  if (!isIn && int.parse(v) > item.quantity) {
                    return 'Cannot exceed current stock';
                  }
                  return null;
                },
                onSaved: (v) => amount = int.parse(v ?? '0'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Note (optional)'),
                onSaved: (v) => note = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isIn ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                if (isIn) {
                  prov.stockIn(item.id!, amount, note ?? 'Stock In');
                } else {
                  prov.stockOut(item.id!, amount, note ?? 'Stock Out');
                }
                Navigator.of(ctx).pop();
              }
            },
            child: Text(isIn ? 'Stock In' : 'Stock Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSetQuantityDialog(
    BuildContext ctx,
    StockItem item,
    StockProvider prov,
  ) async {
    final formKey = GlobalKey<FormState>();
    int newQty = item.quantity;
    
    await showDialog<void>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Set Quantity'),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: item.quantity.toString(),
            decoration: const InputDecoration(labelText: 'New Quantity'),
            keyboardType: TextInputType.number,
            autofocus: true,
            validator: (v) =>
                (v == null || int.tryParse(v) == null || int.parse(v) < 0)
                ? 'Enter 0 or positive'
                : null,
            onSaved: (v) => newQty = int.parse(v ?? '0'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                prov.setQuantity(item.id!, newQty, 'Manual adjustment');
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext ctx,
    StockItem item,
    StockProvider prov,
  ) async {
    final formKey = GlobalKey<FormState>();
    String name = item.name;
    String? brand = item.brand;
    int threshold = item.threshold;
    
    await showDialog<void>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Edit Item'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                onSaved: (v) => name = v!.trim(),
              ),
              TextFormField(
                initialValue: brand,
                decoration: const InputDecoration(labelText: 'Brand (optional)'),
                onSaved: (v) =>
                    brand = v?.trim().isEmpty ?? true ? null : v?.trim(),
              ),
              TextFormField(
                initialValue: threshold.toString(),
                decoration: const InputDecoration(
                  labelText: 'Reorder threshold',
                  helperText: 'Set to 0 to disable alerts',
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || int.tryParse(v) == null || int.parse(v) < 0)
                    ? 'Enter 0 or positive'
                    : null,
                onSaved: (v) => threshold = int.parse(v ?? '0'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                final updated = StockItem(
                  id: item.id,
                  name: name,
                  quantity: item.quantity,
                  brand: brand,
                  threshold: threshold,
                );
                await prov.updateItem(updated);
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext ctx,
    StockItem item,
    StockProvider prov,
  ) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Delete "${item.name}" and all its transactions?\n\nThis cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (ok == true && ctx.mounted) {
      await prov.deleteItem(item.id!);
      if (ctx.mounted) Navigator.of(ctx).pop();
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filled(
          onPressed: onPressed,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.1),
            foregroundColor: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final StockTransaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIn = transaction.delta > 0;
    final dt = transaction.dateTime;
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: isIn ? Colors.green.shade100 : Colors.red.shade100,
        child: Icon(
          isIn ? Icons.add : Icons.remove,
          size: 16,
          color: isIn ? Colors.green : Colors.red,
        ),
      ),
      title: Text(
        '${isIn ? '+' : ''}${transaction.delta} units',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isIn ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
      subtitle: Text(transaction.note ?? ''),
      trailing: Text(
        '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}
