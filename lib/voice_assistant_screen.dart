import 'package:flutter/material.dart';
import 'package:farming/app_theme.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speech.initialize();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() => _text = val.recognizedWords),
        );
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
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
            _isListening ? "Listening..." : "Tap to speak",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _text.isEmpty
                ? (_isListening ? "سن رہا ہے..." : "بولنے کے لیے ٹیپ کریں")
                : _text,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          GestureDetector(
            onTap: _listen,
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
