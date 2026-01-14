import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../models/stock_item.dart';
import '../widgets/gradient_app_bar.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<StockProvider>(context);
    return Scaffold(
      appBar: const GradientAppBar(title: 'Transactions'),
      body: prov.transactions.isEmpty
          ? const Center(child: Text('No transactions yet'))
          : ListView.separated(
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              padding: const EdgeInsets.all(12),
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
                final dt = DateTime.fromMillisecondsSinceEpoch(
                  t.timestamp,
                ).toLocal();
                final isIn = t.delta > 0;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isIn
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                      child: Icon(
                        isIn ? Icons.arrow_upward : Icons.arrow_downward,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      '$itemName — ${isIn ? '+' : ''}${t.delta}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} ${t.note != null ? ' · ${t.note}' : ''}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
