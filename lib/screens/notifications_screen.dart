import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = [
      {'title': 'Sync complete', 'time': 'Just now'},
      {'title': 'Low stock: Nails Box', 'time': '1h'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (_, i) => ListTile(
          leading: const Icon(Icons.notifications_none),
          title: Text(notes[i]['title']!),
          trailing: Text(notes[i]['time']!),
        ),
      ),
    );
  }
}
