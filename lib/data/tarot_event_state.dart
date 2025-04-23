// lib/data/tarot_event_state.dart
import 'package:equatable/equatable.dart';
import 'package:tarot_fal/models/tarot_card.dart';

// ================== EVENTS ==================
abstract class TarotEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// --- Mevcut Eventler (DEĞİŞİKLİK YOK) ---
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

class ClaimDailyToken extends TarotEvent {}


// --- Okuma (Draw) Eventleri (GÜNCELLENDİ) ---
// <<< DEĞİŞİKLİK: Tüm Draw... eventlerine selectedCards eklendi >>>

class DrawSingleCard extends TarotEvent {
  final String? customPrompt;
  final List<TarotCard> selectedCards; // <-- Eklendi

  DrawSingleCard({required this.selectedCards, this.customPrompt}); // <-- Güncellendi

  @override
  List<Object?> get props => [customPrompt, selectedCards]; // <-- Güncellendi
}

class DrawPastPresentFuture extends TarotEvent {
  final String? customPrompt;
  final List<TarotCard> selectedCards; // <-- Eklendi

  DrawPastPresentFuture({required this.selectedCards, this.customPrompt}); // <-- Güncellendi

  @override
  List<Object?> get props => [customPrompt, selectedCards]; // <-- Güncellendi
}

class DrawProblemSolution extends TarotEvent {
  final String? customPrompt;
  final List<TarotCard> selectedCards; // <-- Eklendi

  DrawProblemSolution({required this.selectedCards, this.customPrompt}); // <-- Güncellendi

  @override
  List<Object?> get props => [customPrompt, selectedCards]; // <-- Güncellendi
}

class DrawFiveCardPath extends TarotEvent {
  final String? customPrompt;
  final List<TarotCard> selectedCards; // <-- Eklendi

  DrawFiveCardPath({required this.selectedCards, this.customPrompt}); // <-- Güncellendi

  @override
  List<Object?> get props => [customPrompt, selectedCards]; // <-- Güncellendi
}

class DrawRelationshipSpread extends TarotEvent {
  final String? customPrompt;
  final List<TarotCard> selectedCards; // <-- Eklendi

  DrawRelationshipSpread({required this.selectedCards, this.customPrompt}); // <-- Güncellendi

  @override
  List<Object?> get props => [customPrompt, selectedCards]; // <-- Güncellendi
}

class DrawCelticCross extends TarotEvent {
  final String? customPrompt;
  final List<TarotCard> selectedCards; // <-- Eklendi

  DrawCelticCross({required this.selectedCards, this.customPrompt}); // <-- Güncellendi

  @override
  List<Object?> get props => [customPrompt, selectedCards]; // <-- Güncellendi
}

class DrawYearlySpread extends TarotEvent {
  final String? customPrompt;
  final List<TarotCard> selectedCards; // <-- Eklendi

  DrawYearlySpread({required this.selectedCards, this.customPrompt}); // <-- Güncellendi

  @override
  List<Object?> get props => [customPrompt, selectedCards]; // <-- Güncellendi
}

class DrawMindBodySpirit extends TarotEvent {
  final String? customPrompt;
  final List<TarotCard> selectedCards; // <-- Eklendi

  DrawMindBodySpirit({required this.selectedCards, this.customPrompt}); // <-- Güncellendi

  @override
  List<Object?> get props => [customPrompt, selectedCards]; // <-- Güncellendi
}

class DrawAstroLogicalCross extends TarotEvent {
  final String? customPrompt;
  final List<TarotCard> selectedCards; // <-- Eklendi

  DrawAstroLogicalCross({required this.selectedCards, this.customPrompt}); // <-- Güncellendi

  @override
  List<Object?> get props => [customPrompt, selectedCards]; // <-- Güncellendi
}

class DrawBrokenHeart extends TarotEvent {
  final String? customPrompt;
  final List<TarotCard> selectedCards; // <-- Eklendi

  DrawBrokenHeart({required this.selectedCards, this.customPrompt}); // <-- Güncellendi

  @override
  List<Object?> get props => [customPrompt, selectedCards]; // <-- Güncellendi
}

class DrawDreamInterpretation extends TarotEvent {
  final String? customPrompt;
  final List<TarotCard> selectedCards; // <-- Eklendi

  DrawDreamInterpretation({required this.selectedCards, this.customPrompt}); // <-- Güncellendi

  @override
  List<Object?> get props => [customPrompt, selectedCards]; // <-- Güncellendi
}

class DrawHorseshoeSpread extends TarotEvent {
  final String? customPrompt;
  final List<TarotCard> selectedCards; // <-- Eklendi

  DrawHorseshoeSpread({required this.selectedCards, this.customPrompt}); // <-- Güncellendi

  @override
  List<Object?> get props => [customPrompt, selectedCards]; // <-- Güncellendi
}

class DrawCareerPathSpread extends TarotEvent {
  final String? customPrompt;
  final List<TarotCard> selectedCards; // <-- Eklendi

  DrawCareerPathSpread({required this.selectedCards, this.customPrompt}); // <-- Güncellendi

  @override
  List<Object?> get props => [customPrompt, selectedCards]; // <-- Güncellendi
}

class DrawFullMoonSpread extends TarotEvent {
  final String? customPrompt;
  final List<TarotCard> selectedCards; // <-- Eklendi

  DrawFullMoonSpread({required this.selectedCards, this.customPrompt}); // <-- Güncellendi

  @override
  List<Object?> get props => [customPrompt, selectedCards]; // <-- Güncellendi
}

class DrawCategoryReading extends TarotEvent {
  final String category;
  final int cardCount;
  final String? customPrompt;
  final List<TarotCard> selectedCards; // <-- Eklendi

  DrawCategoryReading({
    required this.category,
    required this.cardCount,
    required this.selectedCards, // <-- Güncellendi
    this.customPrompt
  });

  @override
  List<Object?> get props => [category, cardCount, customPrompt, selectedCards]; // <-- Güncellendi
}


// ================== STATES ==================
// State sınıflarında herhangi bir değişiklik yapılmadı.
// Önceki kodunuzla aynı kalacaklar.
abstract class TarotState extends Equatable {
  final double userTokens;
  final String? lastSelectedCategory;
  final String? userName;
  final int? userAge;
  final String? userGender;
  final bool userInfoCollected;
  final bool isDailyTokenAvailable;
  final DateTime? nextDailyTokenTime;

  const TarotState({
    required this.userTokens,
    this.lastSelectedCategory,
    this.userName,
    this.userAge,
    this.userGender,
    this.userInfoCollected = false,
    this.isDailyTokenAvailable = false,
    this.nextDailyTokenTime,
  });

  @override
  List<Object?> get props => [
    userTokens,
    lastSelectedCategory,
    userName,
    userAge,
    userGender,
    userInfoCollected,
    isDailyTokenAvailable,
    nextDailyTokenTime,
  ];

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

class TarotInitial extends TarotState {
  const TarotInitial({
    super.userTokens = 0.0,
    super.lastSelectedCategory,
    super.userName,
    super.userAge,
    super.userGender,
    super.userInfoCollected = false,
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
      isDailyTokenAvailable: isDailyTokenAvailable ?? this.isDailyTokenAvailable,
      nextDailyTokenTime: nextDailyTokenTime ?? this.nextDailyTokenTime,
    );
  }
}

class TarotLoading extends TarotState {
  const TarotLoading({
    required super.userTokens,
    super.lastSelectedCategory,
    super.userName,
    super.userAge,
    super.userGender,
    super.userInfoCollected,
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
    // String? message,
  }) {
    return TarotError(
      message,
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


class DailyTokenClaimSuccess extends TarotState {
  const DailyTokenClaimSuccess({
    required super.userTokens,
    super.lastSelectedCategory,
    super.userName,
    super.userAge,
    super.userGender,
    super.userInfoCollected,
    super.isDailyTokenAvailable = false,
    required super.nextDailyTokenTime,
  });

  @override
  DailyTokenClaimSuccess copyWith({
    double? userTokens,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
    bool? isDailyTokenAvailable,
    DateTime? nextDailyTokenTime,
  }) {
    return DailyTokenClaimSuccess(
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
// Enum tanımı aynı kalabilir.
enum SpreadType {
  singleCard(1, 600, 2000, 10, 'single_card_purchase', 300),
  pastPresentFuture(3, 1200, 2000, 20, 'past_present_future_purchase', 600),
  problemSolution(3, 1200, 2000, 20, 'problem_solution_purchase', 600),
  fiveCardPath(5, 1800, 3000, 30.0, 'five_card_path_purchase', 900),
  relationshipSpread(7, 2500, 4000, 40, 'relationship_spread_purchase', 1200),
  celticCross(10, 3000, 4000, 50, 'celtic_cross_purchase', 1500),
  yearlySpread(12, 3000, 4000, 60, 'yearly_spread_purchase', 1800), // Yıllık 12 kart varsayımı
  mindBodySpirit(3, 1200, 3000, 20, 'mind_body_spirit_purchase', 600),
  astroLogicalCross(5, 1800, 3000, 30, 'astrological_cross_purchase', 900),
  brokenHeart(5, 1800, 3000, 30.0, 'broken_heart_purchase', 900),
  dreamInterpretation(3, 1200, 2000, 20, 'dream_interpretation_purchase', 800),
  horseshoeSpread(7, 2500, 3000, 40.0, 'horseshoe_spread_purchase', 1200),
  careerPathSpread(5, 1800, 3000, 30, 'career_path_purchase', 900),
  fullMoonSpread(6, 1800, 3000, 30, 'full_moon_purchase', 900),
  categoryReading(5, 1800, 3000, 30, 'category_reading_purchase', 900); // Varsayılan kart sayısı 5

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