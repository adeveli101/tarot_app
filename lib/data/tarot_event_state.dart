// lib/data/tarot_event_state.dart
import 'package:equatable/equatable.dart';
import 'package:tarot_fal/models/tarot_card.dart';

// Events
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

// States
abstract class TarotState extends Equatable {
  final double userTokens;
  final int dailyFreeFalCount;
  final String? lastSelectedCategory;
  final String? userName;
  final int? userAge;
  final String? userGender;
  final bool userInfoCollected;

  const TarotState({
    required this.userTokens,
    required this.dailyFreeFalCount,
    this.lastSelectedCategory,
    this.userName,
    this.userAge,
    this.userGender,
    this.userInfoCollected = false,
  });

  @override
  List<Object?> get props => [
    userTokens,
    dailyFreeFalCount,
    lastSelectedCategory,
    userName,
    userAge,
    userGender,
    userInfoCollected,
  ];

  TarotState copyWith({
    double? userTokens,
    int? dailyFreeFalCount,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
  });
}

class TarotInitial extends TarotState {
  const TarotInitial({
    super.userTokens = 0.0,
    super.dailyFreeFalCount = 0,
    super.lastSelectedCategory,
    super.userName,
    super.userAge,
    super.userGender,
    super.userInfoCollected = false,
  });

  @override
  TarotState copyWith({
    double? userTokens,
    int? dailyFreeFalCount,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
  }) {
    return TarotInitial(
      userTokens: userTokens ?? this.userTokens,
      dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}

class TarotLoading extends TarotState {
  const TarotLoading({
    required super.userTokens,
    required super.dailyFreeFalCount,
    super.lastSelectedCategory,
    super.userName,
    super.userAge,
    super.userGender,
    super.userInfoCollected,
  });

  @override
  TarotState copyWith({
    double? userTokens,
    int? dailyFreeFalCount,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
  }) {
    return TarotLoading(
      userTokens: userTokens ?? this.userTokens,
      dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}

class TarotError extends TarotState {
  final String message;
  const TarotError(
      this.message, {
        required super.userTokens,
        required super.dailyFreeFalCount,
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
      });

  @override
  List<Object?> get props => [message, ...super.props];

  @override
  TarotState copyWith({
    double? userTokens,
    int? dailyFreeFalCount,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
  }) {
    return TarotError(
      message,
      userTokens: userTokens ?? this.userTokens,
      dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}

class TarotCardsLoaded extends TarotState {
  final List<TarotCard> cards;
  const TarotCardsLoaded(
      this.cards, {
        required super.userTokens,
        required super.dailyFreeFalCount,
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
      });

  @override
  List<Object?> get props => [cards, ...super.props];

  @override
  TarotState copyWith({
    double? userTokens,
    int? dailyFreeFalCount,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
  }) {
    return TarotCardsLoaded(
      cards,
      userTokens: userTokens ?? this.userTokens,
      dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}

class CouponRedeemed extends TarotState {
  final String message;
  const CouponRedeemed(
      this.message, {
        required super.userTokens,
        required super.dailyFreeFalCount,
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
      });

  @override
  List<Object?> get props => [message, ...super.props];

  @override
  TarotState copyWith({
    bool? isPremium,
    double? userTokens,
    int? dailyFreeFalCount,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
  }) {
    return CouponRedeemed(
      message,
      userTokens: userTokens ?? this.userTokens,
      dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}

class CouponInvalid extends TarotState {
  final String message;
  const CouponInvalid(
      this.message, {
        required super.userTokens,
        required super.dailyFreeFalCount,
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
      });

  @override
  List<Object?> get props => [message, ...super.props];

  @override
  TarotState copyWith({
    bool? isPremium,
    double? userTokens,
    int? dailyFreeFalCount,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
  }) {
    return CouponInvalid(
      message,
      userTokens: userTokens ?? this.userTokens,
      dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}

class SingleCardDrawn extends TarotState {
  final TarotCard card;
  const SingleCardDrawn(
      this.card, {
        required super.userTokens,
        required super.dailyFreeFalCount,
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
      });

  @override
  List<Object?> get props => [card, ...super.props];

  @override
  TarotState copyWith({
    bool? isPremium,
    double? userTokens,
    int? dailyFreeFalCount,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
  }) {
    return SingleCardDrawn(
      card,
      userTokens: userTokens ?? this.userTokens,
      dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}

class SpreadDrawn extends TarotState {
  final Map<String, TarotCard> spread;
  const SpreadDrawn(
      this.spread, {
        required super.userTokens,
        required super.dailyFreeFalCount,
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
      });

  @override
  List<Object?> get props => [spread, ...super.props];

  @override
  TarotState copyWith({
    bool? isPremium,
    double? userTokens,
    int? dailyFreeFalCount,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
  }) {
    return SpreadDrawn(
      spread,
      userTokens: userTokens ?? this.userTokens,
      dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}

class FalYorumuLoaded extends TarotState {
  final String yorum;
  final int tokenCount;
  final double cost;
  const FalYorumuLoaded(
      this.yorum, {
        required this.tokenCount,
        required this.cost,
        required super.userTokens,
        required super.dailyFreeFalCount,
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
      });

  @override
  List<Object?> get props => [yorum, tokenCount, cost, ...super.props];

  @override
  TarotState copyWith({
    bool? isPremium,
    double? userTokens,
    int? dailyFreeFalCount,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
  }) {
    return FalYorumuLoaded(
      yorum,
      tokenCount: tokenCount,
      cost: cost,
      userTokens: userTokens ?? this.userTokens,
      dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}

class InsufficientResources extends TarotState {
  final double requiredTokens;
  const InsufficientResources(
      this.requiredTokens, {
        required super.userTokens,
        required super.dailyFreeFalCount,
        super.lastSelectedCategory,
        super.userName,
        super.userAge,
        super.userGender,
        super.userInfoCollected,
      });

  @override
  List<Object?> get props => [requiredTokens, ...super.props];

  @override
  TarotState copyWith({
    bool? isPremium,
    double? userTokens,
    int? dailyFreeFalCount,
    String? lastSelectedCategory,
    String? userName,
    int? userAge,
    String? userGender,
    bool? userInfoCollected,
  }) {
    return InsufficientResources(
      requiredTokens,
      userTokens: userTokens ?? this.userTokens,
      dailyFreeFalCount: dailyFreeFalCount ?? this.dailyFreeFalCount,
      lastSelectedCategory: lastSelectedCategory ?? this.lastSelectedCategory,
      userName: userName ?? this.userName,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
      userInfoCollected: userInfoCollected ?? this.userInfoCollected,
    );
  }
}

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
  categoryReading(5, 1800, 3000, 30, 'category_reading_purchase', 900);

  final int cardCount;
  final int freeTokenLimit;
  final int premiumTokenLimit;
  final double costInCredits;
  final String productId;
  final int maxPromptLength;

  static List<String> get allProductIds => SpreadType.values.map((type) => type.productId).toList();

  const SpreadType(this.cardCount, this.freeTokenLimit, this.premiumTokenLimit,
      this.costInCredits, this.productId, this.maxPromptLength);

  // Kart sayısına göre token limit hesaplama (isteğe bağlı yardımcı metod)
  static int calculateTokenLimit(int cardCount, bool isPremium) {
    if (isPremium) {
      return cardCount * 400;  // Premium kullanıcılar için kart başına 400 token
    } else {
      return cardCount * 300;  // Ücretsiz kullanıcılar için kart başına 300 token
    }
  }
}
