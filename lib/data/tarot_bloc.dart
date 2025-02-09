// lib/bloc/tarot_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarot_fal/data/tarot_repository.dart';
import '../gemini_service.dart';
import '../models/tarot_card.dart';

// Events (aynı)
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
class DrawCategoryReading extends TarotEvent {
  final String category;
  final int cardCount;

  DrawCategoryReading({required this.category, required this.cardCount});

  @override
  List<Object?> get props => [category, cardCount];
}

// States (aynı)
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

class FalYorumuLoaded extends TarotState { // Yeni state
  final String yorum;
  FalYorumuLoaded(this.yorum);
  @override
  List<Object?> get props => [yorum];
}

// Bloc
class TarotBloc extends Bloc<TarotEvent, TarotState> {
  final TarotRepository repository;
  final GeminiService geminiService = GeminiService();
  String _promptTemplate = '''
ÖNEMLİ: Aşağıdaki formata kesinlikle UYGUN cevap verin. Başka hiçbir ilave bilgi eklemeyin.  
Tüm bölümler tamamen Türkçe, akıcı, yaratıcı ve seçilen kategoriye özgü detayları içermelidir.  
Önemli bir kart veya özel bir durum söz konusu olduğunda, ekstra açıklama ve destekleyici yorumlar ekleyebilirsiniz.

✨ Tarot Falı - Gizemli Yolların Kılavuzu ✨  
Bu fal, [KATEGORİ] konusunda [AÇILIM_TİPİ] açılımı ile kişisel ve derin içgörüler sunmaktadır. Ruhunuzun derinliklerine inmeye ve kartların size özel mesajlarını keşfetmeye hazır olun!

---

### Kartların İlahi Senfonisi

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

### Birleşik Kaderin Yansımaları

Bu kartların birleşik enerjisi, [KATEGORİ] alanındaki yolculuğunuzda kritik bir dönüm noktasını simgeliyor.  
- **Genel Analiz:** [GENEL_ANALİZ]  
- **Kartların Birlikte Değerlendirilmesi:** [KARTLARIN_BERABER_DEĞERLENDİRİLMESİ]  
- **Özel Not:** Seçilen kategoriye ilişkin ekstra açıklamalar ve öngörüler.

---

### Derinlemesine Genel Yorum

Kartların sembolleri ve enerjileri, [KATEGORİ] alanındaki mevcut durumunuza ışık tutar.  
[DETAYLI_GENEL_YORUM]

---

### Yol Gösterici Fısıltılar & Öneriler

Yakın geleceğiniz için katmanlı ve özgün öneriler sunun:  
- **Zaman Çizelgesi & Öneriler:** [YAKIN_GELECEK_ÖNERİLER]  
- **Dikkat Edilmesi Gerekenler:** [DİKKAT_EDİLMESİ_GEREKEN_NOKTALAR]  
- **Kategoriye Özel İpuçları:** [KATEGORI_ÖNERİLER]

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
    on<DrawCategoryReading>(_onDrawCategoryReading);
  }

  Future<void> _onLoadTarotCards(LoadTarotCards event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      await repository.loadCardsFromAsset();
      emit(TarotCardsLoaded(repository.getAllCards()));
    } catch (e) {
      emit(TarotError("Kartlar yüklenirken bir hata oluştu: ${e.toString()}"));
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
      final prompt = _generatePrompt(
          category: 'Genel',
          spreadType: 'Tek Kart',
          cards: {
            'Kart': card,
          }
      );

      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError("Tek kart açılımı alınırken bir hata oluştu: ${e.toString()}"));
    }
  }
  Future<void> _onDrawPastPresentFuture(DrawPastPresentFuture event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.pastPresentFutureReading();

      final prompt = _generatePrompt(
          category: 'Genel',
          spreadType: 'Geçmiş-Şimdi-Gelecek',
          cards: {
            'Geçmiş': spread['Geçmiş']!,
            'Şimdi': spread['Şimdi']!,
            'Gelecek': spread['Gelecek']!,
          }
      );
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError("Geçmiş-Şimdi-Gelecek açılımı alınırken bir hata oluştu: ${e.toString()}"));
    }
  }

  Future<void> _onDrawProblemSolution(DrawProblemSolution event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.problemSolutionReading();
      final prompt = _generatePrompt(
          category: 'Genel',
          spreadType: 'Problem-Neden-Çözüm',
          cards: {
            'Problem': spread['Problem']!,
            'Neden': spread['Neden']!,
            'Çözüm': spread['Çözüm']!,
          }
      );
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError("Problem-Neden-Çözüm açılımı alınırken bir hata oluştu: ${e.toString()}"));
    }
  }
  Future<void> _onDrawFiveCardPath(DrawFiveCardPath event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.fiveCardPathReading();
      final prompt = _generatePrompt(
          category: 'Genel',
          spreadType: 'Beş Kart Yol Ayrımı',
          cards: {
            'Mevcut Durum': spread['Mevcut Durum']!,
            'Engeller': spread['Engeller']!,
            'En İyi Sonuç': spread['En İyi Sonuç']!,
            'Temel': spread['Temel']!,
            'Potansiyel': spread['Potansiyel']!,
          }
      );
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError("Beş Kart Yol Ayrımı açılımı alınırken bir hata oluştu: ${e.toString()}"));
    }
  }
  Future<void> _onDrawRelationshipSpread(DrawRelationshipSpread event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.relationshipReading();
      final prompt = _generatePrompt(
          category: 'Aşk',
          spreadType: 'İlişki Açılımı',
          cards: {
            'Siz': spread['Siz']!,
            'Partner': spread['Partner']!,
            'İlişki': spread['İlişki']!,
            'Güçlü Yönler': spread['Güçlü Yönler']!,
            'Zayıf Yönler': spread['Zayıf Yönler']!,
            'Yapılması Gerekenler': spread['Yapılması Gerekenler']!,
            'Sonuç': spread['Sonuç']!,
          }
      );
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError("İlişki açılımı alınırken bir hata oluştu: ${e.toString()}"));
    }
  }
  Future<void> _onDrawCelticCross(DrawCelticCross event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.celticCrossReading();
      final prompt = _generatePrompt(
          category: 'Genel',
          spreadType: 'Celtic Cross Açılımı',
          cards: {
            'Mevcut Durum': spread['Mevcut Durum']!,
            'Engel': spread['Engel']!,
            'Bilinçaltı': spread['Bilinçaltı']!,
            'Geçmiş': spread['Geçmiş']!,
            'Olası Gelecek': spread['Olası Gelecek']!,
            'Yakın Gelecek': spread['Yakın Gelecek']!,
            'Kişisel Duruş': spread['Kişisel Duruş']!,
            'Çevre Etkileri': spread['Çevre Etkileri']!,
            'Umutlar/Korkular': spread['Umutlar/Korkular']!,
            'Nihai Sonuç': spread['Nihai Sonuç']!,
          }
      );
      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError("Celtic Cross açılımı alınırken bir hata oluştu: ${e.toString()}"));
    }
  }
  Future<void> _onDrawYearlySpread(DrawYearlySpread event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.yearlyReading();

      final prompt = _generatePrompt(
          category: 'Genel',
          spreadType: 'Yıllık Açılım',
          cards: spread
      );

      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError("Yıllık açılım alınırken bir hata oluştu: ${e.toString()}"));
    }
  }

  Future<void> _onDrawCategoryReading(DrawCategoryReading event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      final spread = repository.categoryReading(event.category, event.cardCount);

      final prompt = _generatePrompt(
          category: event.category,
          spreadType: 'Kategori Bazlı Açılım',
          cards: spread
      );

      final yorum = await geminiService.generateContent(prompt);
      emit(FalYorumuLoaded(yorum));
    } catch (e) {
      emit(TarotError("Kategori bazlı açılım alınırken bir hata oluştu: ${e.toString()}"));
    }
  }
  // Prompt oluşturma metodu
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
        .replaceAll('[KATEGORİ]', category)
        .replaceAll('[AÇILIM_TİPİ]', spreadType)
        .replaceAllMapped(RegExp(r'\[KART_(\d+)_POZİSYON\]'), (match) {
      final index = int.parse(match.group(1)!);
      if(cards.length > index){
        return cards.keys.toList()[index];
      }
      return '';
    })
        .replaceAllMapped(RegExp(r'\[KART_(\d+)_ADI\]'), (match) {
      final index = int.parse(match.group(1)!);
      if(cards.length > index){
        return cards.values.toList()[index].name;
      }
      return '';

    })
        .replaceAllMapped(RegExp(r'\[KART_(\d+)_ANLAMI\]'), (match) {
      final index = int.parse(match.group(1)!);
      if(cards.length > index){
        return cards.values.toList()[index].meanings.light.join(', ');
      }
      return '';

    })
        .replaceAllMapped(RegExp(r'\[KART_(\d+)_MİSTİK_YORUM\]'), (match) {
      final index = int.parse(match.group(1)!);
      if(cards.length > index){
        return cards.values.toList()[index].meanings.shadow.join(', ');
      }
      return '';
    })

        .replaceAll('[GENEL_ANALİZ]', 'Kartların birleşimi ve enerji akışı')
        .replaceAll('[KARTLARIN_BERABER_DEĞERLENDİRİLMESİ]', 'Kartların enerjileri birbirini etkiliyor.')
        .replaceAll('[DETAYLI_GENEL_YORUM]',  'Bu kartlar hayatınızdaki önemli dinamikleri vurguluyor.')
        .replaceAll('[YAKIN_GELECEK_ÖNERİLER]', 'Bu önerilere kulak verin.')
        .replaceAll('[DİKKAT_EDİLMESİ_GEREKEN_NOKTALAR]', 'Bu noktalara dikkat edin.')

    ;
  }
}