// lib/data/tarot_event_state.dart
import 'package:equatable/equatable.dart';
import 'package:tarot_fal/models/tarot_card.dart';

// Events (unchanged)
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
  final bool isPremium;
  final double userTokens; // Renamed from userCredits to userTokens
  final int dailyFreeFalCount;

  const TarotState({
    required this.isPremium,
    required this.userTokens,
    required this.dailyFreeFalCount,
  });

  @override
  List<Object?> get props => [isPremium, userTokens, dailyFreeFalCount];
}

class TarotInitial extends TarotState {
  const TarotInitial({
    super.isPremium = false,
    super.userTokens = 0.0,
    super.dailyFreeFalCount = 0,
  });
}

class TarotLoading extends TarotState {
  const TarotLoading({
    required super.isPremium,
    required super.userTokens,
    required super.dailyFreeFalCount,
  });
}

class TarotError extends TarotState {
  final String message;
  const TarotError(
      this.message, {
        required super.isPremium,
        required super.userTokens,
        required super.dailyFreeFalCount,
      });
  @override
  List<Object?> get props => [message, isPremium, userTokens, dailyFreeFalCount];
}

class TarotCardsLoaded extends TarotState {
  final List<TarotCard> cards;
  const TarotCardsLoaded(
      this.cards, {
        required super.isPremium,
        required super.userTokens,
        required super.dailyFreeFalCount,
      });
  @override
  List<Object?> get props => [cards, isPremium, userTokens, dailyFreeFalCount];
}

class CouponRedeemed extends TarotState {
  final String message;
  const CouponRedeemed(
      this.message, {
        required super.isPremium,
        required super.userTokens,
        required super.dailyFreeFalCount,
      });
  @override
  List<Object?> get props => [message, isPremium, userTokens, dailyFreeFalCount];
}

class CouponInvalid extends TarotState {
  final String message;
  const CouponInvalid(
      this.message, {
        required super.isPremium,
        required super.userTokens,
        required super.dailyFreeFalCount,
      });
  @override
  List<Object?> get props => [message, isPremium, userTokens, dailyFreeFalCount];
}

class SingleCardDrawn extends TarotState {
  final TarotCard card;
  const SingleCardDrawn(
      this.card, {
        required super.isPremium,
        required super.userTokens,
        required super.dailyFreeFalCount,
      });
  @override
  List<Object?> get props => [card, isPremium, userTokens, dailyFreeFalCount];
}

class SpreadDrawn extends TarotState {
  final Map<String, TarotCard> spread;
  const SpreadDrawn(
      this.spread, {
        required super.isPremium,
        required super.userTokens,
        required super.dailyFreeFalCount,
      });
  @override
  List<Object?> get props => [spread, isPremium, userTokens, dailyFreeFalCount];
}

class FalYorumuLoaded extends TarotState {
  final String yorum;
  final int tokenCount;
  final double cost;
  const FalYorumuLoaded(
      this.yorum, {
        required this.tokenCount,
        required this.cost,
        required super.isPremium,
        required super.userTokens,
        required super.dailyFreeFalCount,
      });
  @override
  List<Object?> get props => [yorum, tokenCount, cost, isPremium, userTokens, dailyFreeFalCount];
}

class InsufficientResources extends TarotState {
  final double requiredTokens; // Renamed from requiredCredits to requiredTokens
  const InsufficientResources(
      this.requiredTokens, {
        required super.isPremium,
        required super.userTokens,
        required super.dailyFreeFalCount,
      });
  @override
  List<Object?> get props => [requiredTokens, isPremium, userTokens, dailyFreeFalCount];
}

// Spread Types (unchanged)
enum SpreadType {
  singleCard(600, 2000, 1.0, 'single_card_purchase'),
  pastPresentFuture(1200, 3000, 2.0, 'past_present_future_purchase'),
  problemSolution(1200, 3000, 2.0, 'problem_solution_purchase'),
  fiveCardPath(1800, 4000, 3.0, 'five_card_path_purchase'),
  relationshipSpread(2500, 5000, 4.0, 'relationship_spread_purchase'),
  celticCross(3000, 5000, 5.0, 'celtic_cross_purchase'),
  yearlySpread(3000, 5000, 6.0, 'yearly_spread_purchase'),
  mindBodySpirit(1200, 3000, 2.0, 'mind_body_spirit_purchase'),
  astroLogicalCross(1800, 4000, 3.0, 'astrological_cross_purchase'),
  brokenHeart(1800, 4000, 3.0, 'broken_heart_purchase'),
  dreamInterpretation(1200, 3000, 2.0, 'dream_interpretation_purchase'),
  horseshoeSpread(2500, 4000, 4.0, 'horseshoe_spread_purchase'),
  careerPathSpread(1800, 4000, 3.0, 'career_path_purchase'),
  fullMoonSpread(1800, 4000, 3.0, 'full_moon_purchase'),
  categoryReading(1800, 4000, 3.0, 'category_reading_purchase');

  final int freeTokenLimit;
  final int premiumTokenLimit;
  final double costInCredits;
  final String productId;
  static List<String> get allProductIds => SpreadType.values.map((type) => type.productId).toList();

  const SpreadType(this.freeTokenLimit, this.premiumTokenLimit, this.costInCredits, this.productId);
}