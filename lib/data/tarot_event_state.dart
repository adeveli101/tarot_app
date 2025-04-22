// lib/data/tarot_event_state.dart
import 'package:equatable/equatable.dart';
import 'package:tarot_fal/models/tarot_card.dart';

// ================== EVENTS ==================
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

// YENİ EVENT: Günlük token talep etmek için
class ClaimDailyToken extends TarotEvent {}


// --- Okuma (Draw) Eventleri ---
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
  final String? lastSelectedCategory;
  final String? userName;
  final int? userAge;
  final String? userGender;
  final bool userInfoCollected;
  // YENİ STATE ALANLARI (Null olmayan default değerlerle):
  final bool isDailyTokenAvailable;
  final DateTime? nextDailyTokenTime;

  const TarotState({
    required this.userTokens,
    this.lastSelectedCategory,
    this.userName,
    this.userAge,
    this.userGender,
    this.userInfoCollected = false,
    // YENİ PARAMETRELER (required değil, default değerleri var):
    this.isDailyTokenAvailable = false, // Default false
    this.nextDailyTokenTime,         // Default null
  });

  @override
  List<Object?> get props => [
    userTokens,
    lastSelectedCategory,
    userName,
    userAge,
    userGender,
    userInfoCollected,
    // YENİ PROPS:
    isDailyTokenAvailable,
    nextDailyTokenTime,
  ];

  // copyWith metodu (türetilmiş sınıflar implemente edecek)
  // Parametreler nullable, atama yapılırken ?? ile mevcut değer korunur.
  TarotState copyWith({
    double? userTokens,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    bool? isDailyTokenAvailable,
    DateTime? nextDailyTokenTime,
  });
}

// --- Initial State ---
class TarotInitial extends TarotState {
  const TarotInitial({
    super.userTokens = 0.0,
    super.lastSelectedCategory,
    super.userName,
    super.userAge,
    super.userGender,
    super.userInfoCollected = false,
    // YENİ ALANLARIN DEFAULT DEĞERLERİ TarotState'ten gelir
     super.isDailyTokenAvailable = false,
     super.nextDailyTokenTime,
  });

  @override
  TarotInitial copyWith({
    double? userTokens,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    bool? isDailyTokenAvailable,
    DateTime? nextDailyTokenTime,
  }) {
    return TarotInitial(
      userTokens: userTokens ?? this.userTokens,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
      isDailyTokenAvailable: isDailyTokenAvailable ?? this.isDailyTokenAvailable, // null değilse yeni değeri ata
      nextDailyTokenTime: nextDailyTokenTime ?? this.nextDailyTokenTime,       // null değilse yeni değeri ata
    );
  }
}

// --- Loading State ---
class TarotLoading extends TarotState {
  const TarotLoading({
    required super.userTokens,
    super.lastSelectedCategory,
    super.userName,
    super.userAge,
    super.userGender,
    super.userInfoCollected,
    // YENİ ALANLAR Loading state'i oluşturulurken önceki state'ten alınmalı
    required super.isDailyTokenAvailable,
    super.nextDailyTokenTime,
  });

  @override
  TarotLoading copyWith({
    double? userTokens,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    bool? isDailyTokenAvailable,
    DateTime? nextDailyTokenTime,
  }) {
    // Loading state'i kopyalamak yerine genellikle yeni bir Loading state oluşturulur
    // ve mevcut state'in değerleri kullanılır. copyWith burada anlamsız olabilir.
    // Yine de ekleyelim:
    return TarotLoading(
      userTokens: userTokens ?? this.userTokens,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
      isDailyTokenAvailable: isDailyTokenAvailable ?? this.isDailyTokenAvailable,
      nextDailyTokenTime: nextDailyTokenTime ?? this.nextDailyTokenTime,
    );
  }
}

// --- Error State ---
class TarotError extends TarotState {
  final String message;
  const TarotError(
      this.message, {
        required super.userTokens,
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
        // YENİ ALANLAR hata anındaki durumu korumalı
        required super.isDailyTokenAvailable,
        super.nextDailyTokenTime,
      });

  @override
  List<Object?> get props => [message, ...super.props];

  @override
  TarotError copyWith({
    double? userTokens,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    bool? isDailyTokenAvailable,
    DateTime? nextDailyTokenTime,
    // String? message, // Hata mesajı genellikle değiştirilmez
  }) {
    return TarotError(
      message, // Mevcut mesajı koru
      userTokens: userTokens ?? this.userTokens,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
      isDailyTokenAvailable: isDailyTokenAvailable ?? this.isDailyTokenAvailable,
      nextDailyTokenTime: nextDailyTokenTime ?? this.nextDailyTokenTime,
    );
  }
}

// --- Cards Loaded State ---
class TarotCardsLoaded extends TarotState {
  final List<TarotCard> cards;
  const TarotCardsLoaded(
      this.cards, {
        required super.userTokens,
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
        // YENİ ALANLAR
        required super.isDailyTokenAvailable,
        super.nextDailyTokenTime,
      });

  @override
  List<Object?> get props => [cards, ...super.props];

  @override
  TarotCardsLoaded copyWith({
    double? userTokens,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    List<TarotCard>? cards,
    bool? isDailyTokenAvailable,
    DateTime? nextDailyTokenTime,
  }) {
    return TarotCardsLoaded(
      cards ?? this.cards,
      userTokens: userTokens ?? this.userTokens,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
      isDailyTokenAvailable: isDailyTokenAvailable ?? this.isDailyTokenAvailable,
      nextDailyTokenTime: nextDailyTokenTime ?? this.nextDailyTokenTime,
    );
  }
}

// --- Coupon Redeemed State ---
class CouponRedeemed extends TarotState {
  final String message;
  const CouponRedeemed(
      this.message, {
        required super.userTokens,
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
        // YENİ ALANLAR
        required super.isDailyTokenAvailable,
        super.nextDailyTokenTime,
      });

  @override
  List<Object?> get props => [message, ...super.props];

  @override
  CouponRedeemed copyWith({
    double? userTokens,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    String? message,
    bool? isDailyTokenAvailable,
    DateTime? nextDailyTokenTime,
  }) {
    return CouponRedeemed(
      message ?? this.message,
      userTokens: userTokens ?? this.userTokens,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
      isDailyTokenAvailable: isDailyTokenAvailable ?? this.isDailyTokenAvailable,
      nextDailyTokenTime: nextDailyTokenTime ?? this.nextDailyTokenTime,
    );
  }
}

// --- Coupon Invalid State ---
class CouponInvalid extends TarotState {
  final String message;
  const CouponInvalid(
      this.message, {
        required super.userTokens,
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
        // YENİ ALANLAR
        required super.isDailyTokenAvailable,
        super.nextDailyTokenTime,
      });

  @override
  List<Object?> get props => [message, ...super.props];

  @override
  CouponInvalid copyWith({
    double? userTokens,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    String? message,
    bool? isDailyTokenAvailable,
    DateTime? nextDailyTokenTime,
  }) {
    return CouponInvalid(
      message ?? this.message,
      userTokens: userTokens ?? this.userTokens,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
      isDailyTokenAvailable: isDailyTokenAvailable ?? this.isDailyTokenAvailable,
      nextDailyTokenTime: nextDailyTokenTime ?? this.nextDailyTokenTime,
    );
  }
}

// --- Single Card Drawn State (Kullanılmıyor olabilir) ---
class SingleCardDrawn extends TarotState {
  final TarotCard card;
  const SingleCardDrawn(
      this.card, {
        required super.userTokens,
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
        // YENİ ALANLAR
        required super.isDailyTokenAvailable,
        super.nextDailyTokenTime,
      });

  @override
  List<Object?> get props => [card, ...super.props];

  @override
  SingleCardDrawn copyWith({
    double? userTokens,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    TarotCard? card,
    bool? isDailyTokenAvailable,
    DateTime? nextDailyTokenTime,
  }) {
    return SingleCardDrawn(
      card ?? this.card,
      userTokens: userTokens ?? this.userTokens,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
      isDailyTokenAvailable: isDailyTokenAvailable ?? this.isDailyTokenAvailable,
      nextDailyTokenTime: nextDailyTokenTime ?? this.nextDailyTokenTime,
    );
  }
}

// --- Spread Drawn State (Kullanılmıyor olabilir) ---
class SpreadDrawn extends TarotState {
  final Map<String, TarotCard> spread;
  const SpreadDrawn(
      this.spread, {
        required super.userTokens,
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
        // YENİ ALANLAR
        required super.isDailyTokenAvailable,
        super.nextDailyTokenTime,
      });

  @override
  List<Object?> get props => [spread, ...super.props];

  @override
  SpreadDrawn copyWith({
    double? userTokens,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    Map<String, TarotCard>? spread,
    bool? isDailyTokenAvailable,
    DateTime? nextDailyTokenTime,
  }) {
    return SpreadDrawn(
      spread ?? this.spread,
      userTokens: userTokens ?? this.userTokens,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
      isDailyTokenAvailable: isDailyTokenAvailable ?? this.isDailyTokenAvailable,
      nextDailyTokenTime: nextDailyTokenTime ?? this.nextDailyTokenTime,
    );
  }
}

// --- Reading Result Loaded State ---
class FalYorumuLoaded extends TarotState {
  final String yorum;
  final int tokenCount;
  final double cost;
  final Map<String, TarotCard> spread;

  const FalYorumuLoaded(
      this.yorum, {
        required this.tokenCount,
        required this.cost,
        required this.spread,
        required super.userTokens,
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
        // YENİ ALANLAR
        required super.isDailyTokenAvailable,
        super.nextDailyTokenTime,
      });

  @override
  List<Object?> get props => [yorum, tokenCount, cost, spread, ...super.props];

  @override
  FalYorumuLoaded copyWith({
    double? userTokens,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    String? yorum,
    int? tokenCount,
    double? cost,
    Map<String, TarotCard>? spread,
    bool? isDailyTokenAvailable,
    DateTime? nextDailyTokenTime,
  }) {
    return FalYorumuLoaded(
      yorum ?? this.yorum,
      tokenCount: tokenCount ?? this.tokenCount,
      cost: cost ?? this.cost,
      spread: spread ?? this.spread,
      userTokens: userTokens ?? this.userTokens,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
      isDailyTokenAvailable: isDailyTokenAvailable ?? this.isDailyTokenAvailable,
      nextDailyTokenTime: nextDailyTokenTime ?? this.nextDailyTokenTime,
    );
  }
}

// --- Insufficient Resources State ---
class InsufficientResources extends TarotState {
  final double requiredTokens;
  const InsufficientResources(
      this.requiredTokens, {
        required super.userTokens,
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
        // YENİ ALANLAR
        required super.isDailyTokenAvailable,
        super.nextDailyTokenTime,
      });

  @override
  List<Object?> get props => [requiredTokens, ...super.props];

  @override
  InsufficientResources copyWith({
    double? userTokens,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    double? requiredTokens,
    bool? isDailyTokenAvailable,
    DateTime? nextDailyTokenTime,
  }) {
    return InsufficientResources(
      requiredTokens ?? this.requiredTokens,
      userTokens: userTokens ?? this.userTokens,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
      isDailyTokenAvailable: isDailyTokenAvailable ?? this.isDailyTokenAvailable,
      nextDailyTokenTime: nextDailyTokenTime ?? this.nextDailyTokenTime,
    );
  }
}


// ================== SPREAD TYPE ENUM ==================
// Enum tanımı aynı kalabilir. fullMoonSpread kart sayısı kontrol edildi.
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
  fullMoonSpread(6, 1800, 3000, 30, 'full_moon_purchase', 900), // Kart sayısı 6 olarak düzeltildi (Repo'ya göre)
  categoryReading(5, 1800, 3000, 30, 'category_reading_purchase', 900); // Varsayılan

  final int cardCount;
  final int freeTokenLimit;
  final int premiumTokenLimit;
  final double costInCredits;
  final String productId;
  final int maxPromptLength;

  static List<String> get allProductIds => SpreadType.values.map((type) => type.productId).toList();

  const SpreadType(this.cardCount, this.freeTokenLimit, this.premiumTokenLimit,
      this.costInCredits, this.productId, this.maxPromptLength);
}