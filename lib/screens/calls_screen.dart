import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/call_log.dart';

// lib/screens/calls_screen.dart


class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  Future<void> _makeCall(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    final logs = CallLog.sampleLogs();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thirrje'),
        actions: [
          IconButton(icon: const Icon(Icons.message), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _makeCall('+355691234567'),
        child: const Icon(Icons.call),
      ),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          final icon = log.type == 'missed' 
            ? Icons.call_received : log.type == 'outgoing' ? Icons.call_made : Icons.call_received;
          final color = log.type == 'missed' ? Colors.red : Colors.green;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: log.avatarColor,
              child: Icon(icon, color: Colors.white),
            ),
            title: Text(log.name),
            subtitle: Text(log.number),
            trailing: Icon(Icons.call, color: color),
            onTap: () => _makeCall(log.number),
          );
        },
      ),
    );
  }
}
