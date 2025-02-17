// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a tr locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'tr';

  static String m0(error) => "Kartlar yüklenirken bir hata oluştu: ${error}";

  static String m1(error) =>
      "Kategori bazlı açılım alınırken bir hata oluştu: ${error}";

  static String m2(error) =>
      "Celtic Cross açılımı alınırken bir hata oluştu: ${error}";

  static String m3(message) => "Hata: ${message}";

  static String m4(error) =>
      "Beş Kart Yol Ayrımı açılımı alınırken bir hata oluştu: ${error}";

  static String m5(category, spreadType) =>
      "Bu fal, ${category} konusunda ${spreadType} açılımı ile derin bir içgörü sunmaktadır. Ruhunuzun derinliklerine yolculuk yaparken, kartların gizemli mesajlarını birlikte yorumlayalım.";

  static String m6(error) =>
      "Geçmiş-Şimdi-Gelecek açılımı alınırken bir hata oluştu: ${error}";

  static String m7(error) =>
      "Problem-Çözüm açılımı alınırken bir hata oluştu: ${error}";

  static String m8(error) =>
      "İlişki açılımı alınırken bir hata oluştu: ${error}";

  static String m9(error) =>
      "Tek kart açılımı alınırken bir hata oluştu: ${error}";

  static String m10(category) =>
      "Bu kartların bir araya gelmesi, ${category} yolculuğunuzda önemli bir dönüm noktasını işaret ediyor. Kartların birleşik enerjisi, ruhunuzun derinliklerindeki mesajları açığa çıkarıyor.";

  static String m11(error) =>
      "Yıllık açılım alınırken bir hata oluştu: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "cardLoadingError": m0,
    "cardsCombinedAssessment": MessageLookupByLibrary.simpleMessage(
      "Kartların Beraber Değerlendirilmesi",
    ),
    "cardsEnergiesInteract": MessageLookupByLibrary.simpleMessage(
      "Kartların enerjileri birbirini etkiliyor.",
    ),
    "careerReading": MessageLookupByLibrary.simpleMessage(
      "Kariyer Açılımı Yap",
    ),
    "categorySpreadReadingError": m1,
    "celticCrossReadingError": m2,
    "divineDance": MessageLookupByLibrary.simpleMessage(
      "Kartların İlahi Dansı",
    ),
    "errorMessage": m3,
    "fiveCardPathReadingError": m4,
    "fortuneInsight": m5,
    "futureSuggestions": MessageLookupByLibrary.simpleMessage(
      "Yakın geleceğiniz için şu önerilere kulak verin: [YAKIN_GELECEK_ÖNERİLER]",
    ),
    "generalDetailedComment": MessageLookupByLibrary.simpleMessage(
      "Genel Yorum (Detaylı)",
    ),
    "guidingWhispers": MessageLookupByLibrary.simpleMessage(
      "Yol Gösterici Fısıltılar",
    ),
    "lifeDynamicsHighlighted": MessageLookupByLibrary.simpleMessage(
      "Bu kartlar hayatınızdaki önemli dinamikleri vurguluyor.",
    ),
    "loveReading": MessageLookupByLibrary.simpleMessage("Aşk Açılımı Yap"),
    "meaning": MessageLookupByLibrary.simpleMessage("Anlamı"),
    "mysticMeaning": MessageLookupByLibrary.simpleMessage("Mistik Yorum"),
    "noSelectionYet": MessageLookupByLibrary.simpleMessage(
      "Henüz bir seçim yapılmadı",
    ),
    "pastPresentFuture": MessageLookupByLibrary.simpleMessage(
      "Geçmiş-Şimdi-Gelecek Açılımı Yap",
    ),
    "pastPresentFutureReadingError": m6,
    "position": MessageLookupByLibrary.simpleMessage("Pozisyon"),
    "potentialPitfalls": MessageLookupByLibrary.simpleMessage(
      "Dikkat etmeniz gereken potansiyel tuzaklar: [DİKKAT_EDİLMESİ_GEREKEN_NOKTALAR]",
    ),
    "problemSolution": MessageLookupByLibrary.simpleMessage(
      "Problem-Çözüm Açılımı Yap",
    ),
    "problemSolutionReadingError": m7,
    "relationshipSpreadReadingError": m8,
    "singleCard": MessageLookupByLibrary.simpleMessage("Tek Kart Açılımı Yap"),
    "singleCardReadingError": m9,
    "tarotFortune": MessageLookupByLibrary.simpleMessage("Tarot Falı"),
    "tarotFortuneGuide": MessageLookupByLibrary.simpleMessage(
      "Tarot Falı - Gizemli Yolların Kılavuzu",
    ),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Tekrar Dene"),
    "unifiedDestinyMessage": m10,
    "unifiedDestinyReflection": MessageLookupByLibrary.simpleMessage(
      "Birleşik Kaderin Yansıması",
    ),
    "yearlySpreadReadingError": m11,
  };
}
