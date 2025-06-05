import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


class WelcomeScreen extends StatelessWidget {
  final Function(bool) onThemeChanged;

  const WelcomeScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/backgrounds/waves.svg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Welcome to",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 1.5,
                      fontFamily: 'MediaSans',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "TRANSLATEme",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.4,
                      fontFamily: 'MediaSans',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    const Text(
                      "No more miming...",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final User? user = await AuthService().signInWithGoogle();
                        if (user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MainScreen(
                                onThemeChanged: onThemeChanged,
                                user: user, // передаём firebase user
                              ),
                            ),
                          );
                        }
                        if (user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MainScreen(
                                onThemeChanged: onThemeChanged,
                                user: user,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF5350),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Sign in"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
