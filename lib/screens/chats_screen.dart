import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_application_1/models/models.dart';

class ChatsTab extends StatefulWidget {
  const ChatsTab({
    super.key,
    required this.currentUser,
    required this.rooms,
    required this.onOpenChat,
    required this.onCreateChat,
  });

  final UserProfile currentUser;
  final List<ChatRoom> rooms;
  final void Function(String roomId) onOpenChat;
  final VoidCallback onCreateChat;

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
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

  List<ChatRoom> get _filteredRooms {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.rooms;
    return widget.rooms.where((room) {
      return room.name.toLowerCase().contains(query) || room.lastMessage.toLowerCase().contains(query) || room.subtitle.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: widget.currentUser.avatarColor,
              child: Text(widget.currentUser.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.currentUser.displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: Colors.green.shade400, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(widget.currentUser.status, style: TextStyle(color: Colors.grey[700], fontSize: 14))),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: widget.onCreateChat,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                      fillColor: Colors.white.withValues(alpha: 0.85),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _showSearch = value.isNotEmpty;
                      });
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        SizedBox(
          height: 100,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: [
              _StoryCircle(name: 'Statusi im', isMe: true),
              ...List.generate(5, (i) => _StoryCircle(name: 'Story ${i + 1}')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AnimatedBuilder(
            animation: _listController,
            builder: (context, child) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: _filteredRooms.length,
                itemBuilder: (context, index) {
                  final room = _filteredRooms[index];
                  return AnimatedBuilder(
                    animation: _listController.view,
                    builder: (context, child) {
                      final scale = 0.8 + (0.2 * index / _filteredRooms.length * _listController.value);
                      return Transform.scale(
                        scale: scale,
                        child: FadeTransition(
                          opacity: _listController.view,
                          child: _ChatTile(room: room, onTap: () => widget.onOpenChat(room.id)),
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
          SizedBox(
            width: 80,
            child: Text(
              name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({required this.room, required this.onTap});

  final ChatRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: room.avatarColor,
                radius: 28,
                child: Text(room.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(room.lastMessage, style: TextStyle(color: Colors.grey[600], fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(room.updatedAt, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  if (room.unreadCount > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.purple.shade600, borderRadius: BorderRadius.circular(16)),
                      child: Text('${room.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
