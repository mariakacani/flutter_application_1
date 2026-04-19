import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'models/models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('messages_db');
  runApp(const ChatApp());
}

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  UserProfile? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _loadSavedUser();
  }

  UserProfile? _loadSavedUser() {
    final savedUser = Hive.box('messages_db').get('current_user');
    if (savedUser == null) return null;
    return UserProfile.fromMap(Map<dynamic, dynamic>.from(savedUser as Map));
  }

  void _persistCurrentUser() {
    if (_currentUser != null) {
      Hive.box('messages_db').put('current_user', _currentUser!.toMap());
    }
  }

  void _signIn(String email) {
    final displayName = _formatNameFromEmail(email);
    setState(() {
      _currentUser = UserProfile(
        email: email,
        displayName: displayName,
        status: 'Available',
        avatarColor: Colors.teal.shade700,
      );
      _persistCurrentUser();
    });
  }

  void _updateProfile(String name, String status) {
    setState(() {
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          displayName: name.isEmpty ? _currentUser!.displayName : name,
          status: status.isEmpty ? _currentUser!.status : status,
        );
        _persistCurrentUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MailChat',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: _currentUser == null
          ? LoginPage(onSignIn: _signIn)
          : HomeScreen(
              currentUser: _currentUser!,
              onProfileUpdate: _updateProfile,
              onLogout: () {
                Hive.box('messages_db').delete('current_user');
                setState(() => _currentUser = null);
              },
            ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onSignIn});

  final void Function(String email) onSignIn;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _autoValidate = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _autoValidate = true;
      });
      return;
    }
    widget.onSignIn(_emailController.text.trim().toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.pink, Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'MailChat',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hyni me email vetëm dhe filloni të bisedoni menjëherë.',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 36),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  color: Colors.white.withValues(alpha: 0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _autoValidate
                          ? AutovalidateMode.always
                          : AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Shkruani email-in tuaj',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ju lutem shkruani email-in tuaj';
                              }
                              if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(value.trim())) {
                                return 'Shkruani një adresë email të vlefshme';
                              }
                              return null;
                              },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _submit,
                            child: const Text('Vazhdo', style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Nuk kërkohet numër telefoni. Profilet ndërtohen vetëm me email-in tuaj.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatHomePage extends StatelessWidget {
  const ChatHomePage({
    super.key,
    required this.currentUser,
    required this.chatRooms,
    required this.onProfileUpdate,
    required this.onSendMessage,
    required this.onAddContact,
  });

  final UserProfile currentUser;
  final List<ChatRoom> chatRooms;
  final void Function(String name, String status) onProfileUpdate;
  final void Function(String roomId, ChatMessage message) onSendMessage;
  final void Function(String name, String subtitle) onAddContact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(context),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.person_add),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 420,
                          child: Column(
                            children: [
                              _buildHeader(context),
                              const SizedBox(height: 12),
                              _buildStoriesRow(),
                              const SizedBox(height: 12),
                              Expanded(child: _buildChatList(context)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(child: _buildDesktopPlaceholder(context)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 12),
                        _buildStoriesRow(),
                        const SizedBox(height: 12),
                        Expanded(child: _buildChatList(context)),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFFEA80FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mirësevini në MailChat',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Zgjidh një chat për të filluar bisedën, ose shto një kontakt të ri duke përdorur butonin e mëposhtëm.',
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => _showAddContactDialog(context),
            child: const Text('Shto kontakt të ri'),
          ),
          const Spacer(),
          const Text(
            'Raporto për çdo problem nëse dëshiron të personalizosh më shumë bisedat tuaja.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: currentUser.avatarColor,
            child: Text(
              currentUser.initials,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Përshëndetje, ${currentUser.firstName}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(currentUser.status, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openProfile(context),
            icon: const Icon(Icons.person_outline, size: 28),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 28),
            onSelected: (value) {
              if (value == 'settings') {
                _openSettingsPage(context);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'settings', child: Text('Cilësimet')),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final nameController = TextEditingController();
    final subtitleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Shto kontakt të ri'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Emri'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subtitleController,
                decoration: const InputDecoration(labelText: 'Titulli ose statusi'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anulo'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final subtitle = subtitleController.text.trim();
                if (name.isNotEmpty) {
                  onAddContact(name, subtitle.isEmpty ? 'Kontakt i ri' : subtitle);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Shto'),
            ),
          ],
        );
      },
    );
  }

  void _openSettingsPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsPage(user: currentUser)));
  }

  Widget _buildStoriesRow() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: chatRooms.length,
        itemBuilder: (context, index) {
          final room = chatRooms[index];
          return Padding(
            padding: EdgeInsets.only(right: index == chatRooms.length - 1 ? 0 : 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: room.avatarColor,
                  child: Text(room.initials, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 72,
                  child: Text(
                    room.name,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatList(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: const [
                Expanded(
                  child: Text('Biseda', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                Icon(Icons.search, color: Colors.black54),
                SizedBox(width: 12),
                Icon(Icons.more_vert, color: Colors.black54),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: chatRooms.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final room = chatRooms[index];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChatRoomPage(
                      currentUser: currentUser,
                      room: room,
                      onSendMessage: onSendMessage,
                    ),
                  )),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: const Color(0xFFF6F7FB),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: room.avatarColor,
                          child: Text(room.initials, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(room.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                              const SizedBox(height: 6),
                              Text(
                                room.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(room.updatedAt, style: const TextStyle(color: Colors.black45, fontSize: 12)),
                            const SizedBox(height: 8),
                            if (room.unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade700,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  room.unreadCount.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ProfilePage(
        user: currentUser,
        onSave: onProfileUpdate,
      ),
    ));
  }
}

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({
    super.key,
    required this.currentUser,
    required this.room,
    required this.onSendMessage,
  });

  final UserProfile currentUser;
  final ChatRoom room;
  final void Function(String roomId, ChatMessage message) onSendMessage;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _messageController = TextEditingController();
  final List<String> _stickers = ['❤️', '😂', '🎉', '🔥', '🌟'];
  bool _isRecording = false;
  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  List<ChatMessage> _loadMessages() {
    final box = Hive.box('messages_db');
    final stored = box.get(widget.room.id, defaultValue: <Map>[]) as List;
    return stored
        .map((item) => ChatMessage.fromMap(item as Map<dynamic, dynamic>))
        .toList();
  }

  void _persistMessages() {
    final box = Hive.box('messages_db');
    box.put(widget.room.id, _messages.map((m) => m.toMap()).toList());
  }

  void _send({String? sticker, bool isVoice = false, String? voicePath}) {
    final text = sticker ?? (isVoice ? 'Mesazh zanor' : _messageController.text.trim());
    if (text.isEmpty) return;

    final newMessage = ChatMessage(
      text: text,
      time: _formattedTime(DateTime.now()),
      isMe: true,
      isVoice: isVoice,
      voicePath: voicePath,
      sticker: sticker,
      isSeen: true,
    );

    setState(() {
      _messages.add(newMessage);
    });
    _persistMessages();
    widget.onSendMessage(widget.room.id, newMessage);
    _messageController.clear();
  }

  void _toggleRecording() {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
      });
      _send(isVoice: true);
      return;
    }

    setState(() {
      _isRecording = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: widget.room.avatarColor,
              child: Text(widget.room.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.room.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(widget.room.subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEDE7F6), Color(0xFFF3F7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(child: _buildMessages()),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _stickers
                      .map(
                        (sticker) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            label: Text(sticker, style: const TextStyle(fontSize: 22)),
                            backgroundColor: Colors.purple.shade50,
                            onPressed: () => _send(sticker: sticker),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _toggleRecording,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: _isRecording ? Colors.red.shade400 : Colors.purple.shade700,
                      child: Icon(_isRecording ? Icons.mic_off : Icons.mic, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Shkruani një mesazh',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        filled: true,
                        fillColor: const Color(0xFFF4F6FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.purple.shade700,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => _send(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildBubble(message);
      },
    );
  }

  Widget _buildBubble(ChatMessage message) {
    final alignment = message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = message.isMe ? Colors.purple.shade700 : Colors.white;
    final textColor = message.isMe ? Colors.white : Colors.black87;
    final radius = message.isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
            bottomLeft: Radius.circular(22),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
            bottomRight: Radius.circular(22),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: color,
              borderRadius: radius,
              boxShadow: message.isMe
                  ? [BoxShadow(color: Colors.purple.shade100.withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 3))]
                  : [const BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: _buildMessageContent(message, textColor),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message.time, style: const TextStyle(fontSize: 12, color: Colors.black45)),
              if (message.isMe) ...[
                const SizedBox(width: 8),
                Icon(
                  message.isSeen ? Icons.done_all : Icons.done,
                  size: 16,
                  color: message.isSeen ? Colors.blueAccent : Colors.black45,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage message, Color textColor) {
    if (message.sticker != null) {
      return Text(message.sticker!, style: TextStyle(fontSize: 32, color: textColor));
    }
    if (message.isVoice) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic, color: textColor),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'Mesazh zanor',
              style: TextStyle(color: textColor, fontSize: 15, height: 1.35),
            ),
          ),
        ],
      );
    }
    return Text(message.text, style: TextStyle(color: textColor, fontSize: 15, height: 1.35));
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.user, required this.onSave});

  final UserProfile user;
  final void Function(String name, String status) onSave;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cilësimet'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: user.avatarColor,
                  child: Text(user.initials, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(user.email, style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text('Llogaria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.lock),
                    title: Text('Privatësia'),
                    subtitle: Text('Kontrolloni kush shikon statusin tuaj'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text('Njoftimet'),
                    subtitle: Text('Menaxhoni tingujt dhe paralajmërimet'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.chat),
                    title: Text('Tema e bisedës'),
                    subtitle: Text('Zgjidhni sfond për bisedat tuaja'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Ndihma', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.help_outline),
                    title: Text('Qëndroni të sigurt'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Mbi aplikacionin'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _statusController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _statusController = TextEditingController(text: widget.user.status);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        title: const Text('Profili'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: widget.user.avatarColor,
              child: Text(widget.user.initials, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 18),
            Text(widget.user.email, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 28),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Emri i shfaqur',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _statusController,
              decoration: const InputDecoration(
                labelText: 'Statusi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  widget.onSave(_nameController.text.trim(), _statusController.text.trim());
                  Navigator.of(context).pop();
                },
                child: const Text('Ruaj profilin', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



String _formatNameFromEmail(String email) {
  final namePart = email.split('@').first.replaceAll(RegExp(r'[._]'), ' ');
  return namePart
      .split(' ')
      .map((part) => part.isEmpty ? '' : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ')
      .trim();
}

String _formattedTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

