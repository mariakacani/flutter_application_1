// lib/models/models.dart - Shared models (UserProfile, ChatRoom, ChatMessage from main.dart + new ones)

import 'package:flutter/material.dart';

class UserProfile {
  const UserProfile({
    required this.email,
    required this.displayName,
    required this.status,
    required this.avatarColor,
  });

  final String email;
  final String displayName;
  final String status;
  final Color avatarColor;

  UserProfile copyWith({String? displayName, String? status, Color? avatarColor}) {
    return UserProfile(
      email: email,
      displayName: displayName ?? this.displayName,
      status: status ?? this.status,
      avatarColor: avatarColor ?? this.avatarColor,
    );
  }

  String get initials {
    final parts = displayName.split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(0, 2)).toUpperCase();
    }
    return parts.map((part) => part.isEmpty ? '' : part[0]).take(2).join().toUpperCase();
  }

  String get firstName => displayName.split(' ').first;
}

class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.lastMessage,
    required this.updatedAt,
    required this.avatarColor,
    required this.messages,
    required this.unreadCount,
  });

  final String id;
  final String name;
  final String subtitle;
  final String lastMessage;
  final String updatedAt;
  final Color avatarColor;
  final List<ChatMessage> messages;
  final int unreadCount;

  ChatRoom copyWith({
    String? lastMessage,
    String? updatedAt,
    List<ChatMessage>? messages,
    int? unreadCount,
  }) {
    return ChatRoom(
      id: id,
      name: name,
      subtitle: subtitle,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarColor: avatarColor,
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(0, 2)).toUpperCase();
    }
    return parts.map((part) => part.isEmpty ? '' : part[0]).take(2).join().toUpperCase();
  }

  static List<ChatRoom> sampleRooms() {
    return [
      ChatRoom(
        id: 'room1',
        name: 'Olta',
        subtitle: 'Në linjë',
        lastMessage: 'Shihemi në 8pm?',
        updatedAt: 'Tani',
        avatarColor: Colors.pink.shade400,
        unreadCount: 2,
        messages: const [],
      ),
      ChatRoom(
        id: 'room2',
        name: 'Familja Grupi',
        subtitle: '5 anëtarë',
        lastMessage: 'Darka fillon në 10 min',
        updatedAt: '17:18',
        avatarColor: Colors.orange.shade400,
        unreadCount: 4,
        messages: const [],
      ),
      ChatRoom(
        id: 'room3',
        name: 'Puna',
        subtitle: 'Përditësim projekti',
        lastMessage: 'Draft dërguar për rishikim.',
        updatedAt: '16:35',
        avatarColor: Colors.green.shade400,
        unreadCount: 0,
        messages: const [],
      ),
    ];
  }
}

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.time,
    required this.isMe,
    this.isVoice = false,
    this.voicePath,
    this.sticker,
    this.isSeen = false,
  });

  final String text;
  final String time;
  final bool isMe;
  final bool isVoice;
  final String? voicePath;
  final String? sticker;
  final bool isSeen;

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'time': time,
      'isMe': isMe,
      'isVoice': isVoice,
      'voicePath': voicePath,
      'sticker': sticker,
      'isSeen': isSeen,
    };
  }

  factory ChatMessage.fromMap(Map<dynamic, dynamic> map) {
    return ChatMessage(
      text: map['text'],
      time: map['time'],
      isMe: map['isMe'],
      isVoice: map['isVoice'] ?? false,
      voicePath: map['voicePath'],
      sticker: map['sticker'],
      isSeen: map['isSeen'] ?? false,
    );
  }
}

