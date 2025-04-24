import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class STr extends S {
  STr([String locale = 'tr']) : super(locale);

  @override
  String get tarotFortune => 'Astral Tarot';

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
  String get lightMeaning => 'Işık (Olumlu):';

  @override
  String get shadowMeaning => 'Gölge (Olumsuz):';

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

  @override
  String get brokenHeart => 'Kalp Kırıklığı';

  @override
  String get brokenHeartDescription => 'Duygusal acıyı anla ve iyileştir.';

  @override
  String get careerPathSpread => 'Kariyer Açılımı';

  @override
  String get careerPathSpreadDescription => 'Kariyerin için detaylı rehberlik.';

  @override
  String get spiritualMystical => 'Manevi ve Mistik';

  @override
  String get spiritualMysticalDescription => 'İçsel benliğinizi, rüyalarınızı ve kozmik bağlantılarınızı keşfedin.';

  @override
  String get pastPresentFutureDescriptionLove => 'Aşk hayatınızdaki geçmiş, şimdiki ve gelecekteki etkileri anlayın.';

  @override
  String get mindBodySpiritDescriptionLove => 'Aşk bağlamında zihin, beden ve ruhunuzu uyumlaştırın.';

  @override
  String get fullMoonSpreadDescriptionLove => 'Dolunay enerjisiyle aşk hayatınızdaki gizli mesajları keşfedin.';

  @override
  String get problemSolutionDescriptionCareer => 'Kariyerinizdeki zorlukları çözmek için rehberlik alın.';

  @override
  String get horseshoeSpreadDescriptionCareer => 'Kariyerinizde geniş bir bakış açısı kazanın.';

  @override
  String get problemSolutionDescriptionMoney => 'Finansal zorlukları çözmek için rehberlik alın.';

  @override
  String get horseshoeSpreadDescriptionMoney => 'Mali durumunuzda geniş bir bakış açısı kazanın.';

  @override
  String get pastPresentFutureDescriptionMoney => 'Mali geçmişinizi, şu anınızı ve geleceğinizi keşfedin.';

  @override
  String get careerPathSpreadDescriptionMoney => 'Finansal büyüme için detaylı rehberlik alın.';

  @override
  String get astroLogicalCrossDescriptionGeneral => 'Yolunuzu yıldızlarla hizalayın.';

  @override
  String get horseshoeSpreadDescriptionGeneral => 'Hayatınızın genelinde geniş bir bakış açısı kazanın.';

  @override
  String get pastPresentFutureDescriptionGeneral => 'Hayatınızdaki geçmiş, şimdiki ve gelecekteki etkileri anlayın.';

  @override
  String get mindBodySpiritDescriptionSpiritual => 'İçsel benliğinizi zihin, beden ve ruhla uyumlaştırın.';

  @override
  String get dreamInterpretationDescriptionSpiritual => 'Rüyalarınızdaki mesajları manevi bir bakış açısıyla çözün.';

  @override
  String get fullMoonSpreadDescriptionSpiritual => 'Dolunay enerjisiyle manevi berraklık kazanın.';

  @override
  String get astroLogicalCrossDescriptionSpiritual => 'Manevi yolunuzu yıldızlarla hizalayın.';

  @override
  String get celticCrossDescriptionSpiritual => 'Manevi hayatınız için kapsamlı bir analiz alın.';

  @override
  String get spiritualDescription => 'İç benliğinizi, rüyalarınızı ve kozmik bağlantılarınızı keşfedin.';

  @override
  String get mindBodySpirit => 'Zihin Beden Ruh';

  @override
  String get mindBodySpiritDescription => 'İç benliğinizi uyumlu hale getirin.';

  @override
  String get astroLogicalCross => 'Astrolojik Haç';

  @override
  String get astroLogicalCrossDescription => 'Yolunuzu yıldızlarla hizalayın.';

  @override
  String get dreamInterpretation => 'Rüya Yorumu';

  @override
  String get dreamInterpretationDescription => 'Rüyalarınızdaki mesajları çözün.';

  @override
  String get horseshoeSpread => 'At Nalı Açılımı';

  @override
  String get horseshoeSpreadDescription => 'Durumunuza geniş bir bakış.';

  @override
  String get fullMoonSpread => 'Dolunay Açılımı';

  @override
  String get fullMoonSpreadDescription => 'Berraklık için ay enerjisini kullanın.';

  @override
  String get unveilTheStars => 'Yıldızları Keşfet';

  @override
  String get unveilingMysticalPath => 'Mistik Yolu Açığa Çıkarıyoruz...';

  @override
  String get instructionsFlipAll => 'Tüm kartları tek dokunuşla çevirin.';

  @override
  String get instructionsReshuffle => 'Kartları yeniden karıştırarak yeni bir çekiliş yapın.';

  @override
  String get instructionsViewResults => 'Tüm kartlar açıldığında sonucu görün.';

  @override
  String get problem => 'Sorun';

  @override
  String get solution => 'Çözüm';

  @override
  String get dreamPast => 'Rüya Geçmişi';

  @override
  String get dreamPresent => 'Rüya Şimdiki Zaman';

  @override
  String get dreamFuture => 'Rüya Gelecek';

  @override
  String get fiveCardPathPast => 'Geçmiş';

  @override
  String get fiveCardPathPresent => 'Şimdiki';

  @override
  String get fiveCardPathChallenge => 'Zorluk';

  @override
  String get fiveCardPathFuture => 'Gelecek';

  @override
  String get fiveCardPathOutcome => 'Sonuç';

  @override
  String get relationshipSelf => 'Kendiniz';

  @override
  String get relationshipPartner => 'Partner';

  @override
  String get relationshipPast => 'Geçmiş';

  @override
  String get relationshipPresent => 'Şimdiki';

  @override
  String get relationshipFuture => 'Gelecek';

  @override
  String get relationshipStrengths => 'Güçlü Yönler';

  @override
  String get relationshipChallenges => 'Zorluklar';

  @override
  String get mindBody => 'Zihin-Beden';

  @override
  String get mindSpirit => 'Zihin-Ruh';

  @override
  String get bodySpirit => 'Beden-Ruh';

  @override
  String get astroPast => 'Astro Geçmiş';

  @override
  String get astroPresent => 'Astro Şimdiki';

  @override
  String get astroFuture => 'Astro Gelecek';

  @override
  String get astroChallenge => 'Astro Zorluk';

  @override
  String get astroOutcome => 'Astro Sonuç';

  @override
  String get brokenHeartCause => 'Neden';

  @override
  String get brokenHeartEmotion => 'Duygu';

  @override
  String get brokenHeartLesson => 'Ders';

  @override
  String get brokenHeartHope => 'Umut';

  @override
  String get brokenHeartHealing => 'İyileşme';

  @override
  String get horseshoePast => 'Geçmiş';

  @override
  String get horseshoePresent => 'Şimdiki';

  @override
  String get horseshoeFuture => 'Gelecek';

  @override
  String get horseshoeStrengths => 'Güçler';

  @override
  String get horseshoeObstacles => 'Engeller';

  @override
  String get horseshoeAdvice => 'Öneri';

  @override
  String get horseshoeOutcome => 'Sonuç';

  @override
  String get careerPast => 'Kariyer Geçmişi';

  @override
  String get careerPresent => 'Kariyer Şimdiki';

  @override
  String get careerChallenge => 'Kariyer Zorluk';

  @override
  String get careerPotential => 'Kariyer Potansiyel';

  @override
  String get careerOutcome => 'Kariyer Sonuç';

  @override
  String get fullMoonPast => 'Dolunay Geçmiş';

  @override
  String get fullMoonPresent => 'Dolunay Şimdiki';

  @override
  String get fullMoonChallenge => 'Dolunay Zorluk';

  @override
  String get fullMoonHope => 'Dolunay Umut';

  @override
  String get fullMoonOutcome => 'Dolunay Sonuç';

  @override
  String get mysticalTokens => 'Mistik Jetonlar';

  @override
  String get errorLoadingReadings => 'Okumaları yüklerken hata oluştu';

  @override
  String get unknownSpread => 'Bilinmeyen dağılım';

  @override
  String get noInterpretation => 'Yorum mevcut değil';

  @override
  String get premium => 'Premium';

  @override
  String get unlimited => 'Sınırsız';

  @override
  String get english => 'English';

  @override
  String get languageChangedToEnglish => 'Dil İngilizce olarak değiştirildi';

  @override
  String get turkish => 'Türkçe';

  @override
  String get languageChangedToTurkish => 'Dil Türkçe olarak değiştirildi';

  @override
  String get tenTokens => '10 Token';

  @override
  String get fiftyTokens => '50 Token';

  @override
  String get hundredTokens => '100 Token';

  @override
  String get premiumSubscription => 'Premium Abonelik';

  @override
  String get drawCards => 'Kartları Çek';

  @override
  String get instructionsDrawCards => 'Kartları manuel olarak çekmek için bu düğmeyi kullanın.';

  @override
  String get selectToDraw => 'Kaderinizi görmek için kaydırın';

  @override
  String get premiumDescription => 'Sınırsız fal ve özel içeriklere erişim';

  @override
  String get bundleDescription => '50 kredi + Premium abonelik';

  @override
  String creditDescription(Object credits) {
    return '$credits kredi ile daha fazla fal aç';
  }

  @override
  String get premiumReadings => 'Premium Okuma';

  @override
  String get confirmPurchase => 'Satın Alımı Onayla';

  @override
  String get areYouSure => 'Satın almak istediğinizden emin misiniz:';

  @override
  String get forText => 'için';

  @override
  String get confirm => 'Onayla';

  @override
  String get couponAlreadyUsed => 'Bu kupon zaten kullanılmış.';

  @override
  String get paymentSuccessful => 'Ödeme Başarılı';

  @override
  String get arcana => 'Sır';

  @override
  String get suit => 'Takım';

  @override
  String get celticCrossConscious => 'Kelt Haçı Bilinçli';

  @override
  String get longPressHint => 'Uzun Basma İpucu';

  @override
  String get instructions => 'Talimatlar';

  @override
  String get slideToDrawCards => 'Kart Çekmek İçin Kaydırın';

  @override
  String get tapCardForDetails => 'Detaylar için karta dokunun';

  @override
  String get interpretation => 'Yorumlama';

  @override
  String get interpretationSection => 'Yorum Bölümü';

  @override
  String get myTarotReading => 'Benim Tarot Falım';

  @override
  String get readingResult => 'Fal Sonucu';

  @override
  String get noReadingData => 'Fal verisi bulunamadı.';

  @override
  String get checkingResources => 'Kaynaklar kontrol ediliyor...';

  @override
  String get obstacleAdvice => 'Engel / Tavsiye';

  @override
  String purchaseConfirmation(String title, String price) {
    return '$title ürününü $price karşılığında satın almak istiyor musunuz?';
  }

  @override
  String creditsAdded(String count) {
    return '$count kredi başarıyla eklendi!';
  }

  @override
  String get premiumActivated => 'Premium abonelik etkinleştirildi!';

  @override
  String purchaseFailed(String error) {
    return 'Satın alma başarısız: $error';
  }

  @override
  String get purchasePending => 'Satın alma bekleniyor...';

  @override
  String get failedToLoadProducts => 'Ürünler yüklenemedi.';

  @override
  String get noProductsAvailable => 'Şu anda mevcut ürün bulunmamaktadır.';

  @override
  String get couponCannotBeEmpty => 'Kupon kodu boş olamaz.';

  @override
  String get errorLoadingCardDetails => 'Kart detayları yüklenirken hata oluştu.';

  @override
  String get cards => 'Kartlar';

  @override
  String get noCardsInSpread => 'Bu açılımda kart bulunamadı.';

  @override
  String get questionsToAsk => 'Sorulacak Sorular';

  @override
  String get overview => 'Genel Bakış';

  @override
  String get details => 'Detaylar';

  @override
  String shareTitle(String spreadType, String dateStr) {
    return '$spreadType Okuması - $dateStr';
  }

  @override
  String get invalidPage => 'Geçersiz Sayfa';

  @override
  String get yearlySpreadSummary => 'Yılın Özeti';

  @override
  String cardLabel(int index) {
    return 'Kart $index';
  }

  @override
  String get mindBodySpiritMind => 'Zihin';

  @override
  String get mindBodySpiritBody => 'Beden';

  @override
  String get mindBodySpiritSpirit => 'Ruh';

  @override
  String get astroLogicalCrossIdentity => 'Kimlik / Benlik';

  @override
  String get astroLogicalCrossEmotional => 'Duygusal Durum';

  @override
  String get astroLogicalCrossExternal => 'Dış Etkenler';

  @override
  String get astroLogicalCrossChallenge => 'Zorluk / Ders';

  @override
  String get astroLogicalCrossDestiny => 'Kader / Sonuç';

  @override
  String get dreamInterpretationPast => 'Rüya - Geçmiş Bağlantısı';

  @override
  String get dreamInterpretationPresent => 'Rüya - Mevcut Duygu';

  @override
  String get dreamInterpretationFuture => 'Rüya - Gelecek Rehberliği';

  @override
  String get horseshoeUserAttitude => 'Yaklaşımınız';

  @override
  String get horseshoeExternalInfluence => 'Dış Etkenler';

  @override
  String get careerPathCurrent => 'Mevcut Durum';

  @override
  String get careerPathObstacles => 'Engeller';

  @override
  String get careerPathOpportunities => 'Fırsatlar';

  @override
  String get careerPathStrengths => 'Güçlü Yönler';

  @override
  String get careerPathOutcome => 'Olası Sonuç';

  @override
  String get fullMoonCulmination => 'Tamamlanma';

  @override
  String get fullMoonRevealed => 'Ortaya Çıkan';

  @override
  String get fullMoonRelease => 'Bırakılması Gereken';

  @override
  String get fullMoonObstacles => 'Bırakma Engelleri';

  @override
  String get fullMoonAction => 'Eylem / Bütünleşme';

  @override
  String get fullMoonResultingEnergy => 'Sonuç Enerjisi';

  @override
  String get claim => 'Al';

  @override
  String dailyRewardClaimedMessage(String time) {
    return 'Günlük ödül alındı! Sonraki ödüle: $time';
  }

  @override
  String get dailyRewardNotificationTitle => 'Günlük Ödül Hazır!';

  @override
  String get dailyRewardNotificationBody => 'Mistik tokenlerin seni bekliyor. Gel ve ödülünü al!';

  @override
  String get claimDailyRewardTooltip => 'Günlük kredini al!';

  @override
  String get nextReward => 'Sonraki:';

  @override
  String nextRewardTooltip(String time) {
    return 'Sonraki günlük ödül $time sonra alınabilir';
  }

  @override
  String claimYourDailyTokens(int count) {
    return 'Günlük $count Kredini Al!';
  }

  @override
  String get dailyRewardInfo => 'Bu sayaç, bir sonraki ücretsiz günlük kredinizin ne zaman alınabileceğini gösterir.';

  @override
  String get creditInfoTooltip => 'Kredi satın almak için dokunun';

  @override
  String get redeemCouponTooltip => 'Kupon Kullan';

  @override
  String get notificationPermissionDeniedTitle => 'Bildirim İzni Gerekli';

  @override
  String get notificationPermissionDeniedText => 'Bu uygulama için bildirimler devre dışı bırakılmış. Önemli güncellemeleri almak için lütfen uygulama ayarlarından bildirimleri etkinleştirin.';

  @override
  String get exactAlarmPermissionDeniedTitle => 'Tam Zamanlı Alarm İzni Gerekli';

  @override
  String get exactAlarmPermissionDeniedText => '\'Alarmlar ve hatırlatıcılar\' izni reddedildi. Günlük ödül bildirimlerini zamanında alabilmek için lütfen uygulama ayarlarından bu izni verin.';

  @override
  String get exactAlarmPermissionTitle => 'İzin Gerekli';

  @override
  String get exactAlarmPermissionExplanation => 'Günlük ödülünüz hazır olduğunda size tam zamanında bildirim gönderebilmemiz için \'Alarmlar ve hatırlatıcılar\' iznine ihtiyacımız var. Bu izin verilmezse bildirimler gecikebilir veya hiç gelmeyebilir.';

  @override
  String get later => 'Sonra';

  @override
  String get allow => 'İzin Ver';

  @override
  String greetingNotificationTitle(String userName) {
    return 'Tekrar hoş geldin, $userName!';
  }

  @override
  String rewardNotificationBody(String rewardAmount) {
    return '$rewardAmount jetonluk ödülün hazır!';
  }

  @override
  String get loadingMessage1 => 'Kaderin iplikleri okunuyor...';

  @override
  String get loadingMessage2 => 'Kozmik enerjilere danışılıyor...';

  @override
  String get loadingMessage3 => 'Yıldızlar sizin için hizalanıyor...';

  @override
  String get loadingMessage4 => 'Semboller çözülüyor...';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get allowNotifications => 'Bildirimlere İzin Ver';

  @override
  String get notificationsEnabledDesc => 'Bildirimler etkin.';

  @override
  String get notificationsDisabledDesc => 'Etkinleştirmek veya ayarlardan yönetmek için dokunun.';

  @override
  String get notificationPermissionDeniedTextShort => 'Bildirim izni verilmedi.';

  @override
  String get disableNotificationsTitle => 'Bildirimleri Kapat';

  @override
  String get disableNotificationsDesc => 'Bildirimleri kapatmak için lütfen uygulama ayarlarını açın.';
}
