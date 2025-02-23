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

  static String m0(count) => "${count} kart";

  static String m1(error) => "Kartlar yüklenirken bir hata oluştu: ${error}";

  static String m2(error) => "Kartlar yüklenirken hata: ${error}";

  static String m3(error) => "Kartlar yüklenirken bir hata oluştu";

  static String m4(error) =>
      "Kategori bazlı açılım alınırken bir hata oluştu: ${error}";

  static String m5(error) =>
      "Celtic Cross açılımı alınırken bir hata oluştu: ${error}";

  static String m6(message) => "Hata: ${message}";

  static String m7(error) =>
      "Beş Kart Yol Ayrımı açılımı alınırken bir hata oluştu: ${error}";

  static String m8(category, spreadType) =>
      "Bu fal, ${category} konusunda ${spreadType} açılımı ile derin bir içgörü sunmaktadır. Ruhunuzun derinliklerine yolculuk yaparken, kartların gizemli mesajlarını birlikte yorumlayalım.";

  static String m9(error) =>
      "Geçmiş-Şimdi-Gelecek açılımı alınırken bir hata oluştu: ${error}";

  static String m10(error) =>
      "Problem-Çözüm açılımı alınırken bir hata oluştu: ${error}";

  static String m11(error) =>
      "İlişki açılımı alınırken bir hata oluştu: ${error}";

  static String m12(error) =>
      "Tek kart açılımı alınırken bir hata oluştu: ${error}";

  static String m13(category, spreadType) =>
      "Bu fal, ${category} konusunda ${spreadType} açılımı ile kişisel ve derin içgörüler sunmaktadır. Ruhunuzun derinliklerine inmeye ve kartların size özel mesajlarını keşfetmeye hazır olun!";

  static String m14(category) =>
      "Bu kartların bir araya gelmesi, ${category} yolculuğunuzda önemli bir dönüm noktasını işaret ediyor. Kartların birleşik enerjisi, ruhunuzun derinliklerindeki mesajları açığa çıkarıyor.";

  static String m15(error) =>
      "Yıllık açılım alınırken bir hata oluştu: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "cardCount": m0,
    "cardDeckEmpty": MessageLookupByLibrary.simpleMessage("Kart destesi boş"),
    "cardLoadingError": m1,
    "cardSelection": MessageLookupByLibrary.simpleMessage("Kart Seçimi"),
    "cardSelectionInstructions": MessageLookupByLibrary.simpleMessage(
      "Kart sayısı kadar kapalı kart ekranda görüntülenecektir. Lütfen tek tek dokunarak açınız, uzun basarak kısa açıklamasını görün veya \'Bütün Kartları Çevir\' seçeneğini kullanınız.",
    ),
    "cardsCombinedAssessment": MessageLookupByLibrary.simpleMessage(
      "Kartların Beraber Değerlendirilmesi",
    ),
    "cardsCombinedEvaluation": MessageLookupByLibrary.simpleMessage(
      "Kartların Birlikte Değerlendirilmesi",
    ),
    "cardsEnergiesInteract": MessageLookupByLibrary.simpleMessage(
      "Kartların enerjileri birbirini etkiliyor.",
    ),
    "cardsLoadingErrorGeneric": m2,
    "cards_loading_error": m3,
    "career": MessageLookupByLibrary.simpleMessage("Kariyer"),
    "careerDescription": MessageLookupByLibrary.simpleMessage(
      "İş hayatınız ve kariyeriniz hakkında rehberlik alın",
    ),
    "careerReading": MessageLookupByLibrary.simpleMessage(
      "Kariyer Açılımı Yap",
    ),
    "categoryInfoBanner": MessageLookupByLibrary.simpleMessage(
      "Seçtiğiniz kategoriye göre özel açılımlar sunulacaktır",
    ),
    "categorySelection": MessageLookupByLibrary.simpleMessage(
      "Kategori Seçimi",
    ),
    "categorySpecificTips": MessageLookupByLibrary.simpleMessage(
      "Kategoriye Özel İpuçları",
    ),
    "categorySpreadReadingError": m4,
    "celticCrossDescription": MessageLookupByLibrary.simpleMessage(
      "Detaylı ve kapsamlı analiz",
    ),
    "celticCrossReading": MessageLookupByLibrary.simpleMessage("Celtic Cross"),
    "celticCrossReadingError": m5,
    "chooseSpread": MessageLookupByLibrary.simpleMessage(
      "Kartların nasıl açılacağını seçin",
    ),
    "chooseTopic": MessageLookupByLibrary.simpleMessage(
      "Fal baktırmak istediğiniz konuyu seçin",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Kapat"),
    "customPromptHint": MessageLookupByLibrary.simpleMessage(
      "Özel isteğinizi buraya yazın...",
    ),
    "customPromptTitle": MessageLookupByLibrary.simpleMessage("Özel İstek"),
    "deck_empty": MessageLookupByLibrary.simpleMessage("Kart destesi boş"),
    "detailedGeneralCommentary": MessageLookupByLibrary.simpleMessage(
      "Derinlemesine Genel Yorum",
    ),
    "differentInterpretation": MessageLookupByLibrary.simpleMessage(
      "Her seçimde farklı bir yorum sizi bekliyor",
    ),
    "divineDance": MessageLookupByLibrary.simpleMessage(
      "Kartların İlahi Dansı",
    ),
    "divineSymphony": MessageLookupByLibrary.simpleMessage(
      "Kartların İlahi Senfonisi",
    ),
    "errorMessage": m6,
    "fiveCardPath": MessageLookupByLibrary.simpleMessage("Beş Kart Yol Ayrımı"),
    "fiveCardPathDescription": MessageLookupByLibrary.simpleMessage(
      "Kariyer seçimleriniz için detaylı analiz",
    ),
    "fiveCardPathReadingError": m7,
    "flipAllCards": MessageLookupByLibrary.simpleMessage(
      "Bütün Kartları Çevir",
    ),
    "fortuneInsight": m8,
    "fortuneTelling": MessageLookupByLibrary.simpleMessage("Fal Yorumu:"),
    "futureSuggestions": MessageLookupByLibrary.simpleMessage(
      "Yakın geleceğiniz için şu önerilere kulak verin: [YAKIN_GELECEK_ÖNERİLER]",
    ),
    "general": MessageLookupByLibrary.simpleMessage("Genel"),
    "generalAnalysis": MessageLookupByLibrary.simpleMessage("Genel Analiz"),
    "generalDescription": MessageLookupByLibrary.simpleMessage(
      "Genel yaşam rehberliği alın",
    ),
    "generalDetailedComment": MessageLookupByLibrary.simpleMessage(
      "Genel Yorum (Detaylı)",
    ),
    "guidingWhispers": MessageLookupByLibrary.simpleMessage(
      "Yol Gösterici Fısıltılar",
    ),
    "guidingWhispersAndSuggestions": MessageLookupByLibrary.simpleMessage(
      "Yol Gösterici Fısıltılar & Öneriler",
    ),
    "keywords": MessageLookupByLibrary.simpleMessage("Anahtar Kelimeler:"),
    "lifeDynamicsHighlighted": MessageLookupByLibrary.simpleMessage(
      "Bu kartlar hayatınızdaki önemli dinamikleri vurguluyor.",
    ),
    "lightMeaning": MessageLookupByLibrary.simpleMessage("Işık:"),
    "loveDescription": MessageLookupByLibrary.simpleMessage(
      "İlişkileriniz hakkında derinlemesine bilgi alın",
    ),
    "loveReading": MessageLookupByLibrary.simpleMessage("Aşk Açılımı Yap"),
    "loveRelationships": MessageLookupByLibrary.simpleMessage(
      "Aşk & İlişkiler",
    ),
    "meaning": MessageLookupByLibrary.simpleMessage("Anlamı"),
    "money": MessageLookupByLibrary.simpleMessage("Para"),
    "moneyDescription": MessageLookupByLibrary.simpleMessage(
      "Finansal konularda içgörü kazanın",
    ),
    "mysticJourney": MessageLookupByLibrary.simpleMessage("Mistik Yolculuk"),
    "mysticMeaning": MessageLookupByLibrary.simpleMessage("Mistik Yorum"),
    "noSelectionYet": MessageLookupByLibrary.simpleMessage(
      "Henüz bir seçim yapılmadı",
    ),
    "pastPresentFuture": MessageLookupByLibrary.simpleMessage(
      "Geçmiş-Şimdi-Gelecek Açılımı Yap",
    ),
    "pastPresentFutureDescription": MessageLookupByLibrary.simpleMessage(
      "Kariyer yolunuz için rehberlik",
    ),
    "pastPresentFutureReadingError": m9,
    "pointsToWatch": MessageLookupByLibrary.simpleMessage(
      "Dikkat Edilmesi Gerekenler",
    ),
    "position": MessageLookupByLibrary.simpleMessage("Pozisyon"),
    "potentialPitfalls": MessageLookupByLibrary.simpleMessage(
      "Dikkat etmeniz gereken potansiyel tuzaklar: [DİKKAT_EDİLMESİ_GEREKEN_NOKTALAR]",
    ),
    "problemSolution": MessageLookupByLibrary.simpleMessage(
      "Problem-Çözüm Açılımı Yap",
    ),
    "problemSolutionReadingError": m10,
    "promptEmptyError": MessageLookupByLibrary.simpleMessage(
      "Lütfen bir istek giriniz.",
    ),
    "relationshipSpread": MessageLookupByLibrary.simpleMessage(
      "İlişki Açılımı",
    ),
    "relationshipSpreadDescription": MessageLookupByLibrary.simpleMessage(
      "İlişkinizin detaylı analizi",
    ),
    "relationshipSpreadReadingError": m11,
    "reshuffleCards": MessageLookupByLibrary.simpleMessage(
      "Kartları Yeniden Karıştır",
    ),
    "sendPrompt": MessageLookupByLibrary.simpleMessage("İsteği Gönder"),
    "settings": MessageLookupByLibrary.simpleMessage("Ayarlar"),
    "shadowMeaning": MessageLookupByLibrary.simpleMessage("Gölge:"),
    "singleCard": MessageLookupByLibrary.simpleMessage("Tek Kart Açılımı Yap"),
    "singleCardDescription": MessageLookupByLibrary.simpleMessage(
      "Hızlı cevap için ideal",
    ),
    "singleCardReadingError": m12,
    "specialNote": MessageLookupByLibrary.simpleMessage("Özel Not"),
    "spreadInfoBanner": MessageLookupByLibrary.simpleMessage(
      "Her açılım farklı sayıda kart ve yorum içerir",
    ),
    "spreadSelection": MessageLookupByLibrary.simpleMessage("Açılım Seçimi"),
    "startJourney": MessageLookupByLibrary.simpleMessage("Yolculuğa Başla"),
    "swipeForMore": MessageLookupByLibrary.simpleMessage(
      "Daha fazla bilgi için kaydırın",
    ),
    "swipeToSeePages": MessageLookupByLibrary.simpleMessage(
      "Sayfaları görmek için kaydırın",
    ),
    "tarotFortune": MessageLookupByLibrary.simpleMessage("Tarot Falı"),
    "tarotFortuneDescription": m13,
    "tarotFortuneGuide": MessageLookupByLibrary.simpleMessage(
      "Tarot Falı - Gizemli Yolların Kılavuzu",
    ),
    "tarotFortuneTitle": MessageLookupByLibrary.simpleMessage(
      "Tarot Falı - Gizemli Yolların Kılavuzu",
    ),
    "timelineAndSuggestions": MessageLookupByLibrary.simpleMessage(
      "Zaman Çizelgesi & Öneriler",
    ),
    "tooManyCardsRequested": MessageLookupByLibrary.simpleMessage(
      "İstenen kart sayısı desteden fazla",
    ),
    "too_many_cards": MessageLookupByLibrary.simpleMessage(
      "Çok fazla kart seçildi",
    ),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Tekrar Dene"),
    "unifiedDestinyMessage": m14,
    "unifiedDestinyReflection": MessageLookupByLibrary.simpleMessage(
      "Birleşik Kaderin Yansıması",
    ),
    "unifiedDestinyReflectionTitle": MessageLookupByLibrary.simpleMessage(
      "Birleşik Kaderin Yansımaları",
    ),
    "viewResults": MessageLookupByLibrary.simpleMessage("Sonuçları Gör"),
    "yearlySpreadDescription": MessageLookupByLibrary.simpleMessage(
      "12 ay için rehberlik",
    ),
    "yearlySpreadReading": MessageLookupByLibrary.simpleMessage(
      "Yıllık Açılım",
    ),
    "yearlySpreadReadingError": m15,
  };
}
