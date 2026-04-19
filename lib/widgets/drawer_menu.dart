// lib/widgets/drawer_menu.dart
import 'package:flutter/material.dart';
import '../models/models.dart';

class ChatDrawer extends StatelessWidget {
  const ChatDrawer({
    super.key,
    required this.user,
    required this.onUpdateProfile,
    required this.onEditProfile,
    required this.onLogout,
  });

  final UserProfile user;
  final void Function(String name, String status) onUpdateProfile;
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.purple, Colors.pink]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'user_avatar',
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: user.avatarColor,
                    child: Text(user.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user.displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(user.status, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onEditProfile,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Ndrysho profilin'),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Biseda e re'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Grup i ri'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.broadcast_on_personal),
            title: const Text('Broadcast'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profili'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Cilësimet'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Fto miq'),
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Dil', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              onLogout();
            },
          ),
        ],
      ),
    );
  }
}

