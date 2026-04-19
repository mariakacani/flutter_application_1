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
    this.onMenuSelected,
  });

  final String title;
  final String subtitle;
  final Color avatarColor;
  final String initials;
  final VoidCallback? onCall;
  final VoidCallback? onVideo;
  final VoidCallback? onBack;
  final void Function(String)? onMenuSelected;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: onBack != null ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack) : null,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(radius: 20, backgroundColor: avatarColor, child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
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
          onSelected: onMenuSelected ?? (_) {},
          itemBuilder: (context) => ['Search', 'View contact', 'Mute'].map((e) => PopupMenuItem(value: e, child: Text(e))).toList(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

