// lib/screens/voice_assistant_screen.dart
import 'package:flutter/material.dart';
import 'package:farming/app_theme.dart';
import 'package:farming/home_screen.dart';
import 'package:farming/marketplace_screen.dart';
import 'package:farming/learning_screen.dart';
import 'package:farming/smart_farming_screen.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  bool _isListening = false;
  final TextEditingController _demoInputController = TextEditingController();

  void _processCommand(String command) {
    command = command.toLowerCase().trim();

    if (command.contains("home")) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
    } else if (command.contains("market") || command.contains("crop")) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
      );
    } else if (command.contains("learning") || command.contains("learn")) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LearningScreen()),
      );
    } else if (command.contains("smart")) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SmartFarmingScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Command not recognized (demo).")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isListening ? "Listening..." : "Tap to speak / type demo command",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            _isListening ? "سن رہا ہے..." : "ٹیپ کریں یا کمانڈ لکھیں",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 30),

          // Mic / Demo input
          GestureDetector(
            onTap: () {
              setState(() => _isListening = !_isListening);
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryRed.withOpacity(0.1),
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

          // Demo TextField for command input
          if (!_isListening)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                controller: _demoInputController,
                decoration: InputDecoration(
                  labelText: "Type command (home / market / learning / smart)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (value) {
                  _processCommand(value);
                },
              ),
            ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              _processCommand(_demoInputController.text);
            },
            child: const Text("Run Command (Demo)"),
          ),

          const SizedBox(height: 20),

          // Suggestions
          Text(
            "Try saying or typing:",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            "\"Home\" | \"Market\" | \"Learning\" | \"Smart Farm\"",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.black.withOpacity(0.7),
            ),
          ),
          Text(
            "\"گھر\" | \"منڈی\" | \"سیکھیں\" | \"سمارٹ فارم\"",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.black.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
