import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [
      {'title': 'Welcome', 'body': 'Thanks for trying Skynet Stock!'},
      {'title': 'Reminder', 'body': 'Check low-stock items before ordering.'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (_, i) => ListTile(
          leading: const Icon(Icons.mail_outline),
          title: Text(messages[i]['title']!),
          subtitle: Text(messages[i]['body']!),
        ),
      ),
    );
  }
}
