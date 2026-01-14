import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../widgets/gradient_app_bar.dart';
import '../theme/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<StockProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Calculate statistics
    final totalItems = prov.items.length;
    final totalUnits = prov.items.fold<int>(0, (sum, item) => sum + item.quantity);
    final lowStockItems = prov.items.where(
      (i) => i.threshold > 0 && i.quantity <= i.threshold
    ).toList();
    final outOfStockItems = prov.items.where((i) => i.quantity == 0).toList();
    final totalTransactions = prov.transactions.length;
    
    // Calculate stock movements
    final stockInTotal = prov.transactions
        .where((t) => t.delta > 0)
        .fold<int>(0, (sum, t) => sum + t.delta);
    final stockOutTotal = prov.transactions
        .where((t) => t.delta < 0)
        .fold<int>(0, (sum, t) => sum + t.delta.abs());
    
    // Get top items by quantity
    final topItems = List.of(prov.items)
      ..sort((a, b) => b.quantity.compareTo(a.quantity));
    
    // Get brands distribution
    final brandCounts = <String, int>{};
    for (final item in prov.items) {
      final brand = item.brand ?? 'No Brand';
      brandCounts[brand] = (brandCounts[brand] ?? 0) + 1;
    }
    
    return Scaffold(
      appBar: const GradientAppBar(title: 'Reports & Analytics'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            const Text(
              'Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  title: 'Total Items',
                  value: totalItems.toString(),
                  icon: Icons.inventory_2_outlined,
                  color: Colors.blue,
                ),
                _StatCard(
                  title: 'Total Units',
                  value: _formatNumber(totalUnits),
                  icon: Icons.all_inbox_outlined,
                  color: Colors.green,
                ),
                _StatCard(
                  title: 'Low Stock',
                  value: lowStockItems.length.toString(),
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
                _StatCard(
                  title: 'Out of Stock',
                  value: outOfStockItems.length.toString(),
                  icon: Icons.error_outline,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Stock Movement
            const Text(
              'Stock Movement',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _MovementTile(
                            title: 'Stock In',
                            value: '+${_formatNumber(stockInTotal)}',
                            color: Colors.green,
                            icon: Icons.arrow_upward,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 60,
                          color: Colors.grey.shade300,
                        ),
                        Expanded(
                          child: _MovementTile(
                            title: 'Stock Out',
                            value: '-${_formatNumber(stockOutTotal)}',
                            color: Colors.red,
                            icon: Icons.arrow_downward,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Transactions',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        Text(
                          totalTransactions.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Top Items
            if (topItems.isNotEmpty) ...[
              const Text(
                'Top Items by Quantity',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topItems.take(5).length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final item = topItems[i];
                    final percentage = totalUnits > 0
                        ? (item.quantity / totalUnits * 100)
                        : 0.0;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo.shade100,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: Colors.indigo.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(item.name),
                      subtitle: item.brand != null ? Text(item.brand!) : null,
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${item.quantity} units',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Low Stock Items
            if (lowStockItems.isNotEmpty) ...[
              const Text(
                'Items Needing Restock',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.orange.shade50,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lowStockItems.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: Colors.orange.shade200,
                  ),
                  itemBuilder: (_, i) {
                    final item = lowStockItems[i];
                    return ListTile(
                      leading: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange.shade700,
                      ),
                      title: Text(item.name),
                      subtitle: Text(
                        'Current: ${item.quantity} | Threshold: ${item.threshold}',
                      ),
                      trailing: Text(
                        'Need ${item.threshold - item.quantity + 1}+',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Brands Distribution
            if (brandCounts.isNotEmpty) ...[
              const Text(
                'Items by Brand',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: brandCounts.entries.map((e) {
                      return Chip(
                        label: Text(
                          '${e.key}: ${e.value}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        backgroundColor: isDark ? AppTheme.darkSurfaceColor : Colors.indigo.shade50,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _MovementTile({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
