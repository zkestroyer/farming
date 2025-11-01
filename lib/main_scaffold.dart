// lib/main_scaffold.dart
import 'package:flutter/material.dart';
import 'package:farming/app_theme.dart';
import 'package:farming/home_screen.dart'; // home_screen
import 'package:farming/learning_screen.dart'; // learning_screen
import 'package:farming/marketplace_screen.dart'; //marketplace_screen
import 'package:farming/smart_farming_screen.dart'; // smart_farming_screen
import 'package:farming/voice_assistant_screen.dart'; //voice_assistant_screenn

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SmartFarmingScreen(),
    MarketplaceScreen(),
    LearningScreen(),
    VoiceAssistantScreen(),
  ];

  void _onItemTapped(int index) {
    // Special case for the Voice Assistant
    if (index == 4) {
      _showVoiceAssistantOverlay();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // This matches your UI spec of an "overlay"
  void _showVoiceAssistantOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VoiceAssistantScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          _buildNavItem(
            context,
            icon: Icons.home_rounded,
            label: "Home",
            urduLabel: "گھر",
          ),
          _buildNavItem(
            context,
            icon: Icons.agriculture_rounded,
            label: "Smart Farm",
            urduLabel: "سمارٹ فارم",
          ),
          _buildNavItem(
            context,
            icon: Icons.shopping_cart_rounded,
            label: "Market",
            urduLabel: "منڈی",
          ),
          _buildNavItem(
            context,
            icon: Icons.school_rounded,
            label: "Learning",
            urduLabel: "سیکھیں",
          ),
          _buildNavItem(
            context,
            icon: Icons.mic_rounded,
            label: "Verda",
            urduLabel: "وردا",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // Helper to create bilingual nav items
  BottomNavigationBarItem _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String urduLabel,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 28),
      label: "$label\n$urduLabel", // Simple newline for bilingual
      activeIcon: Icon(icon, size: 30, color: AppColors.primaryRed),
    );
  }
}
