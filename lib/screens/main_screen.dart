import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'translate_screen.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'welcome_screen.dart';

class MainScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final User user;

  const MainScreen({
    Key? key,
    required this.onThemeChanged,
    required this.user,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final List<Widget> _screens = [
    const TranslateScreen(),
    const FavoritesScreen(),
    const HistoryScreen(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _handleThemeChanged(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    widget.onThemeChanged(value);
  }

  Future<void> _signOut() async {
    try {
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Ошибка при выходе: $e');
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => WelcomeScreen(onThemeChanged: widget.onThemeChanged),
      ),
    );
  }

  void _navigateToWelcomeScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => WelcomeScreen(onThemeChanged: widget.onThemeChanged),
      ),
    );
  }

  void _navigateToSettingsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          isDarkMode: _isDarkMode,
          onThemeChanged: _handleThemeChanged,
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _signOut();
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _navigateToWelcomeScreen,
          child: const Text(
            'TRANSLATEme',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettingsScreen,
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _showLogoutDialog,
              child: CircleAvatar(
                radius: 18,
                backgroundImage: widget.user.photoURL != null
                    ? NetworkImage(widget.user.photoURL!)
                    : null,
                backgroundColor: Colors.grey[300],
                child: widget.user.photoURL == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(theme),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(ThemeData theme) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: theme.colorScheme.secondary,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.translate),
          label: 'Translate',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          activeIcon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
      ],
    );
  }
}
