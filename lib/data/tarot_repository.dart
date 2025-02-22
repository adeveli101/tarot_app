// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:tarot_fal/generated/l10n.dart';
import '../models/tarot_card.dart';

class TarotRepository {
  static final TarotRepository _instance = TarotRepository._internal();
  factory TarotRepository() => _instance;
  TarotRepository._internal();

  List<TarotCard> _cards = [];

  Future<void> loadCardsFromAsset() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/tarot_cards.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      _cards = (data['cards'] as List).map((cardJson) => TarotCard.fromJson(cardJson)).toList();
    } catch (e) {
      throw TarotException(e.toString());
    }
  }

  List<TarotCard> getAllCards() => _cards;

  List<TarotCard> getMajorArcanaCards() => _cards.where((card) => card.arcana == "Major Arcana").toList();

  List<TarotCard> getMinorArcanaCards() => _cards.where((card) => card.arcana == "Minor Arcana").toList();

  List<TarotCard> getCourtCards() => _cards.where((card) {
    final name = card.name.toLowerCase();
    return name.contains('page') || name.contains('knight') || name.contains('queen') || name.contains('king');
  }).toList();

  TarotCard? getCardByName(String name) {
    try {
      return _cards.firstWhere((card) => card.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  TarotCard? getCardByNumber(String number) {
    try {
      return _cards.firstWhere((card) => card.number == number);
    } catch (e) {
      return null;
    }
  }

  List<TarotCard> getCardsBySuit(String suit) =>
      _cards.where((card) => card.suit.toLowerCase() == suit.toLowerCase()).toList();

  TarotCard drawRandomCard() {
    if (_cards.isEmpty) throw TarotException('deck_empty');
    return _cards[Random().nextInt(_cards.length)];
  }

  List<TarotCard> drawRandomCards(int count) {
    if (_cards.isEmpty) throw TarotException('deck_empty');
    if (count > _cards.length) throw TarotException('too_many_cards');

    final List<TarotCard> tempDeck = List.from(_cards);
    final List<TarotCard> drawnCards = [];

    for (int i = 0; i < count; i++) {
      final index = Random().nextInt(tempDeck.length);
      drawnCards.add(tempDeck[index]);
      tempDeck.removeAt(index);
    }
    return drawnCards;
  }

  List<TarotCard> searchCards(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _cards.where((card) {
      return card.name.toLowerCase().contains(lowercaseQuery) ||
          card.keywords.any((k) => k.toLowerCase().contains(lowercaseQuery)) ||
          card.meanings.light.any((m) => m.toLowerCase().contains(lowercaseQuery)) ||
          card.meanings.shadow.any((m) => m.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  void shuffleDeck() => _cards.shuffle();

  void sortDeck() {
    _cards.sort((a, b) {
      if (a.arcana != b.arcana) return a.arcana.compareTo(b.arcana);
      return (int.tryParse(a.number) ?? 0).compareTo(int.tryParse(b.number) ?? 0);
    });
  }

  TarotCard singleCardReading() => drawRandomCard();

  Map<String, TarotCard> pastPresentFutureReading() {
    final cards = drawRandomCards(3);
    return {'Past': cards[0], 'Present': cards[1], 'Future': cards[2]};
  }

  Map<String, TarotCard> problemSolutionReading() {
    final cards = drawRandomCards(3);
    return {'Problem': cards[0], 'Reason': cards[1], 'Solution': cards[2]};
  }

  Map<String, TarotCard> fiveCardPathReading() {
    final cards = drawRandomCards(5);
    return {
      'Current Situation': cards[0],
      'Obstacles': cards[1],
      'Best Outcome': cards[2],
      'Foundation': cards[3],
      'Potential': cards[4],
    };
  }

  Map<String, TarotCard> relationshipReading() {
    final cards = drawRandomCards(7);
    return {
      'You': cards[0],
      'Partner': cards[1],
      'Relationship': cards[2],
      'Strengths': cards[3],
      'Weaknesses': cards[4],
      'Actions Needed': cards[5],
      'Outcome': cards[6],
    };
  }

  Map<String, TarotCard> celticCrossReading() {
    final cards = drawRandomCards(10);
    return {
      'Current Situation': cards[0],
      'Challenge': cards[1],
      'Subconscious': cards[2],
      'Past': cards[3],
      'Possible Future': cards[4],
      'Near Future': cards[5],
      'Personal Stance': cards[6],
      'External Influences': cards[7],
      'Hopes/Fears': cards[8],
      'Final Outcome': cards[9],
    };
  }

  Map<String, TarotCard> yearlyReading() {
    final cards = drawRandomCards(12);
    Map<String, TarotCard> reading = {};
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    for (int i = 0; i < 12; i++) {
      reading[months[i]] = cards[i];
    }
    return reading;
  }

  Map<String, TarotCard> categoryReading(String category, int cardCount) {
    final cards = drawRandomCards(cardCount);
    Map<String, TarotCard> reading = {};
    switch (category.toLowerCase()) {
      case 'love':
        reading = {'Past': cards[0], 'Present': cards[1], 'Future': cards[2]};
        break;
      case 'career':
        reading = {'Current Job': cards[0], 'Opportunities': cards[1], 'Obstacles': cards[2]};
        break;
      case 'money':
        reading = {'Financial Situation': cards[0], 'Potential': cards[1], 'Advice': cards[2]};
        break;
      default:
        reading = {'General Situation': cards[0], 'Obstacles': cards[1], 'Advice': cards[2]};
    }
    return reading;
  }

  Map<String, TarotCard> mindBodySpiritReading() {
    final cards = drawRandomCards(3);
    return {'Mind': cards[0], 'Body': cards[1], 'Spirit': cards[2]};
  }

  Map<String, TarotCard> astroLogicalCrossReading() {
    final cards = drawRandomCards(5);
    return {
      'Identity': cards[0],
      'Emotional State': cards[1],
      'External Influences': cards[2],
      'Challenges': cards[3],
      'Destiny': cards[4],
    };
  }

  Map<String, TarotCard> brokenHeartReading() {
    final cards = drawRandomCards(5);
    return {
      'Source of Pain': cards[0],
      'Emotional Wounds': cards[1],
      'Inner Conflict': cards[2],
      'Healing Process': cards[3],
      'New Beginning': cards[4],
    };
  }

  Map<String, TarotCard> dreamInterpretationReading() {
    final cards = drawRandomCards(3);
    return {'Dream Symbol': cards[0], 'Emotional Response': cards[1], 'Message': cards[2]};
  }

  Map<String, TarotCard> horseshoeSpread() {
    final cards = drawRandomCards(7);
    return {
      'Past': cards[0],
      'Present': cards[1],
      'Future': cards[2],
      'Goals/Fears': cards[3],
      'External Influences': cards[4],
      'Advice': cards[5],
      'Outcome': cards[6],
    };
  }

  Map<String, TarotCard> careerPathSpread() {
    final cards = drawRandomCards(5);
    return {
      'Current Situation': cards[0],
      'Obstacles': cards[1],
      'Opportunities': cards[2],
      'Strengths': cards[3],
      'Outcome': cards[4],
    };
  }

  Map<String, TarotCard> fullMoonSpread() {
    final cards = drawRandomCards(6);
    return {
      'Past Cycle': cards[0],
      'Current Energy': cards[1],
      'Subconscious Message': cards[2],
      'Obstacles': cards[3],
      'Recommended Action': cards[4],
      'Resulting Energy': cards[5],
    };
  }

  int get deckSize => _cards.length;
}

class TarotException implements Exception {
  final String message;
  TarotException(this.message);

  @override
  String toString() => 'TarotException: $message';
}