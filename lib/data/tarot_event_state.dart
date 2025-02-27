import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarot_fal/data/tarot_repository.dart';
import 'package:tarot_fal/gemini_service.dart';
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
  @override
  List<Object?> get props => [];
}

class TarotInitial extends TarotState {}

class TarotLoading extends TarotState {}

class TarotError extends TarotState {
  final String message;
  TarotError(this.message);
  @override
  List<Object?> get props => [message];
}

class TarotCardsLoaded extends TarotState {
  final List<TarotCard> cards;
  TarotCardsLoaded(this.cards);
  @override
  List<Object?> get props => [cards];
}

class CouponRedeemed extends TarotState {
  final String message;
  CouponRedeemed(this.message);
  @override
  List<Object?> get props => [message];
}

class CouponInvalid extends TarotState {
  final String message;
  CouponInvalid(this.message);
  @override
  List<Object?> get props => [message];
}

class SingleCardDrawn extends TarotState {
  final TarotCard card;
  SingleCardDrawn(this.card);
  @override
  List<Object?> get props => [card];
}

class SpreadDrawn extends TarotState {
  final Map<String, TarotCard> spread;
  SpreadDrawn(this.spread);
  @override
  List<Object?> get props => [spread];
}

class FalYorumuLoaded extends TarotState {
  final String yorum;
  final int tokenCount;
  final double cost;
  FalYorumuLoaded(this.yorum, {required this.tokenCount, required this.cost});
  @override
  List<Object?> get props => [yorum, tokenCount, cost];
}

class InsufficientResources extends TarotState {
  final double requiredCredits;
  InsufficientResources(this.requiredCredits);
  @override
  List<Object?> get props => [requiredCredits];
}


// Spread Types
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
  static List<String> get allProductIds {
    return SpreadType.values.map((type) => type.productId).toList();
  }
  const SpreadType(this.freeTokenLimit, this.premiumTokenLimit, this.costInCredits, this.productId);
}