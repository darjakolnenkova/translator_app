import 'package:flutter/material.dart';
import 'translate_screen.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'welcome_screen.dart';

class MainScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  const MainScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _navigateToWelcomeScreen(),
          child: const Text(
            'TRANSLATEme',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigateToSettingsScreen(),
            tooltip: 'Settings',
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