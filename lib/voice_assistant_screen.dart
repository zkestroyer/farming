// lib/screens/voice_assistant_screen.dart
import 'package:flutter/material.dart';
import 'package:farming/app_theme.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  // In a real app, this would be tied to your voice recognition state
  bool _isListening = true;

  @override
  Widget build(BuildContext context) {
    // This creates the "white overlay" effect on the bottom half
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
            _isListening ? "Listening..." : "Tap to speak",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            _isListening ? "سن رہا ہے..." : "بولنے کے لیے ٹیپ کریں",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 40),

          // Listening Animation
          // This is a simple placeholder; you'd replace this with
          // a proper animation (e.g., Lottie)
          GestureDetector(
            onTap: () => setState(() => _isListening = !_isListening),
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
          const SizedBox(height: 40),

          // Suggestions
          Text("Try saying:", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            "\"Weather today?\" | \"Market rates?\"",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.black.withOpacity(0.7),
            ),
          ),
          Text(
            "\"آج کا موسم؟\" | \"منڈی کے ریٹ؟\"",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.black.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
