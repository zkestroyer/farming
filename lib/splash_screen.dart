// lib/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farming/app_theme.dart'; // For your colors

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Wait for 2 seconds (to show the splash screen)
    await Future.delayed(const Duration(seconds: 2));

    // Check if the user is logged in
    User? user = FirebaseAuth.instance.currentUser;

    if (!mounted) return; // Check if the widget is still in the tree

    if (user != null) {
      // User is logged in, go to the language screen (which is '/home')
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // User is not logged in, go to the auth screen
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This is a simple splash UI. You can customize it with your logo.
    return Scaffold(
      backgroundColor: AppColors.warmBeige,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your Verda Logo (same as from language_selection_screen)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.chocolateBrown.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.eco, // Placeholder icon
                  size: 70,
                  color: AppColors.primaryRed,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Verda",
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.chocolateBrown,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: AppColors.primaryRed,
            ),
          ],
        ),
      ),
    );
  }
}