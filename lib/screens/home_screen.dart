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
    await showDialog<void>(
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

  void _openAddDialog(BuildContext context) {
    final outerContext = context;
    showDialog(
      context: context,
      builder: (dialogCtx) {
        final formKey = GlobalKey<FormState>();
        String name = '';
        int quantity = 0;
        return AlertDialog(
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
                      (v == null || int.tryParse(v) == null || int.parse(v) < 0)
                      ? 'Enter 0 or positive'
                      : null,
                  onSaved: (v) => quantity = int.parse(v ?? '0'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  formKey.currentState?.save();
                  final prov = Provider.of<StockProvider>(
                    outerContext,
                    listen: false,
                  );
                  final messenger = ScaffoldMessenger.of(outerContext);
                  final dialogNavigator = Navigator.of(dialogCtx);
                  await prov.addItem(name, quantity);
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text('Added $name')),
                  );
                  dialogNavigator.pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
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
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  const Text('No items yet.', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _openAddDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add your first item'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: prov.loadAll,
              child: Column(
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
                      padding: const EdgeInsets.all(8),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final item = filtered[i];
                        final last = prov.lastTransactionFor(item.id!);
                        final messenger = ScaffoldMessenger.of(context);
                        return Card(
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: item.quantity > 0
                                  ? Colors.green.shade700
                                  : Colors.grey.shade400,
                              child: Text(
                                item.quantity.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: last == null
                                ? const Text('No transactions yet')
                                : Text(
                                    '${last.delta > 0 ? '+' : ''}${last.delta} · ${DateTime.fromMillisecondsSinceEpoch(last.timestamp).toLocal()}${last.note != null ? ' · ${last.note}' : ''}',
                                  ),
                            onTap: () => _showSetQuantityDialog(
                              context,
                              item.id!,
                              item.quantity,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Remove 1',
                                  onPressed: () async {
                                    final provLocal = prov;
                                    final messengerLocal = messenger;
                                    await provLocal.stockOut(item.id!, 1);
                                    messengerLocal.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Removed 1 from ${item.name}',
                                        ),
                                        action: SnackBarAction(
                                          label: 'Undo',
                                          onPressed: () => provLocal.stockIn(
                                            item.id!,
                                            1,
                                            'Undo',
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.remove,
                                    color: Colors.red,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Add 1',
                                  onPressed: () async {
                                    final provLocal = prov;
                                    final messengerLocal = messenger;
                                    await provLocal.stockIn(item.id!, 1);
                                    messengerLocal.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Added 1 to ${item.name}',
                                        ),
                                        action: SnackBarAction(
                                          label: 'Undo',
                                          onPressed: () => provLocal.stockOut(
                                            item.id!,
                                            1,
                                            'Undo',
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
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
                      final navigator = Navigator.of(context);
                      final prov = Provider.of<StockProvider>(
                        context,
                        listen: false,
                      );
                      await prov.addItem(name, quantity);
                      if (!mounted) return;
                      navigator.pop();
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
