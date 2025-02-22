// ignore_for_file: unused_import, unused_local_variable

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarot_fal/data/tarot_repository.dart';
import 'package:tarot_fal/generated/l10n.dart';
import '../gemini_service.dart';
import '../models/tarot_card.dart';

// Events
abstract class TarotEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTarotCards extends TarotEvent {}
class ShuffleDeck extends TarotEvent {}
class DrawSingleCard extends TarotEvent {}
class DrawPastPresentFuture extends TarotEvent {}
class DrawProblemSolution extends TarotEvent {}
class DrawFiveCardPath extends TarotEvent {}
class DrawRelationshipSpread extends TarotEvent {}
class DrawCelticCross extends TarotEvent {}
class DrawYearlySpread extends TarotEvent {}
class DrawMindBodySpirit extends TarotEvent {}
class DrawAstroLogicalCross extends TarotEvent {}
class DrawBrokenHeart extends TarotEvent {}
class DrawDreamInterpretation extends TarotEvent {}
class DrawHorseshoeSpread extends TarotEvent {}
class DrawCareerPathSpread extends TarotEvent {}
class DrawFullMoonSpread extends TarotEvent {}

class DrawCategoryReading extends TarotEvent {
  final String category;
  final int cardCount;

  DrawCategoryReading({required this.category, required this.cardCount});

  @override
  List<Object?> get props => [category, cardCount];
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
  FalYorumuLoaded(this.yorum);

  @override
  List<Object?> get props => [yorum];
}

// Bloc
class TarotBloc extends Bloc<TarotEvent, TarotState> {
  final TarotRepository repository;
  final GeminiService geminiService = GeminiService();

  // Prompt şablonu (lokalizasyon UI'da veya Gemini yanıtında yapılacak)
  String _promptTemplate = '''
ÖNEMLİ: Aşağıdaki formata kesinlikle UYGUN cevap verin. Başka hiçbir ilave bilgi eklemeyin.  
Tüm bölümler tamamen [DİL] (akıcı, yaratıcı ve seçilen kategoriye özgü detayları içermelidir).  
Önemli bir kart veya özel bir durum söz konusu olduğunda, ekstra açıklama ve destekleyici yorumlar ekleyebilirsiniz.

✨ [TAROT_FORTUNE_TITLE] ✨  
[TAROT_FORTUNE_DESCRIPTION]

---

### [DIVINE_SYMPHONY]

[KART_1_POZİSYON]: [KART_1_ADI]  
- Anlamı: [KART_1_ANLAMI]  
- Mistik Yorum: [KART_1_MİSTİK_YORUM]  
- **Kategoriye Özel Yorum:** [KART_1_KATEGORI_YORUM]  

[KART_2_POZİSYON]: [KART_2_ADI]  
- Anlamı: [KART_2_ANLAMI]  
- Mistik Yorum: [KART_2_MİSTİK_YORUM]  
- **Kategoriye Özel Yorum:** [KART_2_KATEGORI_YORUM]  

[KART_3_POZİSYON]: [KART_3_ADI]  
- Anlamı: [KART_3_ANLAMI]  
- Mistik Yorum: [KART_3_MİSTİK_YORUM]  
- **Kategoriye Özel Yorum:** [KART_3_KATEGORI_YORUM]  

... (Gerekirse daha fazla kart ekleyin. Her kart için kategoriye özgü detaylı yorumlar verin.)

---

### [UNIFIED_DESTINY_REFLECTION_TITLE]

[UNIFIED_DESTINY_MESSAGE]  
- **[GENERAL_ANALYSIS]:** [GENEL_ANALİZ]  
- **[CARDS_COMBINED_EVALUATION]:** [KARTLARIN_BERABER_DEĞERLENDİRİLMESİ]  
- **[SPECIAL_NOTE]:** Seçilen kategoriye ilişkin ekstra açıklamalar ve öngörüler.

---

### [DETAILED_GENERAL_COMMENTARY]

[DETAYLI_GENEL_YORUM]

---

### [GUIDING_WHISPERS_AND_SUGGESTIONS]

- **[TIMELINE_AND_SUGGESTIONS]:** [YAKIN_GELECEK_ÖNERİLER]  
- **[POINTS_TO_WATCH]:** [DİKKAT_EDİLMESİ_GEREKEN_NOKTALAR]  
- **[CATEGORY_SPECIFIC_TIPS]:** [KATEGORI_ÖNERİLER]

---

Talimatlar:  
1. Tüm açıklamalar özgün, detaylı ve yaratıcı olmalıdır.  
2. Her bölüm, seçilen kategoriye (örneğin; aşk, kariyer, sağlık vb.) özgü öğeler içermelidir.  
3. Yanıt, sadece verilen alanları dolduracak ve ek bilgi içermeyecektir.  
4. Kartların sembolik değerleri, enerjileri ve aralarındaki etkileşimler, derinlemesine yorumlanmalıdır.
''';

  TarotBloc({required this.repository}) : super(TarotInitial()) {
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

  Future<void> _onLoadTarotCards(LoadTarotCards event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      await repository.loadCardsFromAsset();
      emit(TarotCardsLoaded(repository.getAllCards()));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  void _onShuffleDeck(ShuffleDeck event, Emitter<TarotState> emit) {
    repository.shuffleDeck();
    emit(TarotCardsLoaded(repository.getAllCards()));
  }

  Future<void> _onDrawSingleCard(DrawSingleCard event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final card = repository.singleCardReading();
      final prompt = _generatePrompt(category: 'General', spreadType: 'Single Card', cards: {'Card': card});
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  Future<void> _onDrawPastPresentFuture(DrawPastPresentFuture event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.pastPresentFutureReading();
      final prompt = _generatePrompt(category: 'General', spreadType: 'Past-Present-Future', cards: spread);
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  Future<void> _onDrawProblemSolution(DrawProblemSolution event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.problemSolutionReading();
      final prompt = _generatePrompt(category: 'General', spreadType: 'Problem-Solution', cards: spread);
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  Future<void> _onDrawFiveCardPath(DrawFiveCardPath event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.fiveCardPathReading();
      final prompt = _generatePrompt(category: 'General', spreadType: 'Five Card Path', cards: spread);
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  Future<void> _onDrawRelationshipSpread(DrawRelationshipSpread event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.relationshipReading();
      final prompt = _generatePrompt(category: 'Love', spreadType: 'Relationship Spread', cards: spread);
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  Future<void> _onDrawCelticCross(DrawCelticCross event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.celticCrossReading();
      final prompt = _generatePrompt(category: 'General', spreadType: 'Celtic Cross', cards: spread);
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  Future<void> _onDrawYearlySpread(DrawYearlySpread event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.yearlyReading();
      final prompt = _generatePrompt(category: 'General', spreadType: 'Yearly Spread', cards: spread);
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  Future<void> _onDrawMindBodySpirit(DrawMindBodySpirit event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.mindBodySpiritReading();
      final prompt = _generatePrompt(category: 'General', spreadType: 'Mind-Body-Spirit', cards: spread);
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  Future<void> _onDrawAstroLogicalCross(DrawAstroLogicalCross event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.astroLogicalCrossReading();
      final prompt = _generatePrompt(category: 'General', spreadType: 'Astrological Cross', cards: spread);
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  Future<void> _onDrawBrokenHeart(DrawBrokenHeart event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.brokenHeartReading();
      final prompt = _generatePrompt(category: 'Love', spreadType: 'Broken Heart', cards: spread);
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  Future<void> _onDrawDreamInterpretation(DrawDreamInterpretation event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.dreamInterpretationReading();
      final prompt = _generatePrompt(category: 'General', spreadType: 'Dream Interpretation', cards: spread);
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  Future<void> _onDrawHorseshoeSpread(DrawHorseshoeSpread event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.horseshoeSpread();
      final prompt = _generatePrompt(category: 'General', spreadType: 'Horseshoe Spread', cards: spread);
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  Future<void> _onDrawCareerPathSpread(DrawCareerPathSpread event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.careerPathSpread();
      final prompt = _generatePrompt(category: 'Career', spreadType: 'Career Path Spread', cards: spread);
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  Future<void> _onDrawFullMoonSpread(DrawFullMoonSpread event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.fullMoonSpread();
      final prompt = _generatePrompt(category: 'General', spreadType: 'Full Moon Spread', cards: spread);
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  Future<void> _onDrawCategoryReading(DrawCategoryReading event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.categoryReading(event.category, event.cardCount);
      final prompt = _generatePrompt(category: event.category, spreadType: 'Category Reading', cards: spread);
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  String _generatePrompt({
    required String category,
    required String spreadType,
    required Map<String, TarotCard> cards,
  }) {
    String cardInfo = '';
    cards.forEach((position, card) {
      cardInfo += '''
        $position: ${card.name}
        - Anlamı: ${card.meanings.light.join(', ')}
        - Mistik Yorum: ${card.meanings.shadow.join(', ')}
      ''';
    });

    return _promptTemplate
        .replaceAll('[DİL]', 'current language') // Dil UI'da belirlenecek
        .replaceAll('[TAROT_FORTUNE_TITLE]', 'Tarot Fortune Title')
        .replaceAll('[TAROT_FORTUNE_DESCRIPTION]', 'This reading provides insights into [$category] using the [$spreadType] spread.')
        .replaceAll('[DIVINE_SYMPHONY]', 'Divine Symphony')
        .replaceAll('[UNIFIED_DESTINY_REFLECTION_TITLE]', 'Unified Destiny Reflection')
        .replaceAll('[UNIFIED_DESTINY_MESSAGE]', 'The combination of these cards marks a turning point in your [$category] journey.')
        .replaceAll('[GENERAL_ANALYSIS]', 'General Analysis')
        .replaceAll('[CARDS_COMBINED_EVALUATION]', 'Cards Combined Evaluation')
        .replaceAll('[SPECIAL_NOTE]', 'Special Note')
        .replaceAll('[DETAILED_GENERAL_COMMENTARY]', 'Detailed General Commentary')
        .replaceAll('[GUIDING_WHISPERS_AND_SUGGESTIONS]', 'Guiding Whispers and Suggestions')
        .replaceAll('[TIMELINE_AND_SUGGESTIONS]', 'Timeline and Suggestions')
        .replaceAll('[POINTS_TO_WATCH]', 'Points to Watch')
        .replaceAll('[CATEGORY_SPECIFIC_TIPS]', 'Category Specific Tips')
        .replaceAllMapped(RegExp(r'\[KART_(\d+)_POZİSYON\]'), (match) {
      final index = int.parse(match.group(1)!);
      return cards.length > index ? cards.keys.toList()[index] : '';
    })
        .replaceAllMapped(RegExp(r'\[KART_(\d+)_ADI\]'), (match) {
      final index = int.parse(match.group(1)!);
      return cards.length > index ? cards.values.toList()[index].name : '';
    })
        .replaceAllMapped(RegExp(r'\[KART_(\d+)_ANLAMI\]'), (match) {
      final index = int.parse(match.group(1)!);
      return cards.length > index ? cards.values.toList()[index].meanings.light.join(', ') : '';
    })
        .replaceAllMapped(RegExp(r'\[KART_(\d+)_MİSTİK_YORUM\]'), (match) {
      final index = int.parse(match.group(1)!);
      return cards.length > index ? cards.values.toList()[index].meanings.shadow.join(', ') : '';
    })
        .replaceAll('[GENEL_ANALİZ]', 'Analysis of card energies')
        .replaceAll('[KARTLARIN_BERABER_DEĞERLENDİRİLMESİ]', 'The energies of the cards interact.')
        .replaceAll('[DETAYLI_GENEL_YORUM]', 'These cards highlight key dynamics.')
        .replaceAll('[YAKIN_GELECEK_ÖNERİLER]', 'Consider these suggestions.')
        .replaceAll('[DİKKAT_EDİLMESİ_GEREKEN_NOKTALAR]', 'Watch out for these pitfalls.')
        .replaceAll('[KATEGORİ]', category)
        .replaceAll('[AÇILIM_TİPİ]', spreadType);
  }
}