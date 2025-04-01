import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late final GenerativeModel _model;
  final String modelName = 'gemini-2.5-pro-exp-03-25';
  final double temperature = 0.3; // Düşük sıcaklık daha tutarlı sonuçlar için
  final int maxOutputTokens = 1600; // Maksimum çıktı token sayısı

  GeminiService() {
    final apiKey = dotenv.get('GEMINI_API_KEY', fallback: '');
    if (kDebugMode) {
      print('API Key: Gemini başlatıldı.');
    }
    if (apiKey.isEmpty) {
      throw Exception('GeminiService. API anahtarı .env dosyasında bulunamadı veya boş.');
    }

    _model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
    );
  }

  Future<String> generateContent(String prompt) async {
    try {
      final content = [Content.text(prompt)];


      final GenerationConfig generationConfig = GenerationConfig(
        temperature: temperature,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: maxOutputTokens,
      );

      final response = await _model.generateContent(
        content,
        generationConfig: generationConfig,
      );

      if (response.text == null) {
        throw Exception("Gemini API'sinden metin yanıtı alınamadı.");
      }
      return response.text!;
    } catch (e) {
      throw Exception('Gemini API çağrısında hata oluştu: $e');
    }
  }
}