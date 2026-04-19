import 'package:flutter/material.dart';
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

  final List<Widget> _tabs = [
    const ChatsTab(),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bisedë e re 🎉')),
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
            child: IndexedStack(
              index: _currentIndex,
              key: ValueKey(_currentIndex),
              children: _tabs,
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
