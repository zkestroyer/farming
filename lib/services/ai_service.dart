import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  final String apiKey = 'YOUR_API_KEY'; // replace with actual key
  final String apiUrl = 'https://api.openrouter.ai/v1/chat/completions';

  // send a prompt and return simple string reply
  Future<String> getAIResponse(String prompt) async {
    if (apiKey == 'YOUR_API_KEY') {
      // Mock reply for hackathon demo (works offline)
      return _mockResponse(prompt);
    }

    final body = {
      "model": "gpt-4o-mini", // example; change per provider
      "messages": [
        {
          "role": "system",
          "content": "You are Verda, a helpful farming assistant.",
        },
        {"role": "user", "content": prompt},
      ],
    };

    final res = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      // adapt to API response structure
      return data['choices']?[0]?['message']?['content']?.toString() ??
          'No answer';
    } else {
      return 'AI service error: ${res.statusCode}';
    }
  }

  String _mockResponse(String q) {
    q = q.toLowerCase();
    if (q.contains('wheat') || q.contains('gehu') || q.contains('geho')) {
      return 'Best fertilizer for wheat: use DAP + compost mix; water twice a week in this season.';
    }
    if (q.contains('rate') || q.contains('price') || q.contains('daam')) {
      return 'Current wheat price (sample): 3400 PKR per 40kg in Punjab.';
    }
    return 'Maaf kijiye, main is sawal ka jawab abhi nahin de sakta. Try a different question.';
  }
}
