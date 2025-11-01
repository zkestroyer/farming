// lib/services/ai_service.dart
import 'dart:convert';
import 'dart:typed_data'; // Required for image bytes
import 'package:http/http.dart' as http;

class AIService {
  // --- OpenRouter for Text/Crop Recommendations ---
  final String _openRouterApiKey = 'YOUR_OPENROUTER_API_KEY'; // replace with actual key
  final String _openRouterUrl = 'https://api.openrouter.ai/v1/chat/completions';

  // --- Hugging Face for Image/Disease Detection ---
  // (Sign up at https://huggingface.co/settings/tokens to get your key)
  final String _hfApiKey = 'YOUR_HUGGINGFACE_API_KEY';
  // This model is good for common crops like Corn, Potato, Rice, Wheat
  final String _hfDiseaseModelUrl =
      'https://api-inference.huggingface.co/models/wambugu71/crop_leaf_diseases_vit';

  /// (Existing Function) Gets a text-based AI response for crop recommendations, etc.
  Future<String> getAIResponse(String prompt) async {
    if (_openRouterApiKey == 'YOUR_OPENROUTER_API_KEY') {
      return _mockResponse(prompt);
    }

    final body = {
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "system",
          "content":
              "You are Verda, a helpful farming assistant for farmers in Pakistan. You must answer in both simple English and Urdu (using Roman Urdu/Urdu script). Provide clear, actionable advice."
        },
        {"role": "user", "content": prompt},
      ],
    };

    final res = await http.post(
      Uri.parse(_openRouterUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openRouterApiKey',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['choices']?[0]?['message']?['content']?.toString() ??
          'No answer';
    } else {
      return 'AI service error: ${res.statusCode}';
    }
  }

  /// (New Function) Detects plant disease from an image.
  /// Takes image bytes (e.g., from image_picker)
  Future<List<dynamic>> detectPlantDisease(Uint8List imageBytes) async {
    if (_hfApiKey == 'YOUR_HUGGINGFACE_API_KEY') {
      return [
        {"label": "Potato___Late_Blight", "score": 0.85},
        {"label": "Potato___Healthy", "score": 0.15}
      ]; // Mock response
    }

    final res = await http.post(
      Uri.parse(_hfDiseaseModelUrl),
      headers: {
        'Authorization': 'Bearer $_hfApiKey',
      },
      body: imageBytes,
    );

    if (res.statusCode == 200) {
      // The API returns a list of classifications
      return jsonDecode(res.body) as List<dynamic>;
    } else {
      throw Exception(
          'Failed to detect disease: ${res.statusCode} ${res.body}');
    }
  }

  /// (Existing Mock)
  String _mockResponse(String q) {
    q = q.toLowerCase();
    if (q.contains('wheat') || q.contains('gandum')) {
      return 'For wheat (گندم): Use DAP and compost mix. Water twice a week in this season.\n\nگندم کے لیے: ڈی اے پی اور کمپوسٹ کا مکسچر استعمال کریں۔ اس موسم میں ہفتے میں دو بار پانی دیں۔';
    }
    if (q.contains('rate') || q.contains('price') || q.contains('daam')) {
      return 'Current wheat price (sample): 3900 PKR per 40kg in Punjab.\n\nگندم کی موجودہ قیمت (نمونہ): 3900 روپے فی 40 کلوگرام پنجاب میں۔';
    }
    return 'Maaf kijiye, main is sawal ka jawab abhi nahin de sakta.\n\nمعاف کیجئے، میں اس سوال کا جواب ابھی نہیں دے سکتا۔';
  }
}