// lib/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';

class CustomChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomChatAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.avatarColor,
    required this.initials,
    this.onCall,
    this.onVideo,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final Color avatarColor;
  final String initials;
  final VoidCallback? onCall;
  final VoidCallback? onVideo;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: onBack != null ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack) : null,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(radius: 20, backgroundColor: avatarColor, child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ]),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.videocam), onPressed: onVideo),
        IconButton(icon: const Icon(Icons.call), onPressed: onCall),
        PopupMenuButton<String>(
          // ignore: avoid_print
          onSelected: (value) => print('Action: $value'),
          itemBuilder: (context) => ['Search', 'View contact', 'Media', 'Mute'].map((e) => PopupMenuItem(value: e, child: Text(e))).toList(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

