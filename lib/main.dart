// lib/main.dart
import 'package:farming/splash_screen.dart'; // Make sure this is imported
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farming/app_theme.dart';
import 'package:farming/language_selection_screen.dart';
import 'firebase_options.dart';
import 'auth_screen.dart'; // Import your AuthScreen

Future<void> main() async {
  // Ensure Firebase is initialized before app runs
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Optional: Enable Firestore persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const VerdaApp());
}

class VerdaApp extends StatelessWidget {
  const VerdaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verda',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      
      // 1. SET 'home' BACK TO SplashScreen
      home: const SplashScreen(),

      // 2. DEFINE ALL YOUR MAIN ROUTES
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const LanguageSelectionScreen(),
        // Note: '/home' now correctly points to LanguageSelectionScreen
        // After auth, you are sent to '/home' (language)
        // After language, you are sent to 'MainScaffold' (the app)
      },
    );
  }
}