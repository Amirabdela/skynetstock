import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/stock_provider.dart';
import '../models/stock_item.dart';
import '../services/auth_service.dart';
import 'item_detail_screen.dart';
import 'transaction_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prov = Provider.of<StockProvider>(context, listen: false);
      await prov.seedIfEmpty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<StockProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final lowStockCount = prov.items.where(
      (i) => i.threshold > 0 && i.quantity <= i.threshold
    ).length;

    return Scaffold(
      body: Column(
        children: [
          // Custom App Bar with Gradient
          _buildAppBar(context, user, lowStockCount),
          
          // Main Content
          Expanded(
            child: prov.items.isEmpty
                ? _buildEmptyState(isDark)
                : _buildInventoryList(prov, isDark),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context, isDark),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, dynamic user, int lowStockCount) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  // Logo & Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'lib/screens/image-removebg-preview (2).png',
                            width: 24,
                            height: 24,
                            errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Skynet Stock',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Inventory Management',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Action Icons
                  _buildIconButton(
                    Icons.mail_outline_rounded,
                    onTap: () => Navigator.pushNamed(context, '/messages'),
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    Icons.notifications_outlined,
                    badge: lowStockCount > 0 ? lowStockCount.toString() : null,
                    onTap: () => Navigator.pushNamed(context, '/notifications'),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/account'),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? const Icon(Icons.person_rounded, color: Colors.white, size: 20)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            
            // Navigation Tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
              child: Row(
                children: [
                  _buildNavTab('Overview', 0, Icons.dashboard_rounded),
                  _buildNavTab('History', 1, Icons.history_rounded),
                  _buildNavTab('Reports', 2, Icons.analytics_rounded),
                  _buildNavTab('Settings', 3, Icons.settings_rounded),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {String? badge, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: badge != null
            ? Badge(
                label: Text(badge, style: const TextStyle(fontSize: 10)),
                child: Icon(icon, color: Colors.white, size: 22),
              )
            : Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildNavTab(String label, int index, IconData icon) {
    final isSelected = _selectedNavIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 0) {
            setState(() => _selectedNavIndex = 0);
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => const TransactionHistoryScreen(),
            ));
          } else if (index == 2) {
            Navigator.pushNamed(context, '/reports');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/settings');
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppTheme.primaryColor : Colors.white70,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryColor : Colors.white70,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No items yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by adding your first inventory item',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddItemDialog(context, isDark),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Your First Item'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryList(StockProvider prov, bool isDark) {
    final filtered = prov.items
        .where((it) => it.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    
    final totalUnits = prov.items.fold<int>(0, (sum, item) => sum + item.quantity);
    final lowStockItems = prov.items.where(
      (i) => i.threshold > 0 && i.quantity <= i.threshold
    ).toList();

    return RefreshIndicator(
      onRefresh: prov.loadAll,
      color: AppTheme.primaryColor,
      child: CustomScrollView(
        slivers: [
          // Stats Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: _buildStatCard(
                    'Total Items',
                    prov.items.length.toString(),
                    Icons.inventory_2_outlined,
                    AppTheme.primaryColor,
                    isDark,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(
                    'Total Units',
                    _formatNumber(totalUnits),
                    Icons.all_inbox_outlined,
                    AppTheme.successColor,
                    isDark,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(
                    'Low Stock',
                    lowStockItems.length.toString(),
                    Icons.warning_amber_rounded,
                    lowStockItems.isEmpty ? (isDark ? AppTheme.darkTextMuted : AppTheme.textMuted) : AppTheme.warningColor,
                    isDark,
                  )),
                ],
              ),
            ),
          ),
          
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  prefixIcon: Icon(Icons.search_rounded, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => setState(() => _query = ''),
                        )
                      : null,
                ),
              ),
            ),
          ),
          
          // Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Inventory (${filtered.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showQuickStockDialog(context, prov, true, isDark),
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('Quick Add'),
                  ),
                ],
              ),
            ),
          ),
          
          // Items List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildItemCard(filtered[index], prov, isDark),
                childCount: filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : AppTheme.cardShadow,
        border: isDark ? Border.all(color: AppTheme.darkBorderColor) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(StockItem item, StockProvider prov, bool isDark) {
    final isLowStock = item.threshold > 0 && item.quantity <= item.threshold;
    final isOutOfStock = item.quantity == 0;
    final lastTx = prov.lastTransactionFor(item.id!);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : AppTheme.cardShadow,
        border: Border.all(
          color: isLowStock 
              ? AppTheme.warningColor.withValues(alpha: 0.5) 
              : (isDark ? AppTheme.darkBorderColor : Colors.transparent),
          width: isLowStock ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Quantity Badge
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: isOutOfStock
                        ? null
                        : isLowStock
                            ? LinearGradient(
                                colors: [AppTheme.warningColor, AppTheme.warningColor.withValues(alpha: 0.8)],
                              )
                            : LinearGradient(
                                colors: [AppTheme.successColor, AppTheme.successColor.withValues(alpha: 0.8)],
                              ),
                    color: isOutOfStock ? (isDark ? AppTheme.darkTextMuted : AppTheme.textMuted) : null,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      item.quantity.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Item Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (item.brand != null && item.brand!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.darkSurfaceColor : AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.brand!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (isLowStock)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.warningColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isOutOfStock ? 'Out of stock' : 'Low stock',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isOutOfStock ? AppTheme.errorColor : AppTheme.warningColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (lastTx != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${lastTx.delta > 0 ? '+' : ''}${lastTx.delta} • ${_formatTime(lastTx.dateTime)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Quick Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQuickAction(
                      Icons.remove_rounded,
                      AppTheme.errorColor,
                      () async {
                        if (item.quantity > 0) {
                          await prov.stockOut(item.id!, 1);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Removed 1 from ${item.name}')),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildQuickAction(
                      Icons.add_rounded,
                      AppTheme.successColor,
                      () async {
                        await prov.stockIn(item.id!, 1);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added 1 to ${item.name}')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, bool isDark) {
    final formKey = GlobalKey<FormState>();
    String name = '';
    int quantity = 0;
    String? brand;
    int threshold = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardColor : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add New Item',
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Item Name *'),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                onSaved: (v) => name = v!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Brand (optional)'),
                onSaved: (v) => brand = v?.trim().isEmpty ?? true ? null : v?.trim(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Initial Qty'),
                      keyboardType: TextInputType.number,
                      initialValue: '0',
                      validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null,
                      onSaved: (v) => quantity = int.parse(v ?? '0'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Low Stock Alert'),
                      keyboardType: TextInputType.number,
                      initialValue: '0',
                      validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null,
                      onSaved: (v) => threshold = int.parse(v ?? '0'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      formKey.currentState?.save();
                      final prov = Provider.of<StockProvider>(context, listen: false);
                      await prov.addItem(name, quantity, brand, threshold);
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added $name')),
                        );
                      }
                    }
                  },
                  child: const Text('Add Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickStockDialog(BuildContext ctx, StockProvider prov, bool isIn, bool isDark) {
    if (prov.items.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('No items available')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    StockItem? selectedItem;
    int amount = 1;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCardColor : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isIn ? 'Quick Stock In' : 'Quick Stock Out',
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<StockItem>(
                  decoration: const InputDecoration(labelText: 'Select Item'),
                  dropdownColor: isDark ? AppTheme.darkCardColor : Colors.white,
                  items: prov.items.map((item) => DropdownMenuItem(
                    value: item,
                    child: Text('${item.name} (${item.quantity})'),
                  )).toList(),
                  onChanged: (v) => setSheetState(() => selectedItem = v),
                  validator: (v) => v == null ? 'Select an item' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  initialValue: '1',
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Enter valid amount';
                    if (!isIn && selectedItem != null && n > selectedItem!.quantity) {
                      return 'Max: ${selectedItem!.quantity}';
                    }
                    return null;
                  },
                  onSaved: (v) => amount = int.parse(v ?? '1'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isIn ? AppTheme.successColor : AppTheme.errorColor,
                    ),
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        formKey.currentState?.save();
                        if (isIn) {
                          prov.stockIn(selectedItem!.id!, amount);
                        } else {
                          prov.stockOut(selectedItem!.id!, amount);
                        }
                        Navigator.pop(sheetCtx);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text(
                            '${isIn ? "Added" : "Removed"} $amount ${isIn ? "to" : "from"} ${selectedItem!.name}'
                          )),
                        );
                      }
                    },
                    child: Text(isIn ? 'Stock In' : 'Stock Out'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
