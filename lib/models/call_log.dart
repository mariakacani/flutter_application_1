// lib/models/call_log.dart
import 'package:flutter/material.dart';

class CallLog {
  const CallLog({
    required this.id,
    required this.name,
    required this.number,
    required this.type, // 'incoming', 'outgoing', 'missed'
    required this.duration,
    required this.time,
    required this.avatarColor,
    required this.hasVideo,
  });

  final String id;
  final String name;
  final String number;
  final String type;
  final String duration;
  final String time;
  final Color avatarColor;
  final bool hasVideo;

  String get initials {
    final parts = name.split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return parts.take(2).map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').join();
  }

  static List<CallLog> sampleLogs() => [
    CallLog(id: '1', name: 'Olta', number: '+355 69 123 4567', type: 'outgoing', duration: '00:45', time: 'Tani', avatarColor: Colors.pink.shade400, hasVideo: false),
    CallLog(id: '2', name: 'Familja', number: '+355 69 987 6543', type: 'incoming', duration: '01:23', time: '17:30', avatarColor: Colors.orange.shade400, hasVideo: true),
    CallLog(id: '3', name: 'Puna', number: '+355 69 555 0000', type: 'missed', duration: '00:00', time: '16:45', avatarColor: Colors.green.shade400, hasVideo: false),
  ];
}

