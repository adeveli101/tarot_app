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

  static String m0(error) => "Astrolojik Haç açılımı hatası: \$${error}";

  static String m1(error) => "Kırık Kalp açılımı hatası: \$${error}";

  static String m2(count) => "${count} kart";

  static String m3(error) => "Kartlar yüklenirken bir hata oluştu: ${error}";

  static String m4(error) => "Kartlar yüklenirken hata: ${error}";

  static String m5(error) => "Kartlar yüklenirken bir hata oluştu";

  static String m6(error) => "Kariyer Yolu açılımı hatası: \$${error}";

  static String m7(error) =>
      "Kategori bazlı açılım alınırken bir hata oluştu: ${error}";

  static String m8(error) =>
      "Celtic Cross açılımı alınırken bir hata oluştu: ${error}";

  static String m9(message) => "${message}";

  static String m10(message) => "${message}";

  static String m11(credits) => "${credits} kredi ile daha fazla fal aç";

  static String m12(count) => "${count} kredi başarıyla eklendi!";

  static String m13(error) => "Rüya Yorumu açılımı hatası: \$${error}";

  static String m14(message) => "Hata: ${message}";

  static String m15(error) =>
      "Beş Kart Yol Ayrımı açılımı alınırken bir hata oluştu: ${error}";

  static String m16(category, spreadType) =>
      "Bu fal, ${category} konusunda ${spreadType} açılımı ile derin bir içgörü sunmaktadır. Ruhunuzun derinliklerine yolculuk yaparken, kartların gizemli mesajlarını birlikte yorumlayalım.";

  static String m17(error) => "Dolunay açılımı hatası: \$${error}";

  static String m18(error) => "At Nalı açılımı hatası: \$${error}";

  static String m19(required) =>
      "Devam etmek için ${required} krediye ihtiyacınız var. Aşağıdan daha fazla kredi satın alın.";

  static String m20(error) => "Zihin-Beden-Ruh açılımı hatası: \$${error}";

  static String m21(hours) =>
      "Bir sonraki ücretsiz fal hakkınız ${hours} saat içinde kullanılabilir olacak.";

  static String m22(error) =>
      "Geçmiş-Şimdi-Gelecek açılımı alınırken bir hata oluştu: ${error}";

  static String m23(error) =>
      "Problem-Çözüm açılımı alınırken bir hata oluştu: ${error}";

  static String m24(title, price) =>
      "${title} ürününü ${price} karşılığında satın almak istiyor musunuz?";

  static String m25(error) => "Satın alma başarısız: ${error}";

  static String m26(error) =>
      "İlişki açılımı alınırken bir hata oluştu: ${error}";

  static String m27(spreadType, dateStr) =>
      "${spreadType} Okuması - ${dateStr}";

  static String m28(error) =>
      "Tek kart açılımı alınırken bir hata oluştu: ${error}";

  static String m29(category, spreadType) =>
      "Bu fal, ${category} konusunda ${spreadType} açılımı ile kişisel ve derin içgörüler sunmaktadır. Ruhunuzun derinliklerine inmeye ve kartların size özel mesajlarını keşfetmeye hazır olun!";

  static String m30(category) =>
      "Bu kartların bir araya gelmesi, ${category} yolculuğunuzda önemli bir dönüm noktasını işaret ediyor. Kartların birleşik enerjisi, ruhunuzun derinliklerindeki mesajları açığa çıkarıyor.";

  static String m31(error) =>
      "Yıllık açılım alınırken bir hata oluştu: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "arcana": MessageLookupByLibrary.simpleMessage("Sır"),
    "areYouSure": MessageLookupByLibrary.simpleMessage(
      "Satın almak istediğinizden emin misiniz:",
    ),
    "astroChallenge": MessageLookupByLibrary.simpleMessage("Astro Zorluk"),
    "astroFuture": MessageLookupByLibrary.simpleMessage("Astro Gelecek"),
    "astroLogicalCross": MessageLookupByLibrary.simpleMessage("Astrolojik Haç"),
    "astroLogicalCrossDescription": MessageLookupByLibrary.simpleMessage(
      "Yolunuzu yıldızlarla hizalayın.",
    ),
    "astroLogicalCrossDescriptionGeneral": MessageLookupByLibrary.simpleMessage(
      "Yolunuzu yıldızlarla hizalayın.",
    ),
    "astroLogicalCrossDescriptionSpiritual":
        MessageLookupByLibrary.simpleMessage(
          "Manevi yolunuzu yıldızlarla hizalayın.",
        ),
    "astroLogicalCrossError": m0,
    "astroOutcome": MessageLookupByLibrary.simpleMessage("Astro Sonuç"),
    "astroPast": MessageLookupByLibrary.simpleMessage("Astro Geçmiş"),
    "astroPresent": MessageLookupByLibrary.simpleMessage("Astro Şimdiki"),
    "bodySpirit": MessageLookupByLibrary.simpleMessage("Beden-Ruh"),
    "brokenHeart": MessageLookupByLibrary.simpleMessage("Kalp Kırıklığı"),
    "brokenHeartCause": MessageLookupByLibrary.simpleMessage("Neden"),
    "brokenHeartDescription": MessageLookupByLibrary.simpleMessage(
      "Duygusal acıyı anla ve iyileştir.",
    ),
    "brokenHeartEmotion": MessageLookupByLibrary.simpleMessage("Duygu"),
    "brokenHeartError": m1,
    "brokenHeartHealing": MessageLookupByLibrary.simpleMessage("İyileşme"),
    "brokenHeartHope": MessageLookupByLibrary.simpleMessage("Umut"),
    "brokenHeartLesson": MessageLookupByLibrary.simpleMessage("Ders"),
    "bundleDescription": MessageLookupByLibrary.simpleMessage(
      "50 kredi + Premium abonelik",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("İptal"),
    "cardCount": m2,
    "cardDeckEmpty": MessageLookupByLibrary.simpleMessage("Kart destesi boş"),
    "cardLoadingError": m3,
    "cardSelection": MessageLookupByLibrary.simpleMessage("Kart Seçimi"),
    "cardSelectionInstructions": MessageLookupByLibrary.simpleMessage(
      "Kart sayısı kadar kapalı kart ekranda görüntülenecektir. Lütfen tek tek dokunarak açınız, uzun basarak kısa açıklamasını görün veya \'Bütün Kartları Çevir\' seçeneğini kullanınız.",
    ),
    "cards": MessageLookupByLibrary.simpleMessage("Kartlar"),
    "cardsCombinedAssessment": MessageLookupByLibrary.simpleMessage(
      "Kartların Beraber Değerlendirilmesi",
    ),
    "cardsCombinedEvaluation": MessageLookupByLibrary.simpleMessage(
      "Kartların Birlikte Değerlendirilmesi",
    ),
    "cardsEnergiesInteract": MessageLookupByLibrary.simpleMessage(
      "Kartların enerjileri birbirini etkiliyor.",
    ),
    "cardsLoadingErrorGeneric": m4,
    "cards_loading_error": m5,
    "career": MessageLookupByLibrary.simpleMessage("Kariyer"),
    "careerChallenge": MessageLookupByLibrary.simpleMessage("Kariyer Zorluk"),
    "careerDescription": MessageLookupByLibrary.simpleMessage(
      "İş hayatınız ve kariyeriniz hakkında rehberlik alın",
    ),
    "careerOutcome": MessageLookupByLibrary.simpleMessage("Kariyer Sonuç"),
    "careerPast": MessageLookupByLibrary.simpleMessage("Kariyer Geçmişi"),
    "careerPathSpread": MessageLookupByLibrary.simpleMessage("Kariyer Açılımı"),
    "careerPathSpreadDescription": MessageLookupByLibrary.simpleMessage(
      "Kariyerin için detaylı rehberlik.",
    ),
    "careerPathSpreadDescriptionMoney": MessageLookupByLibrary.simpleMessage(
      "Finansal büyüme için detaylı rehberlik alın.",
    ),
    "careerPathSpreadError": m6,
    "careerPotential": MessageLookupByLibrary.simpleMessage(
      "Kariyer Potansiyel",
    ),
    "careerPresent": MessageLookupByLibrary.simpleMessage("Kariyer Şimdiki"),
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
    "categorySpreadReadingError": m7,
    "celticCrossChallenge": MessageLookupByLibrary.simpleMessage("Zorluk"),
    "celticCrossConscious": MessageLookupByLibrary.simpleMessage(
      "Kelt Haçı Bilinçli",
    ),
    "celticCrossCurrentSituation": MessageLookupByLibrary.simpleMessage(
      "Mevcut Durum",
    ),
    "celticCrossDescription": MessageLookupByLibrary.simpleMessage(
      "Detaylı ve kapsamlı analiz",
    ),
    "celticCrossDescriptionSpiritual": MessageLookupByLibrary.simpleMessage(
      "Manevi hayatınız için kapsamlı bir analiz alın.",
    ),
    "celticCrossExternalInfluences": MessageLookupByLibrary.simpleMessage(
      "Dış Etkiler",
    ),
    "celticCrossFinalOutcome": MessageLookupByLibrary.simpleMessage("Sonuç"),
    "celticCrossFuture": MessageLookupByLibrary.simpleMessage("Olası Gelecek"),
    "celticCrossHopesFears": MessageLookupByLibrary.simpleMessage(
      "Umutlar ve Korkular",
    ),
    "celticCrossNearFuture": MessageLookupByLibrary.simpleMessage(
      "Yakın Gelecek",
    ),
    "celticCrossPast": MessageLookupByLibrary.simpleMessage("Geçmiş"),
    "celticCrossPersonalStance": MessageLookupByLibrary.simpleMessage(
      "Kişisel Duruş",
    ),
    "celticCrossReading": MessageLookupByLibrary.simpleMessage("Celtic Cross"),
    "celticCrossReadingError": m8,
    "celticCrossSubconscious": MessageLookupByLibrary.simpleMessage(
      "Bilinçaltı",
    ),
    "checkingResources": MessageLookupByLibrary.simpleMessage(
      "Kaynaklar kontrol ediliyor...",
    ),
    "chooseSpread": MessageLookupByLibrary.simpleMessage(
      "Kartların nasıl açılacağını seçin",
    ),
    "chooseTopic": MessageLookupByLibrary.simpleMessage(
      "Fal baktırmak istediğiniz konuyu seçin",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Kapat"),
    "confirm": MessageLookupByLibrary.simpleMessage("Onayla"),
    "confirmPurchase": MessageLookupByLibrary.simpleMessage(
      "Satın Alımı Onayla",
    ),
    "couponAlreadyUsed": MessageLookupByLibrary.simpleMessage(
      "Bu kupon zaten kullanılmış.",
    ),
    "couponCannotBeEmpty": MessageLookupByLibrary.simpleMessage(
      "Kupon kodu boş olamaz.",
    ),
    "couponHint": MessageLookupByLibrary.simpleMessage("Kupon kodunu girin"),
    "couponInvalid": m9,
    "couponRedeemed": m10,
    "creditDescription": m11,
    "creditsAdded": m12,
    "customPromptHint": MessageLookupByLibrary.simpleMessage(
      "Özel isteğinizi buraya yazın...",
    ),
    "customPromptTitle": MessageLookupByLibrary.simpleMessage("Özel İstek"),
    "dailyFreeReadings": MessageLookupByLibrary.simpleMessage(
      "Günlük Ücretsiz Fallar",
    ),
    "dailyLimitExceeded": MessageLookupByLibrary.simpleMessage(
      "Günlük ücretsiz fal limitine ulaşıldı. Lütfen kredi satın alın veya premium’a yükseltin.",
    ),
    "dailyLimitReached": MessageLookupByLibrary.simpleMessage(
      "Günlük ücretsiz fal hakkınız doldu.",
    ),
    "dateLabel": MessageLookupByLibrary.simpleMessage("Tarih:"),
    "deck_empty": MessageLookupByLibrary.simpleMessage("Kart destesi boş"),
    "detailedGeneralCommentary": MessageLookupByLibrary.simpleMessage(
      "Derinlemesine Genel Yorum",
    ),
    "details": MessageLookupByLibrary.simpleMessage("Detaylar"),
    "differentInterpretation": MessageLookupByLibrary.simpleMessage(
      "Her seçimde farklı bir yorum sizi bekliyor",
    ),
    "divineDance": MessageLookupByLibrary.simpleMessage(
      "Kartların İlahi Dansı",
    ),
    "divineSymphony": MessageLookupByLibrary.simpleMessage(
      "Kartların İlahi Senfonisi",
    ),
    "drawCards": MessageLookupByLibrary.simpleMessage("Kartları Çek"),
    "dreamFuture": MessageLookupByLibrary.simpleMessage("Rüya Gelecek"),
    "dreamInterpretation": MessageLookupByLibrary.simpleMessage("Rüya Yorumu"),
    "dreamInterpretationDescription": MessageLookupByLibrary.simpleMessage(
      "Rüyalarınızdaki mesajları çözün.",
    ),
    "dreamInterpretationDescriptionSpiritual":
        MessageLookupByLibrary.simpleMessage(
          "Rüyalarınızdaki mesajları manevi bir bakış açısıyla çözün.",
        ),
    "dreamInterpretationError": m13,
    "dreamPast": MessageLookupByLibrary.simpleMessage("Rüya Geçmişi"),
    "dreamPresent": MessageLookupByLibrary.simpleMessage("Rüya Şimdiki Zaman"),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "errorLoadingCardDetails": MessageLookupByLibrary.simpleMessage(
      "Kart detayları yüklenirken hata oluştu.",
    ),
    "errorLoadingReadings": MessageLookupByLibrary.simpleMessage(
      "Okumaları yüklerken hata oluştu",
    ),
    "errorMessage": m14,
    "failedToLoadProducts": MessageLookupByLibrary.simpleMessage(
      "Ürünler yüklenemedi.",
    ),
    "fiftyTokens": MessageLookupByLibrary.simpleMessage("50 Token"),
    "fiveCardPath": MessageLookupByLibrary.simpleMessage("Beş Kart Yol Ayrımı"),
    "fiveCardPathChallenge": MessageLookupByLibrary.simpleMessage("Zorluk"),
    "fiveCardPathDescription": MessageLookupByLibrary.simpleMessage(
      "Kariyer seçimleriniz için detaylı analiz",
    ),
    "fiveCardPathFuture": MessageLookupByLibrary.simpleMessage("Gelecek"),
    "fiveCardPathOutcome": MessageLookupByLibrary.simpleMessage("Sonuç"),
    "fiveCardPathPast": MessageLookupByLibrary.simpleMessage("Geçmiş"),
    "fiveCardPathPresent": MessageLookupByLibrary.simpleMessage("Şimdiki"),
    "fiveCardPathReadingError": m15,
    "flipAllCards": MessageLookupByLibrary.simpleMessage(
      "Bütün Kartları Çevir",
    ),
    "forText": MessageLookupByLibrary.simpleMessage("için"),
    "fortuneInsight": m16,
    "fortuneTelling": MessageLookupByLibrary.simpleMessage("Fal Yorumu:"),
    "fullMoonChallenge": MessageLookupByLibrary.simpleMessage("Dolunay Zorluk"),
    "fullMoonHope": MessageLookupByLibrary.simpleMessage("Dolunay Umut"),
    "fullMoonOutcome": MessageLookupByLibrary.simpleMessage("Dolunay Sonuç"),
    "fullMoonPast": MessageLookupByLibrary.simpleMessage("Dolunay Geçmiş"),
    "fullMoonPresent": MessageLookupByLibrary.simpleMessage("Dolunay Şimdiki"),
    "fullMoonSpread": MessageLookupByLibrary.simpleMessage("Dolunay Açılımı"),
    "fullMoonSpreadDescription": MessageLookupByLibrary.simpleMessage(
      "Berraklık için ay enerjisini kullanın.",
    ),
    "fullMoonSpreadDescriptionLove": MessageLookupByLibrary.simpleMessage(
      "Dolunay enerjisiyle aşk hayatınızdaki gizli mesajları keşfedin.",
    ),
    "fullMoonSpreadDescriptionSpiritual": MessageLookupByLibrary.simpleMessage(
      "Dolunay enerjisiyle manevi berraklık kazanın.",
    ),
    "fullMoonSpreadError": m17,
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
    "horseshoeAdvice": MessageLookupByLibrary.simpleMessage("Öneri"),
    "horseshoeFuture": MessageLookupByLibrary.simpleMessage("Gelecek"),
    "horseshoeObstacles": MessageLookupByLibrary.simpleMessage("Engeller"),
    "horseshoeOutcome": MessageLookupByLibrary.simpleMessage("Sonuç"),
    "horseshoePast": MessageLookupByLibrary.simpleMessage("Geçmiş"),
    "horseshoePresent": MessageLookupByLibrary.simpleMessage("Şimdiki"),
    "horseshoeSpread": MessageLookupByLibrary.simpleMessage("At Nalı Açılımı"),
    "horseshoeSpreadDescription": MessageLookupByLibrary.simpleMessage(
      "Durumunuza geniş bir bakış.",
    ),
    "horseshoeSpreadDescriptionCareer": MessageLookupByLibrary.simpleMessage(
      "Kariyerinizde geniş bir bakış açısı kazanın.",
    ),
    "horseshoeSpreadDescriptionGeneral": MessageLookupByLibrary.simpleMessage(
      "Hayatınızın genelinde geniş bir bakış açısı kazanın.",
    ),
    "horseshoeSpreadDescriptionMoney": MessageLookupByLibrary.simpleMessage(
      "Mali durumunuzda geniş bir bakış açısı kazanın.",
    ),
    "horseshoeSpreadError": m18,
    "horseshoeStrengths": MessageLookupByLibrary.simpleMessage("Güçler"),
    "hundredTokens": MessageLookupByLibrary.simpleMessage("100 Token"),
    "instructions": MessageLookupByLibrary.simpleMessage("Talimatlar"),
    "instructionsDrawCards": MessageLookupByLibrary.simpleMessage(
      "Kartları manuel olarak çekmek için bu düğmeyi kullanın.",
    ),
    "instructionsFlipAll": MessageLookupByLibrary.simpleMessage(
      "Tüm kartları tek dokunuşla çevirin.",
    ),
    "instructionsReshuffle": MessageLookupByLibrary.simpleMessage(
      "Kartları yeniden karıştırarak yeni bir çekiliş yapın.",
    ),
    "instructionsViewResults": MessageLookupByLibrary.simpleMessage(
      "Tüm kartlar açıldığında sonucu görün.",
    ),
    "insufficientCredits": MessageLookupByLibrary.simpleMessage(
      "Devam etmek için yeterli krediniz yok.",
    ),
    "insufficientCreditsAndLimit": MessageLookupByLibrary.simpleMessage(
      "Günlük ücretsiz fal hakkınız doldu ve yeterli krediniz yok.",
    ),
    "insufficientCreditsMessage": m19,
    "interpretation": MessageLookupByLibrary.simpleMessage("Yorumlama"),
    "interpretationSection": MessageLookupByLibrary.simpleMessage(
      "Yorum Bölümü",
    ),
    "invalidPage": MessageLookupByLibrary.simpleMessage("Geçersiz Sayfa"),
    "keywords": MessageLookupByLibrary.simpleMessage("Anahtar Kelimeler:"),
    "language": MessageLookupByLibrary.simpleMessage("Dil"),
    "languageChangedToEnglish": MessageLookupByLibrary.simpleMessage(
      "Dil İngilizce olarak değiştirildi",
    ),
    "languageChangedToTurkish": MessageLookupByLibrary.simpleMessage(
      "Dil Türkçe olarak değiştirildi",
    ),
    "lifeDynamicsHighlighted": MessageLookupByLibrary.simpleMessage(
      "Bu kartlar hayatınızdaki önemli dinamikleri vurguluyor.",
    ),
    "lightMeaning": MessageLookupByLibrary.simpleMessage("Işık (Olumlu):"),
    "longPressHint": MessageLookupByLibrary.simpleMessage("Uzun Basma İpucu"),
    "loveDescription": MessageLookupByLibrary.simpleMessage(
      "İlişkileriniz hakkında derinlemesine bilgi alın",
    ),
    "loveReading": MessageLookupByLibrary.simpleMessage("Aşk Açılımı Yap"),
    "loveRelationships": MessageLookupByLibrary.simpleMessage(
      "Aşk & İlişkiler",
    ),
    "meaning": MessageLookupByLibrary.simpleMessage("Anlamı"),
    "mindBody": MessageLookupByLibrary.simpleMessage("Zihin-Beden"),
    "mindBodySpirit": MessageLookupByLibrary.simpleMessage("Zihin Beden Ruh"),
    "mindBodySpiritDescription": MessageLookupByLibrary.simpleMessage(
      "İç benliğinizi uyumlu hale getirin.",
    ),
    "mindBodySpiritDescriptionLove": MessageLookupByLibrary.simpleMessage(
      "Aşk bağlamında zihin, beden ve ruhunuzu uyumlaştırın.",
    ),
    "mindBodySpiritDescriptionSpiritual": MessageLookupByLibrary.simpleMessage(
      "İçsel benliğinizi zihin, beden ve ruhla uyumlaştırın.",
    ),
    "mindBodySpiritError": m20,
    "mindSpirit": MessageLookupByLibrary.simpleMessage("Zihin-Ruh"),
    "money": MessageLookupByLibrary.simpleMessage("Para"),
    "moneyDescription": MessageLookupByLibrary.simpleMessage(
      "Finansal konularda içgörü kazanın",
    ),
    "myTarotReading": MessageLookupByLibrary.simpleMessage("Benim Tarot Falım"),
    "mysticJourney": MessageLookupByLibrary.simpleMessage("Mistik Yolculuk"),
    "mysticMeaning": MessageLookupByLibrary.simpleMessage("Mistik Yorum"),
    "mysticalTokens": MessageLookupByLibrary.simpleMessage("Mistik Jetonlar"),
    "nextFreeReadingInfo": m21,
    "noCardsInSpread": MessageLookupByLibrary.simpleMessage(
      "Bu açılımda kart bulunamadı.",
    ),
    "noInterpretation": MessageLookupByLibrary.simpleMessage(
      "Yorum mevcut değil",
    ),
    "noProductsAvailable": MessageLookupByLibrary.simpleMessage(
      "Şu anda mevcut ürün bulunmamaktadır.",
    ),
    "noReadingData": MessageLookupByLibrary.simpleMessage(
      "Fal verisi bulunamadı.",
    ),
    "noReadings": MessageLookupByLibrary.simpleMessage(
      "Kayıtlı fal bulunamadı",
    ),
    "noSelectionYet": MessageLookupByLibrary.simpleMessage(
      "Henüz bir seçim yapılmadı",
    ),
    "obstacleAdvice": MessageLookupByLibrary.simpleMessage("Engel / Tavsiye"),
    "overview": MessageLookupByLibrary.simpleMessage("Genel Bakış"),
    "pastPresentFuture": MessageLookupByLibrary.simpleMessage(
      "Geçmiş-Şimdi-Gelecek Açılımı Yap",
    ),
    "pastPresentFutureDescription": MessageLookupByLibrary.simpleMessage(
      "Kariyer yolunuz için rehberlik",
    ),
    "pastPresentFutureDescriptionGeneral": MessageLookupByLibrary.simpleMessage(
      "Hayatınızdaki geçmiş, şimdiki ve gelecekteki etkileri anlayın.",
    ),
    "pastPresentFutureDescriptionLove": MessageLookupByLibrary.simpleMessage(
      "Aşk hayatınızdaki geçmiş, şimdiki ve gelecekteki etkileri anlayın.",
    ),
    "pastPresentFutureDescriptionMoney": MessageLookupByLibrary.simpleMessage(
      "Mali geçmişinizi, şu anınızı ve geleceğinizi keşfedin.",
    ),
    "pastPresentFutureReadingError": m22,
    "paymentSuccessful": MessageLookupByLibrary.simpleMessage("Ödeme Başarılı"),
    "pleaseWait": MessageLookupByLibrary.simpleMessage("Lütfen Bekleyin."),
    "pointsToWatch": MessageLookupByLibrary.simpleMessage(
      "Dikkat Edilmesi Gerekenler",
    ),
    "position": MessageLookupByLibrary.simpleMessage("Pozisyon"),
    "potentialPitfalls": MessageLookupByLibrary.simpleMessage(
      "Dikkat etmeniz gereken potansiyel tuzaklar: [DİKKAT_EDİLMESİ_GEREKEN_NOKTALAR]",
    ),
    "premium": MessageLookupByLibrary.simpleMessage("Premium"),
    "premiumActivated": MessageLookupByLibrary.simpleMessage(
      "Premium abonelik etkinleştirildi!",
    ),
    "premiumDescription": MessageLookupByLibrary.simpleMessage(
      "Sınırsız fal ve özel içeriklere erişim",
    ),
    "premiumReadings": MessageLookupByLibrary.simpleMessage("Premium Okuma"),
    "premiumSubscription": MessageLookupByLibrary.simpleMessage(
      "Premium Abonelik",
    ),
    "problem": MessageLookupByLibrary.simpleMessage("Sorun"),
    "problemSolution": MessageLookupByLibrary.simpleMessage(
      "Problem-Çözüm Açılımı Yap",
    ),
    "problemSolutionDescriptionCareer": MessageLookupByLibrary.simpleMessage(
      "Kariyerinizdeki zorlukları çözmek için rehberlik alın.",
    ),
    "problemSolutionDescriptionMoney": MessageLookupByLibrary.simpleMessage(
      "Finansal zorlukları çözmek için rehberlik alın.",
    ),
    "problemSolutionReadingError": m23,
    "profile": MessageLookupByLibrary.simpleMessage("Profil"),
    "promptEmptyError": MessageLookupByLibrary.simpleMessage(
      "Lütfen bir istek giriniz.",
    ),
    "purchaseConfirmation": m24,
    "purchaseCredits": MessageLookupByLibrary.simpleMessage("Kredi Satın Al"),
    "purchaseFailed": m25,
    "purchasePending": MessageLookupByLibrary.simpleMessage(
      "Satın alma bekleniyor...",
    ),
    "questionsToAsk": MessageLookupByLibrary.simpleMessage("Sorulacak Sorular"),
    "readingResult": MessageLookupByLibrary.simpleMessage("Fal Sonucu"),
    "redeem": MessageLookupByLibrary.simpleMessage("Kullan"),
    "relationshipChallenges": MessageLookupByLibrary.simpleMessage("Zorluklar"),
    "relationshipFuture": MessageLookupByLibrary.simpleMessage("Gelecek"),
    "relationshipPartner": MessageLookupByLibrary.simpleMessage("Partner"),
    "relationshipPast": MessageLookupByLibrary.simpleMessage("Geçmiş"),
    "relationshipPresent": MessageLookupByLibrary.simpleMessage("Şimdiki"),
    "relationshipSelf": MessageLookupByLibrary.simpleMessage("Kendiniz"),
    "relationshipSpread": MessageLookupByLibrary.simpleMessage(
      "İlişki Açılımı",
    ),
    "relationshipSpreadDescription": MessageLookupByLibrary.simpleMessage(
      "İlişkinizin detaylı analizi",
    ),
    "relationshipSpreadReadingError": m26,
    "relationshipStrengths": MessageLookupByLibrary.simpleMessage(
      "Güçlü Yönler",
    ),
    "reshuffleCards": MessageLookupByLibrary.simpleMessage(
      "Kartları Yeniden Karıştır",
    ),
    "returnToHome": MessageLookupByLibrary.simpleMessage("Ana Sayfaya Dön"),
    "selectToDraw": MessageLookupByLibrary.simpleMessage(
      "Kaderinizi görmek için kaydırın",
    ),
    "sendPrompt": MessageLookupByLibrary.simpleMessage("İsteği Gönder"),
    "settings": MessageLookupByLibrary.simpleMessage("Ayarlar"),
    "settingsHelp": MessageLookupByLibrary.simpleMessage(
      "Dil ayarlarınızı yapın ve mistik tokenlarınızı buradan yönetin.",
    ),
    "shadowMeaning": MessageLookupByLibrary.simpleMessage("Gölge (Olumsuz):"),
    "shareTitle": m27,
    "singleCard": MessageLookupByLibrary.simpleMessage("Tek Kart Açılımı Yap"),
    "singleCardDescription": MessageLookupByLibrary.simpleMessage(
      "Hızlı cevap için ideal",
    ),
    "singleCardReadingError": m28,
    "slideToDrawCards": MessageLookupByLibrary.simpleMessage(
      "Kart Çekmek İçin Kaydırın",
    ),
    "solution": MessageLookupByLibrary.simpleMessage("Çözüm"),
    "specialNote": MessageLookupByLibrary.simpleMessage("Özel Not"),
    "spiritualDescription": MessageLookupByLibrary.simpleMessage(
      "İç benliğinizi, rüyalarınızı ve kozmik bağlantılarınızı keşfedin.",
    ),
    "spiritualMystical": MessageLookupByLibrary.simpleMessage(
      "Manevi ve Mistik",
    ),
    "spiritualMysticalDescription": MessageLookupByLibrary.simpleMessage(
      "İçsel benliğinizi, rüyalarınızı ve kozmik bağlantılarınızı keşfedin.",
    ),
    "spreadInfoBanner": MessageLookupByLibrary.simpleMessage(
      "Her açılım farklı sayıda kart ve yorum içerir",
    ),
    "spreadSelection": MessageLookupByLibrary.simpleMessage("Açılım Seçimi"),
    "startJourney": MessageLookupByLibrary.simpleMessage("Yolculuğa Başla"),
    "suit": MessageLookupByLibrary.simpleMessage("Takım"),
    "swipeForMore": MessageLookupByLibrary.simpleMessage(
      "Daha fazla bilgi için kaydırın",
    ),
    "swipeToSeePages": MessageLookupByLibrary.simpleMessage(
      "Sayfaları görmek için kaydırın",
    ),
    "tapCardForDetails": MessageLookupByLibrary.simpleMessage(
      "Detaylar için karta dokunun",
    ),
    "tarotFortune": MessageLookupByLibrary.simpleMessage("Astral Tarot"),
    "tarotFortuneDescription": m29,
    "tarotFortuneGuide": MessageLookupByLibrary.simpleMessage(
      "Tarot Falı - Gizemli Yolların Kılavuzu",
    ),
    "tarotFortuneTitle": MessageLookupByLibrary.simpleMessage(
      "Tarot Falı - Gizemli Yolların Kılavuzu",
    ),
    "tenTokens": MessageLookupByLibrary.simpleMessage("10 Token"),
    "timelineAndSuggestions": MessageLookupByLibrary.simpleMessage(
      "Zaman Çizelgesi & Öneriler",
    ),
    "tokenLimitExceeded": MessageLookupByLibrary.simpleMessage(
      "Bu açılım için token limiti aşıldı. Daha detaylı yorumlar için premium’a yükseltin.",
    ),
    "tooManyCardsRequested": MessageLookupByLibrary.simpleMessage(
      "İstenen kart sayısı desteden fazla",
    ),
    "too_many_cards": MessageLookupByLibrary.simpleMessage(
      "Çok fazla kart seçildi",
    ),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Tekrar Dene"),
    "turkish": MessageLookupByLibrary.simpleMessage("Türkçe"),
    "unifiedDestinyMessage": m30,
    "unifiedDestinyReflection": MessageLookupByLibrary.simpleMessage(
      "Birleşik Kaderin Yansıması",
    ),
    "unifiedDestinyReflectionTitle": MessageLookupByLibrary.simpleMessage(
      "Birleşik Kaderin Yansımaları",
    ),
    "unknownSpread": MessageLookupByLibrary.simpleMessage("Bilinmeyen dağılım"),
    "unlimited": MessageLookupByLibrary.simpleMessage("Sınırsız"),
    "unveilTheStars": MessageLookupByLibrary.simpleMessage("Yıldızları Keşfet"),
    "unveilingMysticalPath": MessageLookupByLibrary.simpleMessage(
      "Mistik Yolu Açığa Çıkarıyoruz...",
    ),
    "userInfo": MessageLookupByLibrary.simpleMessage("Kullanıcı Bilgileri"),
    "viewResults": MessageLookupByLibrary.simpleMessage("Sonuçları Gör"),
    "warning": MessageLookupByLibrary.simpleMessage("Uyarı"),
    "yearlySpreadDescription": MessageLookupByLibrary.simpleMessage(
      "12 ay için rehberlik",
    ),
    "yearlySpreadReading": MessageLookupByLibrary.simpleMessage(
      "Yıllık Açılım",
    ),
    "yearlySpreadReadingError": m31,
  };
}
