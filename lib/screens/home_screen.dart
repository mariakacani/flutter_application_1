import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/models.dart';
import '../widgets/drawer_menu.dart';
import 'calls_screen.dart';
import 'status_screen.dart';
import 'chats_screen.dart';

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
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  final List<Widget> _tabs = [
    const ChatsTab(), // Step 3
    const CallsScreen(),
    const StatusScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      drawer: ChatDrawer(
        user: widget.currentUser,
        onUpdateProfile: widget.onProfileUpdate,
        onLogout: widget.onLogout,
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
        onPressed: () {
          // New chat/action
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bisedë e re \\u{1F60A}')),
          );
        },
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
        child: const Icon(Icons.edit),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _tabs[_currentIndex].copyWithKey(Key(_currentIndex.toString())),
          ),
          // Gradient overlay for vibrant look
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.purple.shade50.withOpacity(0.3),
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

// Placeholder for ChatsTab - implement in step 3
class ChatsTab extends StatelessWidget {
  const ChatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Biseda - Coming Soon', style: TextStyle(fontSize: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget copyWithKey(Key key) => KeyedSubtree(key: key, child: this);
}

extension KeyedWidget on Widget {
  Widget copyWithKey(Key key) => KeyedSubtree(key: key, child: this);
}
