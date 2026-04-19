// lib/models/status_story.dart
import 'package:flutter/material.dart';
import 'models.dart';


class StatusStory {
  const StatusStory({
    required this.id,
    required this.user,
    required this.timestamp,
    required this.seenBy,
  });

  final String id;
  final UserProfile user;
  final String timestamp;
  final List<String> seenBy;

  static List<StatusStory> sampleStories() => [
    StatusStory(id: '1', user: UserProfile(email: 'olta@test.com', displayName: 'Olta', status: 'Në linjë', avatarColor: Colors.pink.shade400), timestamp: 'Tani', seenBy: []),
    StatusStory(id: '2', user: UserProfile(email: 'family@test.com', displayName: 'Familja', status: '5 anëtarë', avatarColor: Colors.orange.shade400), timestamp: '17:20', seenBy: ['You']),
  ];
}

