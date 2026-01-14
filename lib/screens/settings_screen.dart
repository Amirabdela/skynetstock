import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<StockProvider>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
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
            ),
            const Divider(),
          ],
          
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('Export data'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final data = await prov.exportData();
              final count = (data['items'] as List).length;
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'Exported $count items (clipboard not implemented)',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Import data (not implemented)'),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Import not implemented')),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Skynet Stock — inventory management app'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Skynet Stock',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2026 Skynet Stock',
                children: [
                  const SizedBox(height: 16),
                  const Text('A modern inventory management solution with Firebase authentication.'),
                ],
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade400),
            title: Text('Sign out', style: TextStyle(color: Colors.red.shade400)),
            onTap: () async {
              final navigator = Navigator.of(context);
              
              // Show confirmation dialog
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
              
              if (confirm == true) {
                await authService.signOut();
                if (context.mounted) {
                   Navigator.of(context).popUntil((route) => route.isFirst);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
