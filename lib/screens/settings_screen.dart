import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../widgets/gradient_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<StockProvider>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authService.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: const GradientAppBar(title: 'Settings'),
      body: ListView(
        children: [
          // User info section
          if (user != null) ...[
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.shade100,
                backgroundImage: user.photoURL != null 
                    ? NetworkImage(user.photoURL!) 
                    : null,
                child: user.photoURL == null 
                    ? Icon(Icons.person, color: Colors.indigo.shade700)
                    : null,
              ),
              title: Text(user.displayName ?? 'User'),
              subtitle: Text(user.email ?? ''),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pushNamed('/account'),
            ),
            const Divider(),
          ],
          
          // Appearance Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Appearance',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          ListTile(
            leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            title: const Text('Dark Mode'),
            subtitle: Text(themeProvider.themeMode == ThemeMode.system 
                ? 'System default' 
                : (isDark ? 'On' : 'Off')),
            trailing: Switch(
              value: isDark,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
            onTap: () => themeProvider.toggleTheme(),
          ),
          
          const Divider(),
          
          // Data Management Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Data Management',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Export Data'),
            subtitle: const Text('Copy inventory data to clipboard'),
            onTap: () => _exportData(context, prov),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload_outlined),
            title: const Text('Import Data'),
            subtitle: const Text('Import inventory from clipboard'),
            onTap: () => _importData(context, prov),
          ),
          ListTile(
            leading: Icon(Icons.delete_sweep_outlined, color: Colors.red.shade400),
            title: Text('Clear All Data', style: TextStyle(color: Colors.red.shade400)),
            subtitle: const Text('Delete all items and transactions'),
            onTap: () => _clearAllData(context, prov),
          ),
          ListTile(
            leading: Icon(Icons.refresh_rounded, color: Colors.blue.shade400),
            title: Text('Reset to Stationery Items', style: TextStyle(color: Colors.blue.shade400)),
            subtitle: const Text('Replace all data with sample stationery'),
            onTap: () => _resetToStationery(context, prov),
          ),
          
          const Divider(),
          
          // App Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'App',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Skynet Stock v1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Skynet Stock',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2026 Skynet Stock',
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'A modern inventory management solution with Firebase authentication.\n\n'
                    'Features:\n'
                    '• Track stock items and quantities\n'
                    '• Set low stock thresholds\n'
                    '• View transaction history\n'
                    '• Export/Import data\n'
                    '• Real-time notifications',
                  ),
                ],
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Help & Support'),
                  content: const SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Quick Tips:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('• Tap an item to set its quantity directly'),
                        Text('• Use + and - buttons for quick adjustments'),
                        Text('• Set thresholds to get low stock alerts'),
                        Text('• Swipe left on an item to delete it'),
                        SizedBox(height: 16),
                        Text(
                          'Need more help?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Contact support at: support@skynetstock.com'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const Divider(),
          
          // Account Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Account',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade400),
            title: Text('Sign Out', style: TextStyle(color: Colors.red.shade400)),
            onTap: () => _signOut(context, authService),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, StockProvider prov) async {
    try {
      final data = await prov.exportData();
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
      
      await Clipboard.setData(ClipboardData(text: jsonStr));
      
      final itemCount = (data['items'] as List).length;
      final txCount = (data['transactions'] as List).length;
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported $itemCount items and $txCount transactions to clipboard'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () => _showExportPreview(context, jsonStr),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  void _showExportPreview(BuildContext context, String jsonStr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exported Data'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonStr,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: jsonStr));
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              }
            },
            child: const Text('Copy Again'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _importData(BuildContext context, StockProvider prov) async {
    final controller = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Data'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste your exported JSON data below. This will replace all existing data.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Paste JSON here...',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () async {
                  final data = await Clipboard.getData('text/plain');
                  if (data?.text != null) {
                    controller.text = data!.text!;
                  }
                },
                icon: const Icon(Icons.paste, size: 18),
                label: const Text('Paste from clipboard'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.isNotEmpty && context.mounted) {
      try {
        final data = json.decode(controller.text) as Map<String, dynamic>;
        
        if (!data.containsKey('items') || !data.containsKey('transactions')) {
          throw const FormatException('Invalid data format');
        }
        
        await prov.importData(data);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data imported successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Import failed: Invalid JSON format')),
          );
        }
      }
    }
    
    controller.dispose();
  }

  Future<void> _clearAllData(BuildContext context, StockProvider prov) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all items and transactions. '
          'This action cannot be undone.\n\n'
          'Consider exporting your data first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await prov.importData({'items': [], 'transactions': []});
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All data cleared')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to clear data: $e')),
          );
        }
      }
    }
  }

  Future<void> _resetToStationery(BuildContext context, StockProvider prov) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset to Stationery Items?'),
        content: const Text(
          'This will replace all your current data with sample stationery items '
          '(pens, pencils, notebooks, erasers, etc.).\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await prov.clearAndReseed();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data reset to stationery items')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to reset data: $e')),
          );
        }
      }
    }
  }

  Future<void> _signOut(BuildContext context, AuthService authService) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await authService.signOut();
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }
}
