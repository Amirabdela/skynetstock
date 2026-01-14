import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../widgets/gradient_app_bar.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _generateMessages();
  }

  void _generateMessages() {
    final prov = Provider.of<StockProvider>(context, listen: false);
    
    // Welcome message
    _messages.add({
      'id': 1,
      'title': 'Welcome to Skynet Stock!',
      'body': 'Thanks for using our inventory management system. Here are some tips to get started:\n\n'
          '• Add items using the "Add Stock" button\n'
          '• Set thresholds to get low stock alerts\n'
          '• Track all changes in transaction history',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'read': true,
      'type': 'info',
    });
    
    // Generate insights based on data
    final lowStockCount = prov.items.where(
      (i) => i.threshold > 0 && i.quantity <= i.threshold
    ).length;
    
    if (lowStockCount > 0) {
      _messages.insert(0, {
        'id': 2,
        'title': 'Inventory Alert',
        'body': 'You have $lowStockCount item${lowStockCount > 1 ? "s" : ""} running low on stock. '
            'Consider restocking soon to avoid stockouts.',
        'time': DateTime.now(),
        'read': false,
        'type': 'warning',
      });
    }
    
    final totalItems = prov.items.length;
    final totalUnits = prov.items.fold<int>(0, (sum, item) => sum + item.quantity);
    
    if (totalItems > 0) {
      _messages.insert(0, {
        'id': 3,
        'title': 'Weekly Summary',
        'body': 'Your inventory currently has $totalItems different items '
            'with a total of $totalUnits units in stock.',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'read': false,
        'type': 'summary',
      });
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'summary':
        return Icons.analytics_outlined;
      case 'info':
      default:
        return Icons.info_outline;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'warning':
        return Colors.orange;
      case 'summary':
        return Colors.blue;
      case 'info':
      default:
        return Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Messages',
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            tooltip: 'Mark all as read',
            onPressed: () {
              setState(() {
                for (var msg in _messages) {
                  msg['read'] = true;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All messages marked as read')),
              );
            },
          ),
        ],
      ),
      body: _messages.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mail_outline, size: 64, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No messages',
                    style: TextStyle(fontSize: 18, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final msg = _messages[i];
                final isRead = msg['read'] as bool;
                final type = msg['type'] as String;
                
                return Card(
                  color: isRead ? null : Colors.indigo.shade50,
                  child: InkWell(
                    onTap: () {
                      setState(() => msg['read'] = true);
                      _showMessageDetail(context, msg);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: _getColor(type).withValues(alpha: 0.2),
                            child: Icon(_getIcon(type), color: _getColor(type)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        msg['title'] as String,
                                        style: TextStyle(
                                          fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (!isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.indigo,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  (msg['body'] as String).split('\n').first,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatTime(msg['time'] as DateTime),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showMessageDetail(BuildContext context, Map<String, dynamic> msg) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getColor(msg['type']).withValues(alpha: 0.2),
                    child: Icon(_getIcon(msg['type']), color: _getColor(msg['type'])),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      msg['title'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatTime(msg['time'] as DateTime),
                style: TextStyle(color: Colors.grey.shade500),
              ),
              const SizedBox(height: 24),
              Text(
                msg['body'] as String,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
