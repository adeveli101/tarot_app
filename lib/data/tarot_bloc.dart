// ignore_for_file: unused_import, unused_local_variable

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

class InsufficientResources extends TarotState {
  final double requiredCredits;
  InsufficientResources(this.requiredCredits);
  @override
  List<Object?> get props => [requiredCredits];
}


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

class InsufficientCredits extends TarotState {
  final double requiredCredits;
  InsufficientCredits(this.requiredCredits);
  @override
  List<Object?> get props => [requiredCredits];
}

// Spread Types with Token Limits and Costs
enum SpreadType {
  singleCard(600, 2000, 1.0, 'single_card_purchase'), // freeTokenLimit 500 -> 600
  pastPresentFuture(1200, 3000, 2.0, 'past_present_future_purchase'), // freeTokenLimit 1000 -> 1200
  problemSolution(1200, 3000, 2.0, 'problem_solution_purchase'), // freeTokenLimit 1000 -> 1200
  fiveCardPath(1800, 4000, 3.0, 'five_card_path_purchase'),
  relationshipSpread(2500, 5000, 4.0, 'relationship_spread_purchase'),
  celticCross(3000, 5000, 5.0, 'celtic_cross_purchase'),
  yearlySpread(3000, 5000, 6.0, 'yearly_spread_purchase'),
  mindBodySpirit(1200, 3000, 2.0, 'mind_body_spirit_purchase'), // freeTokenLimit 1000 -> 1200
  astroLogicalCross(1800, 4000, 3.0, 'astrological_cross_purchase'),
  brokenHeart(1800, 4000, 3.0, 'broken_heart_purchase'),
  dreamInterpretation(1200, 3000, 2.0, 'dream_interpretation_purchase'), // freeTokenLimit 1000 -> 1200
  horseshoeSpread(2500, 4000, 4.0, 'horseshoe_spread_purchase'),
  careerPathSpread(1800, 4000, 3.0, 'career_path_purchase'),
  fullMoonSpread(1800, 4000, 3.0, 'full_moon_purchase'),
  categoryReading(1800, 4000, 3.0, 'category_reading_purchase');

  final int freeTokenLimit;
  final int premiumTokenLimit;
  final double costInCredits;
  final String productId;

  const SpreadType(this.freeTokenLimit, this.premiumTokenLimit, this.costInCredits, this.productId);
}



  class TarotBloc extends Bloc<TarotEvent, TarotState> {
  final TarotRepository repository;
  final GeminiService geminiService;
  final String locale;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  int _dailyFreeFalCount = 0;
  static const int _maxFreeFalsPerDay = 5;
  bool _isPremium = false;
  double _userCredits = 10.0;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  SpreadType? _currentSpreadType;


  // Sabit kupon listesi (test ve kullanıcılar için)
  final Map<String, Map<String, dynamic>> _validCoupons = {
  'PREMIUM_TEST': {'type': 'premium', 'value': true}, // Premium üyelik testi
  'CREDITS_50': {'type': 'credits', 'value': 50.0},   // 50 kredi testi
  'FREE_READING': {'type': 'credits', 'value': 10.0}, // 10 kredi
  };

  // Public getter'lar
  String get userId => _auth.currentUser!.uid;
  bool get isPremium => _isPremium;
  double get userCredits => _userCredits;
  SpreadType? get currentSpreadType => _currentSpreadType;
  int get dailyFreeFalCount => _dailyFreeFalCount;

  TarotBloc({
  required this.repository,
  required this.geminiService,
  required this.locale,
  }) : super(TarotInitial()) {
  _initializeUser();
  _setupPurchaseListener();
  on<LoadTarotCards>(_onLoadTarotCards);
  on<ShuffleDeck>(_onShuffleDeck);
  on<DrawSingleCard>(_onDrawSingleCard);
  on<DrawPastPresentFuture>(_onDrawPastPresentFuture);
  on<DrawProblemSolution>(_onDrawProblemSolution);
  on<DrawFiveCardPath>(_onDrawFiveCardPath);
  on<DrawRelationshipSpread>(_onDrawRelationshipSpread);
  on<DrawCelticCross>(_onDrawCelticCross);
  on<DrawYearlySpread>(_onDrawYearlySpread);
  on<DrawMindBodySpirit>(_onDrawMindBodySpirit);
  on<DrawAstroLogicalCross>(_onDrawAstroLogicalCross);
  on<DrawBrokenHeart>(_onDrawBrokenHeart);
  on<DrawDreamInterpretation>(_onDrawDreamInterpretation);
  on<DrawHorseshoeSpread>(_onDrawHorseshoeSpread);
  on<DrawCareerPathSpread>(_onDrawCareerPathSpread);
  on<DrawFullMoonSpread>(_onDrawFullMoonSpread);
  on<DrawCategoryReading>(_onDrawCategoryReading);
  on<RedeemCoupon>(_onRedeemCoupon); // Yeni event handler
  }

  Future<void> _initializeUser() async {
  try {
  await repository.signInAnonymously();
  await _loadUserData();
  } catch (e) {
  debugPrint("User initialization error: $e");
  }
  }

  Future<void> _loadUserData() async {
  final prefs = await SharedPreferences.getInstance();
  _isPremium = prefs.getBool('is_premium_${_auth.currentUser!.uid}') ?? false;
  _userCredits = prefs.getDouble('credits_${_auth.currentUser!.uid}') ?? 0.0;
  _dailyFreeFalCount = prefs.getInt('daily_free_fals_${_auth.currentUser!.uid}') ?? 0;
  }

  void _setupPurchaseListener() {
  final purchaseUpdated = _inAppPurchase.purchaseStream;
  _subscription = purchaseUpdated.listen(
  (purchases) {
  _handlePurchaseUpdates(purchases);
  },
  onDone: () => _subscription.cancel(),
  onError: (error) => debugPrint("Purchase error: $error"),
  );
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
  final prefs = await SharedPreferences.getInstance();
  for (var purchase in purchases) {
  switch (purchase.status) {
  case PurchaseStatus.purchased:
  case PurchaseStatus.restored:
  if (purchase.productID == 'premium_subscription') {
  _isPremium = true;
  await prefs.setBool('is_premium_${_auth.currentUser!.uid}', true);
  } else {
  double credits = _getCreditValue(purchase.productID);
  await _updateUserCredits(credits);
  }
  await _inAppPurchase.completePurchase(purchase);
  break;
  case PurchaseStatus.error:
  debugPrint("Purchase error: ${purchase.error}");
  break;
  default:
  break;
  }
  }
  }

  double _getCreditValue(String productId) {
  switch (productId) {
  case '10_credits':
  return 10.0;
  case '50_credits':
  return 50.0;
  case '100_credits':
  return 100.0;
  default:
  return 0.0;
  }
  }

  Future<void> _updateUserCredits(double amount) async {
  final prefs = await SharedPreferences.getInstance();
  _userCredits += amount;
  await prefs.setDouble('credits_${_auth.currentUser!.uid}', _userCredits);
  }

  Future<void> _deductCredits(double cost) async {
  if (!_isPremium) {
  _userCredits -= cost;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('credits_${_auth.currentUser!.uid}', _userCredits);
  }
  }

  Future<void> _checkDailyLimit(Emitter<TarotState> emit) async {
  final prefs = await SharedPreferences.getInstance();
  final lastReset = prefs.getInt('last_reset_${_auth.currentUser!.uid}') ?? 0;
  final now = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
  if (lastReset < now) {
  await prefs.setInt('last_reset_${_auth.currentUser!.uid}', now);
  await prefs.setInt('daily_free_fals_${_auth.currentUser!.uid}', 0);
  _dailyFreeFalCount = 0;
  } else {
  _dailyFreeFalCount = prefs.getInt('daily_free_fals_${_auth.currentUser!.uid}') ?? 0;
  }
  if (!_isPremium && _dailyFreeFalCount >= _maxFreeFalsPerDay) {
  emit(TarotError("Daily free reading limit reached"));
  throw Exception('Daily limit exceeded');
  }
  }

  Future<bool> _checkCreditsAndTokenLimit(Emitter<TarotState> emit, SpreadType spreadType) async {
    final tokenLimit = _isPremium ? spreadType.premiumTokenLimit : spreadType.freeTokenLimit;
    final cost = _isPremium ? 0.0 : spreadType.costInCredits;

    if (!_isPremium && _dailyFreeFalCount >= _maxFreeFalsPerDay && _userCredits < cost) {
      emit(InsufficientResources(spreadType.costInCredits)); // Yeni durum
      return false;
    }
    if (!_isPremium && _userCredits < cost) {
      emit(InsufficientResources(spreadType.costInCredits)); // Yeni durum
      return false;
    }

    final estimatedTokens = _estimateTokensForSpread(spreadType);
    if (estimatedTokens > tokenLimit) {
      emit(TarotError("Token limit exceeded for ${spreadType.name}: Estimated $estimatedTokens tokens, Limit $tokenLimit"));
      return false;
    }
    return true;
  }

  Future<void> _saveReadingToFirestore(String yorum, SpreadType spreadType, Map<String, TarotCard> spread) async {
  final user = _auth.currentUser;
  if (user != null) {
  final readingData = spread.map((key, value) => MapEntry(key, {
  'name': value.name,
  'arcana': value.arcana,
  'suit': value.suit,
  'number': value.number,
  'keywords': value.keywords,
  'meanings': {
  'light': value.meanings.light,
  'shadow': value.meanings.shadow,
  },
  'fortuneTelling': value.fortuneTelling,
  'img': value.img,
  }));
  await _firestore.collection('readings').doc(user.uid).collection('history').add({
  'yorum': yorum,
  'spreadType': spreadType.toString().split('.').last,
  'spread': readingData,
  'timestamp': FieldValue.serverTimestamp(),
  'locale': locale,
  });
  }
  }

  Future<void> saveReadingToFirestore(String content, SpreadType spreadType, Map<String, TarotCard> spread) async {
  await _saveReadingToFirestore(content, spreadType, spread);
  }

  int _estimateTokensForSpread(SpreadType spreadType) {
  switch (spreadType) {
  case SpreadType.singleCard:
  return 600;
  case SpreadType.pastPresentFuture:
  case SpreadType.problemSolution:
  case SpreadType.mindBodySpirit:
  case SpreadType.dreamInterpretation:
  return 1200;
  case SpreadType.fiveCardPath:
  case SpreadType.astroLogicalCross:
  case SpreadType.brokenHeart:
  case SpreadType.careerPathSpread:
  case SpreadType.fullMoonSpread:
  case SpreadType.categoryReading:
  return 1800;
  case SpreadType.relationshipSpread:
  case SpreadType.horseshoeSpread:
  return 2500;
  case SpreadType.celticCross:
  case SpreadType.yearlySpread:
  return 3000;
  default:
  return 1500;
  }
  }

  Future<void> _onLoadTarotCards(LoadTarotCards event, Emitter<TarotState> emit) async {
  emit(TarotLoading());
  try {
  await repository.loadCardsFromAsset();
  emit(TarotCardsLoaded(repository.getAllCards()));
  } catch (e) {
  emit(TarotError("Error loading cards: $e"));
  }
  }

  void _onShuffleDeck(ShuffleDeck event, Emitter<TarotState> emit) {
  repository.shuffleDeck();
  emit(TarotCardsLoaded(repository.getAllCards()));
  }

  Future<void> _onDrawSingleCard(DrawSingleCard event, Emitter<TarotState> emit) async {
  _currentSpreadType = SpreadType.singleCard;
  await _checkDailyLimit(emit);
  if (!await _checkCreditsAndTokenLimit(emit, SpreadType.singleCard)) return;
  emit(TarotLoading());
  try {
  final card = repository.singleCardReading();
  final spread = {'Card': card};
  final prompt = _generatePromptForSingleCard(category: 'general', card: card, customPrompt: event.customPrompt);
  final yorum = await geminiService.generateContent(prompt);
  await _deductCredits(SpreadType.singleCard.costInCredits);
  await _saveReadingToFirestore(yorum, SpreadType.singleCard, spread);
  final tokenCount = _estimateTokensForSpread(SpreadType.singleCard);
  emit(FalYorumuLoaded(yorum, tokenCount: tokenCount, cost: SpreadType.singleCard.costInCredits));
  if (!_isPremium) {
  _dailyFreeFalCount++;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('daily_free_fals_${_auth.currentUser!.uid}', _dailyFreeFalCount);
  }
  } catch (e) {
  emit(TarotError("Error drawing single card: $e"));
  }
  }

  Future<void> _onDrawPastPresentFuture(DrawPastPresentFuture event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.pastPresentFuture;
    await _checkDailyLimit(emit);
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.pastPresentFuture)) return;
    emit(TarotLoading());
    try {
      final spread = repository.pastPresentFutureReading();
      final prompt = _generatePromptForPastPresentFuture(category: 'general', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      await _deductCredits(SpreadType.pastPresentFuture.costInCredits);
      await _saveReadingToFirestore(yorum, SpreadType.pastPresentFuture, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.pastPresentFuture);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount, cost: SpreadType.pastPresentFuture.costInCredits));
      if (!_isPremium) {
        _dailyFreeFalCount++;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('daily_free_fals_${_auth.currentUser!.uid}', _dailyFreeFalCount);
      }
    } catch (e) {
      emit(TarotError("Error drawing past-present-future: $e"));
    }
  }

  Future<void> _onDrawProblemSolution(DrawProblemSolution event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.problemSolution;
    await _checkDailyLimit(emit);
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.problemSolution)) return;
    emit(TarotLoading());
    try {
      final spread = repository.problemSolutionReading();
      final prompt = _generatePromptForProblemSolution(category: 'general', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      await _deductCredits(SpreadType.problemSolution.costInCredits);
      await _saveReadingToFirestore(yorum, SpreadType.problemSolution, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.problemSolution);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount, cost: SpreadType.problemSolution.costInCredits));
      if (!_isPremium) {
        _dailyFreeFalCount++;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('daily_free_fals_${_auth.currentUser!.uid}', _dailyFreeFalCount);
      }
    } catch (e) {
      emit(TarotError("Error drawing problem-solution: $e"));
    }
  }

  Future<void> _onDrawFiveCardPath(DrawFiveCardPath event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.fiveCardPath;
    await _checkDailyLimit(emit);
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.fiveCardPath)) return;
    emit(TarotLoading());
    try {
      final spread = repository.fiveCardPathReading();
      final prompt = _generatePromptForFiveCardPath(category: 'career', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      await _deductCredits(SpreadType.fiveCardPath.costInCredits);
      await _saveReadingToFirestore(yorum, SpreadType.fiveCardPath, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.fiveCardPath);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount, cost: SpreadType.fiveCardPath.costInCredits));
      if (!_isPremium) {
        _dailyFreeFalCount++;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('daily_free_fals_${_auth.currentUser!.uid}', _dailyFreeFalCount);
      }
    } catch (e) {
      emit(TarotError("Error drawing five-card path: $e"));
    }
  }

  Future<void> _onDrawRelationshipSpread(DrawRelationshipSpread event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.relationshipSpread;
    await _checkDailyLimit(emit);
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.relationshipSpread)) return;
    emit(TarotLoading());
    try {
      final spread = repository.relationshipReading();
      final prompt = _generatePromptForRelationshipSpread(category: 'loveRelationships', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      await _deductCredits(SpreadType.relationshipSpread.costInCredits);
      await _saveReadingToFirestore(yorum, SpreadType.relationshipSpread, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.relationshipSpread);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount, cost: SpreadType.relationshipSpread.costInCredits));
      if (!_isPremium) {
        _dailyFreeFalCount++;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('daily_free_fals_${_auth.currentUser!.uid}', _dailyFreeFalCount);
      }
    } catch (e) {
      emit(TarotError("Error drawing relationship spread: $e"));
    }
  }

  Future<void> _onDrawCelticCross(DrawCelticCross event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.celticCross;
    await _checkDailyLimit(emit);
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.celticCross)) return;
    emit(TarotLoading());
    try {
      final spread = repository.celticCrossReading();
      final prompt = _generatePromptForCelticCross(category: 'general', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      await _deductCredits(SpreadType.celticCross.costInCredits);
      await _saveReadingToFirestore(yorum, SpreadType.celticCross, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.celticCross);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount, cost: SpreadType.celticCross.costInCredits));
      if (!_isPremium) {
        _dailyFreeFalCount++;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('daily_free_fals_${_auth.currentUser!.uid}', _dailyFreeFalCount);
      }
    } catch (e) {
      emit(TarotError("Error drawing Celtic Cross: $e"));
    }
  }

  Future<void> _onDrawYearlySpread(DrawYearlySpread event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.yearlySpread;
    await _checkDailyLimit(emit);
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.yearlySpread)) return;
    emit(TarotLoading());
    try {
      final spread = repository.yearlyReading();
      final prompt = _generatePromptForYearlySpread(category: 'general', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      await _deductCredits(SpreadType.yearlySpread.costInCredits);
      await _saveReadingToFirestore(yorum, SpreadType.yearlySpread, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.yearlySpread);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount, cost: SpreadType.yearlySpread.costInCredits));
      if (!_isPremium) {
        _dailyFreeFalCount++;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('daily_free_fals_${_auth.currentUser!.uid}', _dailyFreeFalCount);
      }
    } catch (e) {
      emit(TarotError("Error drawing yearly spread: $e"));
    }
  }

  Future<void> _onDrawMindBodySpirit(DrawMindBodySpirit event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.mindBodySpirit;
    await _checkDailyLimit(emit);
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.mindBodySpirit)) return;
    emit(TarotLoading());
    try {
      final spread = repository.mindBodySpiritReading();
      final prompt = _generatePromptForMindBodySpirit(category: 'holistic', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      await _deductCredits(SpreadType.mindBodySpirit.costInCredits);
      await _saveReadingToFirestore(yorum, SpreadType.mindBodySpirit, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.mindBodySpirit);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount, cost: SpreadType.mindBodySpirit.costInCredits));
      if (!_isPremium) {
        _dailyFreeFalCount++;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('daily_free_fals_${_auth.currentUser!.uid}', _dailyFreeFalCount);
      }
    } catch (e) {
      emit(TarotError("Mind-Body-Spirit reading error: $e"));
    }
  }

  Future<void> _onDrawAstroLogicalCross(DrawAstroLogicalCross event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.astroLogicalCross;
    await _checkDailyLimit(emit);
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.astroLogicalCross)) return;
    emit(TarotLoading());
    try {
      final spread = repository.astroLogicalCrossReading();
      final prompt = _generatePromptForAstroLogicalCross(category: 'general', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      await _deductCredits(SpreadType.astroLogicalCross.costInCredits);
      await _saveReadingToFirestore(yorum, SpreadType.astroLogicalCross, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.astroLogicalCross);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount, cost: SpreadType.astroLogicalCross.costInCredits));
      if (!_isPremium) {
        _dailyFreeFalCount++;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('daily_free_fals_${_auth.currentUser!.uid}', _dailyFreeFalCount);
      }
    } catch (e) {
      emit(TarotError("AstroLogical Cross reading error: $e"));
    }
  }

  Future<void> _onDrawBrokenHeart(DrawBrokenHeart event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.brokenHeart;
    await _checkDailyLimit(emit);
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.brokenHeart)) return;
    emit(TarotLoading());
    try {
      final spread = repository.brokenHeartReading();
      final prompt = _generatePromptForBrokenHeart(category: 'heart', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      await _deductCredits(SpreadType.brokenHeart.costInCredits);
      await _saveReadingToFirestore(yorum, SpreadType.brokenHeart, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.brokenHeart);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount, cost: SpreadType.brokenHeart.costInCredits));
      if (!_isPremium) {
        _dailyFreeFalCount++;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('daily_free_fals_${_auth.currentUser!.uid}', _dailyFreeFalCount);
      }
    } catch (e) {
      emit(TarotError("Broken Heart reading error: $e"));
    }
  }

  Future<void> _onDrawDreamInterpretation(DrawDreamInterpretation event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.dreamInterpretation;
    await _checkDailyLimit(emit);
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.dreamInterpretation)) return;
    emit(TarotLoading());
    try {
      final spread = repository.dreamInterpretationReading();
      final prompt = _generatePromptForDreamInterpretation(category: 'dream', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      await _deductCredits(SpreadType.dreamInterpretation.costInCredits);
      await _saveReadingToFirestore(yorum, SpreadType.dreamInterpretation, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.dreamInterpretation);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount, cost: SpreadType.dreamInterpretation.costInCredits));
      if (!_isPremium) {
        _dailyFreeFalCount++;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('daily_free_fals_${_auth.currentUser!.uid}', _dailyFreeFalCount);
      }
    } catch (e) {
      emit(TarotError("Dream Interpretation reading error: $e"));
    }
  }

  Future<void> _onDrawHorseshoeSpread(DrawHorseshoeSpread event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.horseshoeSpread;
    await _checkDailyLimit(emit);
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.horseshoeSpread)) return;
    emit(TarotLoading());
    try {
      final spread = repository.horseshoeSpread();
      final prompt = _generatePromptForHorseshoeSpread(category: 'general', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      await _deductCredits(SpreadType.horseshoeSpread.costInCredits);
      await _saveReadingToFirestore(yorum, SpreadType.horseshoeSpread, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.horseshoeSpread);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount, cost: SpreadType.horseshoeSpread.costInCredits));
      if (!_isPremium) {
        _dailyFreeFalCount++;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('daily_free_fals_${_auth.currentUser!.uid}', _dailyFreeFalCount);
      }
    } catch (e) {
      emit(TarotError("Horseshoe Spread reading error: $e"));
    }
  }

  Future<void> _onDrawCareerPathSpread(DrawCareerPathSpread event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.careerPathSpread;
    await _checkDailyLimit(emit);
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.careerPathSpread)) return;
    emit(TarotLoading());
    try {
      final spread = repository.careerPathSpread();
      final prompt = _generatePromptForCareerPathSpread(category: 'career', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      await _deductCredits(SpreadType.careerPathSpread.costInCredits);
      await _saveReadingToFirestore(yorum, SpreadType.careerPathSpread, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.careerPathSpread);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount, cost: SpreadType.careerPathSpread.costInCredits));
      if (!_isPremium) {
        _dailyFreeFalCount++;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('daily_free_fals_${_auth.currentUser!.uid}', _dailyFreeFalCount);
      }
    } catch (e) {
      emit(TarotError("Career Path Spread reading error: $e"));
    }
  }

  Future<void> _onDrawFullMoonSpread(DrawFullMoonSpread event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.fullMoonSpread;
    await _checkDailyLimit(emit);
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.fullMoonSpread)) return;
    emit(TarotLoading());
    try {
      final spread = repository.fullMoonSpread();
      final prompt = _generatePromptForFullMoonSpread(category: 'lunar', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      await _deductCredits(SpreadType.fullMoonSpread.costInCredits);
      await _saveReadingToFirestore(yorum, SpreadType.fullMoonSpread, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.fullMoonSpread);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount, cost: SpreadType.fullMoonSpread.costInCredits));
      if (!_isPremium) {
        _dailyFreeFalCount++;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('daily_free_fals_${_auth.currentUser!.uid}', _dailyFreeFalCount);
      }
    } catch (e) {
      emit(TarotError("Full Moon Spread reading error: $e"));
    }
  }

  Future<void> _onDrawCategoryReading(DrawCategoryReading event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.categoryReading;
    await _checkDailyLimit(emit);
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.categoryReading)) return;
    emit(TarotLoading());
    try {
      final spread = repository.categoryReading(event.category, event.cardCount);
      final prompt = _generatePromptForCategoryReading(category: event.category, spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      await _deductCredits(SpreadType.categoryReading.costInCredits);
      await _saveReadingToFirestore(yorum, SpreadType.categoryReading, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.categoryReading);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount, cost: SpreadType.categoryReading.costInCredits));
      if (!_isPremium) {
        _dailyFreeFalCount++;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('daily_free_fals_${_auth.currentUser!.uid}', _dailyFreeFalCount);
      }
    } catch (e) {
      emit(TarotError("Error drawing category reading: $e"));
    }
  }


  Future<void> _onRedeemCoupon(RedeemCoupon event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final couponCode = event.couponCode.trim().toUpperCase();
      final coupon = _validCoupons[couponCode];

      if (coupon == null) {
        emit(CouponInvalid("Invalid coupon code"));
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      if (coupon['type'] == 'premium') {
        _isPremium = true;
        await prefs.setBool('is_premium_${_auth.currentUser!.uid}', true);
        emit(CouponRedeemed("Successfully redeemed premium membership!"));
      } else if (coupon['type'] == 'credits') {
        final creditsToAdd = coupon['value'] as double;
        await _updateUserCredits(creditsToAdd);
        emit(CouponRedeemed("Successfully added $creditsToAdd credits!"));
      } else {
        emit(CouponInvalid("Unknown coupon type"));
      }
    } catch (e) {
      emit(CouponInvalid("Error redeeming coupon: $e"));
    }
  }

  // Prompt Generators (remaining the same as in your document)
  String _generatePromptForSingleCard({
    required String category,
    required TarotCard card,
    String? customPrompt,
  }) {
    String customPromptSection = customPrompt != null && customPrompt.trim().isNotEmpty
        ? 'User\'s custom request: "$customPrompt"\nIncorporate this request into your interpretation.'
        : 'No custom request provided by the user; provide a general interpretation.';
    return '''
IMPORTANT: Strictly adhere to the format below. Do NOT include any placeholders like [GENERAL_ANALYSIS] in your response. Instead, replace these with detailed, original text in [LANGUAGE]. Do not add any additional information.

✨ Tarot Reading - Guide to Mystical Paths ✨  
This reading provides a personal insight into $category using a single card spread. Prepare to uncover the unique message of the card!

$customPromptSection

---

### The Divine Dance of the Cards

Card: ${card.name}  
- Meaning: ${card.meanings.light.join(', ')}  
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}  
- **Category-Specific Insight**: Provide a brief insight specific to $category.

---

### In-Depth General Commentary

Offer a concise, creative commentary on the card’s energy and its significance for the user’s $category context.

---

### Guiding Whispers & Suggestions

- Timeline & Suggestions: Offer a simple suggestion for the user’s near future in the $category context.  
- Points to Watch Out For: Highlight a potential challenge or pitfall to avoid in the $category context.  
- Category-Specific Tips: Provide tailored advice specific to the user’s $category.

---

Instructions:  
1. All descriptions must be original, detailed, and creative.  
2. Each section must include elements specific to $category and, if provided, the custom request.  
3. The response should only fill the given fields with original text, without including any placeholders or extra information.  
4. The symbolic values and energies of the card must be interpreted in depth, limited to 500 tokens for free users or 2000 tokens for premium users.
'''.replaceAll('[LANGUAGE]', locale == 'tr' ? 'Türkçe' : 'English');
  }

  String _generatePromptForPastPresentFuture({
    required String category,
    required Map<String, TarotCard> spread,
    String? customPrompt,
  }) {
    String cardInfo = '';
    int cardIndex = 1;
    spread.forEach((position, card) {
      cardInfo += '''
[KART_${cardIndex}_POZİSYON]: $position  
- Card: ${card.name}  
- Meaning: ${card.meanings.light.join(', ')}  
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}  
''';
      cardIndex++;
    });

    String customPromptSection = customPrompt != null && customPrompt.trim().isNotEmpty
        ? 'User\'s custom request: "$customPrompt"\nIncorporate this request into your interpretation.'
        : 'No custom request provided by the user; provide a general interpretation.';
    return '''
IMPORTANT: Strictly adhere to the format below. Do NOT include any placeholders like [GENERAL_ANALYSIS] in your response. Instead, replace these with detailed, original text in [LANGUAGE]. Do not add any additional information.

✨ Tarot Reading - Guide to Mystical Paths ✨  
This reading provides personal insights into $category using the Past-Present-Future spread. Prepare to uncover the unique messages across time!

$customPromptSection

---

### The Divine Symphony of the Cards

$cardInfo

---

### Reflections of Unified Destiny

The combination of these cards marks a journey through time in your $category context.  
- General Analysis: Provide a detailed analysis of the card energies and their significance across Past, Present, and Future for the user’s $category.  
- Combined Evaluation of the Cards: Describe how the cards interact and what their combined energy suggests for the user’s $category journey over time.  
- Special Note: Offer a specific insight or advice related to the user’s $category and, if provided, their custom request.

---

### In-Depth General Commentary

Provide a comprehensive commentary on the overall reading, focusing on the user’s $category journey through time.

---

### Guiding Whispers & Suggestions

- Timeline & Suggestions: Offer practical suggestions for the user’s near future in the $category context, based on the Past and Present.  
- Points to Watch Out For: Highlight potential challenges or pitfalls to avoid in the $category context.  
- Category-Specific Tips: Provide tailored advice specific to the user’s $category and time-based insights.

---

Instructions:  
1. All descriptions must be original, detailed, and creative.  
2. Each section must include elements specific to $category and, if provided, the custom request.  
3. The response should only fill the given fields with original text, without including any placeholders or extra information.  
4. The symbolic values, energies, and interactions between the cards must be interpreted in depth, limited to 1000 tokens for free users or 3000 tokens for premium users.
'''.replaceAll('[LANGUAGE]', locale == 'tr' ? 'Türkçe' : 'English');
  }

  String _generatePromptForProblemSolution({
    required String category,
    required Map<String, TarotCard> spread,
    String? customPrompt,
  }) {
    String cardInfo = '';
    int cardIndex = 1;
    spread.forEach((position, card) {
      cardInfo += '''
[KART_${cardIndex}_POZISYON]: $position
- Card: ${card.name}
- Meaning: ${card.meanings.light.join(', ')}
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}
''';
      cardIndex++;
    });

    String customPromptSection = customPrompt != null && customPrompt.trim().isNotEmpty
        ? 'User\'s custom request: "$customPrompt"\nIncorporate this request into your interpretation.'
        : 'No custom request provided by the user; provide a general interpretation.';
    return '''
IMPORTANT: Strictly adhere to the format below. Do NOT include any placeholders like [GENERAL_ANALYSIS] in your response. Instead, provide detailed, original text in [LANGUAGE].

✨ Tarot Reading - Problem Solution Insight ✨  
This reading aims to identify and explore the problem as well as outline potential solutions within the context of $category.

$customPromptSection

---

### The Elements of the Problem

$cardInfo

---

### Analysis & Diagnosis

Analyze the problem depicted by the cards, discussing how their combined symbolism reflects the challenge in the $category context.

---

### Strategic Recommendations

Offer strategic advice and suggestions, detailing specific steps or insights to address the issue.

---

### Concluding Thoughts

Summarize the key insights and suggested actions to resolve the problem.

Instructions:  
1. Descriptions must be original, detailed, and creative.
2. Limit the response to 1000 tokens for free users or 3000 tokens for premium users.
'''.replaceAll('[LANGUAGE]', locale == 'tr' ? 'Türkçe' : 'English');
  }

  String _generatePromptForFiveCardPath({
    required String category,
    required Map<String, TarotCard> spread,
    String? customPrompt,
  }) {
    String cardInfo = '';
    int cardIndex = 1;
    spread.forEach((position, card) {
      cardInfo += '''
[KART_${cardIndex}_POZİSYON]: $position  
- Card: ${card.name}  
- Meaning: ${card.meanings.light.join(', ')}  
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}  
''';
      cardIndex++;
    });

    String customPromptSection = customPrompt != null && customPrompt.trim().isNotEmpty
        ? 'User\'s custom request: "$customPrompt"\nIncorporate this request into your interpretation.'
        : 'No custom request provided by the user; provide a general interpretation.';
    return '''
IMPORTANT: Strictly adhere to the format below. Do NOT include any placeholders like [GENERAL_ANALYSIS] in your response. Instead, replace these with detailed, original text in [LANGUAGE]. Do not add any additional information.

✨ Tarot Reading - Guide to Mystical Paths ✨  
This reading provides personal insights into $category using the Five Card Path spread. Prepare to uncover the unique messages for your career journey!

$customPromptSection

---

### The Divine Symphony of the Cards

$cardInfo

---

### Reflections of Unified Destiny

The combination of these cards marks a path in your $category context.  
- General Analysis: Provide a detailed analysis of the card energies and their significance for Current Situation, Obstacles, Best Outcome, Foundation, and Potential in the user’s $category.  
- Combined Evaluation of the Cards: Describe how the cards interact and what their combined energy suggests for the user’s $category journey.  
- Special Note: Offer a specific insight or advice related to the user’s $category and, if provided, their custom request.

---

### In-Depth General Commentary

Provide a comprehensive commentary on the overall reading, focusing on the user’s $category path.

---

### Guiding Whispers & Suggestions

- Timeline & Suggestions: Offer practical suggestions for the user’s near future in the $category context.  
- Points to Watch Out For: Highlight potential challenges or pitfalls to avoid in the $category context.  
- Category-Specific Tips: Provide tailored advice specific to the user’s $category and career path.

---

Instructions:  
1. All descriptions must be original, detailed, and creative.  
2. Each section must include elements specific to $category and, if provided, the custom request.  
3. The response should only fill the given fields with original text, without including any placeholders or extra information.  
4. The symbolic values, energies, and interactions between the cards must be interpreted in depth, limited to 1500 tokens for free users or 4000 tokens for premium users.
'''.replaceAll('[LANGUAGE]', locale == 'tr' ? 'Türkçe' : 'English');
  }

  String _generatePromptForRelationshipSpread({
    required String category,
    required Map<String, TarotCard> spread,
    String? customPrompt,
  }) {
    String cardInfo = '';
    int cardIndex = 1;
    spread.forEach((position, card) {
      cardInfo += '''
[KART_${cardIndex}_POZISYON]: $position
- Card: ${card.name}
- Meaning: ${card.meanings.light.join(', ')}
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}
''';
      cardIndex++;
    });

    String customPromptSection = customPrompt != null && customPrompt.trim().isNotEmpty
        ? 'User\'s custom request: "$customPrompt"\nIntegrate this into your relationship reading interpretation.'
        : 'No custom request provided by the user; offer a general relationship interpretation.';
    return '''
IMPORTANT: Strictly adhere to the format below. Do NOT include any placeholders like [GENERAL_ANALYSIS] in your response. Instead, provide detailed, original content in [LANGUAGE].

✨ Tarot Reading - Relationship Insight ✨  
This reading provides insights into relationship dynamics within the context of $category.

$customPromptSection

---

### The Dynamics of the Relationship

$cardInfo

---

### Analysis of Interaction

Discuss the interplay of energies and roles within the relationship. Analyze how the cards reflect shared energies, individual influences, and mutual interactions in the $category context.

---

### Guidance & Recommendations

Offer tailored advice and suggestions for improving or understanding the relationship better, drawing from the symbolism of the cards.

---

### Summary Reflection

Conclude with key insights and practical recommendations based on the overall reading.

Instructions:  
1. Descriptions must be original and thoughtful.
2. Limit the response to 1500 tokens for free users or 4000 tokens for premium users.
'''.replaceAll('[LANGUAGE]', locale == 'tr' ? 'Türkçe' : 'English');
  }

  String _generatePromptForCelticCross({
    required String category,
    required Map<String, TarotCard> spread,
    String? customPrompt,
  }) {
    String cardInfo = '';
    int cardIndex = 1;
    spread.forEach((position, card) {
      cardInfo += '''
[KART_${cardIndex}_POZISYON]: $position
- Card: ${card.name}
- Meaning: ${card.meanings.light.join(', ')}
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}
''';
      cardIndex++;
    });

    String customPromptSection = customPrompt != null && customPrompt.trim().isNotEmpty
        ? 'User\'s custom request: "$customPrompt"\nIncorporate this into the reading.'
        : 'No custom request provided by the user; provide a general interpretation.';
    return '''
IMPORTANT: Adhere strictly to the format below. Do NOT leave any placeholders such as [GENERAL_ANALYSIS]. Provide original, detailed commentary in [LANGUAGE].

✨ Tarot Reading - Celtic Cross Spread ✨  
This reading uses the Celtic Cross spread to deliver comprehensive insights into $category.

$customPromptSection

---

### The Celtic Cross Layout

$cardInfo

---

### Deep Analysis

Provide an in-depth analysis of the spread, discussing the individual and combined meanings of the cards, along with their relevance to the $category context.

---

### Recommendations and Advice

Offer practical advice and suggestions based on the analysis of the cards, focusing on potential challenges and opportunities.

---

### Final Summary

Conclude with a summary of key insights and actionable guidance for the user.

Instructions:  
1. All descriptions must be original, creative, and extensive.
2. Tailor the response with insightful commentary fitting for a Celtic Cross reading.
'''.replaceAll('[LANGUAGE]', locale == 'tr' ? 'Türkçe' : 'English');
  }

  String _generatePromptForYearlySpread({
    required String category,
    required Map<String, TarotCard> spread,
    String? customPrompt,
  }) {
    String cardInfo = '';
    int cardIndex = 1;
    spread.forEach((position, card) {
      cardInfo += '''
[KART_${cardIndex}_POZISYON]: $position
- Card: ${card.name}
- Meaning: ${card.meanings.light.join(', ')}
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}
''';
      cardIndex++;
    });

    String customPromptSection = customPrompt != null && customPrompt.trim().isNotEmpty
        ? 'User\'s custom request: "$customPrompt"\nInclude this in the year-ahead reading.'
        : 'No custom request provided by the user; provide a general interpretation for the upcoming year.';
    return '''
IMPORTANT: Follow the format exactly as specified. Do NOT include any placeholders like [GENERAL_ANALYSIS]. Provide detailed, original commentary in [LANGUAGE].

✨ Tarot Reading - Yearly Spread ✨  
This reading explores the themes and energies for the upcoming year within the context of $category. Each card represents significant insights for different aspects or periods of the year.

$customPromptSection

---

### Yearly Card Layout

$cardInfo

---

### Long-Term Analysis

Provide a comprehensive analysis of the cards, discussing the long-term influences, challenges, and opportunities in the $category context throughout the coming year.

---

### Year-Ahead Guidance

Offer practical advice and recommendations for navigating the upcoming year, highlighting key insights from the reading.

---

### Conclusion

Summarize the overall themes and actionable insights derived from the reading.

Instructions:  
1. Ensure all descriptions are original, detailed, and reflective.
2. Adjust token limits: 1500 tokens for free users, 4000 tokens for premium users.
'''.replaceAll('[LANGUAGE]', locale == 'tr' ? 'Türkçe' : 'English');
  }

  String _generatePromptForMindBodySpirit({
    required String category,
    required Map<String, TarotCard> spread,
    String? customPrompt,
  }) {
    String cardInfo = '';
    int cardIndex = 1;
    spread.forEach((position, card) {
      cardInfo += '''
[KART_${cardIndex}_POZİSYON]: $position
- Card: ${card.name}
- Meaning: ${card.meanings.light.join(', ')}
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}
''';
      cardIndex++;
    });

    String customPromptSection = customPrompt != null && customPrompt.trim().isNotEmpty
        ? 'User\'s custom request: "$customPrompt"\nIncorporate this request into your holistic mind, body, and spirit reading.'
        : 'No custom request provided by the user; provide a general mind, body, and spirit interpretation.';
    return '''
IMPORTANT: Follow the format strictly. Provide detailed, original interpretation in [LANGUAGE].

✨ Tarot Reading - Mind Body Spirit Spread ✨  
This reading explores the connections between the mind, body, and spirit within the context of $category.

$customPromptSection

---

### The Layout of the Cards

$cardInfo

---

### Holistic Analysis

Discuss how the cards reflect aspects of mental clarity, physical well-being, and spiritual insight in the $category context.

---

### Recommendations

Offer actionable advice to harmonize these aspects.

Instructions:  
1. Use [LANGUAGE] replaced by the correct language.
'''.replaceAll('[LANGUAGE]', locale == 'tr' ? 'Türkçe' : 'English');
  }

  String _generatePromptForAstroLogicalCross({
    required String category,
    required Map<String, TarotCard> spread,
    String? customPrompt,
  }) {
    String cardInfo = '';
    int cardIndex = 1;
    spread.forEach((position, card) {
      cardInfo += '''
[KART_${cardIndex}_POZİSYON]: $position
- Card: ${card.name}
- Meaning: ${card.meanings.light.join(', ')}
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}
''';
      cardIndex++;
    });

    String customPromptSection = customPrompt != null && customPrompt.trim().isNotEmpty
        ? 'User\'s custom request: "$customPrompt"\nWeave this request into the astrological reading.'
        : 'No custom request provided by the user; provide a general astrological cross interpretation.';
    return '''
IMPORTANT: Strictly follow the format. Fill each field with your insights in [LANGUAGE].

✨ Tarot Reading - AstroLogical Cross Spread ✨  
This reading interprets the interplay between astrological symbols and tarot energy in the context of $category.

$customPromptSection

---

### Card Layout

$cardInfo

---

### Astrological Insights

Discuss how the cards’ positions align with astrological themes in $category.

---

### Practical Guidance

Offer advice based on the astrological cross spread.

Instructions:
1. Replace [LANGUAGE] with the appropriate language.
'''.replaceAll('[LANGUAGE]', locale == 'tr' ? 'Türkçe' : 'English');
  }

  String _generatePromptForBrokenHeart({
    required String category,
    required Map<String, TarotCard> spread,
    String? customPrompt,
  }) {
    String cardInfo = '';
    int cardIndex = 1;
    spread.forEach((position, card) {
      cardInfo += '''
[KART_${cardIndex}_POZİSYON]: $position
- Card: ${card.name}
- Meaning: ${card.meanings.light.join(', ')}
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}
''';
      cardIndex++;
    });

    String customPromptSection = customPrompt != null && customPrompt.trim().isNotEmpty
        ? 'User\'s custom request: "$customPrompt"\nReflect this emotional nuance in your interpretation.'
        : 'No custom request provided by the user; provide a compassionate reading for heartbreak.';
    return '''
IMPORTANT: Adhere to the template strictly. Provide detailed text in [LANGUAGE] without placeholders.

✨ Tarot Reading - Broken Heart Spread ✨  
This reading aims to heal and provide understanding within the context of emotional pain in $category.

$customPromptSection

---

### Card Layout and Energy

$cardInfo

---

### Emotional Analysis

Discuss how the cards guide emotional recovery in $category.

---

### Healing Suggestions

Offer supportive recommendations to overcome heartbreak.

Instructions:
1. Replace [LANGUAGE] with the appropriate language.
'''.replaceAll('[LANGUAGE]', locale == 'tr' ? 'Türkçe' : 'English');
  }

  String _generatePromptForDreamInterpretation({
    required String category,
    required Map<String, TarotCard> spread,
    String? customPrompt,
  }) {
    String cardInfo = '';
    int cardIndex = 1;
    spread.forEach((position, card) {
      cardInfo += '''
[KART_${cardIndex}_POZİSYON]: $position
- Card: ${card.name}
- Meaning: ${card.meanings.light.join(', ')}
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}
''';
      cardIndex++;
    });

    String customPromptSection = customPrompt != null && customPrompt.trim().isNotEmpty
        ? 'User\'s custom request: "$customPrompt"\nInterpret how this request influences the dream symbols.'
        : 'No custom request provided by the user; provide a general dream interpretation.';
    return '''
IMPORTANT: Use the format strictly. Provide detailed interpretation in [LANGUAGE] without placeholders.

✨ Tarot Reading - Dream Interpretation Spread ✨  
This reading deciphers the symbolism of your dreams within the context of $category using tarot as a guide.

$customPromptSection

---

### Dream Symbol Layout

$cardInfo

---

### Symbolic Analysis

Discuss the meaning of each card in relation to dream symbols and personal experiences in $category.

---

### Insights & Guidance

Offer advice on how the dream symbols relate to the dreamer’s life in $category.

Instructions:
1. Replace [LANGUAGE] with the appropriate language.
'''.replaceAll('[LANGUAGE]', locale == 'tr' ? 'Türkçe' : 'English');
  }

  String _generatePromptForHorseshoeSpread({
    required String category,
    required Map<String, TarotCard> spread,
    String? customPrompt,
  }) {
    String cardInfo = '';
    int cardIndex = 1;
    spread.forEach((position, card) {
      cardInfo += '''
[KART_${cardIndex}_POZİSYON]: $position
- Card: ${card.name}
- Meaning: ${card.meanings.light.join(', ')}
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}
''';
      cardIndex++;
    });

    String customPromptSection = customPrompt != null && customPrompt.trim().isNotEmpty
        ? 'User\'s custom request: "$customPrompt"\nInclude this request in your comprehensive reading.'
        : 'No custom request provided by the user; offer a general interpretation.';
    return '''
IMPORTANT: Follow the format strictly. Provide content in [LANGUAGE] without extra placeholders.

✨ Tarot Reading - Horseshoe Spread ✨  
This reading employs the Horseshoe Spread to deliver insights into various aspects of $category.

$customPromptSection

---

### Horseshoe Card Layout

$cardInfo

---

### Detailed Analysis

Discuss how the horseshoe layout informs challenges, opportunities, and guidance in $category.

---

### Final Recommendations

Offer actionable advice based on the horseshoe spread analysis.

Instructions:
1. Replace [LANGUAGE] with the appropriate language.
'''.replaceAll('[LANGUAGE]', locale == 'tr' ? 'Türkçe' : 'English');
  }

  String _generatePromptForCareerPathSpread({
    required String category,
    required Map<String, TarotCard> spread,
    String? customPrompt,
  }) {
    String cardInfo = '';
    int cardIndex = 1;
    spread.forEach((position, card) {
      cardInfo += '''
[KART_${cardIndex}_POZİSYON]: $position
- Card: ${card.name}
- Meaning: ${card.meanings.light.join(', ')}
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}
''';
      cardIndex++;
    });

    String customPromptSection = customPrompt != null && customPrompt.trim().isNotEmpty
        ? 'User\'s custom request: "$customPrompt"\nWeave this request into the career insights.'
        : 'No custom request provided by the user; provide a general career guidance interpretation.';
    return '''
IMPORTANT: Adhere strictly to the format below. Provide original, comprehensive commentary in [LANGUAGE].

✨ Tarot Reading - Career Path Spread ✨  
This reading is crafted to explore your career trajectory and professional challenges within the context of $category.

$customPromptSection

---

### Cards in the Career Path Layout

$cardInfo

---

### Analysis and Evaluation

Discuss how each card reflects aspects of career progression and challenges in $category.

---

### Strategic Career Advice

Offer concrete suggestions to navigate professional challenges.

Instructions:
1. Replace [LANGUAGE] with the appropriate language.
'''.replaceAll('[LANGUAGE]', locale == 'tr' ? 'Türkçe' : 'English');
  }

  String _generatePromptForFullMoonSpread({
    required String category,
    required Map<String, TarotCard> spread,
    String? customPrompt,
  }) {
    String cardInfo = '';
    int cardIndex = 1;
    spread.forEach((position, card) {
      cardInfo += '''
[KART_${cardIndex}_POZİSYON]: $position
- Card: ${card.name}
- Meaning: ${card.meanings.light.join(', ')}
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}
''';
      cardIndex++;
    });

    String customPromptSection = customPrompt != null && customPrompt.trim().isNotEmpty
        ? 'User\'s custom request: "$customPrompt"\nIncorporate this into your lunar analysis.'
        : 'No custom request provided by the user; offer a general full moon reading interpretation.';
    return '''
IMPORTANT: Follow the provided format accurately. Provide all details in [LANGUAGE] without placeholders.

✨ Tarot Reading - Full Moon Spread ✨  
This reading harnesses the energy of the full moon to illuminate hidden insights and energies in the context of $category.

$customPromptSection

---

### Full Moon Card Layout

$cardInfo

---

### Lunar Analysis

Discuss the symbolism of the full moon in relation to the cards and its effect on the reading in $category.

---

### Harmonizing Lunar Energies

Offer guidance to help balance and harness lunar influences.

Instructions:
1. Replace [LANGUAGE] with the appropriate language.
'''.replaceAll('[LANGUAGE]', locale == 'tr' ? 'Türkçe' : 'English');
  }

  String _generatePromptForCategoryReading({
    required String category,
    required Map<String, TarotCard> spread,
    String? customPrompt,
  }) {
    String cardInfo = '';
    int cardIndex = 1;
    spread.forEach((position, card) {
      cardInfo += '''
[KART_${cardIndex}_POZİSYON]: $position
- Card: ${card.name}
- Meaning: ${card.meanings.light.join(', ')}
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}
''';
      cardIndex++;
    });

    String customPromptSection = customPrompt != null && customPrompt.trim().isNotEmpty
        ? 'User\'s custom request: "$customPrompt"\nIncorporate this into your category-specific reading.'
        : 'No custom request provided by the user; provide a general interpretation for the category of $category.';
    return '''
IMPORTANT: Strictly comply with the format below. Provide detailed, original interpretation in [LANGUAGE].

✨ Tarot Reading - Category Reading ✨  
This reading is crafted specifically for the context of $category, merging the symbolism of the cards with unique aspects of this domain.

$customPromptSection

---

### Card Layout

$cardInfo

---

### Analysis and Commentary

Discuss how each card contributes to understanding the $category context and offer a comprehensive interpretation.

---

### Strategic Guidance

Provide practical advice and insights tailored to $category.

Instructions:
1. Replace [LANGUAGE] with the appropriate language.
'''.replaceAll('[LANGUAGE]', locale == 'tr' ? 'Türkçe' : 'English');
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}