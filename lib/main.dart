// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farming/app_theme.dart';
import 'package:farming/language_selection_screen.dart';

Future<void> main() async {
  // Ensure Firebase is initialized before app runs
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
      // Starting screen (your friend's UI)
      home: const LanguageSelectionScreen(),
    );
  }
}
