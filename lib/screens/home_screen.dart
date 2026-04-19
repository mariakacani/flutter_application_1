import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import '../widgets/drawer_menu.dart';
import 'calls_screen.dart';
import 'status_screen.dart';
import 'chats_screen.dart';
import 'chat_room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.currentUser,
    required this.onProfileUpdate,
    required this.onLogout,
  });

  final UserProfile currentUser;
  final void Function(String name, String status) onProfileUpdate;
  final VoidCallback onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final Box _box;
  List<ChatRoom> _rooms = ChatRoom.sampleRooms();

  @override
  void initState() {
    super.initState();
    _box = Hive.box('messages_db');
    final savedRooms = _box.get('chat_rooms');
    if (savedRooms != null) {
      _rooms = List<ChatRoom>.from(
        (savedRooms as List).map((item) => ChatRoom.fromMap(Map<dynamic, dynamic>.from(item as Map))),
      );
    }
  }

  void _saveRooms() {
    _box.put('chat_rooms', _rooms.map((room) => room.toMap()).toList());
  }

  void _openProfileEditor() {
    final nameController = TextEditingController(text: widget.currentUser.displayName);
    final statusController = TextEditingController(text: widget.currentUser.status);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ndrysho profilin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Emri'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: statusController,
                decoration: const InputDecoration(labelText: 'Statusi'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Anulo')),
            FilledButton(
              onPressed: () {
                widget.onProfileUpdate(nameController.text.trim(), statusController.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Ruaj'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateChatDialog() {
    final nameController = TextEditingController();
    final subtitleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Krijo bisedë të re'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Emri i kontaktit'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subtitleController,
                decoration: const InputDecoration(labelText: 'Përshkrimi i shkurtër'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Anulo')),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                setState(() {
                  _rooms.insert(
                    0,
                    ChatRoom(
                      id: 'room_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      subtitle: subtitleController.text.trim().isEmpty ? 'Kontakt i ri' : subtitleController.text.trim(),
                      lastMessage: 'Bisedë e re e krijuar.',
                      updatedAt: 'Tani',
                      avatarColor: Colors.primaries[_rooms.length % Colors.primaries.length].shade400,
                      unreadCount: 0,
                      messages: const [
                        ChatMessage(text: 'Hej! Kjo është një bisedë e re.', time: 'Tani', isMe: false),
                      ],
                    ),
                  );
                  _saveRooms();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Krijo'),
            ),
          ],
        );
      },
    );
  }

  void _openChatRoom(String roomId) {
    final room = _rooms.firstWhere((room) => room.id == roomId);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(
          currentUser: widget.currentUser,
          room: room,
          onSendMessage: _sendMessageToRoom,
        ),
      ),
    );
  }

  void _sendMessageToRoom(String roomId, ChatMessage message) {
    setState(() {
      _rooms = _rooms.map((room) {
        if (room.id != roomId) return room;
        return room.copyWith(
          lastMessage: message.text,
          updatedAt: message.time,
          messages: [...room.messages, message],
          unreadCount: room.unreadCount,
        );
      }).toList();
      _saveRooms();
    });
  }

  void _onMenuAction(String value) {
    if (value == 'Profil') {
      _openProfileEditor();
      return;
    }
    if (value == 'Cilësimet') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cilësimet do të vijnë së shpejti')));
      return;
    }
    if (value == 'Dil') {
      widget.onLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ChatsTab(
        currentUser: widget.currentUser,
        rooms: _rooms,
        onOpenChat: _openChatRoom,
        onCreateChat: _showCreateChatDialog,
      ),
      const CallsScreen(),
      const StatusScreen(),
    ];

    return Scaffold(
      extendBody: true,
      drawer: ChatDrawer(
        user: widget.currentUser,
        onUpdateProfile: widget.onProfileUpdate,
        onEditProfile: _openProfileEditor,
        onLogout: widget.onLogout,
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: widget.currentUser.avatarColor,
              child: Text(widget.currentUser.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.currentUser.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(widget.currentUser.status, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showCreateChatDialog,
          ),
          PopupMenuButton<String>(
            onSelected: _onMenuAction,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Profil', child: Text('Profil')),
              PopupMenuItem(value: 'Cilësimet', child: Text('Cilësimet')),
              PopupMenuItem(value: 'Dil', child: Text('Dil')),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: Colors.purple.shade600,
          unselectedItemColor: Colors.grey.shade400,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Biseda'),
            BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Thirrje'),
            BottomNavigationBarItem(icon: Icon(Icons.circle_notifications_outlined), label: 'Statusi'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateChatDialog,
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
        child: const Icon(Icons.edit),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: IndexedStack(
              index: _currentIndex,
              key: ValueKey(_currentIndex),
              children: tabs,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.purple.shade50.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
