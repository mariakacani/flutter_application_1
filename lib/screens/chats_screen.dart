import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_application_1/models/models.dart'; // ChatRoom

class ChatsTab extends StatefulWidget {
  const ChatsTab({super.key});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<ChatRoom> rooms = ChatRoom.sampleRooms();
  bool _showSearch = false;

  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _listController.forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Vibrant search bar with glass effect
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Kërko biseda',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onChanged: (value) {
                          // Filter logic
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedScale(
                  scale: _showSearch ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _showSearch = false);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Story carousel - vibrant circles
        SizedBox(
          height: 100,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: [
              _StoryCircle(name: 'Statusi im', isMe: true),
              ...List.generate(5, (i) => _StoryCircle(name: 'Story ${i+1}')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Animated chat list
        Expanded(
          child: AnimatedBuilder(
            animation: _listController,
            builder: (context, child) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _listController.view,
                    builder: (context, child) {
                      final scale = 0.8 + (0.2 * index / rooms.length * _listController.value);
                      return Transform.scale(
                        scale: scale,
                        child: FadeTransition(
                          opacity: _listController.view,
                          child: _ChatTile(room: rooms[index]),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StoryCircle extends StatelessWidget {
  const _StoryCircle({required this.name, this.isMe = false});

  final String name;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isMe 
                ? const LinearGradient(colors: [Colors.green, Colors.greenAccent])
                : const LinearGradient(colors: [Colors.purple, Colors.pink]),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: isMe
              ? const Icon(Icons.add, color: Colors.white, size: 30)
              : const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({required this.room});

  final ChatRoom room;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: room.avatarColor,
          radius: 28,
          child: Text(room.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(room.subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            Text(room.lastMessage, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(room.updatedAt, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            if (room.unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.purple.shade600, borderRadius: BorderRadius.circular(12)),
                child: Text('${room.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ],
        ),
        onTap: () {
          // Navigate to chat room
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hapur ${room.name} 🎉')),
          );
        },
      ),
    );
  }
}
