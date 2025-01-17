import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/tarot_card.dart';

class TarotRepository {
  // Singleton pattern
  static final TarotRepository _instance = TarotRepository._internal();
  factory TarotRepository() => _instance;
  TarotRepository._internal();

  // Tüm kartları tutan liste
  List<TarotCard> _cards = [];

  // JSON'dan kartları yükle
  Future<void> loadCardsFromAsset() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/tarot_cards.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      _cards = (data['cards'] as List)
          .map((cardJson) => TarotCard.fromJson(cardJson))
          .toList();
    } catch (e) {
      throw TarotException('Kartlar yüklenirken hata: $e');
    }
  }

  // Tüm kartları getir
  List<TarotCard> getAllCards() => _cards;

  // Major Arcana kartları
  List<TarotCard> getMajorArcanaCards() =>
      _cards.where((card) => card.arcana == "Major Arcana").toList();

  // Minor Arcana kartları
  List<TarotCard> getMinorArcanaCards() =>
      _cards.where((card) => card.arcana == "Minor Arcana").toList();

  // Court kartları
  List<TarotCard> getCourtCards() => _cards.where((card) {
    final name = card.name.toLowerCase();
    return name.contains('page') ||
        name.contains('knight') ||
        name.contains('queen') ||
        name.contains('king');
  }).toList();

  // İsme göre kart getir
  TarotCard? getCardByName(String name) {
    try {
      return _cards.firstWhere(
              (card) => card.name.toLowerCase() == name.toLowerCase()
      );
    } catch (e) {
      return null;
    }
  }

  // Numaraya göre kart getir
  TarotCard? getCardByNumber(String number) {
    try {
      return _cards.firstWhere((card) => card.number == number);
    } catch (e) {
      return null;
    }
  }

  // Suit'e göre kartları getir
  List<TarotCard> getCardsBySuit(String suit) =>
      _cards.where((card) => card.suit.toLowerCase() == suit.toLowerCase()).toList();

  // Rastgele kart çek
  TarotCard drawRandomCard() {
    if (_cards.isEmpty) throw TarotException('Kart destesi boş');
    return _cards[Random().nextInt(_cards.length)];
  }

  // Belirli sayıda rastgele kart çek
  List<TarotCard> drawRandomCards(int count) {
    if (_cards.isEmpty) throw TarotException('Kart destesi boş');
    if (count > _cards.length) {
      throw TarotException('İstenen kart sayısı desteden fazla');
    }

    final List<TarotCard> tempDeck = List.from(_cards);
    final List<TarotCard> drawnCards = [];

    for (int i = 0; i < count; i++) {
      final index = Random().nextInt(tempDeck.length);
      drawnCards.add(tempDeck[index]);
      tempDeck.removeAt(index);
    }
    return drawnCards;
  }

  // Arama yap
  List<TarotCard> searchCards(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _cards.where((card) {
      return card.name.toLowerCase().contains(lowercaseQuery) ||
          card.keywords.any((k) => k.toLowerCase().contains(lowercaseQuery)) ||
          card.meanings.light.any((m) => m.toLowerCase().contains(lowercaseQuery)) ||
          card.meanings.shadow.any((m) => m.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Desteyi karıştır
  void shuffleDeck() => _cards.shuffle();

  // Desteyi sırala
  void sortDeck() {
    _cards.sort((a, b) {
      if (a.arcana != b.arcana) return a.arcana.compareTo(b.arcana);
      return int.tryParse(a.number) ?? 0.compareTo(int.tryParse(b.number) ?? 0);
    });
  }



  TarotCard singleCardReading() {
    return drawRandomCard();
  }

  // Üçlü Açılım (Geçmiş-Şimdi-Gelecek)
  Map<String, TarotCard> pastPresentFutureReading() {
    final cards = drawRandomCards(3);
    return {
      'Geçmiş': cards[0],
      'Şimdi': cards[1],
      'Gelecek': cards[2],
    };
  }

  // Problem-Neden-Çözüm Açılımı
  Map<String, TarotCard> problemSolutionReading() {
    final cards = drawRandomCards(3);
    return {
      'Problem': cards[0],
      'Neden': cards[1],
      'Çözüm': cards[2],
    };
  }

  // Beş Kart Yol Ayrımı Açılımı
  Map<String, TarotCard> fiveCardPathReading() {
    final cards = drawRandomCards(5);
    return {
      'Mevcut Durum': cards[0],
      'Engeller': cards[1],
      'En İyi Sonuç': cards[2],
      'Temel': cards[3],
      'Potansiyel': cards[4],
    };
  }

  // Yedi Kart İlişki Açılımı
  Map<String, TarotCard> relationshipReading() {
    final cards = drawRandomCards(7);
    return {
      'Siz': cards[0],
      'Partner': cards[1],
      'İlişki': cards[2],
      'Güçlü Yönler': cards[3],
      'Zayıf Yönler': cards[4],
      'Yapılması Gerekenler': cards[5],
      'Sonuç': cards[6],
    };
  }

  // Celtic Cross Açılımı
  Map<String, TarotCard> celticCrossReading() {
    final cards = drawRandomCards(10);
    return {
      'Mevcut Durum': cards[0],
      'Engel': cards[1],
      'Bilinçaltı': cards[2],
      'Geçmiş': cards[3],
      'Olası Gelecek': cards[4],
      'Yakın Gelecek': cards[5],
      'Kişisel Duruş': cards[6],
      'Çevre Etkileri': cards[7],
      'Umutlar/Korkular': cards[8],
      'Nihai Sonuç': cards[9],
    };
  }

  // Yıllık Açılım
  Map<String, TarotCard> yearlyReading() {
    final cards = drawRandomCards(12);
    Map<String, TarotCard> reading = {};
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];

    for (int i = 0; i < 12; i++) {
      reading[months[i]] = cards[i];
    }
    return reading;
  }

  // Kategorisel fal bakma metodu
  Map<String, TarotCard> categoryReading(String category, int cardCount) {
    final cards = drawRandomCards(cardCount);
    Map<String, TarotCard> reading = {};

    switch(category.toLowerCase()) {
      case 'aşk':
        reading = {
          'Geçmiş': cards[0],
          'Şimdi': cards[1],
          'Gelecek': cards[2],
        };
        break;
      case 'kariyer':
        reading = {
          'Mevcut İş': cards[0],
          'Fırsatlar': cards[1],
          'Engeller': cards[2],
        };
        break;
      case 'para':
        reading = {
          'Finansal Durum': cards[0],
          'Potansiyel': cards[1],
          'Tavsiye': cards[2],
        };
        break;
      default:
        reading = {
          'Genel Durum': cards[0],
          'Engeller': cards[1],
          'Tavsiye': cards[2],
        };
    }
    return reading;
  }




  // Deste boyutu
  int get deckSize => _cards.length;
}

// Özel hata sınıfı
class TarotException implements Exception {
  final String message;
  TarotException(this.message);

  @override
  String toString() => 'TarotException: $message';
}

