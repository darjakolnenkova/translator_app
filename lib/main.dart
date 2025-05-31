import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.web,
      );
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Translator App',
      themeMode: _themeMode,
      theme: ThemeData(
        primaryColor: const Color(0xFF4A90E2),
        scaffoldBackgroundColor: const Color(0xFFF0F8FF),
        fontFamily: 'Montserrat',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A90E2),
          foregroundColor: Colors.white,
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4A90E2),
          secondary: Color(0xFFE57373),
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: const Color(0xFF4A90E2),
        scaffoldBackgroundColor: const Color(0xFF333333),
        fontFamily: 'Montserrat',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4A90E2),
          secondary: Color(0xFFE57373),
          background: Color(0xFF121212),
          surface: Color(0xFF1E1E1E),
        ),
        cardColor: const Color(0xFF1E1E1E),
      ),
      home: WelcomeScreen(onThemeChanged: _toggleTheme),
    );
  }
}
