// lib/data/tarot_bloc.dart
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarot_fal/data/tarot_repository.dart';
import 'package:tarot_fal/gemini_service.dart';
import 'package:tarot_fal/models/tarot_card.dart';
import 'package:tarot_fal/data/user_data_manager.dart';
import 'package:tarot_fal/data/tarot_event_state.dart';
import 'dart:developer' as developer;

class TarotBloc extends Bloc<TarotEvent, TarotState> {
  final TarotRepository repository;
  final GeminiService geminiService;
  final String locale;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserDataManager _userDataManager = UserDataManager();
  SpreadType? _currentSpreadType;


  UserDataManager get userDataManager => _userDataManager;
  SpreadType? get currentSpreadType => _currentSpreadType;
  String get userId => _auth.currentUser?.uid ?? '';

  TarotBloc({
    required this.repository,
    required this.geminiService,
    required this.locale,
  }) : super(const TarotInitial()) {
    _initializeUser();
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
    on<RedeemCoupon>(_onRedeemCoupon);
  }

  Future<void> _initializeUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        final prefs = await SharedPreferences.getInstance();
        final storedUid = prefs.getString('anonymous_uid');
        if (storedUid != null) {
          await _auth.signInWithCustomToken(storedUid);
        } else {
          await repository.signInAnonymously();
          await prefs.setString('anonymous_uid', _auth.currentUser!.uid);
        }
      }
      await _loadUserData();
    } catch (e) {
      emit(TarotError(
        "Failed to initialize user: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
  }

  Future<void> _loadUserData() async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
    final lastReset = await _userDataManager.getLastReset();
    if (lastReset < now || lastReset == 0) {
      await _userDataManager.saveDailyFreeReads(0);
      await _userDataManager.saveTokens(3.0);
      await _userDataManager.savePremiumStatus(false);
      await _userDataManager.saveLastReset(now);
    }
    final isPremium = await _userDataManager.isPremiumUser();
    final userTokens = await _userDataManager.getTokens();
    final dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
    emit(TarotInitial(
      isPremium: isPremium,
      userTokens: userTokens,
      dailyFreeFalCount: dailyFreeFalCount,
    ));
  }


  Future<bool> _checkCreditsAndTokenLimit(Emitter<TarotState> emit, SpreadType spreadType) async {
    final isPremium = await _userDataManager.isPremiumUser();
    final dailyFreeReads = await _userDataManager.getDailyFreeReads();
    final tokens = await _userDataManager.getTokens();

    final tokenLimit = isPremium ? spreadType.premiumTokenLimit : spreadType.freeTokenLimit;
    final cost = isPremium ? 0.0 : spreadType.costInCredits;

    if (!isPremium && dailyFreeReads >= 3 && tokens < cost) {
      emit(InsufficientResources(
        cost,
        isPremium: isPremium,
        userTokens: tokens,
        dailyFreeFalCount: dailyFreeReads,
      ));
      return false;
    }
    if (!isPremium && tokens < cost) {
      emit(InsufficientResources(
        cost,
        isPremium: isPremium,
        userTokens: tokens,
        dailyFreeFalCount: dailyFreeReads,
      ));
      return false;
    }

    final estimatedTokens = _estimateTokensForSpread(spreadType);
    if (estimatedTokens > tokenLimit) {
      emit(TarotError(
        "Token limit exceeded for ${spreadType.name}: $estimatedTokens/$tokenLimit",
        isPremium: isPremium,
        userTokens: tokens,
        dailyFreeFalCount: dailyFreeReads,
      ));
      return false;
    }
    return true;
  }

  Future<void> _deductTokens(double cost) async {
    final tokens = await _userDataManager.getTokens();
    if (tokens >= cost) {
      await _userDataManager.saveTokens(tokens - cost);
    }
  }

  Future<void> _incrementDailyFreeReads() async {
    final dailyFreeReads = await _userDataManager.getDailyFreeReads();
    await _userDataManager.saveDailyFreeReads(dailyFreeReads + 1);
  }

  Future<void> _saveReadingToFirestore(String yorum, SpreadType spreadType, Map<String, TarotCard> spread) async {
    final user = _auth.currentUser;
    if (user == null || yorum.isEmpty) return;
    try {
      final sanitizedSpread = spread.map((key, value) => MapEntry(
        key,
        {
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
        }..removeWhere((k, v) => v == null),
      ));
      final prefs = await SharedPreferences.getInstance();
      final oldUid = prefs.getString('anonymous_uid');
      if (oldUid != null && oldUid != user.uid) {
        final oldReadings = await _firestore.collection('readings').doc(oldUid).collection('history').get();
        for (var doc in oldReadings.docs) {
          await _firestore.collection('readings').doc(user.uid).collection('history').add(doc.data());
          await doc.reference.delete();
        }
        await prefs.setString('anonymous_uid', user.uid);
      }
      await _firestore.collection('readings').doc(user.uid).collection('history').add({
        'yorum': yorum,
        'spreadType': spreadType.toString().split('.').last,
        'spread': sanitizedSpread,
        'timestamp': FieldValue.serverTimestamp(),
        'pinned': false,
        'locale': locale,
      });
    } catch (e) {
      emit(TarotError(
        "Failed to save reading to Firestore: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
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
    emit(TarotLoading(
      isPremium: state.isPremium,
      userTokens: state.userTokens,
      dailyFreeFalCount: state.dailyFreeFalCount,
    ));
    try {
      await repository.loadCardsFromAsset();
      final cards = repository.getAllCards();
      if (cards.isEmpty) throw Exception("No tarot cards loaded");
      emit(TarotCardsLoaded(
        cards,
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    } catch (e) {
      emit(TarotError(
        "Failed to load tarot cards: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
  }

  void _onShuffleDeck(ShuffleDeck event, Emitter<TarotState> emit) {
    try {
      repository.shuffleDeck();
      final cards = repository.getAllCards();
      emit(TarotCardsLoaded(
        cards,
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    } catch (e) {
      emit(TarotError(
        "Failed to shuffle deck: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
  }

  Future<void> _onDrawSingleCard(DrawSingleCard event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.singleCard;
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.singleCard)) return;
    emit(TarotLoading(
      isPremium: state.isPremium,
      userTokens: state.userTokens,
      dailyFreeFalCount: state.dailyFreeFalCount,
    ));
    try {
      final card = repository.singleCardReading();
      final spread = {'Card': card};
      final prompt = _generatePromptForSingleCard(category: 'general', card: card, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      if (yorum.isEmpty) throw Exception("Failed to generate reading");

      final isPremium = await _userDataManager.isPremiumUser();
      var dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
      var userTokens = await _userDataManager.getTokens();
      if (!isPremium) {
        await _deductTokens(SpreadType.singleCard.costInCredits);
        await _incrementDailyFreeReads();
        dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
        userTokens = await _userDataManager.getTokens();
      }

      await _saveReadingToFirestore(yorum, SpreadType.singleCard, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.singleCard);
      emit(FalYorumuLoaded(
        yorum,
        tokenCount: tokenCount,
        cost: SpreadType.singleCard.costInCredits,
        isPremium: isPremium,
        userTokens: userTokens,
        dailyFreeFalCount: dailyFreeFalCount,
      ));
    } catch (e) {
      emit(TarotError(
        "Failed to draw single card: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
  }

  Future<void> _onDrawPastPresentFuture(DrawPastPresentFuture event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.pastPresentFuture;
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.pastPresentFuture)) return;
    emit(TarotLoading(
      isPremium: state.isPremium,
      userTokens: state.userTokens,
      dailyFreeFalCount: state.dailyFreeFalCount,
    ));
    try {
      final spread = repository.pastPresentFutureReading();
      if (spread.isEmpty) throw Exception("No spread generated");
      final prompt = _generatePromptForPastPresentFuture(category: 'general', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      if (yorum.isEmpty) throw Exception("Failed to generate reading");

      final isPremium = await _userDataManager.isPremiumUser();
      var dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
      var userTokens = await _userDataManager.getTokens();
      if (!isPremium) {
        await _deductTokens(SpreadType.pastPresentFuture.costInCredits);
        await _incrementDailyFreeReads();
        dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
        userTokens = await _userDataManager.getTokens();
      }

      await _saveReadingToFirestore(yorum, SpreadType.pastPresentFuture, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.pastPresentFuture);
      emit(FalYorumuLoaded(
        yorum,
        tokenCount: tokenCount,
        cost: SpreadType.pastPresentFuture.costInCredits,
        isPremium: isPremium,
        userTokens: userTokens,
        dailyFreeFalCount: dailyFreeFalCount,
      ));
    } catch (e) {
      emit(TarotError(
        "Failed to draw past-present-future: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
  }

  Future<void> _onDrawProblemSolution(DrawProblemSolution event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.problemSolution;
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.problemSolution)) return;
    emit(TarotLoading(
      isPremium: state.isPremium,
      userTokens: state.userTokens,
      dailyFreeFalCount: state.dailyFreeFalCount,
    ));
    try {
      final spread = repository.problemSolutionReading();
      if (spread.isEmpty) throw Exception("No spread generated");
      final prompt = _generatePromptForProblemSolution(category: 'general', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      if (yorum.isEmpty) throw Exception("Failed to generate reading");

      final isPremium = await _userDataManager.isPremiumUser();
      var dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
      var userTokens = await _userDataManager.getTokens();
      if (!isPremium) {
        await _deductTokens(SpreadType.problemSolution.costInCredits);
        await _incrementDailyFreeReads();
        dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
        userTokens = await _userDataManager.getTokens();
      }

      await _saveReadingToFirestore(yorum, SpreadType.problemSolution, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.problemSolution);
      emit(FalYorumuLoaded(
        yorum,
        tokenCount: tokenCount,
        cost: SpreadType.problemSolution.costInCredits,
        isPremium: isPremium,
        userTokens: userTokens,
        dailyFreeFalCount: dailyFreeFalCount,
      ));
    } catch (e) {
      emit(TarotError(
        "Failed to draw problem-solution: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
  }

  Future<void> _onDrawFiveCardPath(DrawFiveCardPath event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.fiveCardPath;
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.fiveCardPath)) return;
    emit(TarotLoading(
      isPremium: state.isPremium,
      userTokens: state.userTokens,
      dailyFreeFalCount: state.dailyFreeFalCount,
    ));
    try {
      final spread = repository.fiveCardPathReading();
      if (spread.isEmpty) throw Exception("No spread generated");
      final prompt = _generatePromptForFiveCardPath(category: 'career', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      if (yorum.isEmpty) throw Exception("Failed to generate reading");

      final isPremium = await _userDataManager.isPremiumUser();
      var dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
      var userTokens = await _userDataManager.getTokens();
      if (!isPremium) {
        await _deductTokens(SpreadType.fiveCardPath.costInCredits);
        await _incrementDailyFreeReads();
        dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
        userTokens = await _userDataManager.getTokens();
      }

      await _saveReadingToFirestore(yorum, SpreadType.fiveCardPath, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.fiveCardPath);
      emit(FalYorumuLoaded(
        yorum,
        tokenCount: tokenCount,
        cost: SpreadType.fiveCardPath.costInCredits,
        isPremium: isPremium,
        userTokens: userTokens,
        dailyFreeFalCount: dailyFreeFalCount,
      ));
    } catch (e) {
      emit(TarotError(
        "Failed to draw five-card path: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
  }

  Future<void> _onDrawRelationshipSpread(DrawRelationshipSpread event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.relationshipSpread;
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.relationshipSpread)) return;
    emit(TarotLoading(
      isPremium: state.isPremium,
      userTokens: state.userTokens,
      dailyFreeFalCount: state.dailyFreeFalCount,
    ));
    try {
      final spread = repository.relationshipReading();
      if (spread.isEmpty) throw Exception("No spread generated");
      final prompt = _generatePromptForRelationshipSpread(category: 'loveRelationships', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      if (yorum.isEmpty) throw Exception("Failed to generate reading");

      final isPremium = await _userDataManager.isPremiumUser();
      var dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
      var userTokens = await _userDataManager.getTokens();
      if (!isPremium) {
        await _deductTokens(SpreadType.relationshipSpread.costInCredits);
        await _incrementDailyFreeReads();
        dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
        userTokens = await _userDataManager.getTokens();
      }

      await _saveReadingToFirestore(yorum, SpreadType.relationshipSpread, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.relationshipSpread);
      emit(FalYorumuLoaded(
        yorum,
        tokenCount: tokenCount,
        cost: SpreadType.relationshipSpread.costInCredits,
        isPremium: isPremium,
        userTokens: userTokens,
        dailyFreeFalCount: dailyFreeFalCount,
      ));
    } catch (e) {
      emit(TarotError(
        "Failed to draw relationship spread: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
  }

  Future<void> _onDrawCelticCross(DrawCelticCross event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.celticCross;
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.celticCross)) return;
    emit(TarotLoading(
      isPremium: state.isPremium,
      userTokens: state.userTokens,
      dailyFreeFalCount: state.dailyFreeFalCount,
    ));
    try {
      final spread = repository.celticCrossReading();
      if (spread.isEmpty) throw Exception("No spread generated");
      final prompt = _generatePromptForCelticCross(category: 'general', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      if (yorum.isEmpty) throw Exception("Failed to generate reading");

      final isPremium = await _userDataManager.isPremiumUser();
      var dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
      var userTokens = await _userDataManager.getTokens();
      if (!isPremium) {
        await _deductTokens(SpreadType.celticCross.costInCredits);
        await _incrementDailyFreeReads();
        dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
        userTokens = await _userDataManager.getTokens();
      }

      await _saveReadingToFirestore(yorum, SpreadType.celticCross, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.celticCross);
      emit(FalYorumuLoaded(
        yorum,
        tokenCount: tokenCount,
        cost: SpreadType.celticCross.costInCredits,
        isPremium: isPremium,
        userTokens: userTokens,
        dailyFreeFalCount: dailyFreeFalCount,
      ));
    } catch (e) {
      emit(TarotError(
        "Failed to draw Celtic Cross: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
  }

  Future<void> _onDrawYearlySpread(DrawYearlySpread event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.yearlySpread;
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.yearlySpread)) return;
    emit(TarotLoading(
      isPremium: state.isPremium,
      userTokens: state.userTokens,
      dailyFreeFalCount: state.dailyFreeFalCount,
    ));
    try {
      final spread = repository.yearlyReading();
      if (spread.isEmpty) throw Exception("No spread generated");
      final prompt = _generatePromptForYearlySpread(category: 'general', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      if (yorum.isEmpty) throw Exception("Failed to generate reading");

      final isPremium = await _userDataManager.isPremiumUser();
      var dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
      var userTokens = await _userDataManager.getTokens();
      if (!isPremium) {
        await _deductTokens(SpreadType.yearlySpread.costInCredits);
        await _incrementDailyFreeReads();
        dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
        userTokens = await _userDataManager.getTokens();
      }

      await _saveReadingToFirestore(yorum, SpreadType.yearlySpread, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.yearlySpread);
      emit(FalYorumuLoaded(
        yorum,
        tokenCount: tokenCount,
        cost: SpreadType.yearlySpread.costInCredits,
        isPremium: isPremium,
        userTokens: userTokens,
        dailyFreeFalCount: dailyFreeFalCount,
      ));
    } catch (e) {
      emit(TarotError(
        "Failed to draw yearly spread: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
  }

  Future<void> _onDrawMindBodySpirit(DrawMindBodySpirit event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.mindBodySpirit;
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.mindBodySpirit)) return;
    emit(TarotLoading(
      isPremium: state.isPremium,
      userTokens: state.userTokens,
      dailyFreeFalCount: state.dailyFreeFalCount,
    ));
    try {
      final spread = repository.mindBodySpiritReading();
      if (spread.isEmpty) throw Exception("No spread generated");
      final prompt = _generatePromptForMindBodySpirit(category: 'holistic', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      if (yorum.isEmpty) throw Exception("Failed to generate reading");

      final isPremium = await _userDataManager.isPremiumUser();
      var dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
      var userTokens = await _userDataManager.getTokens();
      if (!isPremium) {
        await _deductTokens(SpreadType.mindBodySpirit.costInCredits);
        await _incrementDailyFreeReads();
        dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
        userTokens = await _userDataManager.getTokens();
      }

      await _saveReadingToFirestore(yorum, SpreadType.mindBodySpirit, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.mindBodySpirit);
      emit(FalYorumuLoaded(
        yorum,
        tokenCount: tokenCount,
        cost: SpreadType.mindBodySpirit.costInCredits,
        isPremium: isPremium,
        userTokens: userTokens,
        dailyFreeFalCount: dailyFreeFalCount,
      ));
    } catch (e) {
      emit(TarotError(
        "Failed to draw Mind-Body-Spirit: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
  }

  Future<void> _onDrawAstroLogicalCross(DrawAstroLogicalCross event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.astroLogicalCross;
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.astroLogicalCross)) return;
    emit(TarotLoading(
      isPremium: state.isPremium,
      userTokens: state.userTokens,
      dailyFreeFalCount: state.dailyFreeFalCount,
    ));
    try {
      final spread = repository.astroLogicalCrossReading();
      if (spread.isEmpty) throw Exception("No spread generated");
      final prompt = _generatePromptForAstroLogicalCross(category: 'general', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      if (yorum.isEmpty) throw Exception("Failed to generate reading");

      final isPremium = await _userDataManager.isPremiumUser();
      var dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
      var userTokens = await _userDataManager.getTokens();
      if (!isPremium) {
        await _deductTokens(SpreadType.astroLogicalCross.costInCredits);
        await _incrementDailyFreeReads();
        dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
        userTokens = await _userDataManager.getTokens();
      }

      await _saveReadingToFirestore(yorum, SpreadType.astroLogicalCross, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.astroLogicalCross);
      emit(FalYorumuLoaded(
        yorum,
        tokenCount: tokenCount,
        cost: SpreadType.astroLogicalCross.costInCredits,
        isPremium: isPremium,
        userTokens: userTokens,
        dailyFreeFalCount: dailyFreeFalCount,
      ));
    } catch (e) {
      emit(TarotError(
        "Failed to draw AstroLogical Cross: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
  }

  Future<void> _onDrawBrokenHeart(DrawBrokenHeart event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.brokenHeart;
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.brokenHeart)) return;
    emit(TarotLoading(
      isPremium: state.isPremium,
      userTokens: state.userTokens,
      dailyFreeFalCount: state.dailyFreeFalCount,
    ));
    try {
      final spread = repository.brokenHeartReading();
      if (spread.isEmpty) throw Exception("No spread generated");
      final prompt = _generatePromptForBrokenHeart(category: 'heart', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      if (yorum.isEmpty) throw Exception("Failed to generate reading");

      final isPremium = await _userDataManager.isPremiumUser();
      var dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
      var userTokens = await _userDataManager.getTokens();
      if (!isPremium) {
        await _deductTokens(SpreadType.brokenHeart.costInCredits);
        await _incrementDailyFreeReads();
        dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
        userTokens = await _userDataManager.getTokens();
      }

      await _saveReadingToFirestore(yorum, SpreadType.brokenHeart, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.brokenHeart);
      emit(FalYorumuLoaded(
        yorum,
        tokenCount: tokenCount,
        cost: SpreadType.brokenHeart.costInCredits,
        isPremium: isPremium,
        userTokens: userTokens,
        dailyFreeFalCount: dailyFreeFalCount,
      ));
    } catch (e) {
      emit(TarotError(
        "Failed to draw Broken Heart: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
  }

  Future<void> _onDrawDreamInterpretation(DrawDreamInterpretation event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.dreamInterpretation;
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.dreamInterpretation)) return;
    emit(TarotLoading(
      isPremium: state.isPremium,
      userTokens: state.userTokens,
      dailyFreeFalCount: state.dailyFreeFalCount,
    ));
    try {
      final spread = repository.dreamInterpretationReading();
      if (spread.isEmpty) throw Exception("No spread generated");
      final prompt = _generatePromptForDreamInterpretation(category: 'dream', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      if (yorum.isEmpty) throw Exception("Failed to generate reading");

      final isPremium = await _userDataManager.isPremiumUser();
      var dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
      var userTokens = await _userDataManager.getTokens();
      if (!isPremium) {
        await _deductTokens(SpreadType.dreamInterpretation.costInCredits);
        await _incrementDailyFreeReads();
        dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
        userTokens = await _userDataManager.getTokens();
      }

      await _saveReadingToFirestore(yorum, SpreadType.dreamInterpretation, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.dreamInterpretation);
      emit(FalYorumuLoaded(
        yorum,
        tokenCount: tokenCount,
        cost: SpreadType.dreamInterpretation.costInCredits,
        isPremium: isPremium,
        userTokens: userTokens,
        dailyFreeFalCount: dailyFreeFalCount,
      ));
    } catch (e) {
      emit(TarotError(
        "Failed to draw Dream Interpretation: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
  }

  Future<void> _onDrawHorseshoeSpread(DrawHorseshoeSpread event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.horseshoeSpread;
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.horseshoeSpread)) return;
    emit(TarotLoading(
      isPremium: state.isPremium,
      userTokens: state.userTokens,
      dailyFreeFalCount: state.dailyFreeFalCount,
    ));
    try {
      final spread = repository.horseshoeSpread();
      if (spread.isEmpty) throw Exception("No spread generated");
      final prompt = _generatePromptForHorseshoeSpread(category: 'general', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      if (yorum.isEmpty) throw Exception("Failed to generate reading");

      final isPremium = await _userDataManager.isPremiumUser();
      var dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
      var userTokens = await _userDataManager.getTokens();
      if (!isPremium) {
        await _deductTokens(SpreadType.horseshoeSpread.costInCredits);
        await _incrementDailyFreeReads();
        dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
        userTokens = await _userDataManager.getTokens();
      }

      await _saveReadingToFirestore(yorum, SpreadType.horseshoeSpread, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.horseshoeSpread);
      emit(FalYorumuLoaded(
        yorum,
        tokenCount: tokenCount,
        cost: SpreadType.horseshoeSpread.costInCredits,
        isPremium: isPremium,
        userTokens: userTokens,
        dailyFreeFalCount: dailyFreeFalCount,
      ));
    } catch (e) {
      emit(TarotError(
        "Failed to draw Horseshoe Spread: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
  }

  Future<void> _onDrawCareerPathSpread(DrawCareerPathSpread event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.careerPathSpread;
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.careerPathSpread)) return;
    emit(TarotLoading(
      isPremium: state.isPremium,
      userTokens: state.userTokens,
      dailyFreeFalCount: state.dailyFreeFalCount,
    ));
    try {
      final spread = repository.careerPathSpread();
      if (spread.isEmpty) throw Exception("No spread generated");
      final prompt = _generatePromptForCareerPathSpread(category: 'career', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      if (yorum.isEmpty) throw Exception("Failed to generate reading");

      final isPremium = await _userDataManager.isPremiumUser();
      var dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
      var userTokens = await _userDataManager.getTokens();
      if (!isPremium) {
        await _deductTokens(SpreadType.careerPathSpread.costInCredits);
        await _incrementDailyFreeReads();
        dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
        userTokens = await _userDataManager.getTokens();
      }

      await _saveReadingToFirestore(yorum, SpreadType.careerPathSpread, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.careerPathSpread);
      emit(FalYorumuLoaded(
        yorum,
        tokenCount: tokenCount,
        cost: SpreadType.careerPathSpread.costInCredits,
        isPremium: isPremium,
        userTokens: userTokens,
        dailyFreeFalCount: dailyFreeFalCount,
      ));
    } catch (e) {
      emit(TarotError(
        "Failed to draw Career Path Spread: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
  }

  Future<void> _onDrawFullMoonSpread(DrawFullMoonSpread event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.fullMoonSpread;
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.fullMoonSpread)) return;
    emit(TarotLoading(
      isPremium: state.isPremium,
      userTokens: state.userTokens,
      dailyFreeFalCount: state.dailyFreeFalCount,
    ));
    try {
      final spread = repository.fullMoonSpread();
      if (spread.isEmpty) throw Exception("No spread generated");
      final prompt = _generatePromptForFullMoonSpread(category: 'lunar', spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      if (yorum.isEmpty) throw Exception("Failed to generate reading");

      final isPremium = await _userDataManager.isPremiumUser();
      var dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
      var userTokens = await _userDataManager.getTokens();
      if (!isPremium) {
        await _deductTokens(SpreadType.fullMoonSpread.costInCredits);
        await _incrementDailyFreeReads();
        dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
        userTokens = await _userDataManager.getTokens();
      }

      await _saveReadingToFirestore(yorum, SpreadType.fullMoonSpread, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.fullMoonSpread);
      emit(FalYorumuLoaded(
        yorum,
        tokenCount: tokenCount,
        cost: SpreadType.fullMoonSpread.costInCredits,
        isPremium: isPremium,
        userTokens: userTokens,
        dailyFreeFalCount: dailyFreeFalCount,
      ));
    } catch (e) {
      emit(TarotError(
        "Failed to draw Full Moon Spread: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
  }

  Future<void> _onDrawCategoryReading(DrawCategoryReading event, Emitter<TarotState> emit) async {
    _currentSpreadType = SpreadType.categoryReading;
    if (!await _checkCreditsAndTokenLimit(emit, SpreadType.categoryReading)) return;
    emit(TarotLoading(
      isPremium: state.isPremium,
      userTokens: state.userTokens,
      dailyFreeFalCount: state.dailyFreeFalCount,
    ));
    try {
      final spread = repository.categoryReading(event.category, event.cardCount);
      if (spread.isEmpty) throw Exception("No spread generated");
      final prompt = _generatePromptForCategoryReading(category: event.category, spread: spread, customPrompt: event.customPrompt);
      final yorum = await geminiService.generateContent(prompt);
      if (yorum.isEmpty) throw Exception("Failed to generate reading");

      final isPremium = await _userDataManager.isPremiumUser();
      var dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
      var userTokens = await _userDataManager.getTokens();
      if (!isPremium) {
        await _deductTokens(SpreadType.categoryReading.costInCredits);
        await _incrementDailyFreeReads();
        dailyFreeFalCount = await _userDataManager.getDailyFreeReads();
        userTokens = await _userDataManager.getTokens();
      }

      await _saveReadingToFirestore(yorum, SpreadType.categoryReading, spread);
      final tokenCount = _estimateTokensForSpread(SpreadType.categoryReading);
      emit(FalYorumuLoaded(
        yorum,
        tokenCount: tokenCount,
        cost: SpreadType.categoryReading.costInCredits,
        isPremium: isPremium,
        userTokens: userTokens,
        dailyFreeFalCount: dailyFreeFalCount,
      ));
    } catch (e) {
      emit(TarotError(
        "Failed to draw category reading: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
  }

  Future<void> _onRedeemCoupon(RedeemCoupon event, Emitter<TarotState> emit) async {
    emit(TarotLoading(
      isPremium: state.isPremium,
      userTokens: state.userTokens,
      dailyFreeFalCount: state.dailyFreeFalCount,
    ));
    try {
      final couponCode = event.couponCode.trim().toUpperCase();
      final validCoupons = {
        'PREMIUM_TEST': {'type': 'premium', 'value': true},
        'CREDITS_50': {'type': 'credits', 'value': 50.0},
        'FREE_READING': {'type': 'credits', 'value': 10.0},
      };

      if (!validCoupons.containsKey(couponCode)) {
        emit(CouponInvalid(
          "Invalid or unrecognized coupon code",
          isPremium: state.isPremium,
          userTokens: state.userTokens,
          dailyFreeFalCount: state.dailyFreeFalCount,
        ));
        return;
      }

      final coupon = validCoupons[couponCode]!;
      if (coupon['type'] == 'premium') {
        await _userDataManager.savePremiumStatus(coupon['value'] as bool);
        emit(CouponRedeemed(
          "Premium status updated successfully!",
          isPremium: await _userDataManager.isPremiumUser(),
          userTokens: state.userTokens,
          dailyFreeFalCount: state.dailyFreeFalCount,
        ));
      } else if (coupon['type'] == 'credits') {
        final creditsToAdd = (coupon['value'] as num).toDouble();
        if (creditsToAdd <= 0) throw ArgumentError("Invalid credit amount");
        final currentTokens = await _userDataManager.getTokens();
        await _userDataManager.saveTokens(currentTokens + creditsToAdd);
        emit(CouponRedeemed(
          "Added $creditsToAdd credits successfully!",
          isPremium: state.isPremium,
          userTokens: await _userDataManager.getTokens(),
          dailyFreeFalCount: state.dailyFreeFalCount,
        ));
      } else {
        emit(CouponInvalid(
          "Unsupported coupon type",
          isPremium: state.isPremium,
          userTokens: state.userTokens,
          dailyFreeFalCount: state.dailyFreeFalCount,
        ));
      }
    } catch (e) {
      emit(CouponInvalid(
        "Coupon redemption failed: ${e.toString()}",
        isPremium: state.isPremium,
        userTokens: state.userTokens,
        dailyFreeFalCount: state.dailyFreeFalCount,
      ));
    }
  }

  String _generatePromptForSingleCard({required String category, required TarotCard card, String? customPrompt}) {
    final customPromptSection = customPrompt?.trim().isNotEmpty == true
        ? 'User\'s custom request: "$customPrompt"\nIncorporate this request into your interpretation.'
        : 'No custom request provided by the user; provide a general interpretation.';
    return '''
IMPORTANT: Strictly adhere to the format below. Do NOT include any technical placeholders like [POSITION] in your response. Replace these with user-friendly text in $locale. Do not add any additional information.

✨ Tarot Reading - Guide to Mystical Paths ✨  
This reading provides a personal insight into $category using a single card spread. Prepare to uncover the unique message of the card!

$customPromptSection

---

### The Divine Dance of the Cards

Position: Single Card  
- Card: ${card.name}  
- Meaning: ${card.meanings.light.join(', ')}  
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}  
- Category-Specific Insight: Provide a brief insight specific to $category.

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
''';
  }

  String _generatePromptForPastPresentFuture({required String category, required Map<String, TarotCard> spread, String? customPrompt}) {
    final cardInfo = StringBuffer();
    spread.forEach((position, card) {
      cardInfo.write('''
Position: ${position.replaceAll('_', ' ').splitMapJoin(RegExp(r'(?=[A-Z])'), onMatch: (m) => ' ', onNonMatch: (n) => n)}  
- Card: ${card.name}  
- Meaning: ${card.meanings.light.join(', ')}  
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}  
''');
    });

    final customPromptSection = customPrompt?.trim().isNotEmpty == true
        ? 'User\'s custom request: "$customPrompt"\nIncorporate this request into your interpretation.'
        : 'No custom request provided by the user; provide a general interpretation.';
    return '''
IMPORTANT: Strictly adhere to the format below. Do NOT include any technical placeholders like [POSITION] in your response. Replace these with user-friendly text in $locale. Do not add any additional information.

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
''';
  }

  String _generatePromptForProblemSolution({required String category, required Map<String, TarotCard> spread, String? customPrompt}) {
    final cardInfo = StringBuffer();
    spread.forEach((position, card) {
      cardInfo.write('''
Position: ${position.replaceAll('_', ' ').splitMapJoin(RegExp(r'(?=[A-Z])'), onMatch: (m) => ' ', onNonMatch: (n) => n)}  
- Card: ${card.name}  
- Meaning: ${card.meanings.light.join(', ')}  
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}  
''');
    });

    final customPromptSection = customPrompt?.trim().isNotEmpty == true
        ? 'User\'s custom request: "$customPrompt"\nIncorporate this request into your interpretation.'
        : 'No custom request provided by the user; provide a general interpretation.';
    return '''
IMPORTANT: Strictly adhere to the format below. Do NOT include any technical placeholders like [POSITION] in your response. Replace these with user-friendly text in $locale.

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
''';
  }

  String _generatePromptForFiveCardPath({required String category, required Map<String, TarotCard> spread, String? customPrompt}) {
    final cardInfo = StringBuffer();
    spread.forEach((position, card) {
      cardInfo.write('''
Position: ${position.replaceAll('_', ' ').splitMapJoin(RegExp(r'(?=[A-Z])'), onMatch: (m) => ' ', onNonMatch: (n) => n)}  
- Card: ${card.name}  
- Meaning: ${card.meanings.light.join(', ')}  
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}  
''');
    });

    final customPromptSection = customPrompt?.trim().isNotEmpty == true
        ? 'User\'s custom request: "$customPrompt"\nIncorporate this request into your interpretation.'
        : 'No custom request provided by the user; provide a general interpretation.';
    return '''
IMPORTANT: Strictly adhere to the format below. Do NOT include any technical placeholders like [POSITION] in your response. Replace these with user-friendly text in $locale.

✨ Tarot Reading - Guide to Mystical Paths ✨  
This reading provides personal insights into $category using the Five Card Path spread. Prepare to uncover the unique messages for your journey!

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
- Category-Specific Tips: Provide tailored advice specific to the user’s $category.

---

Instructions:  
1. All descriptions must be original, detailed, and creative.  
2. Each section must include elements specific to $category and, if provided, the custom request.  
3. The response should only fill the given fields with original text, without including any placeholders or extra information.  
4. The symbolic values, energies, and interactions between the cards must be interpreted in depth, limited to 1500 tokens for free users or 4000 tokens for premium users.
''';
  }

  String _generatePromptForRelationshipSpread({required String category, required Map<String, TarotCard> spread, String? customPrompt}) {
    final cardInfo = StringBuffer();
    spread.forEach((position, card) {
      cardInfo.write('''
Position: ${position.replaceAll('_', ' ').splitMapJoin(RegExp(r'(?=[A-Z])'), onMatch: (m) => ' ', onNonMatch: (n) => n)}  
- Card: ${card.name}  
- Meaning: ${card.meanings.light.join(', ')}  
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}  
''');
    });

    final customPromptSection = customPrompt?.trim().isNotEmpty == true
        ? 'User\'s custom request: "$customPrompt"\nIntegrate this into your relationship reading interpretation.'
        : 'No custom request provided by the user; offer a general relationship interpretation.';
    return '''
IMPORTANT: Strictly adhere to the format below. Do NOT include any technical placeholders like [POSITION] in your response. Replace these with user-friendly text in $locale.

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
''';
  }

  String _generatePromptForCelticCross({required String category, required Map<String, TarotCard> spread, String? customPrompt}) {
    final cardInfo = StringBuffer();
    spread.forEach((position, card) {
      cardInfo.write('''
Position: ${position.replaceAll('_', ' ').splitMapJoin(RegExp(r'(?=[A-Z])'), onMatch: (m) => ' ', onNonMatch: (n) => n)}  
- Card: ${card.name}  
- Meaning: ${card.meanings.light.join(', ')}  
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}  
''');
    });

    final customPromptSection = customPrompt?.trim().isNotEmpty == true
        ? 'User\'s custom request: "$customPrompt"\nIncorporate this into the reading.'
        : 'No custom request provided by the user; provide a general interpretation.';
    return '''
IMPORTANT: Adhere strictly to the format below. Do NOT include any technical placeholders like [POSITION] in your response. Replace these with user-friendly text in $locale.

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
''';
  }

  String _generatePromptForYearlySpread({required String category, required Map<String, TarotCard> spread, String? customPrompt}) {
    final cardInfo = StringBuffer();
    spread.forEach((position, card) {
      cardInfo.write('''
Position: ${position.replaceAll('_', ' ').splitMapJoin(RegExp(r'(?=[A-Z])'), onMatch: (m) => ' ', onNonMatch: (n) => n)}  
- Card: ${card.name}  
- Meaning: ${card.meanings.light.join(', ')}  
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}  
''');
    });

    final customPromptSection = customPrompt?.trim().isNotEmpty == true
        ? 'User\'s custom request: "$customPrompt"\nInclude this in the year-ahead reading.'
        : 'No custom request provided by the user; provide a general interpretation for the upcoming year.';
    return '''
IMPORTANT: Follow the format exactly as specified. Do NOT include any technical placeholders like [POSITION] in your response. Replace these with user-friendly text in $locale.

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
''';
  }

  String _generatePromptForMindBodySpirit({required String category, required Map<String, TarotCard> spread, String? customPrompt}) {
    final cardInfo = StringBuffer();
    spread.forEach((position, card) {
      cardInfo.write('''
Position: ${position.replaceAll('_', ' ').splitMapJoin(RegExp(r'(?=[A-Z])'), onMatch: (m) => ' ', onNonMatch: (n) => n)}  
- Card: ${card.name}  
- Meaning: ${card.meanings.light.join(', ')}  
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}  
''');
    });

    final customPromptSection = customPrompt?.trim().isNotEmpty == true
        ? 'User\'s custom request: "$customPrompt"\nIncorporate this request into your holistic mind, body, and spirit reading.'
        : 'No custom request provided by the user; provide a general mind, body, and spirit interpretation.';
    return '''
IMPORTANT: Follow the format strictly. Provide detailed, original interpretation in $locale without placeholders.

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
1. Use $locale as the language.
''';
  }

  String _generatePromptForAstroLogicalCross({required String category, required Map<String, TarotCard> spread, String? customPrompt}) {
    final cardInfo = StringBuffer();
    spread.forEach((position, card) {
      cardInfo.write('''
Position: ${position.replaceAll('_', ' ').splitMapJoin(RegExp(r'(?=[A-Z])'), onMatch: (m) => ' ', onNonMatch: (n) => n)}  
- Card: ${card.name}  
- Meaning: ${card.meanings.light.join(', ')}  
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}  
''');
    });

    final customPromptSection = customPrompt?.trim().isNotEmpty == true
        ? 'User\'s custom request: "$customPrompt"\nWeave this request into the astrological reading.'
        : 'No custom request provided by the user; provide a general astrological cross interpretation.';
    return '''
IMPORTANT: Strictly follow the format. Fill each field with your insights in $locale without extra placeholders.

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
1. Use $locale as the language.
''';
  }

  String _generatePromptForBrokenHeart({required String category, required Map<String, TarotCard> spread, String? customPrompt}) {
    final cardInfo = StringBuffer();
    spread.forEach((position, card) {
      cardInfo.write('''
Position: ${position.replaceAll('_', ' ').splitMapJoin(RegExp(r'(?=[A-Z])'), onMatch: (m) => ' ', onNonMatch: (n) => n)}  
- Card: ${card.name}  
- Meaning: ${card.meanings.light.join(', ')}  
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}  
''');
    });

    final customPromptSection = customPrompt?.trim().isNotEmpty == true
        ? 'User\'s custom request: "$customPrompt"\nReflect this emotional nuance in your interpretation.'
        : 'No custom request provided by the user; provide a compassionate reading for heartbreak.';
    return '''
IMPORTANT: Adhere to the template strictly. Provide detailed text in $locale without placeholders.

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
1. Use $locale as the language.
''';
  }

  String _generatePromptForDreamInterpretation({required String category, required Map<String, TarotCard> spread, String? customPrompt}) {
    final cardInfo = StringBuffer();
    spread.forEach((position, card) {
      cardInfo.write('''
Position: ${position.replaceAll('_', ' ').splitMapJoin(RegExp(r'(?=[A-Z])'), onMatch: (m) => ' ', onNonMatch: (n) => n)}  
- Card: ${card.name}  
- Meaning: ${card.meanings.light.join(', ')}  
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}  
''');
    });

    final customPromptSection = customPrompt?.trim().isNotEmpty == true
        ? 'User\'s custom request: "$customPrompt"\nInterpret how this request influences the dream symbols.'
        : 'No custom request provided by the user; provide a general dream interpretation.';
    return '''
IMPORTANT: Use the format strictly. Provide detailed interpretation in $locale without placeholders.

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
1. Use $locale as the language.
''';
  }

  String _generatePromptForHorseshoeSpread({required String category, required Map<String, TarotCard> spread, String? customPrompt}) {
    final cardInfo = StringBuffer();
    spread.forEach((position, card) {
      cardInfo.write('''
Position: ${position.replaceAll('_', ' ').splitMapJoin(RegExp(r'(?=[A-Z])'), onMatch: (m) => ' ', onNonMatch: (n) => n)}  
- Card: ${card.name}  
- Meaning: ${card.meanings.light.join(', ')}  
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}  
''');
    });

    final customPromptSection = customPrompt?.trim().isNotEmpty == true
        ? 'User\'s custom request: "$customPrompt"\nInclude this request in your comprehensive reading.'
        : 'No custom request provided by the user; offer a general interpretation.';
    return '''
IMPORTANT: Follow the format strictly. Provide content in $locale without extra placeholders.

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
1. Use $locale as the language.
''';
  }

  String _generatePromptForCareerPathSpread({required String category, required Map<String, TarotCard> spread, String? customPrompt}) {
    final cardInfo = StringBuffer();
    spread.forEach((position, card) {
      cardInfo.write('''
Position: ${position.replaceAll('_', ' ').splitMapJoin(RegExp(r'(?=[A-Z])'), onMatch: (m) => ' ', onNonMatch: (n) => n)}  
- Card: ${card.name}  
- Meaning: ${card.meanings.light.join(', ')}  
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}  
''');
    });

    final customPromptSection = customPrompt?.trim().isNotEmpty == true
        ? 'User\'s custom request: "$customPrompt"\nWeave this request into the career insights.'
        : 'No custom request provided by the user; provide a general career guidance interpretation.';
    return '''
IMPORTANT: Adhere strictly to the format below. Provide original, comprehensive commentary in $locale.

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
1. Use $locale as the language.
''';
  }

  String _generatePromptForFullMoonSpread({required String category, required Map<String, TarotCard> spread, String? customPrompt}) {
    final cardInfo = StringBuffer();
    spread.forEach((position, card) {
      cardInfo.write('''
Position: ${position.replaceAll('_', ' ').splitMapJoin(RegExp(r'(?=[A-Z])'), onMatch: (m) => ' ', onNonMatch: (n) => n)}  
- Card: ${card.name}  
- Meaning: ${card.meanings.light.join(', ')}  
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}  
''');
    });

    final customPromptSection = customPrompt?.trim().isNotEmpty == true
        ? 'User\'s custom request: "$customPrompt"\nIncorporate this into your lunar analysis.'
        : 'No custom request provided by the user; offer a general full moon reading interpretation.';
    return '''
IMPORTANT: Follow the provided format accurately. Provide all details in $locale without placeholders.

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
1. Use $locale as the language.
''';
  }

  String _generatePromptForCategoryReading({required String category, required Map<String, TarotCard> spread, String? customPrompt}) {
    final cardInfo = StringBuffer();
    spread.forEach((position, card) {
      cardInfo.write('''
Position: ${position.replaceAll('_', ' ').splitMapJoin(RegExp(r'(?=[A-Z])'), onMatch: (m) => ' ', onNonMatch: (n) => n)}  
- Card: ${card.name}  
- Meaning: ${card.meanings.light.join(', ')}  
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}  
''');
    });

    final customPromptSection = customPrompt?.trim().isNotEmpty == true
        ? 'User\'s custom request: "$customPrompt"\nIncorporate this into your category-specific reading.'
        : 'No custom request provided by the user; provide a general interpretation for the category of $category.';
    return '''
IMPORTANT: Strictly comply with the format below. Provide detailed, original interpretation in $locale.

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
1. Use $locale as the language.
''';
  }

  @override
  // ignore: unnecessary_overrides
  Future<void> close() {
    return super.close();
  }
}