// lib/screens/status_screen.dart
import 'package:flutter/material.dart';
import '../models/status_story.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stories = StatusStory.sampleStories();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statusi'),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.add, color: Colors.white)),
            title: const Text('Statusi im'),
            subtitle: const Text('Tap për të postuar'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: story.user.avatarColor,
                    child: Text(story.user.initials, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  title: Text(story.user.displayName),
                  subtitle: Text(story.timestamp),
                  trailing: Text('${story.seenBy.length} shikuar'),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

