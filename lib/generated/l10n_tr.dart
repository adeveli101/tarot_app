import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class STr extends S {
  STr([String locale = 'tr']) : super(locale);

  @override
  String get tarotFortune => 'Tarot';

  @override
  String errorMessage(Object message) {
    return 'Hata: $message';
  }

  @override
  String get tryAgain => 'Tekrar Dene';

  @override
  String get pastPresentFuture => 'Geçmiş-Şimdi-Gelecek Açılımı Yap';

  @override
  String get problemSolution => 'Problem-Çözüm Açılımı Yap';

  @override
  String get singleCard => 'Tek Kart Açılımı Yap';

  @override
  String get loveReading => 'Aşk Açılımı Yap';

  @override
  String get careerReading => 'Kariyer Açılımı Yap';

  @override
  String get noSelectionYet => 'Henüz bir seçim yapılmadı';

  @override
  String get position => 'Pozisyon';

  @override
  String get meaning => 'Anlamı';

  @override
  String get mysticMeaning => 'Mistik Yorum';

  @override
  String get tarotFortuneGuide => 'Tarot Falı - Gizemli Yolların Kılavuzu';

  @override
  String fortuneInsight(Object category, Object spreadType) {
    return 'Bu fal, $category konusunda $spreadType açılımı ile derin bir içgörü sunmaktadır. Ruhunuzun derinliklerine yolculuk yaparken, kartların gizemli mesajlarını birlikte yorumlayalım.';
  }

  @override
  String get divineDance => 'Kartların İlahi Dansı';

  @override
  String get unifiedDestinyReflection => 'Birleşik Kaderin Yansıması';

  @override
  String unifiedDestinyMessage(Object category) {
    return 'Bu kartların bir araya gelmesi, $category yolculuğunuzda önemli bir dönüm noktasını işaret ediyor. Kartların birleşik enerjisi, ruhunuzun derinliklerindeki mesajları açığa çıkarıyor.';
  }

  @override
  String get cardsCombinedAssessment => 'Kartların Beraber Değerlendirilmesi';

  @override
  String get cardsEnergiesInteract => 'Kartların enerjileri birbirini etkiliyor.';

  @override
  String get generalDetailedComment => 'Genel Yorum (Detaylı)';

  @override
  String get lifeDynamicsHighlighted => 'Bu kartlar hayatınızdaki önemli dinamikleri vurguluyor.';

  @override
  String get guidingWhispers => 'Yol Gösterici Fısıltılar';

  @override
  String get futureSuggestions => 'Yakın geleceğiniz için şu önerilere kulak verin: [YAKIN_GELECEK_ÖNERİLER]';

  @override
  String get potentialPitfalls => 'Dikkat etmeniz gereken potansiyel tuzaklar: [DİKKAT_EDİLMESİ_GEREKEN_NOKTALAR]';

  @override
  String cardLoadingError(Object error) {
    return 'Kartlar yüklenirken bir hata oluştu: $error';
  }

  @override
  String singleCardReadingError(Object error) {
    return 'Tek kart açılımı alınırken bir hata oluştu: $error';
  }

  @override
  String pastPresentFutureReadingError(Object error) {
    return 'Geçmiş-Şimdi-Gelecek açılımı alınırken bir hata oluştu: $error';
  }

  @override
  String problemSolutionReadingError(Object error) {
    return 'Problem-Çözüm açılımı alınırken bir hata oluştu: $error';
  }

  @override
  String fiveCardPathReadingError(Object error) {
    return 'Beş Kart Yol Ayrımı açılımı alınırken bir hata oluştu: $error';
  }

  @override
  String relationshipSpreadReadingError(Object error) {
    return 'İlişki açılımı alınırken bir hata oluştu: $error';
  }

  @override
  String celticCrossReadingError(Object error) {
    return 'Celtic Cross açılımı alınırken bir hata oluştu: $error';
  }

  @override
  String yearlySpreadReadingError(Object error) {
    return 'Yıllık açılım alınırken bir hata oluştu: $error';
  }

  @override
  String categorySpreadReadingError(Object error) {
    return 'Kategori bazlı açılım alınırken bir hata oluştu: $error';
  }

  @override
  String get cardDeckEmpty => 'Kart destesi boş';

  @override
  String get tooManyCardsRequested => 'İstenen kart sayısı desteden fazla';

  @override
  String cardsLoadingErrorGeneric(Object error) {
    return 'Kartlar yüklenirken hata: $error';
  }

  @override
  String get tarotFortuneTitle => 'Tarot Falı - Gizemli Yolların Kılavuzu';

  @override
  String tarotFortuneDescription(Object category, Object spreadType) {
    return 'Bu fal, $category konusunda $spreadType açılımı ile kişisel ve derin içgörüler sunmaktadır. Ruhunuzun derinliklerine inmeye ve kartların size özel mesajlarını keşfetmeye hazır olun!';
  }

  @override
  String get divineSymphony => 'Kartların İlahi Senfonisi';

  @override
  String get unifiedDestinyReflectionTitle => 'Birleşik Kaderin Yansımaları';

  @override
  String get generalAnalysis => 'Genel Analiz';

  @override
  String get cardsCombinedEvaluation => 'Kartların Birlikte Değerlendirilmesi';

  @override
  String get specialNote => 'Özel Not';

  @override
  String get detailedGeneralCommentary => 'Derinlemesine Genel Yorum';

  @override
  String get guidingWhispersAndSuggestions => 'Yol Gösterici Fısıltılar & Öneriler';

  @override
  String get timelineAndSuggestions => 'Zaman Çizelgesi & Öneriler';

  @override
  String get pointsToWatch => 'Dikkat Edilmesi Gerekenler';

  @override
  String get categorySpecificTips => 'Kategoriye Özel İpuçları';

  @override
  String get deck_empty => 'Kart destesi boş';

  @override
  String get too_many_cards => 'Çok fazla kart seçildi';

  @override
  String cards_loading_error(Object error) {
    return 'Kartlar yüklenirken bir hata oluştu';
  }

  @override
  String get keywords => 'Anahtar Kelimeler:';

  @override
  String get lightMeaning => 'Işık:';

  @override
  String get shadowMeaning => 'Gölge:';

  @override
  String get swipeForMore => 'Daha fazla bilgi için kaydırın';

  @override
  String get swipeToSeePages => 'Sayfaları görmek için kaydırın';

  @override
  String get fortuneTelling => 'Fal Yorumu:';

  @override
  String get settings => 'Ayarlar';

  @override
  String get mysticJourney => 'Mistik Yolculuk';

  @override
  String get startJourney => 'Yolculuğa Başla';

  @override
  String get differentInterpretation => 'Her seçimde farklı bir yorum sizi bekliyor';

  @override
  String get categorySelection => 'Kategori Seçimi';

  @override
  String get chooseTopic => 'Fal baktırmak istediğiniz konuyu seçin';

  @override
  String get loveRelationships => 'Aşk & İlişkiler';

  @override
  String get loveDescription => 'İlişkileriniz hakkında derinlemesine bilgi alın';

  @override
  String get career => 'Kariyer';

  @override
  String get careerDescription => 'İş hayatınız ve kariyeriniz hakkında rehberlik alın';

  @override
  String get money => 'Para';

  @override
  String get moneyDescription => 'Finansal konularda içgörü kazanın';

  @override
  String get general => 'Genel';

  @override
  String get generalDescription => 'Genel yaşam rehberliği alın';

  @override
  String get categoryInfoBanner => 'Seçtiğiniz kategoriye göre özel açılımlar sunulacaktır';

  @override
  String get spreadSelection => 'Açılım Seçimi';

  @override
  String get chooseSpread => 'Kartların nasıl açılacağını seçin';

  @override
  String get spreadInfoBanner => 'Her açılım farklı sayıda kart ve yorum içerir';

  @override
  String get singleCardDescription => 'Hızlı cevap için ideal';

  @override
  String get relationshipSpread => 'İlişki Açılımı';

  @override
  String get relationshipSpreadDescription => 'İlişkinizin detaylı analizi';

  @override
  String get pastPresentFutureDescription => 'Kariyer yolunuz için rehberlik';

  @override
  String get fiveCardPath => 'Beş Kart Yol Ayrımı';

  @override
  String get fiveCardPathDescription => 'Kariyer seçimleriniz için detaylı analiz';

  @override
  String get celticCrossDescription => 'Detaylı ve kapsamlı analiz';

  @override
  String get yearlySpreadDescription => '12 ay için rehberlik';

  @override
  String cardCount(Object count) {
    return '$count kart';
  }

  @override
  String get celticCrossReading => 'Celtic Cross';

  @override
  String get yearlySpreadReading => 'Yıllık Açılım';

  @override
  String get cardSelection => 'Kart Seçimi';

  @override
  String get cardSelectionInstructions => 'Kart sayısı kadar kapalı kart ekranda görüntülenecektir. Lütfen tek tek dokunarak açınız, uzun basarak kısa açıklamasını görün veya \'Bütün Kartları Çevir\' seçeneğini kullanınız.';

  @override
  String get flipAllCards => 'Bütün Kartları Çevir';

  @override
  String get reshuffleCards => 'Kartları Yeniden Karıştır';

  @override
  String get viewResults => 'Sonuçları Gör';

  @override
  String get close => 'Kapat';

  @override
  String get customPromptTitle => 'Özel İstek';

  @override
  String get customPromptHint => 'Özel isteğinizi buraya yazın...';

  @override
  String get promptEmptyError => 'Lütfen bir istek giriniz.';

  @override
  String get sendPrompt => 'İsteği Gönder';

  @override
  String get cancel => 'İptal';

  @override
  String get dailyLimitExceeded => 'Günlük ücretsiz fal limitine ulaşıldı. Lütfen kredi satın alın veya premium’a yükseltin.';

  @override
  String get tokenLimitExceeded => 'Bu açılım için token limiti aşıldı. Daha detaylı yorumlar için premium’a yükseltin.';

  @override
  String mindBodySpiritError(Object error) {
    return 'Zihin-Beden-Ruh açılımı hatası: \$$error';
  }

  @override
  String astroLogicalCrossError(Object error) {
    return 'Astrolojik Haç açılımı hatası: \$$error';
  }

  @override
  String brokenHeartError(Object error) {
    return 'Kırık Kalp açılımı hatası: \$$error';
  }

  @override
  String dreamInterpretationError(Object error) {
    return 'Rüya Yorumu açılımı hatası: \$$error';
  }

  @override
  String horseshoeSpreadError(Object error) {
    return 'At Nalı açılımı hatası: \$$error';
  }

  @override
  String careerPathSpreadError(Object error) {
    return 'Kariyer Yolu açılımı hatası: \$$error';
  }

  @override
  String fullMoonSpreadError(Object error) {
    return 'Dolunay açılımı hatası: \$$error';
  }

  @override
  String get readingSaved => 'Reading saved successfully';

  @override
  String get save => 'Save';

  @override
  String get share => 'Share';

  @override
  String get warning => 'Uyarı';

  @override
  String get insufficientCredits => 'Devam etmek için yeterli krediniz yok.';

  @override
  String get dailyLimitReached => 'Günlük ücretsiz fal hakkınız doldu.';

  @override
  String get insufficientCreditsAndLimit => 'Günlük ücretsiz fal hakkınız doldu ve yeterli krediniz yok.';

  @override
  String get couponHint => 'Kupon kodunu girin';

  @override
  String get redeem => 'Kullan';

  @override
  String couponRedeemed(Object message) {
    return '$message';
  }

  @override
  String couponInvalid(Object message) {
    return '$message';
  }

  @override
  String get returnToHome => 'Ana Sayfaya Dön';

  @override
  String get pleaseWait => 'Lütfen Bekleyin.';

  @override
  String get profile => 'Profil';

  @override
  String get noReadings => 'Kayıtlı fal bulunamadı';

  @override
  String get dateLabel => 'Tarih:';

  @override
  String get purchaseCredits => 'Kredi Satın Al';

  @override
  String insufficientCreditsMessage(Object required) {
    return 'Devam etmek için $required krediye ihtiyacınız var. Aşağıdan daha fazla kredi satın alın.';
  }

  @override
  String nextFreeReadingInfo(Object hours) {
    return 'Bir sonraki ücretsiz fal hakkınız $hours saat içinde kullanılabilir olacak.';
  }

  @override
  String get userInfo => 'Kullanıcı Bilgileri';

  @override
  String get dailyFreeReadings => 'Günlük Ücretsiz Fallar';

  @override
  String get language => 'Dil';

  @override
  String get settingsHelp => 'Dil ayarlarınızı yapın ve mistik tokenlarınızı buradan yönetin.';

  @override
  String get celticCrossCurrentSituation => 'Mevcut Durum';

  @override
  String get celticCrossChallenge => 'Zorluk';

  @override
  String get celticCrossSubconscious => 'Bilinçaltı';

  @override
  String get celticCrossPast => 'Geçmiş';

  @override
  String get celticCrossFuture => 'Olası Gelecek';

  @override
  String get celticCrossNearFuture => 'Yakın Gelecek';

  @override
  String get celticCrossPersonalStance => 'Kişisel Duruş';

  @override
  String get celticCrossExternalInfluences => 'Dış Etkiler';

  @override
  String get celticCrossHopesFears => 'Umutlar ve Korkular';

  @override
  String get celticCrossFinalOutcome => 'Sonuç';
}
