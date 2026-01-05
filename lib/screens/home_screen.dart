import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../models/stock_item.dart';
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

  Future<void> _showEditDialog(BuildContext ctx, StockItem item) async {
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
                decoration: const InputDecoration(
                  labelText: 'Brand (optional)',
                ),
                onSaved: (v) =>
                    brand = v?.trim().isEmpty ?? true ? null : v?.trim(),
              ),
              TextFormField(
                initialValue: threshold.toString(),
                decoration: const InputDecoration(
                  labelText: 'Reorder threshold (optional)',
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
                final prov = Provider.of<StockProvider>(ctx, listen: false);
                final updated = StockItem(
                  id: item.id,
                  name: name,
                  quantity: item.quantity,
                  brand: brand,
                  threshold: threshold,
                );
                await prov.updateItem(updated);
                if (!mounted) return;
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext ctx, int itemId, String name) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Delete item'),
        content: Text('Delete "$name" and its transactions?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await Provider.of<StockProvider>(ctx, listen: false).deleteItem(itemId);
    }
  }

  Future<void> _seedSampleData() async {
    final prov = Provider.of<StockProvider>(context, listen: false);
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
      {'name': 'Level', 'brand': 'TrueLine', 'quantity': 7, 'threshold': 2},
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
      {
        'name': 'Paint Brush',
        'brand': 'BrushCo',
        'quantity': 60,
        'threshold': 15,
      },
      {
        'name': 'Paint Can (1L)',
        'brand': 'ColorMax',
        'quantity': 18,
        'threshold': 5,
      },
      {
        'name': 'Gloves',
        'brand': 'SafeHands',
        'quantity': 120,
        'threshold': 20,
      },
      {
        'name': 'Safety Glasses',
        'brand': 'ClearView',
        'quantity': 35,
        'threshold': 5,
      },
      {
        'name': 'Utility Knife',
        'brand': 'CutPro',
        'quantity': 22,
        'threshold': 4,
      },
      {
        'name': 'Extension Cord',
        'brand': 'PowerLine',
        'quantity': 14,
        'threshold': 3,
      },
      {'name': 'Workbench', 'brand': 'BuildIt', 'quantity': 3, 'threshold': 1},
      {'name': 'Ladder', 'brand': 'ReachHigh', 'quantity': 6, 'threshold': 1},
      {
        'name': 'Flashlight',
        'brand': 'BrightLite',
        'quantity': 45,
        'threshold': 10,
      },
    ];

    for (final s in samples) {
      await prov.addItem(
        s['name'] as String,
        s['quantity'] as int,
        s['brand'] as String?,
        s['threshold'] as int,
      );
    }
    await prov.loadAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Inserted ${samples.length} sample items')),
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
        String? brand;
        int threshold = 0;
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
                    labelText: 'Brand (optional)',
                  ),
                  onSaved: (v) =>
                      brand = v?.trim().isEmpty ?? true ? null : v?.trim(),
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
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Reorder threshold (optional)',
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: '0',
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
                  await prov.addItem(name, quantity, brand, threshold);
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text('Added $name')),
                  );
                  Navigator.of(dialogCtx).pop();
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
        title: Row(
          children: [
            Image.asset(
              'lib/screens/image-removebg-preview (2).png',
              height: 32,
            ),
            const SizedBox(width: 8),
            const Text('Skystoc'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Seed sample items',
            icon: const Icon(Icons.cloud_download),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Seed data'),
                  content: const Text(
                    'Insert 20 sample items into the database?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Insert'),
                    ),
                  ],
                ),
              );
              if (ok != true) return;
              await _seedSampleData();
            },
          ),
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
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (item.brand != null &&
                                    item.brand!.isNotEmpty)
                                  Text(
                                    item.brand!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                if (item.threshold > 0 &&
                                    item.quantity <= item.threshold)
                                  Text(
                                    'Low stock',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                last == null
                                    ? const Text('No transactions yet')
                                    : Text(
                                        '${last.delta > 0 ? '+' : ''}${last.delta} · ${DateTime.fromMillisecondsSinceEpoch(last.timestamp).toLocal()}${last.note != null ? ' · ${last.note}' : ''}',
                                      ),
                              ],
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
                                PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'edit')
                                      _showEditDialog(context, item);
                                    if (v == 'delete')
                                      _confirmDelete(
                                        context,
                                        item.id!,
                                        item.name,
                                      );
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
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
          String? brand;
          int threshold = 0;
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
                        labelText: 'Brand (optional)',
                      ),
                      onSaved: (v) =>
                          brand = v?.trim().isEmpty ?? true ? null : v?.trim(),
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
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Reorder threshold (optional)',
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: '0',
                      validator: (v) =>
                          (v == null ||
                              int.tryParse(v) == null ||
                              int.parse(v) < 0)
                          ? 'Enter 0 or positive'
                          : null,
                      onSaved: (v) => threshold = int.parse(v ?? '0'),
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
                      await prov.addItem(name, quantity, brand, threshold);
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
