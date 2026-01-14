import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../models/stock_item.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<StockProvider>(context);
    
    // Generate real notifications based on stock data
    final notifications = <Map<String, dynamic>>[];
    
    // Low stock alerts
    final lowStockItems = prov.items.where(
      (item) => item.threshold > 0 && item.quantity <= item.threshold
    ).toList();
    
    for (final item in lowStockItems) {
      notifications.add({
        'type': 'low_stock',
        'title': 'Low Stock Alert: ${item.name}',
        'body': 'Only ${item.quantity} units left (threshold: ${item.threshold})',
        'icon': Icons.warning_amber_rounded,
        'color': Colors.orange,
        'item': item,
      });
    }
    
    // Out of stock alerts
    final outOfStockItems = prov.items.where((item) => item.quantity == 0).toList();
    
    for (final item in outOfStockItems) {
      notifications.add({
        'type': 'out_of_stock',
        'title': 'Out of Stock: ${item.name}',
        'body': 'This item needs to be restocked immediately',
        'icon': Icons.error_outline,
        'color': Colors.red,
        'item': item,
      });
    }
    
    // Recent transactions (last 5)
    final recentTx = prov.transactions.take(5).toList();
    for (final tx in recentTx) {
      final item = prov.items.firstWhere(
        (i) => i.id == tx.itemId,
        orElse: () => StockItem(name: 'Unknown Item', quantity: 0),
      );
      final isIn = tx.delta > 0;
      notifications.add({
        'type': 'transaction',
        'title': '${isIn ? "Stock In" : "Stock Out"}: ${item.name}',
        'body': '${isIn ? "+" : ""}${tx.delta} units ${tx.note != null ? "- ${tx.note}" : ""}',
        'icon': isIn ? Icons.add_circle_outline : Icons.remove_circle_outline,
        'color': isIn ? Colors.green : Colors.blue,
        'time': tx.dateTime,
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications marked as read')),
                );
              },
              child: const Text('Mark all read', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'re all caught up!',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final notif = notifications[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (notif['color'] as Color).withValues(alpha: 0.2),
                      child: Icon(
                        notif['icon'] as IconData,
                        color: notif['color'] as Color,
                      ),
                    ),
                    title: Text(
                      notif['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notif['body'] as String),
                        if (notif['time'] != null)
                          Text(
                            _formatTime(notif['time'] as DateTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                    trailing: notif['type'] == 'low_stock' || notif['type'] == 'out_of_stock'
                        ? TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Could navigate to restock dialog
                            },
                            child: const Text('Restock'),
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
