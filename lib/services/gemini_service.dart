import 'dart:async'; // Timeout için eklendi
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late final GenerativeModel _model;
  // --- Ayarlar ---
  // Model adını güncel ve geçerli tutun (örn: 'gemini-1.5-flash-latest')
  final String _modelName = 'gemini-1.5-flash-latest';
  final double _temperature = 0.3; // Düşük sıcaklık daha tutarlı sonuçlar için
  final int _maxOutputTokens = 1600; // Maksimum çıktı token sayısı
  final Duration _timeoutDuration = const Duration(seconds: 45); // API isteği için zaman aşımı süresi

  // --- Önbelleklenmiş Yapılandırmalar ---
  late final GenerationConfig _generationConfig;
  late final List<SafetySetting> _safetySettings;

  GeminiService() {
    // API Anahtarını yükle
    final apiKey = dotenv.get('GEMINI_API_KEY', fallback: '');
    if (apiKey.isEmpty) {
      if (kDebugMode) {
        print('HATA: GeminiService - API anahtarı .env dosyasında bulunamadı veya boş.');
      }
      // Uygulamanın başlangıcında bu hatayı fırlatmak genellikle daha iyidir
      throw Exception('GeminiService: API anahtarı .env dosyasında bulunamadı veya boş.');
    }
    if (kDebugMode) {
      print('GeminiService: API Anahtarı yüklendi, model başlatılıyor...');
    }

    // Modeli başlat
    _model = GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
      // GenerationConfig ve SafetySettings burada tanımlanabilir veya generateContent içinde kullanılabilir.
      // generateContent içinde kullanmak daha esnek olabilir ama burada tanımlamak tekrarı önler.
    );

    // GenerationConfig'i bir kere oluştur
    _generationConfig = GenerationConfig(
      temperature: _temperature,
      topK: 40, // Bu değerleri ihtiyacınıza göre ayarlayın
      topP: 0.95, // Bu değerleri ihtiyacınıza göre ayarlayın
      maxOutputTokens: _maxOutputTokens,
      // candidateCount: 1, // Genellikle 1 yeterlidir
      // stopSequences: [], // Gerekirse durdurma dizileri
    );

    // Güvenlik Ayarlarını Tanımla (İhtiyacınıza göre ayarlayın!)
    _safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
    ];

    if (kDebugMode) {
      print('GeminiService: Model ($_modelName) başarıyla başlatıldı.');
    }
  }

  Future<String> generateContent(String prompt) async {
    if (kDebugMode) {
      print('GeminiService: İçerik üretimi başlatılıyor...');
      // Güvenlik riski oluşturabileceği için prompt'u debug modda bile loglamaktan kaçının
      // print('Prompt length: ${prompt.length}');
    }

    try {
      final content = [Content.text(prompt)];

      // API isteğini yap ve zaman aşımı uygula
      final response = await _model.generateContent(
        content,
        generationConfig: _generationConfig, // Önbelleklenmiş config'i kullan
        safetySettings: _safetySettings,      // Tanımlanmış güvenlik ayarlarını kullan
      ).timeout( // <<< Zaman aşımı eklendi
        _timeoutDuration,
        onTimeout: () {
          if (kDebugMode) {
            print('GeminiService: API isteği zaman aşımına uğradı ($_timeoutDuration).');
          }
          // Zaman aşımı durumunda özel bir hata fırlat
          throw TimeoutException('Gemini API isteği zaman aşımına uğradı.');
        },
      );

      // Yanıtı kontrol et
      final text = response.text;
      if (text == null) {
        // Yanıtın neden null olduğunu anlamak için response'u loglayabiliriz
        if (kDebugMode) {
          print('GeminiService Hata: API yanıtı null. FinishReason: ${response.promptFeedback?.blockReason}, SafetyRatings: ${response.candidates.firstOrNull?.safetyRatings}');
        }
        // Kullanıcıya daha anlamlı bir hata mesajı verilebilir
        String errorMessage = "Gemini API'sinden metin yanıtı alınamadı.";
        if (response.promptFeedback?.blockReason != null) {
          errorMessage += " Sebep: ${response.promptFeedback!.blockReason!.name}";
        } else if (response.candidates.firstOrNull?.finishReason != FinishReason.stop) {
          errorMessage += " Sebep: ${response.candidates.firstOrNull?.finishReason?.name}";
        }
        throw Exception(errorMessage);
      }

      if (kDebugMode) {
        print('GeminiService: İçerik başarıyla üretildi (Uzunluk: ${text.length}).');
      }
      return text;

    } on TimeoutException catch (e) { // Zaman aşımını özel olarak yakala
      if (kDebugMode) {
        print('GeminiService Hata (Timeout): $e');
      }
      // Tekrar deneyip denemeyeceğine veya kullanıcıya bilgi verip vermeyeceğine karar ver
      throw Exception('İstek zaman aşımına uğradı. Lütfen tekrar deneyin.'); // Kullanıcı dostu mesaj
    } on GenerativeAIException catch (e) { // API'ye özgü hataları yakala
      if (kDebugMode) {
        // API hataları genellikle daha fazla detay içerir
        print('GeminiService Hata (API): ${e.message}');
      }
      // Kullanıcıya daha spesifik bilgi verilebilir (örn. "İçerik güvenlik nedeniyle engellendi.")
      // ancak genellikle genel bir hata mesajı yeterlidir.
      throw Exception('Fal yorumu oluşturulurken bir sorun oluştu: ${e.message}');
    } catch (e, stackTrace) { // Diğer beklenmedik hataları yakala
      if (kDebugMode) {
        // Beklenmedik hatalar için StackTrace'i loglamak önemlidir
        print('GeminiService Hata (Bilinmeyen): $e');
        print(stackTrace);
      }
      // Genel hata mesajı
      throw Exception('Beklenmedik bir hata oluştu: $e');
    }
  }
}