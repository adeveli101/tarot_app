// lib/services/gemini_service.dart

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // .env kullanımı için

class GeminiService {
  late final GenerativeModel _model;
  final String modelName = 'gemini-2.0-flash-experimental'; // Sabit model

  GeminiService() {
    // .env'den API anahtarını yükle
    dotenv.load(fileName: ".env");
    final apiKey = dotenv.get('GEMINI_API_KEY', fallback: '');
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
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw Exception("Gemini API'sinden metin yanıtı alınamadı.");
      }
      return response.text!;
    } catch (e) {
      throw Exception('Gemini API çağrısında hata oluştu: $e');
    }
  }
}