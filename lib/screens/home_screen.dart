import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
// import 'add_item_screen.dart';
import 'transaction_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StockProvider>(context, listen: false).loadAll();
    });
  }

  Future<void> _showAdjustDialog(
    BuildContext ctx,
    int itemId,
    String title,
    bool isIn,
  ) async {
    final formKey = GlobalKey<FormState>();
    int amount = 0;
    String? note;
    await showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || int.tryParse(v) == null || int.parse(v) <= 0)
                    ? 'Enter positive number'
                    : null,
                onSaved: (v) => amount = int.parse(v ?? '0'),
              ),
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
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                if (isIn) {
                  Provider.of<StockProvider>(
                    ctx,
                    listen: false,
                  ).stockIn(itemId, amount, note);
                } else {
                  Provider.of<StockProvider>(
                    ctx,
                    listen: false,
                  ).stockOut(itemId, amount, note);
                }
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSetQuantityDialog(
    BuildContext ctx,
    int itemId,
    int current,
  ) async {
    final formKey = GlobalKey<FormState>();
    int newQty = current;
    await showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Set Quantity'),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: current.toString(),
            decoration: const InputDecoration(labelText: 'Quantity'),
            keyboardType: TextInputType.number,
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
                Provider.of<StockProvider>(
                  ctx,
                  listen: false,
                ).setQuantity(itemId, newQty);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<StockProvider>(context);
    final filtered = prov.items
        .where((it) => it.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skystoc'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const TransactionHistoryScreen(),
              ),
            ),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: prov.items.isEmpty
          ? const Center(
              child: Text('No items yet. Add items with the + button.'),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search items',
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final item = filtered[i];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: GestureDetector(
                          onTap: () => _showSetQuantityDialog(
                            context,
                            item.id!,
                            item.quantity,
                          ),
                          child: Text(
                            'Quantity: ${item.quantity} — tap to edit',
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onLongPress: () => _showAdjustDialog(
                                context,
                                item.id!,
                                'Stock Out',
                                false,
                              ),
                              child: IconButton(
                                onPressed: () => prov.stockOut(item.id!, 1),
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onLongPress: () => _showAdjustDialog(
                                context,
                                item.id!,
                                'Stock In',
                                true,
                              ),
                              child: IconButton(
                                onPressed: () => prov.stockIn(item.id!, 1),
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final formKey = GlobalKey<FormState>();
          String name = '';
          int quantity = 0;
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Add Item'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                      onSaved: (v) => name = v!.trim(),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Initial quantity',
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: '0',
                      validator: (v) =>
                          (v == null ||
                              int.tryParse(v) == null ||
                              int.parse(v) < 0)
                          ? 'Enter 0 or positive'
                          : null,
                      onSaved: (v) => quantity = int.parse(v ?? '0'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      formKey.currentState?.save();
                      await Provider.of<StockProvider>(
                        context,
                        listen: false,
                      ).addItem(name, quantity);
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
