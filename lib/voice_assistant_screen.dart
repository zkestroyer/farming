// lib/screens/voice_assistant_screen.dart
import 'package:flutter/material.dart';
import 'package:farming/app_theme.dart';
import 'home_screen.dart';
import 'marketplace_screen.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isListening = false;
  String _recognizedText = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Offline AI simulation
  void _processCommand(String text) {
    text = text.toLowerCase();
    String message;

    if (text.contains("home")) {
      message = "Navigating to Home";
      Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } else if (text.contains("market")) {
      message = "Navigating to Marketplace";
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
      );
    } else if (text.contains("learning")) {
      message = "Navigating to Learning";
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MarketplaceScreen(initialTab: "tutorials"),
        ),
      );
    } else {
      message = "Command not recognized";
    }

    setState(() => _recognizedText = message);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _startListening() {
    setState(() => _isListening = true);
    // Demo: simulate recognition after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _processCommand("market"); // Demo command
      setState(() => _isListening = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BilingualText(
          englishText: "Voice Assistant",
          urduText: "وائس اسسٹنٹ",
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Commands | کمانڈز"),
            Tab(text: "Suggestions | تجاویز"),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Commands tab
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isListening ? "Listening..." : "Tap mic to speak",
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _isListening ? null : _startListening,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryRed.withOpacity(0.2),
                        ),
                        child: Center(
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryRed,
                            ),
                            child: const Icon(
                              Icons.mic,
                              color: AppColors.white,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        _recognizedText,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.primaryRed),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Suggestions tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: const [
                  Text(
                    "Try saying:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("\"Weather today?\" | \"آج کا موسم؟\""),
                  Text("\"Market rates?\" | \"منڈی کے ریٹ؟\""),
                  Text("\"Home\" | \"ہوم\""),
                  Text("\"Learning\" | \"لرننگ\""),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
