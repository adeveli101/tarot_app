// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/models/tarot_card.dart';

class TarotRepository {
  static final TarotRepository _instance = TarotRepository._internal();
  factory TarotRepository({String locale = 'en'}) => _instance..setLocale(locale); // Varsayılan: İngilizce
  TarotRepository._internal();

  List<TarotCard> _cards = [];
  String _currentLocale = 'en'; // Varsayılan locale
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Kartları dosyadan yükleme
  void setLocale(String locale) {
    if (locale == 'tr' || locale == 'en') {
      _currentLocale = locale;
      loadCards(); // Locale değiştiğinde kartları yeniden yükle
    } else {
      throw TarotException('Desteklenmeyen dil: $locale');
    }
  }

  // Kartları dosyadan yükleme (locale'e göre)
  Future<void> loadCards() async {
    try {
      final String jsonFile = 'assets/tarot_cards_$_currentLocale.json';
      final String jsonString = await rootBundle.loadString(jsonFile);
      final Map<String, dynamic> data = json.decode(jsonString);
      _cards = (data['cards'] as List).map((cardJson) => TarotCard.fromJson(cardJson)).toList();
    } catch (e) {
      throw TarotException('Kartlar yüklenemedi: $e');
    }
  }

  // Anonim giriş
  Future<void> signInAnonymously() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
        await _setupNotifications();
      }
    } catch (e) {
      throw TarotException('Anonim giriş başarısız: $e');
    }
  }

  // Bildirim sistemi kurulumu
  Future<void> _setupNotifications() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await _messaging.getToken();
        if (token != null && _auth.currentUser != null) {
          await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
            'fcmToken': token,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)); // SetOptions burada doğru şekilde import edildi
        }
      }
    } catch (e) {
      throw TarotException('Bildirim kurulumu başarısız: $e');
    }
  }

  // CRUD Operasyonları için Firestore ile Fal Kaydetme
  Future<void> saveReading(Map<String, TarotCard> reading, String spreadType) async {
    final user = _auth.currentUser;
    if (user == null) throw TarotException('Kullanıcı giriş yapmamış');

    try {
      final readingData = reading.map((key, value) => MapEntry(key, {
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
        'spreadType': spreadType,
        'reading': readingData,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw TarotException('Fal kaydetme başarısız: $e');
    }
  }

  // Kullanıcının geçmiş fallarını okuma
  Future<List<Map<String, dynamic>>> getUserReadings() async {
    final user = _auth.currentUser;
    if (user == null) throw TarotException('Kullanıcı giriş yapmamış');

    try {
      final snapshot = await _firestore
          .collection('readings')
          .doc(user.uid)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw TarotException('Geçmiş fallar alınamadı: $e');
    }
  }

  // Belirli bir falı güncelleme (örneğin, not ekleme)
  Future<void> updateReading(String readingId, Map<String, dynamic> updates) async {
    final user = _auth.currentUser;
    if (user == null) throw TarotException('Kullanıcı giriş yapmamış');

    try {
      await _firestore
          .collection('readings')
          .doc(user.uid)
          .collection('history')
          .doc(readingId)
          .update(updates);
    } catch (e) {
      throw TarotException('Fal güncelleme başarısız: $e');
    }
  }

  // Belirli bir falı silme
  Future<void> deleteReading(String readingId) async {
    final user = _auth.currentUser;
    if (user == null) throw TarotException('Kullanıcı giriş yapmamış');

    try {
      await _firestore
          .collection('readings')
          .doc(user.uid)
          .collection('history')
          .doc(readingId)
          .delete();
    } catch (e) {
      throw TarotException('Fal silme başarısız: $e');
    }
  }

  // Mevcut kart operasyonları
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

  // Fal açılım metodları (CRUD ile entegre)
  TarotCard singleCardReading() {
    final card = drawRandomCard();
    saveReading({'Card': card}, 'singleCard');
    return card;
  }

  Map<String, TarotCard> pastPresentFutureReading() {
    final cards = drawRandomCards(3);
    final reading = {'Past': cards[0], 'Present': cards[1], 'Future': cards[2]};
    saveReading(reading, 'pastPresentFuture');
    return reading;
  }

  Map<String, TarotCard> problemSolutionReading() {
    final cards = drawRandomCards(3);
    final reading = {'Problem': cards[0], 'Reason': cards[1], 'Solution': cards[2]};
    saveReading(reading, 'problemSolution');
    return reading;
  }

  Map<String, TarotCard> fiveCardPathReading() {
    final cards = drawRandomCards(5);
    final reading = {
      'Current Situation': cards[0],
      'Obstacles': cards[1],
      'Best Outcome': cards[2],
      'Foundation': cards[3],
      'Potential': cards[4],
    };
    saveReading(reading, 'fiveCardPath');
    return reading;
  }

  Map<String, TarotCard> relationshipReading() {
    final cards = drawRandomCards(7);
    final reading = {
      'You': cards[0],
      'Partner': cards[1],
      'Relationship': cards[2],
      'Strengths': cards[3],
      'Weaknesses': cards[4],
      'Actions Needed': cards[5],
      'Outcome': cards[6],
    };
    saveReading(reading, 'relationship');
    return reading;
  }

  Map<String, TarotCard> celticCrossReading() {
    final cards = drawRandomCards(10);
    final reading = {
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
    saveReading(reading, 'celticCross');
    return reading;
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
    saveReading(reading, 'yearly');
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
    saveReading(reading, 'category_$category');
    return reading;
  }

  Map<String, TarotCard> mindBodySpiritReading() {
    final cards = drawRandomCards(3);
    final reading = {'Mind': cards[0], 'Body': cards[1], 'Spirit': cards[2]};
    saveReading(reading, 'mindBodySpirit');
    return reading;
  }

  Map<String, TarotCard> astroLogicalCrossReading() {
    final cards = drawRandomCards(5);
    final reading = {
      'Identity': cards[0],
      'Emotional State': cards[1],
      'External Influences': cards[2],
      'Challenges': cards[3],
      'Destiny': cards[4],
    };
    saveReading(reading, 'astroLogicalCross');
    return reading;
  }

  Map<String, TarotCard> brokenHeartReading() {
    final cards = drawRandomCards(5);
    final reading = {
      'Source of Pain': cards[0],
      'Emotional Wounds': cards[1],
      'Inner Conflict': cards[2],
      'Healing Process': cards[3],
      'New Beginning': cards[4],
    };
    saveReading(reading, 'brokenHeart');
    return reading;
  }

  Map<String, TarotCard> dreamInterpretationReading() {
    final cards = drawRandomCards(3);
    final reading = {'Dream Symbol': cards[0], 'Emotional Response': cards[1], 'Message': cards[2]};
    saveReading(reading, 'dreamInterpretation');
    return reading;
  }

  Map<String, TarotCard> horseshoeSpread() {
    final cards = drawRandomCards(7);
    final reading = {
      'Past': cards[0],
      'Present': cards[1],
      'Future': cards[2],
      'Goals/Fears': cards[3],
      'External Influences': cards[4],
      'Advice': cards[5],
      'Outcome': cards[6],
    };
    saveReading(reading, 'horseshoe');
    return reading;
  }

  Map<String, TarotCard> careerPathSpread() {
    final cards = drawRandomCards(5);
    final reading = {
      'Current Situation': cards[0],
      'Obstacles': cards[1],
      'Opportunities': cards[2],
      'Strengths': cards[3],
      'Outcome': cards[4],
    };
    saveReading(reading, 'careerPath');
    return reading;
  }

  Map<String, TarotCard> fullMoonSpread() {
    final cards = drawRandomCards(6);
    final reading = {
      'Past Cycle': cards[0],
      'Current Energy': cards[1],
      'Subconscious Message': cards[2],
      'Obstacles': cards[3],
      'Recommended Action': cards[4],
      'Resulting Energy': cards[5],
    };
    saveReading(reading, 'fullMoon');
    return reading;
  }

  int get deckSize => _cards.length;
}

class TarotException implements Exception {
  final String message;
  TarotException(this.message);

  @override
  String toString() => 'TarotException: $message';
}