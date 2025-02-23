// ignore_for_file: unused_import, unused_local_variable

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarot_fal/data/tarot_repository.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/models/tarot_card.dart';
import '../gemini_service.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class TarotEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTarotCards extends TarotEvent {}

class ShuffleDeck extends TarotEvent {}

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
  final int tokenCount; // Kullanılan token sayısını sakla
  FalYorumuLoaded(this.yorum, {required this.tokenCount});
  @override
  List<Object?> get props => [yorum, tokenCount];
}

// Token limitleri için enum
enum SpreadType {
  singleCard(500, 2000), // Ücretsiz: 500 token, Premium: 2000 token
  pastPresentFuture(1000, 3000),
  problemSolution(1000, 3000),
  fiveCardPath(1500, 4000),
  relationshipSpread(2000, 5000),
  celticCross(2000, 5000),
  yearlySpread(2000, 5000),
  mindBodySpirit(1000, 3000),
  astroLogicalCross(1500, 4000),
  brokenHeart(1500, 4000),
  dreamInterpretation(1000, 3000),
  horseshoeSpread(1500, 4000),
  careerPathSpread(1500, 4000),
  fullMoonSpread(1500, 4000),
  categoryReading(1500, 4000);

  final int freeTokenLimit;
  final int premiumTokenLimit;

  const SpreadType(this.freeTokenLimit, this.premiumTokenLimit);
}

// Bloc
class TarotBloc extends Bloc<TarotEvent, TarotState> {
  final TarotRepository repository;
  final GeminiService geminiService;
  final String locale;
  int _dailyFreeFalCount = 0;
  static const int _maxFreeFalsPerDay = 1;
  bool _isPremium = false; // Premium durumu (örneğin, SharedPreferences ile saklanabilir)

  TarotBloc({
    required this.repository,
    required this.geminiService,
    required this.locale,
  }) : super(TarotInitial()) {
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
  }

  Future<void> _checkDailyLimit(Emitter<TarotState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final lastReset = prefs.getInt('last_reset') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 86400000; // Gün olarak
    if (lastReset < now) {
      prefs.setInt('last_reset', now);
      prefs.setInt('daily_free_fals', 0);
      _dailyFreeFalCount = 0;
    } else {
      _dailyFreeFalCount = prefs.getInt('daily_free_fals') ?? 0;
    }
    if (!_isPremium && _dailyFreeFalCount >= _maxFreeFalsPerDay) {
      emit(TarotError('Daily free reading limit reached. Upgrade to premium for more.'));
      throw Exception('Daily limit exceeded');
    }
    if (!_isPremium) {
      _dailyFreeFalCount++;
      await prefs.setInt('daily_free_fals', _dailyFreeFalCount);
    }
  }

  Future<void> _checkTokenLimit(Emitter<TarotState> emit, SpreadType spreadType) async {
    final tokenLimit = _isPremium ? spreadType.premiumTokenLimit : spreadType.freeTokenLimit;
    // Token sayısını simüle ediyoruz (gerçek uygulamada Gemini API’dan alınmalı)
    final int estimatedTokens = _estimateTokensForSpread(spreadType); // Tahmini token hesaplama
    if (estimatedTokens > tokenLimit) {
      emit(TarotError(
          'Token limit exceeded for this spread. Upgrade to premium for more detailed readings.'));
      throw Exception('Token limit exceeded');
    }
  }

  int _estimateTokensForSpread(SpreadType spreadType) {
    // Basit bir tahmini token hesaplama (gerçek uygulamada Gemini API token sayısını döndürmeli)
    switch (spreadType) {
      case SpreadType.singleCard:
        return 600; // Tahmini token sayısı
      case SpreadType.pastPresentFuture:
        return 1200;
      case SpreadType.fiveCardPath:
        return 1800;
      case SpreadType.relationshipSpread:
        return 2500;
      case SpreadType.celticCross:
        return 2500;
      case SpreadType.yearlySpread:
        return 2500;
      default:
        return 1500; // Varsayılan tahmini
    }
  }

  Future<void> _onLoadTarotCards(LoadTarotCards event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      await repository.loadCardsFromAsset();
      emit(TarotCardsLoaded(repository.getAllCards()));
    } catch (e) {
      emit(TarotError('Cards loading error: $e'));
    }
  }

  void _onShuffleDeck(ShuffleDeck event, Emitter<TarotState> emit) {
    repository.shuffleDeck();
    emit(TarotCardsLoaded(repository.getAllCards()));
  }

  Future<void> _onDrawSingleCard(DrawSingleCard event, Emitter<TarotState> emit) async {
    await _checkDailyLimit(emit);
    await _checkTokenLimit(emit, SpreadType.singleCard);
    emit(TarotLoading());
    try {
      final card = repository.singleCardReading();
      final prompt = _generatePromptForSingleCard(
        category: 'general',
        card: card,
        customPrompt: event.customPrompt,
      );
      final yorum = await geminiService.generateContent(prompt);
      final tokenCount = _estimateTokensForSpread(SpreadType.singleCard); // Gerçek token sayısını al
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount));
    } catch (e) {
      emit(TarotError('Single card reading error: $e'));
    }
  }

  Future<void> _onDrawPastPresentFuture(DrawPastPresentFuture event, Emitter<TarotState> emit) async {
    await _checkDailyLimit(emit);
    await _checkTokenLimit(emit, SpreadType.pastPresentFuture);
    emit(TarotLoading());
    try {
      final spread = repository.pastPresentFutureReading();
      final prompt = _generatePromptForPastPresentFuture(
        category: 'general',
        spread: spread,
        customPrompt: event.customPrompt,
      );
      final yorum = await geminiService.generateContent(prompt);
      final tokenCount = _estimateTokensForSpread(SpreadType.pastPresentFuture);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount));
    } catch (e) {
      emit(TarotError('Past-Present-Future reading error: $e'));
    }
  }

  Future<void> _onDrawProblemSolution(DrawProblemSolution event, Emitter<TarotState> emit) async {
    await _checkDailyLimit(emit);
    await _checkTokenLimit(emit, SpreadType.problemSolution);
    emit(TarotLoading());
    try {
      final spread = repository.problemSolutionReading();
      final prompt = _generatePromptForProblemSolution(
        category: 'general',
        spread: spread,
        customPrompt: event.customPrompt,
      );
      final yorum = await geminiService.generateContent(prompt);
      final tokenCount = _estimateTokensForSpread(SpreadType.problemSolution);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount));
    } catch (e) {
      emit(TarotError('Problem-Solution reading error: $e'));
    }
  }

  Future<void> _onDrawFiveCardPath(DrawFiveCardPath event, Emitter<TarotState> emit) async {
    await _checkDailyLimit(emit);
    await _checkTokenLimit(emit, SpreadType.fiveCardPath);
    emit(TarotLoading());
    try {
      final spread = repository.fiveCardPathReading();
      final prompt = _generatePromptForFiveCardPath(
        category: 'career',
        spread: spread,
        customPrompt: event.customPrompt,
      );
      final yorum = await geminiService.generateContent(prompt);
      final tokenCount = _estimateTokensForSpread(SpreadType.fiveCardPath);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount));
    } catch (e) {
      emit(TarotError('Five Card Path reading error: $e'));
    }
  }

  Future<void> _onDrawRelationshipSpread(DrawRelationshipSpread event, Emitter<TarotState> emit) async {
    await _checkDailyLimit(emit);
    await _checkTokenLimit(emit, SpreadType.relationshipSpread);
    emit(TarotLoading());
    try {
      final spread = repository.relationshipReading();
      final prompt = _generatePromptForRelationshipSpread(
        category: 'loveRelationships',
        spread: spread,
        customPrompt: event.customPrompt,
      );
      final yorum = await geminiService.generateContent(prompt);
      final tokenCount = _estimateTokensForSpread(SpreadType.relationshipSpread);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount));
    } catch (e) {
      emit(TarotError('Relationship spread reading error: $e'));
    }
  }

  Future<void> _onDrawCelticCross(DrawCelticCross event, Emitter<TarotState> emit) async {
    await _checkDailyLimit(emit);
    await _checkTokenLimit(emit, SpreadType.celticCross);
    emit(TarotLoading());
    try {
      final spread = repository.celticCrossReading();
      final prompt = _generatePromptForCelticCross(
        category: 'general',
        spread: spread,
        customPrompt: event.customPrompt,
      );
      final yorum = await geminiService.generateContent(prompt);
      final tokenCount = _estimateTokensForSpread(SpreadType.celticCross);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount));
    } catch (e) {
      emit(TarotError('Celtic Cross reading error: $e'));
    }
  }

  Future<void> _onDrawYearlySpread(DrawYearlySpread event, Emitter<TarotState> emit) async {
    await _checkDailyLimit(emit);
    await _checkTokenLimit(emit, SpreadType.yearlySpread);
    emit(TarotLoading());
    try {
      final spread = repository.yearlyReading();
      final prompt = _generatePromptForYearlySpread(
        category: 'general',
        spread: spread,
        customPrompt: event.customPrompt,
      );
      final yorum = await geminiService.generateContent(prompt);
      final tokenCount = _estimateTokensForSpread(SpreadType.yearlySpread);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount));
    } catch (e) {
      emit(TarotError('Yearly spread reading error: $e'));
    }
  }


  Future<void> _onDrawMindBodySpirit(DrawMindBodySpirit event, Emitter<TarotState> emit) async {
    await _checkDailyLimit(emit);
    await _checkTokenLimit(emit, SpreadType.mindBodySpirit);
    emit(TarotLoading());
    try {
      final spread = repository.mindBodySpiritReading();
      final prompt = _generatePromptForMindBodySpirit(
        category: 'holistic',
        spread: spread,
        customPrompt: event.customPrompt,
      );
      final yorum = await geminiService.generateContent(prompt);
      final tokenCount = _estimateTokensForSpread(SpreadType.mindBodySpirit);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount));
    } catch (e) {
      emit(TarotError('Mind-Body-Spirit reading error: $e'));
    }
  }

  Future<void> _onDrawAstroLogicalCross(DrawAstroLogicalCross event, Emitter<TarotState> emit) async {
    await _checkDailyLimit(emit);
    await _checkTokenLimit(emit, SpreadType.astroLogicalCross);
    emit(TarotLoading());
    try {
      final spread = repository.astroLogicalCrossReading();
      final prompt = _generatePromptForAstroLogicalCross(
        category: 'general',
        spread: spread,
        customPrompt: event.customPrompt,
      );
      final yorum = await geminiService.generateContent(prompt);
      final tokenCount = _estimateTokensForSpread(SpreadType.astroLogicalCross);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount));
    } catch (e) {
      emit(TarotError('AstroLogical Cross reading error: $e'));
    }
  }

  Future<void> _onDrawBrokenHeart(DrawBrokenHeart event, Emitter<TarotState> emit) async {
    await _checkDailyLimit(emit);
    await _checkTokenLimit(emit, SpreadType.brokenHeart);
    emit(TarotLoading());
    try {
      final spread = repository.brokenHeartReading();
      final prompt = _generatePromptForBrokenHeart(
        category: 'heart',
        spread: spread,
        customPrompt: event.customPrompt,
      );
      final yorum = await geminiService.generateContent(prompt);
      final tokenCount = _estimateTokensForSpread(SpreadType.brokenHeart);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount));
    } catch (e) {
      emit(TarotError('Broken Heart reading error: $e'));
    }
  }

  Future<void> _onDrawDreamInterpretation(DrawDreamInterpretation event, Emitter<TarotState> emit) async {
    await _checkDailyLimit(emit);
    await _checkTokenLimit(emit, SpreadType.dreamInterpretation);
    emit(TarotLoading());
    try {
      final spread = repository.dreamInterpretationReading();
      final prompt = _generatePromptForDreamInterpretation(
        category: 'dream',
        spread: spread,
        customPrompt: event.customPrompt,
      );
      final yorum = await geminiService.generateContent(prompt);
      final tokenCount = _estimateTokensForSpread(SpreadType.dreamInterpretation);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount));
    } catch (e) {
      emit(TarotError('Dream interpretation reading error: $e'));
    }
  }

  Future<void> _onDrawHorseshoeSpread(DrawHorseshoeSpread event, Emitter<TarotState> emit) async {
    await _checkDailyLimit(emit);
    await _checkTokenLimit(emit, SpreadType.horseshoeSpread);
    emit(TarotLoading());
    try {
      final spread = repository.horseshoeSpread();
      final prompt = _generatePromptForHorseshoeSpread(
        category: 'general',
        spread: spread,
        customPrompt: event.customPrompt,
      );
      final yorum = await geminiService.generateContent(prompt);
      final tokenCount = _estimateTokensForSpread(SpreadType.horseshoeSpread);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount));
    } catch (e) {
      emit(TarotError('Horseshoe spread reading error: $e'));
    }
  }

  Future<void> _onDrawCareerPathSpread(DrawCareerPathSpread event, Emitter<TarotState> emit) async {
    await _checkDailyLimit(emit);
    await _checkTokenLimit(emit, SpreadType.careerPathSpread);
    emit(TarotLoading());
    try {
      final spread = repository.careerPathSpread();
      final prompt = _generatePromptForCareerPathSpread(
        category: 'career',
        spread: spread,
        customPrompt: event.customPrompt,
      );
      final yorum = await geminiService.generateContent(prompt);
      final tokenCount = _estimateTokensForSpread(SpreadType.careerPathSpread);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount));
    } catch (e) {
      emit(TarotError('Career path spread reading error: $e'));
    }
  }

  Future<void> _onDrawFullMoonSpread(DrawFullMoonSpread event, Emitter<TarotState> emit) async {
    await _checkDailyLimit(emit);
    await _checkTokenLimit(emit, SpreadType.fullMoonSpread);
    emit(TarotLoading());
    try {
      final spread = repository.fullMoonSpread();
      final prompt = _generatePromptForFullMoonSpread(
        category: 'lunar',
        spread: spread,
        customPrompt: event.customPrompt,
      );
      final yorum = await geminiService.generateContent(prompt);
      final tokenCount = _estimateTokensForSpread(SpreadType.fullMoonSpread);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount));
    } catch (e) {
      emit(TarotError('Full Moon spread reading error: $e'));
    }
  }

  Future<void> _onDrawCategoryReading(DrawCategoryReading event, Emitter<TarotState> emit) async {
    await _checkDailyLimit(emit);
    await _checkTokenLimit(emit, SpreadType.categoryReading);
    emit(TarotLoading());
    try {
      final spread = repository.categoryReading(event.category, event.cardCount);
      final prompt = _generatePromptForCategoryReading(
        category: event.category,
        spread: spread,
        customPrompt: event.customPrompt,
      );
      final yorum = await geminiService.generateContent(prompt);
      final tokenCount = _estimateTokensForSpread(SpreadType.categoryReading);
      emit(FalYorumuLoaded(yorum, tokenCount: tokenCount));
    } catch (e) {
      emit(TarotError('Category reading error: $e'));
    }
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

### The Divine Message of the Card

Card: ${card.name}  
- Meaning: ${card.meanings.light.join(', ')}  
- Mystical Interpretation: ${card.meanings.shadow.join(', ')}  
- **Category-Specific Insight:** Provide a brief insight specific to $category.

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


}