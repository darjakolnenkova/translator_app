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

  bool _isDarkMode = false; // текущая тема

  final List<Widget> _screens = const [
    TranslateScreen(),
    FavoritesScreen(),
    HistoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Обработчик смены темы
  void _handleThemeChanged(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    widget.onThemeChanged(value); // если нужно поднять наверх
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => WelcomeScreen(onThemeChanged: widget.onThemeChanged),
              ),
            );
          },
          child: const Text('TRANSLATEme'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    isDarkMode: _isDarkMode,
                    onThemeChanged: _handleThemeChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.translate), label: 'Translate'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}


