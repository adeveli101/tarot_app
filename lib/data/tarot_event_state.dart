// lib/data/tarot_event_state.dart
import 'package:equatable/equatable.dart';
import 'package:tarot_fal/models/tarot_card.dart';

// ================== EVENTS ==================
// (Event sınıflarında değişiklik yok, aynı kalabilirler)
abstract class TarotEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTarotCards extends TarotEvent {}
class ShuffleDeck extends TarotEvent {}

class RedeemCoupon extends TarotEvent {
  final String couponCode;
  RedeemCoupon(this.couponCode);
  @override
  List<Object?> get props => [couponCode];
}

class UpdateLastCategory extends TarotEvent {
  final String category;
  UpdateLastCategory(this.category);
  @override
  List<Object?> get props => [category];
}

class UpdateUserInfo extends TarotEvent {
  final String? name;
  final int? age;
  final String? gender;
  UpdateUserInfo(this.name, this.age, this.gender);
  @override
  List<Object?> get props => [name, age, gender];
}

class DrawSingleCard extends TarotEvent {
  final String? customPrompt;
  DrawSingleCard({this.customPrompt});
  @override
  List<Object?> get props => [customPrompt];
}

class DrawPastPresentFuture extends TarotEvent {
  final String? customPrompt;
  DrawPastPresentFuture({this.customPrompt});
  @override
  List<Object?> get props => [customPrompt];
}

class DrawProblemSolution extends TarotEvent {
  final String? customPrompt;
  DrawProblemSolution({this.customPrompt});
  @override
  List<Object?> get props => [customPrompt];
}

class DrawFiveCardPath extends TarotEvent {
  final String? customPrompt;
  DrawFiveCardPath({this.customPrompt});
  @override
  List<Object?> get props => [customPrompt];
}

class DrawRelationshipSpread extends TarotEvent {
  final String? customPrompt;
  DrawRelationshipSpread({this.customPrompt});
  @override
  List<Object?> get props => [customPrompt];
}

class DrawCelticCross extends TarotEvent {
  final String? customPrompt;
  DrawCelticCross({this.customPrompt});
  @override
  List<Object?> get props => [customPrompt];
}

class DrawYearlySpread extends TarotEvent {
  final String? customPrompt;
  DrawYearlySpread({this.customPrompt});
  @override
  List<Object?> get props => [customPrompt];
}

class DrawMindBodySpirit extends TarotEvent {
  final String? customPrompt;
  DrawMindBodySpirit({this.customPrompt});
  @override
  List<Object?> get props => [customPrompt];
}

class DrawAstroLogicalCross extends TarotEvent {
  final String? customPrompt;
  DrawAstroLogicalCross({this.customPrompt});
  @override
  List<Object?> get props => [customPrompt];
}

class DrawBrokenHeart extends TarotEvent {
  final String? customPrompt;
  DrawBrokenHeart({this.customPrompt});
  @override
  List<Object?> get props => [customPrompt];
}

class DrawDreamInterpretation extends TarotEvent {
  final String? customPrompt;
  DrawDreamInterpretation({this.customPrompt});
  @override
  List<Object?> get props => [customPrompt];
}

class DrawHorseshoeSpread extends TarotEvent {
  final String? customPrompt;
  DrawHorseshoeSpread({this.customPrompt});
  @override
  List<Object?> get props => [customPrompt];
}

class DrawCareerPathSpread extends TarotEvent {
  final String? customPrompt;
  DrawCareerPathSpread({this.customPrompt});
  @override
  List<Object?> get props => [customPrompt];
}

class DrawFullMoonSpread extends TarotEvent {
  final String? customPrompt;
  DrawFullMoonSpread({this.customPrompt});
  @override
  List<Object?> get props => [customPrompt];
}

class DrawCategoryReading extends TarotEvent {
  final String category;
  final int cardCount;
  final String? customPrompt;
  DrawCategoryReading({required this.category, required this.cardCount, this.customPrompt});
  @override
  List<Object?> get props => [category, cardCount, customPrompt];
}

// ================== STATES ==================
abstract class TarotState extends Equatable {
  final double userTokens;
  // final int dailyFreeFalCount; // <--- KALDIRILDI
  final String? lastSelectedCategory;
  final String? userName;
  final int? userAge;
  final String? userGender;
  final bool userInfoCollected;

  const TarotState({
    required this.userTokens,
    // required this.dailyFreeFalCount, // <--- KALDIRILDI
    this.lastSelectedCategory,
    this.userName,
    this.userAge,
    this.userGender,
    this.userInfoCollected = false,
  });

  @override
  List<Object?> get props => [
    userTokens,
    // dailyFreeFalCount, // <--- KALDIRILDI
    lastSelectedCategory,
    userName,
    userAge,
    userGender,
    userInfoCollected,
  ];

  // copyWith metodunu tanımla (türetilmiş sınıflar bunu implemente edecek)
  TarotState copyWith({
    double? userTokens,
    // int? dailyFreeFalCount, // <--- KALDIRILDI
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
  });
}

// --- Initial State ---
class TarotInitial extends TarotState {
  const TarotInitial({
    super.userTokens = 0.0, // Başlangıç token'ı 0 olsun, yüklenince güncellenir
    // super.dailyFreeFalCount = 0, // <--- KALDIRILDI
    super.lastSelectedCategory,
    super.userName,
    super.userAge,
    super.userGender,
    super.userInfoCollected = false,
  });

  @override
  TarotInitial copyWith({
    double? userTokens,
    // int? dailyFreeFalCount, // <--- KALDIRILDI
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
  }) {
    return TarotInitial(
      userTokens: userTokens ?? this.userTokens,
      // dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount, // <--- KALDIRILDI
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}

// --- Loading State ---
class TarotLoading extends TarotState {
  const TarotLoading({
    required super.userTokens,
    // required super.dailyFreeFalCount, // <--- KALDIRILDI
    super.lastSelectedCategory,
    super.userName,
    super.userAge,
    super.userGender,
    super.userInfoCollected,
  });

  @override
  TarotLoading copyWith({
    double? userTokens,
    // int? dailyFreeFalCount, // <--- KALDIRILDI
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
  }) {
    // Loading state'i kopyalarken genellikle yeni değerler atanmaz,
    // mevcut state'in yükleniyor versiyonu oluşturulur.
    // Eğer yükleme sırasında bazı değerler güncelleniyorsa burası değiştirilebilir.
    return TarotLoading(
      userTokens: userTokens ?? this.userTokens,
      // dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount, // <--- KALDIRILDI
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}

// --- Error State ---
class TarotError extends TarotState {
  final String message;
  const TarotError(
      this.message, {
        required super.userTokens,
        // required super.dailyFreeFalCount, // <--- KALDIRILDI
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
      });

  @override
  List<Object?> get props => [message, ...super.props]; // Hata mesajını da ekle

  @override
  TarotError copyWith({
    double? userTokens,
    // int? dailyFreeFalCount, // <--- KALDIRILDI
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    // Hata mesajı genellikle kopyalanmaz, yeni hata için yeni state oluşturulur.
    // String? message,
  }) {
    return TarotError(
      message, // Mevcut hata mesajını koru
      userTokens: userTokens ?? this.userTokens,
      // dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount, // <--- KALDIRILDI
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}

// --- Cards Loaded State ---
class TarotCardsLoaded extends TarotState {
  final List<TarotCard> cards;
  const TarotCardsLoaded(
      this.cards, {
        required super.userTokens,
        // required super.dailyFreeFalCount, // <--- KALDIRILDI
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
      });

  @override
  List<Object?> get props => [cards, ...super.props]; // Kart listesini ekle

  @override
  TarotCardsLoaded copyWith({
    double? userTokens,
    // int? dailyFreeFalCount, // <--- KALDIRILDI
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    List<TarotCard>? cards, // Kart listesi de kopyalanabilir (opsiyonel)
  }) {
    return TarotCardsLoaded(
      cards ?? this.cards, // Yeni kart listesi varsa onu kullan, yoksa mevcutu koru
      userTokens: userTokens ?? this.userTokens,
      // dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount, // <--- KALDIRILDI
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}

// --- Coupon Redeemed State ---
class CouponRedeemed extends TarotState {
  final String message; // Başarı mesajı
  const CouponRedeemed(
      this.message, {
        required super.userTokens, // Kupon sonrası güncel token
        // required super.dailyFreeFalCount, // <--- KALDIRILDI
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
      });

  @override
  List<Object?> get props => [message, ...super.props];

  @override
  CouponRedeemed copyWith({
    double? userTokens,
    // int? dailyFreeFalCount, // <--- KALDIRILDI
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    String? message, // Mesaj da kopyalanabilir
  }) {
    return CouponRedeemed(
      message ?? this.message,
      userTokens: userTokens ?? this.userTokens,
      // dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount, // <--- KALDIRILDI
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}

// --- Coupon Invalid State ---
class CouponInvalid extends TarotState {
  final String message; // Hata/Geçersizlik mesajı
  const CouponInvalid(
      this.message, {
        required super.userTokens, // Kupon denemesi öncesi token durumu
        // required super.dailyFreeFalCount, // <--- KALDIRILDI
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
      });

  @override
  List<Object?> get props => [message, ...super.props];

  @override
  CouponInvalid copyWith({
    double? userTokens,
    // int? dailyFreeFalCount, // <--- KALDIRILDI
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    String? message,
  }) {
    return CouponInvalid(
      message ?? this.message,
      userTokens: userTokens ?? this.userTokens,
      // dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount, // <--- KALDIRILDI
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}

// --- Single Card Drawn State (Artık kullanılmıyor olabilir, yorum alınca FalYorumuLoaded'a geçiliyor) ---
// Eğer kart seçimi sonrası hemen bir state göstermek isterseniz kullanılabilir.
class SingleCardDrawn extends TarotState {
  final TarotCard card;
  const SingleCardDrawn(
      this.card, {
        required super.userTokens,
        // required super.dailyFreeFalCount, // <--- KALDIRILDI
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
      });

  @override
  List<Object?> get props => [card, ...super.props];

  @override
  SingleCardDrawn copyWith({
    double? userTokens,
    // int? dailyFreeFalCount, // <--- KALDIRILDI
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    TarotCard? card,
  }) {
    return SingleCardDrawn(
      card ?? this.card,
      userTokens: userTokens ?? this.userTokens,
      // dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount, // <--- KALDIRILDI
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}

// --- Spread Drawn State (Artık kullanılmıyor olabilir, yorum alınca FalYorumuLoaded'a geçiliyor) ---
// Eğer kart seçimi sonrası hemen bir state göstermek isterseniz kullanılabilir.
class SpreadDrawn extends TarotState {
  final Map<String, TarotCard> spread;
  const SpreadDrawn(
      this.spread, {
        required super.userTokens,
        // required super.dailyFreeFalCount, // <--- KALDIRILDI
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
      });

  @override
  List<Object?> get props => [spread, ...super.props];

  @override
  SpreadDrawn copyWith({
    double? userTokens,
    // int? dailyFreeFalCount, // <--- KALDIRILDI
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    Map<String, TarotCard>? spread,
  }) {
    return SpreadDrawn(
      spread ?? this.spread,
      userTokens: userTokens ?? this.userTokens,
      // dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount, // <--- KALDIRILDI
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}

// --- Reading Result Loaded State ---
class FalYorumuLoaded extends TarotState {
  final String yorum; // Gemini yorumu
  final int tokenCount; // Yorum için harcanan (tahmini) token
  final double cost; // Okumanın kredi maliyeti
  final Map<String, TarotCard> spread; // Okumadaki kartlar

  const FalYorumuLoaded(
      this.yorum, {
        required this.tokenCount,
        required this.cost,
        required this.spread,
        required super.userTokens, // Yorum sonrası güncel token
        // required super.dailyFreeFalCount, // <--- KALDIRILDI
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
      });

  @override
  List<Object?> get props => [yorum, tokenCount, cost, spread, ...super.props];

  @override
  FalYorumuLoaded copyWith({
    double? userTokens,
    // int? dailyFreeFalCount, // <--- KALDIRILDI
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    String? yorum,
    int? tokenCount,
    double? cost,
    Map<String, TarotCard>? spread,
  }) {
    return FalYorumuLoaded(
      yorum ?? this.yorum,
      tokenCount: tokenCount ?? this.tokenCount,
      cost: cost ?? this.cost,
      spread: spread ?? this.spread,
      userTokens: userTokens ?? this.userTokens,
      // dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount, // <--- KALDIRILDI
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}

// --- Insufficient Resources State ---
class InsufficientResources extends TarotState {
  final double requiredTokens; // Gerekli token miktarı
  const InsufficientResources(
      this.requiredTokens, {
        required super.userTokens, // Mevcut token durumu
        // required super.dailyFreeFalCount, // <--- KALDIRILDI
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
      });

  @override
  List<Object?> get props => [requiredTokens, ...super.props];

  @override
  InsufficientResources copyWith({
    double? userTokens,
    // int? dailyFreeFalCount, // <--- KALDIRILDI
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    double? requiredTokens,
  }) {
    return InsufficientResources(
      requiredTokens ?? this.requiredTokens,
      userTokens: userTokens ?? this.userTokens,
      // dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount, // <--- KALDIRILDI
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}


// ================== SPREAD TYPE ENUM ==================
// (Burada değişiklik yok, aynı kalabilir)
enum SpreadType {
  singleCard(1, 600, 2000, 10, 'single_card_purchase', 300),
  pastPresentFuture(3, 1200, 2000, 20, 'past_present_future_purchase', 600),
  problemSolution(3, 1200, 2000, 20, 'problem_solution_purchase', 600),
  fiveCardPath(5, 1800, 3000, 30.0, 'five_card_path_purchase', 900),
  relationshipSpread(7, 2500, 4000, 40, 'relationship_spread_purchase', 1200),
  celticCross(10, 3000, 4000, 50, 'celtic_cross_purchase', 1500),
  yearlySpread(12, 3000, 4000, 60, 'yearly_spread_purchase', 1800),
  mindBodySpirit(3, 1200, 3000, 20, 'mind_body_spirit_purchase', 600),
  astroLogicalCross(5, 1800, 3000, 30, 'astrological_cross_purchase', 900),
  brokenHeart(5, 1800, 3000, 30.0, 'broken_heart_purchase', 900),
  dreamInterpretation(3, 1200, 2000, 20, 'dream_interpretation_purchase', 800),
  horseshoeSpread(7, 2500, 3000, 40.0, 'horseshoe_spread_purchase', 1200),
  careerPathSpread(5, 1800, 3000, 30, 'career_path_purchase', 900),
  fullMoonSpread(5, 1800, 3000, 30, 'full_moon_purchase', 900),
  // categoryReading için kart sayısı ve maliyet dinamik olabilir,
  // buradaki değerler varsayılan veya temsilidir.
  categoryReading(5, 1800, 3000, 30, 'category_reading_purchase', 900);

  final int cardCount;
  final int freeTokenLimit; // Premium olmadığı için bu limitler anlamsız olabilir
  final int premiumTokenLimit; // Premium olmadığı için bu limitler anlamsız olabilir
  final double costInCredits; // Okumanın token maliyeti
  final String productId; // İlişkili satın alma ürün ID'si (opsiyonel)
  final int maxPromptLength; // Prompt uzunluk limiti (opsiyonel)

  static List<String> get allProductIds => SpreadType.values.map((type) => type.productId).toList();

  const SpreadType(this.cardCount, this.freeTokenLimit, this.premiumTokenLimit,
      this.costInCredits, this.productId, this.maxPromptLength);

  // Premium özelliği kaldırıldığı için bu metot da gereksiz olabilir:
  // static int calculateTokenLimit(int cardCount, bool isPremium) { ... }
}