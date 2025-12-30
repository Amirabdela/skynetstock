import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../models/stock_item.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<StockProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: prov.transactions.isEmpty
          ? const Center(child: Text('No transactions yet'))
          : ListView.builder(
              itemCount: prov.transactions.length,
              itemBuilder: (_, i) {
                final t = prov.transactions[i];
                final matched = prov.items.firstWhere(
                  (it) => it.id == t.itemId,
                  orElse: () => StockItem(
                    id: t.itemId,
                    name: 'Item ${t.itemId}',
                    quantity: 0,
                  ),
                );
                final itemName = matched.name;
                final dt = DateTime.fromMillisecondsSinceEpoch(t.timestamp);
                return ListTile(
                  title: Text(
                    '$itemName — ${t.delta > 0 ? '+' : ''}${t.delta}',
                  ),
                  subtitle: Text(
                    '${dt.toLocal()}${t.note != null ? ' · ${t.note}' : ''}',
                  ),
                );
              },
            ),
    );
  }
}
