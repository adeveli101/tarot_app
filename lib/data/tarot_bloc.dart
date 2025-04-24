// lib/data/tarot_bloc.dart
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:convert'; // JSON encoding için
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // kDebugMode için
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarot_fal/data/tarot_repository.dart';
import 'package:tarot_fal/services/gemini_service.dart'; // GeminiService importunu kontrol edin
import 'package:tarot_fal/models/tarot_card.dart';
import 'package:tarot_fal/data/user_data_manager.dart';
// Güncellenmiş State/Event dosyasını import ediyoruz
import 'package:tarot_fal/data/tarot_event_state.dart';

import '../services/notification_service.dart';

class TarotBloc extends Bloc<TarotEvent, TarotState> {
  final TarotRepository repository;
  final GeminiService geminiService;
  final String locale;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserDataManager _userDataManager = UserDataManager();
  SpreadType? _currentSpreadType;

  // --- Constants ---
  static const double dailyLoginTokens = 20.0;
  static const double initialTokens = 10.0;
  static const double firstTimeBonusTokens = 50.0;

  // --- Getters ---
  UserDataManager get userDataManager => _userDataManager;
  SpreadType? get currentSpreadType => _currentSpreadType;
  String? get userId => _auth.currentUser?.uid;

  TarotBloc({
    required this.repository,
    required this.geminiService,
    required this.locale,
  }) : super(const TarotInitial( // Başlangıç state'i güncellendi
    userTokens: 0.0,
    isDailyTokenAvailable: false,
    nextDailyTokenTime: null,
  )) {
    // Kullanıcı ve verileri yükle (ilk açılışta)
    _initializeUserAndLoadData();

    // --- Event Handlers Kayıtları ---
    on<LoadTarotCards>(_onLoadTarotCards);
    on<ShuffleDeck>(_onShuffleDeck);
    on<RedeemCoupon>(_onRedeemCoupon);
    on<UpdateLastCategory>(_onUpdateLastCategory);
    on<UpdateUserInfo>(_onUpdateUserInfo);

    // YENİ: Günlük Token Talep Event Handler
    on<ClaimDailyToken>(_onClaimDailyToken);

    // Okuma (Draw) Event Handlers
    // <<< DEĞİŞİKLİK: Tüm Draw event handler'ları burada kayıtlı kalacak >>>
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

  // ===========================================================================
  // --- Kullanıcı Başlatma, Veri Yükleme ve Bonus/Günlük Token Durumu Belirleme ---
  // ===========================================================================
  // Bu kısımlar önceki cevapta olduğu gibi kalır, değişiklik yok.
  Future<void> _initializeUserAndLoadData() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        if (kDebugMode) { print("TarotBloc: Oturum açmış kullanıcı yok, anonim oturum deneniyor..."); }
        final prefs = await SharedPreferences.getInstance();
        final bool hasExistingData = prefs.containsKey(UserDataManager.tokensKey);

        await repository.signInAnonymously();
        currentUser = _auth.currentUser;

        if (!hasExistingData && currentUser != null) {
          if (kDebugMode) { print("TarotBloc: Yeni anonim kullanıcı oluşturuldu: ${currentUser.uid}. Başlangıç verileri ayarlanıyor..."); }
          await _setInitialUserData();
        } else if (currentUser != null) {
          if (kDebugMode) { print("TarotBloc: Anonim oturum açıldı (muhtemelen eski kullanıcı): ${currentUser.uid}"); }
        }
      } else {
        if (kDebugMode) { print("TarotBloc: Mevcut kullanıcı oturumu: ${currentUser.uid}"); }
      }

      if (currentUser != null) {
        await _loadUserDataAndCheckRewards();
      } else {
        throw Exception("Kullanıcı oturumu başlatılamadı.");
      }
    } catch (e) {
      if (kDebugMode) { print("TarotBloc: Kullanıcı başlatma/yükleme hatası: $e"); }
      emit(TarotError(
        "Kullanıcı başlatılamadı: ${e.toString()}",
        userTokens: state.userTokens,
        isDailyTokenAvailable: false,
        nextDailyTokenTime: state.nextDailyTokenTime,
        userName: state.userName,
        userAge: state.userAge,
        userGender: state.userGender,
        userInfoCollected: state.userInfoCollected,
      ));
    }
  }

  Future<void> _setInitialUserData() async {
    try {
      await _userDataManager.saveTokens(initialTokens);
      await _userDataManager.savePremiumStatus(false);
      await _userDataManager.saveLastReset(0);
      await _userDataManager.saveUserInfoCollected(false);
      if (kDebugMode) { print("TarotBloc: Yeni kullanıcı için başlangıç verileri ayarlandı (Tokens: $initialTokens)."); }
    } catch (e) {
      if (kDebugMode) { print("TarotBloc: Başlangıç verileri ayarlanırken hata: $e"); }
    }
  }

  Future<void> _loadUserDataAndCheckRewards() async {
    if (kDebugMode) { print("TarotBloc: Kullanıcı verileri ve ödül durumu kontrol ediliyor..."); }
    try {
      final now = DateTime.now();
      final todayEpochDay = DateTime.utc(now.year, now.month, now.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
      final lastResetEpochDay = await _userDataManager.getLastReset();
      double currentTokens = await _userDataManager.getTokens();
      bool bonusNeedsSave = false;

      bool isAvailableToday;
      DateTime? nextClaimTime;

      if (lastResetEpochDay < todayEpochDay) {
        isAvailableToday = true;
        nextClaimTime = null;
        if (kDebugMode) { print("TarotBloc: Günlük token BU GÜN İÇİN alınabilir."); }
      } else {
        isAvailableToday = false;
        final tomorrowLocal = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
        nextClaimTime = tomorrowLocal;
        if (kDebugMode) { print("TarotBloc: Günlük token bugün zaten alınmış. Sonraki alınabilir zaman: $nextClaimTime (Yerel)"); }
      }

      final bool bonusAlreadyGiven = await _userDataManager.hasReceivedFirstTimeBonus();
      if (!bonusAlreadyGiven) {
        currentTokens += firstTimeBonusTokens;
        await _userDataManager.markFirstTimeBonusAsGiven();
        bonusNeedsSave = true;
        if (kDebugMode) { print("TarotBloc: İlk kullanım bonusu ($firstTimeBonusTokens token) OTOMATİK eklendi."); }
      }

      if (bonusNeedsSave) {
        await _userDataManager.saveTokens(currentTokens);
        if (kDebugMode) { print("TarotBloc: İlk bonus sonrası bakiye kaydedildi: $currentTokens"); }
      }

      final userName = await _userDataManager.getUserName();
      final userAge = await _userDataManager.getUserAge();
      final userGender = await _userDataManager.getUserGender();
      final userInfoCollected = await _userDataManager.getUserInfoCollected();

      emit(state.copyWith(
        userTokens: currentTokens,
        userName: userName,
        userAge: userAge,
        userGender: userGender,
        userInfoCollected: userInfoCollected,
        isDailyTokenAvailable: isAvailableToday,
        nextDailyTokenTime: nextClaimTime,
      ));

      if (kDebugMode) { print("TarotBloc: Kullanıcı verileri yüklendi. Günlük token alınabilir: $isAvailableToday. Tokens=$currentTokens"); }

    } catch (e) {
      if (kDebugMode) { print("TarotBloc: Kullanıcı verileri/ödül kontrolü sırasında hata: $e"); }
      emit(TarotError(
        "Kullanıcı verileri yüklenemedi: ${e.toString()}",
        userTokens: state.userTokens,
        isDailyTokenAvailable: false,
        nextDailyTokenTime: state.nextDailyTokenTime,
        userName: state.userName,
        userAge: state.userAge,
        userGender: state.userGender,
        userInfoCollected: state.userInfoCollected,
      ));
    }
  }

  // ===========================================================================
  // --- Yeni Event Handler: ClaimDailyToken ---
  // ===========================================================================
  // Bu kısımlar önceki cevapta olduğu gibi kalır, değişiklik yok.
  Future<void> _onClaimDailyToken(ClaimDailyToken event, Emitter<TarotState> emit) async {
    if (kDebugMode) { print("TarotBloc: ClaimDailyToken eventi alındı..."); }

    final stateBeforeLoading = state;

    if (!stateBeforeLoading.isDailyTokenAvailable) {
      if (kDebugMode) { print("TarotBloc: Token talep edilemez (state.isDailyTokenAvailable=false)."); }
      return;
    }
    final now = DateTime.now();
    final todayEpochDay = DateTime.utc(now.year, now.month, now.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
    final lastResetEpochDay = await _userDataManager.getLastReset();
    if (lastResetEpochDay >= todayEpochDay) {
      if (kDebugMode) { print("TarotBloc Hata: Token bugün zaten alınmış (double claim engellendi)."); }
      emit(stateBeforeLoading.copyWith(isDailyTokenAvailable: false));
      return;
    }

    emit(TarotLoading(
      userTokens: stateBeforeLoading.userTokens,
      isDailyTokenAvailable: false,
      nextDailyTokenTime: stateBeforeLoading.nextDailyTokenTime,
      lastSelectedCategory: stateBeforeLoading.lastSelectedCategory,
      userName: stateBeforeLoading.userName,
      userAge: stateBeforeLoading.userAge,
      userGender: stateBeforeLoading.userGender,
      userInfoCollected: stateBeforeLoading.userInfoCollected,
    ));

    try {
      final currentTokens = stateBeforeLoading.userTokens;
      final newTokens = currentTokens + dailyLoginTokens;
      await _userDataManager.saveTokens(newTokens);
      await _userDataManager.saveLastReset(todayEpochDay);
      final nextClaimTime = DateTime(now.year, now.month, now.day).add(const
      Duration(hours: 8));

      final successState = DailyTokenClaimSuccess(
        userTokens: newTokens,
        nextDailyTokenTime: nextClaimTime,
        lastSelectedCategory: stateBeforeLoading.lastSelectedCategory,
        userName: stateBeforeLoading.userName,
        userAge: stateBeforeLoading.userAge,
        userGender: stateBeforeLoading.userGender,
        userInfoCollected: stateBeforeLoading.userInfoCollected,
      );
      emit(successState);

      if (kDebugMode) {
        print("TarotBloc: Günlük token ($dailyLoginTokens) talep edildi. Yeni bakiye: $newTokens. Sonraki alınabilir: $nextClaimTime");
      }

      try {
        await NotificationService().scheduleDailyRewardNotification(
          
          scheduledTime: nextClaimTime,
          titleKey: 'dailyRewardNotificationTitle',
          bodyKey: 'dailyRewardNotificationBody',
        );
      } catch (e) {
        if (kDebugMode) {
          print("Bildirim planlama çağrısı sırasında hata (BLoC): $e");
        }
      }

    } catch (e) {
      if (kDebugMode) { print("TarotBloc: Token talep edilirken/kaydedilirken hata: $e"); }
      emit(TarotError(
        "Token alınırken bir hata oluştu: ${e.toString()}",
        userTokens: stateBeforeLoading.userTokens,
        isDailyTokenAvailable: true,
        nextDailyTokenTime: stateBeforeLoading.nextDailyTokenTime,
        lastSelectedCategory: stateBeforeLoading.lastSelectedCategory,
        userName: stateBeforeLoading.userName,
        userAge: stateBeforeLoading.userAge,
        userGender: stateBeforeLoading.userGender,
        userInfoCollected: stateBeforeLoading.userInfoCollected,
      ));
    }
  }

  // ===========================================================================
  // --- Kaynak Kontrolü ve Yönetimi (Mevcut, Geri Eklendi) ---
  // ===========================================================================
  // Bu kısımlar önceki cevapta olduğu gibi kalır, değişiklik yok.
  Future<bool> _checkCreditsAndTokenLimit(Emitter<TarotState> emit, SpreadType spreadType) async {
    final tokens = state.userTokens;
    final cost = spreadType.costInCredits;

    if (tokens < cost) {
      if (kDebugMode) { print("TarotBloc: Yetersiz kredi. Gerekli: $cost, Mevcut: $tokens"); }
      emit(InsufficientResources(
        cost,
        userTokens: state.userTokens,
        isDailyTokenAvailable: state.isDailyTokenAvailable,
        nextDailyTokenTime: state.nextDailyTokenTime,
        lastSelectedCategory: state.lastSelectedCategory,
        userName: state.userName,
        userAge: state.userAge,
        userGender: state.userGender,
        userInfoCollected: state.userInfoCollected,
      ));
      return false;
    }
    return true;
  }

  Future<void> _deductTokens(double cost) async {
    if (cost <= 0) return;
    final currentTokens = await _userDataManager.getTokens();
    if (currentTokens >= cost) {
      final newTokens = currentTokens - cost;
      await _userDataManager.saveTokens(newTokens);
      if (kDebugMode) { print("TarotBloc: $cost kredi düşüldü. Kalan: $newTokens"); }
    } else {
      if (kDebugMode) { print("TarotBloc Hata: Token düşülemedi - yetersiz bakiye (beklenmedik durum)."); }
      emit(TarotError(
        "Kredi düşme hatası (yetersiz bakiye).",
        userTokens: currentTokens,
        isDailyTokenAvailable: state.isDailyTokenAvailable,
        nextDailyTokenTime: state.nextDailyTokenTime,
        lastSelectedCategory: state.lastSelectedCategory,
        userName: state.userName, userAge: state.userAge, userGender: state.userGender, userInfoCollected: state.userInfoCollected,
      ));
      throw Exception("Token düşülemedi.");
    }
  }

  // ===========================================================================
  // --- Firestore Kayıt İşlemi (Mevcut, Geri Eklendi) ---
  // ===========================================================================
  // Bu kısımlar önceki cevapta olduğu gibi kalır, değişiklik yok.
  Future<void> _saveReadingToFirestore(String yorum, SpreadType spreadType, Map<String, TarotCard> spread) async {
    final user = _auth.currentUser;
    if (user == null || yorum.isEmpty) {
      if (kDebugMode) { print("TarotBloc Uyarı: Kullanıcı null veya yorum boş olduğu için Firestore'a kaydedilmedi."); }
      return;
    }

    try {
      final sanitizedSpread = spread.map((key, value) => MapEntry(
          key,
          {'name': value.name, 'img': value.img}));

      await _firestore
          .collection('readings')
          .doc(user.uid)
          .collection('history')
          .add({
        'yorum': yorum,
        'spreadType': spreadType.name,
        'spread': sanitizedSpread,
        'timestamp': FieldValue.serverTimestamp(),
        'locale': locale,
        'userName': state.userName,
        'userAge': state.userAge,
        'userGender': state.userGender,
        'pinned': false,
      });

      if (kDebugMode) { print("TarotBloc: Okuma Firestore'a başarıyla kaydedildi (UID: ${user.uid})."); }

    } catch (e) {
      if (kDebugMode) { print("TarotBloc Hata: Okuma Firestore'a kaydedilemedi: ${e.toString()}"); }
      throw Exception("Firestore kaydetme hatası: $e");
    }
  }

  // ===========================================================================
  // --- Diğer Event Handler'lar (State Kopyalama Güncellemeleri) ---
  // ===========================================================================
  // Bu kısımlar önceki cevapta olduğu gibi kalır, değişiklik yok.
  Future<void> _onLoadTarotCards(LoadTarotCards event, Emitter<TarotState> emit) async {
    emit(TarotLoading(
      userTokens: state.userTokens,
      isDailyTokenAvailable: state.isDailyTokenAvailable,
      nextDailyTokenTime: state.nextDailyTokenTime,
      lastSelectedCategory: state.lastSelectedCategory,
      userName: state.userName, userAge: state.userAge, userGender: state.userGender, userInfoCollected: state.userInfoCollected,
    ));
    try {
      await repository.loadCards();
      final cards = repository.getAllCards();
      if (cards.isEmpty) throw Exception("Kart destesi yüklenemedi veya boş.");
      emit(TarotCardsLoaded(
        cards,
        userTokens: state.userTokens,
        isDailyTokenAvailable: state.isDailyTokenAvailable,
        nextDailyTokenTime: state.nextDailyTokenTime,
        lastSelectedCategory: state.lastSelectedCategory,
        userName: state.userName, userAge: state.userAge, userGender: state.userGender, userInfoCollected: state.userInfoCollected,
      ));
    } catch (e) {
      emit(TarotError(
        "Kartlar yüklenirken hata: ${e.toString()}",
        userTokens: state.userTokens,
        isDailyTokenAvailable: state.isDailyTokenAvailable,
        nextDailyTokenTime: state.nextDailyTokenTime,
        lastSelectedCategory: state.lastSelectedCategory,
        userName: state.userName, userAge: state.userAge, userGender: state.userGender, userInfoCollected: state.userInfoCollected,
      ));
    }
  }

  void _onShuffleDeck(ShuffleDeck event, Emitter<TarotState> emit) {
    try {
      repository.shuffleDeck();
      if (kDebugMode) { print("TarotBloc: Deste karıştırıldı."); }
    } catch (e) {
      emit(TarotError(
        "Deste karıştırılamadı: ${e.toString()}",
        userTokens: state.userTokens,
        isDailyTokenAvailable: state.isDailyTokenAvailable,
        nextDailyTokenTime: state.nextDailyTokenTime,
        lastSelectedCategory: state.lastSelectedCategory,
        userName: state.userName, userAge: state.userAge, userGender: state.userGender, userInfoCollected: state.userInfoCollected,
      ));
    }
  }

  void _onUpdateLastCategory(UpdateLastCategory event, Emitter<TarotState> emit) {
    emit(state.copyWith(lastSelectedCategory: event.category));
    if (kDebugMode) { print("TarotBloc: Son kategori güncellendi: ${event.category}"); }
  }

  Future<void> _onUpdateUserInfo(UpdateUserInfo event, Emitter<TarotState> emit) async {
    try {
      await _userDataManager.saveUserName(event.name);
      await _userDataManager.saveUserAge(event.age);
      await _userDataManager.saveUserGender(event.gender);
      await _userDataManager.saveUserInfoCollected(true);
      emit(state.copyWith(
        userName: event.name,
        userAge: event.age,
        userGender: event.gender,
        userInfoCollected: true,
      ));
      if (kDebugMode) { print("TarotBloc: Kullanıcı bilgileri güncellendi."); }
    } catch (e) {
      emit(TarotError(
        "Kullanıcı bilgileri kaydedilemedi: ${e.toString()}",
        userTokens: state.userTokens,
        isDailyTokenAvailable: state.isDailyTokenAvailable,
        nextDailyTokenTime: state.nextDailyTokenTime,
        lastSelectedCategory: state.lastSelectedCategory,
        userName: state.userName, userAge: state.userAge, userGender: state.userGender, userInfoCollected: state.userInfoCollected,
      ));
    }
  }

  Future<void> _onRedeemCoupon(RedeemCoupon event, Emitter<TarotState> emit) async {
    emit(TarotLoading(
      userTokens: state.userTokens,
      isDailyTokenAvailable: state.isDailyTokenAvailable,
      nextDailyTokenTime: state.nextDailyTokenTime,
      lastSelectedCategory: state.lastSelectedCategory,
      userName: state.userName, userAge: state.userAge, userGender: state.userGender, userInfoCollected: state.userInfoCollected,
    ));
    try {
      final couponCode = event.couponCode.trim().toUpperCase();
      if (couponCode.isEmpty) {
        emit(CouponInvalid("Kupon kodu boş olamaz.", userTokens: state.userTokens, isDailyTokenAvailable: state.isDailyTokenAvailable, nextDailyTokenTime: state.nextDailyTokenTime, lastSelectedCategory: state.lastSelectedCategory, userName: state.userName, userAge: state.userAge, userGender: state.userGender, userInfoCollected: state.userInfoCollected,)); return;
      }
      final alreadyUsed = await _userDataManager.isCouponUsed(couponCode);
      if (alreadyUsed) {
        emit(CouponInvalid("Bu kupon kodu zaten kullanılmış.", userTokens: state.userTokens, isDailyTokenAvailable: state.isDailyTokenAvailable, nextDailyTokenTime: state.nextDailyTokenTime, lastSelectedCategory: state.lastSelectedCategory, userName: state.userName, userAge: state.userAge, userGender: state.userGender, userInfoCollected: state.userInfoCollected,)); return;
      }
      final Map<String, Map<String, dynamic>> validCoupons = { 'CREDITS': {'type': 'credits', 'value': 1000.0},
        'FREE_READING': {'type': 'credits', 'value': 10.0},
        'WELCOME10': {'type': 'credits', 'value': 10.0},
        'TAROT50': {'type': 'credits', 'value': 50.0},
        'FIRSTFREE': {'type': 'credits', 'value': 25.0},
        'LOYALTY100': {'type': 'credits', 'value': 1000.0}, };

      if (!validCoupons.containsKey(couponCode)) {
        emit(CouponInvalid("Geçersiz kupon kodu.", userTokens: state.userTokens, isDailyTokenAvailable: state.isDailyTokenAvailable, nextDailyTokenTime: state.nextDailyTokenTime, lastSelectedCategory: state.lastSelectedCategory, userName: state.userName, userAge: state.userAge, userGender: state.userGender, userInfoCollected: state.userInfoCollected,)); return;
      }
      final coupon = validCoupons[couponCode]!;
      final couponType = coupon['type'] as String?;
      final couponValue = coupon['value'];
      if (couponType == 'credits' && couponValue is num && couponValue > 0) {
        final creditsToAdd = couponValue.toDouble();
        final currentTokens = await _userDataManager.getTokens();
        final newTokens = currentTokens + creditsToAdd;
        await _userDataManager.saveTokens(newTokens);
        await _userDataManager.markCouponAsUsed(couponCode);
        emit(CouponRedeemed(
          "${creditsToAdd.toStringAsFixed(0)} kredi eklendi!",
          userTokens: newTokens,
          isDailyTokenAvailable: state.isDailyTokenAvailable,
          nextDailyTokenTime: state.nextDailyTokenTime,
          lastSelectedCategory: state.lastSelectedCategory,
          userName: state.userName, userAge: state.userAge, userGender: state.userGender, userInfoCollected: state.userInfoCollected,
        ));
        if (kDebugMode) { print("TarotBloc: Kupon '$couponCode' kullanıldı. $creditsToAdd kredi eklendi. Yeni bakiye: $newTokens"); }
      } else {
        emit(CouponInvalid("Desteklenmeyen kupon tipi.", userTokens: state.userTokens, isDailyTokenAvailable: state.isDailyTokenAvailable, nextDailyTokenTime: state.nextDailyTokenTime, lastSelectedCategory: state.lastSelectedCategory, userName: state.userName, userAge: state.userAge, userGender: state.userGender, userInfoCollected: state.userInfoCollected,));
      }
    } catch (e) {
      if (kDebugMode) { print("TarotBloc Kupon işleme hatası: $e"); }
      emit(CouponInvalid("Kupon kullanılırken bir hata oluştu.", userTokens: state.userTokens, isDailyTokenAvailable: state.isDailyTokenAvailable, nextDailyTokenTime: state.nextDailyTokenTime, lastSelectedCategory: state.lastSelectedCategory, userName: state.userName, userAge: state.userAge, userGender: state.userGender, userInfoCollected: state.userInfoCollected,));
    }
  }

  // ===========================================================================
  // --- Okuma Süreci Yönetimi (_handleReadingProcess - GÜNCELLENDİ) ---
  // ===========================================================================

  /// Genel okuma sürecini yöneten merkezi metot (GÜNCELLENDİ).
  /// Artık drawFunction yerine seçilen kartları doğrudan alır.
  Future<void> _handleReadingProcess(
      SpreadType spreadType,
      String category,
      List<TarotCard> selectedCards, // <<< DEĞİŞİKLİK: drawFunction yerine kart listesi
      String Function({
      required String category,
      required Map<String, TarotCard> spread, // spread Map'i hala gerekli
      String? customPrompt,
      required String locale,
      required TarotState currentState,
      }) promptGenerator,
      Emitter<TarotState> emit, {
        String? customPrompt,
      }) async {
    _currentSpreadType = spreadType;
    if (kDebugMode) { print("TarotBloc: Okuma süreci başlıyor - Spread: ${spreadType.name}, Category: $category"); }

    // 1. Kaynak Kontrolü (Aynı kalır)
    if (!await _checkCreditsAndTokenLimit(emit, spreadType)) {
      if (kDebugMode) { print("TarotBloc: Yetersiz kredi. Okuma iptal edildi."); }
      _currentSpreadType = null; // İptal durumunda da temizle
      return;
    }

    // 2. Yükleniyor State'i (Aynı kalır)
    emit(TarotLoading(
      userTokens: state.userTokens,
      isDailyTokenAvailable: state.isDailyTokenAvailable, // Aktar
      nextDailyTokenTime: state.nextDailyTokenTime,       // Aktar
      lastSelectedCategory: state.lastSelectedCategory,
      userName: state.userName, userAge: state.userAge, userGender: state.userGender, userInfoCollected: state.userInfoCollected,
    ));

    try {
      // <<< DEĞİŞİKLİK BAŞLANGICI >>>
      // 3. Kart Çekme İşlemi KALDIRILDI
      // final spread = drawFunction(); // <-- BU SATIR SİLİNDİ

      // YENİ: Gelen kart listesini açılım Map'ine dönüştür
      final Map<String, TarotCard> spread = _mapSelectedCardsToSpread(spreadType, selectedCards);

      // Dönüşüm başarısız olduysa veya kart sayısı eşleşmiyorsa hata ver
      if (spread.isEmpty && selectedCards.isNotEmpty) {
        throw Exception("Seçilen kartlar ($spreadType) açılıma dönüştürülemedi. Beklenen: ${spreadType.cardCount}, Gelen: ${selectedCards.length}");
      }
      // Kart sayısını tekrar kontrol et (opsiyonel ama güvenli)
      if (spread.length != spreadType.cardCount) {
        if (kDebugMode) print("Uyarı: Oluşturulan spread map boyutu (${spread.length}) beklenen kart sayısından (${spreadType.cardCount}) farklı.");
        // Duruma göre hata fırlatabilir veya devam edebilirsiniz.
        // throw Exception("Oluşturulan spread map boyutu (${spread.length}) beklenen kart sayısından (${spreadType.cardCount}) farklı.");
      }
      if (kDebugMode) { print("TarotBloc: Event'ten alınan kartlar açılıma dönüştürüldü (${spread.length} adet)."); }
      // <<< DEĞİŞİKLİK SONU >>>


      // 4. Gemini için Prompt Oluştur (Aynı kalır, artık dönüştürülmüş spread'i kullanır)
      final prompt = promptGenerator( category: category, spread: spread, customPrompt: customPrompt, locale: locale, currentState: state,);
      if (kDebugMode) { print("--- Gemini Prompt (${spreadType.name}) ---"); /* print(prompt); */ }

      // 5. Gemini'den Yorumu Al (Aynı kalır)
      final yorum = await geminiService.generateContent(prompt);
      if (yorum.isEmpty) throw Exception("Tarot yorumu alınamadı (boş cevap).");
      if (kDebugMode) { print("--- Gemini Response Alındı (${yorum.length} chars) ---"); }

      // 6. Token Düşme İşlemi (Aynı kalır)
      final cost = spreadType.costInCredits;
      await _deductTokens(cost); // Hata fırlatırsa catch yakalar

      // 7. Firestore'a Kaydet (Aynı kalır)
      await _saveReadingToFirestore(yorum, spreadType, spread); // Artık doğru spread'i kaydedecek

      // 8. Başarılı State'i Yayınla (Aynı kalır, artık doğru spread'i içerir)
      final updatedTokens = await _userDataManager.getTokens();
      emit(FalYorumuLoaded(
        yorum,
        tokenCount: 0, // Bu alan anlamsızsa 0 bırakın veya kaldırın
        cost: cost,
        spread: spread, // <-- Doğru (dönüştürülmüş) spread
        userTokens: updatedTokens,
        isDailyTokenAvailable: state.isDailyTokenAvailable, // Aktar
        nextDailyTokenTime: state.nextDailyTokenTime,       // Aktar
        lastSelectedCategory: category, // Kategori güncellenebilir
        userName: state.userName, userAge: state.userAge, userGender: state.userGender, userInfoCollected: state.userInfoCollected,
      ));
      if (kDebugMode) { print("TarotBloc: Okuma süreci başarıyla tamamlandı."); }

    } catch (e) {
      if (kDebugMode) { print("TarotBloc Okuma/Kaydetme Hatası (${spreadType.name}): $e"); }
      // Hata durumunda güncel token miktarını alarak hata state'i yayınla
      final errorTokens = await _userDataManager.getTokens();
      emit(TarotError(
        "Okuma veya kaydetme başarısız oldu: ${e.toString()}",
        userTokens: errorTokens, // Hata sonrası token durumu
        isDailyTokenAvailable: state.isDailyTokenAvailable, // Hata öncesi durumu koru
        nextDailyTokenTime: state.nextDailyTokenTime,       // Hata öncesi durumu koru
        lastSelectedCategory: state.lastSelectedCategory,
        userName: state.userName, userAge: state.userAge, userGender: state.userGender, userInfoCollected: state.userInfoCollected,
      ));
    } finally {
      _currentSpreadType = null; // Okuma bitince temizle
    }
  }

  // ===========================================================================
  // --- YENİ: _mapSelectedCardsToSpread Yardımcı Metodu ---
  // ===========================================================================

  /// Seçilen kart listesini, SpreadType'a göre pozisyon isimleri içeren bir Map'e dönüştürür.
  /// Repository'deki draw fonksiyonlarının döndürdüğü anahtarlarla eşleşmelidir.
  Map<String, TarotCard> _mapSelectedCardsToSpread(SpreadType spreadType, List<TarotCard> cards) {
    final Map<String, TarotCard> spread = {};
    final int expectedCount = spreadType.cardCount;

    // Gelen kart sayısı beklenenle eşleşmiyorsa hata yönetimi yap
    if (cards.length != expectedCount) {
      if (kDebugMode) {
        print("Hata: _mapSelectedCardsToSpread - Beklenen kart sayısı ($expectedCount) ile gelen kart sayısı (${cards.length}) eşleşmiyor. SpreadType: $spreadType");
      }
      // Boş map döndürerek hatayı _handleReadingProcess'te yakalamayı sağla
      return {};
    }

    // SpreadType'a göre pozisyon isimlerini repository'deki draw fonksiyonlarına göre ata
    switch (spreadType) {
      case SpreadType.singleCard:
      // Repository'deki singleCardReading Map anahtarı neyse onu kullanın.
      // Veya FalYorumuLoaded state'inde nasıl bir anahtar bekliyorsanız onu kullanın.
        spread['Card'] = cards[0]; // tarot_repository.dart'a göre 'Card' anahtarı kullanılıyor.
        break;
      case SpreadType.pastPresentFuture:
      // tarot_repository.dart -> pastPresentFutureReading() metodundaki anahtarlar:
        spread['Past'] = cards[0];
        spread['Present'] = cards[1];
        spread['Future'] = cards[2];
        break;
      case SpreadType.problemSolution:
      // tarot_repository.dart -> problemSolutionReading() metodundaki anahtarlar:
        spread['Problem'] = cards[0];
        spread['Reason'] = cards[1];
        spread['Solution'] = cards[2];
        break;
      case SpreadType.fiveCardPath:
      // tarot_repository.dart -> fiveCardPathReading() metodundaki anahtarlar:
        spread['Current Situation'] = cards[0];
        spread['Obstacles'] = cards[1];
        spread['Best Outcome'] = cards[2];
        spread['Foundation'] = cards[3];
        spread['Potential'] = cards[4];
        break;
      case SpreadType.relationshipSpread:
      // tarot_repository.dart -> relationshipReading() metodundaki anahtarlar:
        spread['You'] = cards[0];
        spread['Partner'] = cards[1];
        spread['Relationship'] = cards[2];
        spread['Strengths'] = cards[3];
        spread['Weaknesses'] = cards[4];
        spread['Actions Needed'] = cards[5];
        spread['Outcome'] = cards[6];
        break;
      case SpreadType.celticCross:
      // tarot_repository.dart -> celticCrossReading() metodundaki anahtarlar:
        spread['Current Situation'] = cards[0];
        spread['Challenge'] = cards[1];
        spread['Subconscious'] = cards[2];
        spread['Past'] = cards[3];
        spread['Possible Future'] = cards[4];
        spread['Near Future'] = cards[5];
        spread['Personal Stance'] = cards[6];
        spread['External Influences'] = cards[7];
        spread['Hopes/Fears'] = cards[8];
        spread['Final Outcome'] = cards[9];
        break;
      case SpreadType.yearlySpread:
      // tarot_repository.dart -> yearlyReading() metodundaki anahtarlar (ay isimleri):
      // Locale'e göre ay isimlerini almak daha doğru olur, ancak şimdilik İngilizce varsayalım.
        final months = [ 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' ];
        // Yıllık açılım 13 kart içeriyorsa (12 ay + 1 özet) kontrol ekleyin
        final count = (expectedCount == 13 && months.length == 12) ? 12 : expectedCount;
        for (int i = 0; i < count; i++) {
          if (i < months.length) {
            spread[months[i]] = cards[i];
          } else {
            spread['Month ${i + 1}'] = cards[i]; // Fallback
          }
        }
        // Eğer 13. kart varsa (Özet kartı)
        if (expectedCount == 13 && cards.length == 13) {
          // Repository'de özet için kullanılan anahtarı buraya yazın, örneğin:
          spread['Yearly Summary'] = cards[12]; // Veya 'Overall Theme' vb.
        }
        break;
      case SpreadType.mindBodySpirit:
      // tarot_repository.dart -> mindBodySpiritReading() metodundaki anahtarlar:
        spread['Mind'] = cards[0];
        spread['Body'] = cards[1];
        spread['Spirit'] = cards[2];
        break;
      case SpreadType.astroLogicalCross:
      // tarot_repository.dart -> astroLogicalCrossReading() metodundaki anahtarlar:
        spread['Identity'] = cards[0];
        spread['Emotional State'] = cards[1];
        spread['External Influences'] = cards[2];
        spread['Challenges'] = cards[3];
        spread['Destiny'] = cards[4];
        break;
      case SpreadType.brokenHeart:
      // tarot_repository.dart -> brokenHeartReading() metodundaki anahtarlar:
        spread['Source of Pain'] = cards[0];
        spread['Emotional Wounds'] = cards[1];
        spread['Inner Conflict'] = cards[2];
        spread['Healing Process'] = cards[3];
        spread['New Beginning'] = cards[4];
        break;
      case SpreadType.dreamInterpretation:
      // tarot_repository.dart -> dreamInterpretationReading() metodundaki anahtarlar:
        spread['Dream Symbol'] = cards[0];
        spread['Emotional Response'] = cards[1];
        spread['Message'] = cards[2];
        break;
      case SpreadType.horseshoeSpread:
      // tarot_repository.dart -> horseshoeSpread() metodundaki anahtarlar:
        spread['Past'] = cards[0];
        spread['Present'] = cards[1];
        spread['Future'] = cards[2];
        spread['Goals/Fears'] = cards[3];
        spread['External Influences'] = cards[4];
        spread['Advice'] = cards[5];
        spread['Outcome'] = cards[6];
        break;
      case SpreadType.careerPathSpread:
      // tarot_repository.dart -> careerPathSpread() metodundaki anahtarlar:
        spread['Current Situation'] = cards[0];
        spread['Obstacles'] = cards[1];
        spread['Opportunities'] = cards[2];
        spread['Strengths'] = cards[3];
        spread['Outcome'] = cards[4];
        break;
      case SpreadType.fullMoonSpread:
      // tarot_repository.dart -> fullMoonSpread() metodundaki anahtarlar:
        spread['Past Cycle'] = cards[0];
        spread['Current Energy'] = cards[1];
        spread['Subconscious Message'] = cards[2];
        spread['Obstacles'] = cards[3];
        spread['Recommended Action'] = cards[4];
        spread['Resulting Energy'] = cards[5];
        break;
      case SpreadType.categoryReading:
      // Kategori okuması için, repository'deki categoryReading fonksiyonu nasıl bir map döndürüyorsa
      // ona benzer bir yapı oluşturun. Örnek:
      // Not: Repository'deki categoryReading fonksiyonu şu anda basit bir 3 kartlı yapı kullanıyor.
      // Eğer dinamik kart sayısı ve pozisyonlar gerekirse repository'nin de güncellenmesi gerekebilir.
      // Şimdilik basit numaralandırma yapalım:
        for (int i = 0; i < cards.length; i++) {
          spread['Card ${i + 1}'] = cards[i]; // Örnek anahtar
        }
        break;
    // default: // Kapsanmayan durumlar için hata fırlat
    //   throw Exception("_mapSelectedCardsToSpread: SpreadType için kart eşleştirme tanımlanmadı: $spreadType");
    }

    return spread;
  }

  // ===========================================================================
  // --- Okuma (Draw) Event Handler'ları (Çağrılar - GÜNCELLENDİ) ---
  // ===========================================================================

  Future<void> _onDrawSingleCard(DrawSingleCard event, Emitter<TarotState> emit) async {
    await _handleReadingProcess(
      SpreadType.singleCard,
      state.lastSelectedCategory ?? 'general',
      event.selectedCards, // <-- Event'ten gelen kart listesini geçir
          ({ // Prompt generator lambda fonksiyonunu güncelle
        required String category,
        required Map<String, TarotCard> spread, // Artık Map alıyor
        String? customPrompt,
        required String locale,
        required TarotState currentState,
      }) {
        // Map'ten tek kartı çıkar
        if (spread.values.isEmpty) {
          throw Exception("Single card spread map is empty.");
        }
        final card = spread.values.first;
        // Tek kart için prompt oluşturucuya gönder
        return _generatePromptForSingleCard(
          category: category,
          card: card, // Tek kartı geçir
          customPrompt: customPrompt,
          locale: locale,
          currentState: currentState,
        );
      },
      emit,
      customPrompt: event.customPrompt,
    );
  }

  Future<void> _onDrawPastPresentFuture(DrawPastPresentFuture event, Emitter<TarotState> emit) async {
    await _handleReadingProcess(
      SpreadType.pastPresentFuture,
      state.lastSelectedCategory ?? 'general',
      event.selectedCards, // <-- Kartları event'ten al
      _generatePromptForPastPresentFuture, // Prompt generator aynı
      emit,
      customPrompt: event.customPrompt,
    );
  }

  Future<void> _onDrawProblemSolution(DrawProblemSolution event, Emitter<TarotState> emit) async {
    await _handleReadingProcess(
      SpreadType.problemSolution,
      state.lastSelectedCategory ?? 'general',
      event.selectedCards, // <-- Kartları event'ten al
      _generatePromptForProblemSolution,
      emit,
      customPrompt: event.customPrompt,
    );
  }

  Future<void> _onDrawFiveCardPath(DrawFiveCardPath event, Emitter<TarotState> emit) async {
    await _handleReadingProcess(
      SpreadType.fiveCardPath,
      state.lastSelectedCategory ?? 'career', // Kategoriye göre default
      event.selectedCards, // <-- Kartları event'ten al
      _generatePromptForFiveCardPath,
      emit,
      customPrompt: event.customPrompt,
    );
  }

  Future<void> _onDrawRelationshipSpread(DrawRelationshipSpread event, Emitter<TarotState> emit) async {
    await _handleReadingProcess(
      SpreadType.relationshipSpread,
      'love', // Kategori sabit
      event.selectedCards, // <-- Kartları event'ten al
      _generatePromptForRelationshipSpread,
      emit,
      customPrompt: event.customPrompt,
    );
  }

  Future<void> _onDrawCelticCross(DrawCelticCross event, Emitter<TarotState> emit) async {
    await _handleReadingProcess(
      SpreadType.celticCross,
      state.lastSelectedCategory ?? 'general',
      event.selectedCards, // <-- Kartları event'ten al
      _generatePromptForCelticCross,
      emit,
      customPrompt: event.customPrompt,
    );
  }

  Future<void> _onDrawYearlySpread(DrawYearlySpread event, Emitter<TarotState> emit) async {
    await _handleReadingProcess(
      SpreadType.yearlySpread,
      state.lastSelectedCategory ?? 'general',
      event.selectedCards, // <-- Kartları event'ten al
      _generatePromptForYearlySpread,
      emit,
      customPrompt: event.customPrompt,
    );
  }

  Future<void> _onDrawMindBodySpirit(DrawMindBodySpirit event, Emitter<TarotState> emit) async {
    await _handleReadingProcess(
      SpreadType.mindBodySpirit,
      state.lastSelectedCategory ?? 'spiritual', // Kategoriye göre default
      event.selectedCards, // <-- Kartları event'ten al
      _generatePromptForMindBodySpirit,
      emit,
      customPrompt: event.customPrompt,
    );
  }

  Future<void> _onDrawAstroLogicalCross(DrawAstroLogicalCross event, Emitter<TarotState> emit) async {
    await _handleReadingProcess(
      SpreadType.astroLogicalCross,
      state.lastSelectedCategory ?? 'spiritual', // Kategoriye göre default
      event.selectedCards, // <-- Kartları event'ten al
      _generatePromptForAstroLogicalCross,
      emit,
      customPrompt: event.customPrompt,
    );
  }

  Future<void> _onDrawBrokenHeart(DrawBrokenHeart event, Emitter<TarotState> emit) async {
    await _handleReadingProcess(
      SpreadType.brokenHeart,
      'love', // Kategori sabit
      event.selectedCards, // <-- Kartları event'ten al
      _generatePromptForBrokenHeart,
      emit,
      customPrompt: event.customPrompt,
    );
  }

  Future<void> _onDrawDreamInterpretation(DrawDreamInterpretation event, Emitter<TarotState> emit) async {
    await _handleReadingProcess(
      SpreadType.dreamInterpretation,
      state.lastSelectedCategory ?? 'spiritual', // Kategoriye göre default
      event.selectedCards, // <-- Kartları event'ten al
      _generatePromptForDreamInterpretation,
      emit,
      customPrompt: event.customPrompt,
    );
  }

  Future<void> _onDrawHorseshoeSpread(DrawHorseshoeSpread event, Emitter<TarotState> emit) async {
    await _handleReadingProcess(
      SpreadType.horseshoeSpread,
      state.lastSelectedCategory ?? 'general',
      event.selectedCards, // <-- Kartları event'ten al
      _generatePromptForHorseshoeSpread,
      emit,
      customPrompt: event.customPrompt,
    );
  }

  Future<void> _onDrawCareerPathSpread(DrawCareerPathSpread event, Emitter<TarotState> emit) async {
    await _handleReadingProcess(
      SpreadType.careerPathSpread,
      state.lastSelectedCategory ?? 'career', // Kategoriye göre default
      event.selectedCards, // <-- Kartları event'ten al
      _generatePromptForCareerPathSpread,
      emit,
      customPrompt: event.customPrompt,
    );
  }

  Future<void> _onDrawFullMoonSpread(DrawFullMoonSpread event, Emitter<TarotState> emit) async {
    await _handleReadingProcess(
      SpreadType.fullMoonSpread,
      state.lastSelectedCategory ?? 'spiritual', // Kategoriye göre default
      event.selectedCards, // <-- Kartları event'ten al
      _generatePromptForFullMoonSpread,
      emit,
      customPrompt: event.customPrompt,
    );
  }

  Future<void> _onDrawCategoryReading(DrawCategoryReading event, Emitter<TarotState> emit) async {
    final spreadType = SpreadType.categoryReading;
    if (event.cardCount <= 0 || event.cardCount != event.selectedCards.length) {
      emit(TarotError(
        "Kategori okuması için kart sayısı veya seçilen kartlar geçersiz.",
        userTokens: state.userTokens,
        isDailyTokenAvailable: state.isDailyTokenAvailable,
        nextDailyTokenTime: state.nextDailyTokenTime,
        lastSelectedCategory: state.lastSelectedCategory,
        userName: state.userName, userAge: state.userAge, userGender: state.userGender, userInfoCollected: state.userInfoCollected,
      ));
      return;
    }
    await _handleReadingProcess(
      spreadType,
      event.category,
      event.selectedCards, // <-- Kartları event'ten al
      _generatePromptForCategoryReading, // Prompt generator aynı
      emit,
      customPrompt: event.customPrompt,
    );
  }

  // ===========================================================================
  // --- Prompt Oluşturma Metotları ---
  // ===========================================================================
  // Bu metotlar önceki cevapta olduğu gibi kalır, değişiklik yok.
  String _buildBasePrompt({ required String spreadName, required String category, required Map<String, TarotCard> spread, required String locale, required TarotState currentState, String? customPrompt, required String formatInstructions, required String personaDescription, required String analysisFocus, }) {
    final userInfoSection = currentState.userInfoCollected && (currentState.userName != null || currentState.userAge != null || currentState.userGender != null) ? '''User Information:\n${currentState.userName != null ? "- Name: ${currentState.userName}\n" : ""}${currentState.userAge != null ? "- Age: ${currentState.userAge}\n" : ""}${currentState.userGender != null ? "- Gender: ${currentState.userGender}\n" : ""}Personalize the reading based on this information where relevant to the '$category' context.''' : 'User information not provided; provide a general interpretation.';
    final customPromptSection = customPrompt?.trim().isNotEmpty == true ? 'User\'s custom question/focus: "$customPrompt"\nAddress this specifically in your interpretation.' : 'No specific question provided; focus on the general $category context.';
    final cardDetails = StringBuffer();
    spread.forEach((position, card) { final lightMeanings = jsonEncode(card.meanings.light); final shadowMeanings = jsonEncode(card.meanings.shadow); final keywords = jsonEncode(card.keywords); cardDetails.writeln('- Position: "$position"'); cardDetails.writeln('  - Card: "${card.name}"'); cardDetails.writeln('  - Keywords: $keywords'); cardDetails.writeln('  - Light Meanings: $lightMeanings'); cardDetails.writeln('  - Shadow Meanings: $shadowMeanings'); });
    return '''
SYSTEM: $personaDescription
You MUST generate the response *only* in the language with code: "$locale".
Adhere strictly to the specified Markdown format using '###' for main sections.
Do not include technical placeholders or instructions to yourself in the final output.
Focus on providing insightful, detailed, creative, and empathetic interpretations related to the user's context.

USER:
Tarot Reading Request
---------------------
Spread Type: $spreadName
Category/Focus: $category
Language for Response: $locale

$userInfoSection

$customPromptSection

Drawn Cards:
------------
$cardDetails

Interpretation Format Required:
-----------------------------
$formatInstructions

$analysisFocus
''';
  }

  String _generatePromptForSingleCard({ required String category, required TarotCard card, String? customPrompt, required String locale, required TarotState currentState}) { final spread = {'Single Card': card}; final spreadName = "Single Card Reading"; final persona = "You are 'Astral Tarot', a compassionate and direct Tarot reader providing concise yet insightful guidance."; final analysisFocus = "Focus on the core message of this single card regarding the user's category/question."; final format = '''### Card's Essence\n[Provide a brief, evocative description of the card's core energy.]\n\n### Interpretation for $category\n[Explain the card's primary meaning in the context of the user's category ($category) and their custom prompt, if provided. Personalize if user info exists.]\n\n### Guidance\n[Offer one clear, actionable piece of advice based on the card's message for the user's situation.]\n'''; return _buildBasePrompt( spreadName: spreadName, category: category, spread: spread, locale: locale, currentState: currentState, customPrompt: customPrompt, formatInstructions: format, personaDescription: persona, analysisFocus: analysisFocus, ); }
  String _generatePromptForPastPresentFuture({ required String category, required Map<String, TarotCard> spread, String? customPrompt, required String locale, required TarotState currentState}) { final spreadName = "Past - Present - Future Spread"; final persona = "You are 'Astral Tarot', a wise Tarot reader skilled in interpreting the flow of time and its influence."; final analysisFocus = "Analyze the progression from past influences to the present situation and potential future outcomes regarding the '$category' category."; final format = '''### Past Influences ({Past Card Name})\n[Analyze the card in the 'Past' position. How do past events or energies affect the current situation related to '$category'? Personalize.]\n\n### Current Situation ({Present Card Name})\n[Analyze the card in the 'Present' position. What is the core energy or challenge the user is facing now regarding '$category'? Personalize.]\n\n### Potential Future ({Future Card Name})\n[Analyze the card in the 'Future' position. What is the likely direction or outcome if the current path continues? What advice does this card offer for the future related to '$category'? Personalize.]\n\n### Synthesis and Guidance\n[Summarize the connection between the three cards. Provide overall advice and actionable steps for the user based on the reading concerning '$category'. Address the custom prompt if provided.]\n'''; final pastCardName = spread['Past']?.name ?? 'Unknown'; final presentCardName = spread['Present']?.name ?? 'Unknown'; final futureCardName = spread['Future']?.name ?? 'Unknown'; final populatedFormat = format .replaceAll('{Past Card Name}', pastCardName) .replaceAll('{Present Card Name}', presentCardName) .replaceAll('{Future Card Name}', futureCardName); return _buildBasePrompt( spreadName: spreadName, category: category, spread: spread, locale: locale, currentState: currentState, customPrompt: customPrompt, formatInstructions: populatedFormat, personaDescription: persona, analysisFocus: analysisFocus, ); }
  String _generatePromptForProblemSolution({ required String category, required Map<String, TarotCard> spread, String? customPrompt, required String locale, required TarotState currentState}) { final spreadName = "Problem - Reason - Solution Spread"; final persona = "You are 'Astral Tarot', a pragmatic and insightful Tarot reader focused on identifying challenges and finding solutions."; final analysisFocus = "Clearly define the problem, analyze its root cause (reason), and offer a concrete solution based on the cards regarding the '$category' category."; final format = '''### The Problem ({Problem Card Name})\n[Describe the core problem or challenge as represented by this card in the context of '$category'. Personalize.]\n\n### Root Cause / Contributing Factors ({Reason Card Name})\n[Analyze the card representing the reason or underlying factors contributing to the problem related to '$category'. Personalize.]\n\n### The Path to Solution ({Solution Card Name})\n[Analyze the card suggesting the solution. What steps, mindset shifts, or actions are recommended to overcome the problem regarding '$category'? Personalize.]\n\n### Action Plan and Summary\n[Synthesize the reading. Provide clear, actionable steps based on the 'Solution' card. Briefly summarize the overall dynamic. Address the custom prompt.]\n'''; final problemCardName = spread['Problem']?.name ?? 'Unknown'; final reasonCardName = spread['Reason']?.name ?? 'Unknown'; final solutionCardName = spread['Solution']?.name ?? 'Unknown'; final populatedFormat = format .replaceAll('{Problem Card Name}', problemCardName) .replaceAll('{Reason Card Name}', reasonCardName) .replaceAll('{Solution Card Name}', solutionCardName); return _buildBasePrompt( spreadName: spreadName, category: category, spread: spread, locale: locale, currentState: currentState, customPrompt: customPrompt, formatInstructions: populatedFormat, personaDescription: persona, analysisFocus: analysisFocus, ); }
  String _generatePromptForFiveCardPath({ required String category, required Map<String, TarotCard> spread, String? customPrompt, required String locale, required TarotState currentState}) { final spreadName = "Five Card Path Spread"; final persona = "You are 'Astral Tarot', guiding users along their path with insights on past, present, challenges, future, and outcome."; final analysisFocus = "Analyze the user's journey regarding '$category', covering the foundation, present situation, obstacles, potential future, and final outcome."; final format = '''### Foundation / Past Influence ({Card 0 Name})\n[Analyze the past events or foundation upon which the current situation regarding '$category' is built.]\n\n### Present Situation ({Card 1 Name})\n[Analyze the current core circumstances or energies related to '$category'.]\n\n### Obstacles / Challenges ({Card 2 Name})\n[Analyze the main challenges or obstacles the user faces on this path regarding '$category'.]\n\n### Near Future / Potential ({Card 3 Name})\n[Analyze the potential developments or energies emerging in the near future related to '$category'.]\n\n### Final Outcome / Resolution ({Card 4 Name})\n[Analyze the likely culmination or resolution of this path based on the other cards.]\n\n### Synthesis and Path Guidance\n[Summarize the journey depicted. Provide guidance on navigating the challenges and leveraging opportunities concerning '$category'. Address the custom prompt.]\n'''; String getCardName(String key, String defaultName) => spread[key]?.name ?? defaultName; final populatedFormat = format .replaceAll('{Card 0 Name}', getCardName('Current Situation', 'Card 1')) .replaceAll('{Card 1 Name}', getCardName('Obstacles', 'Card 2')) .replaceAll('{Card 2 Name}', getCardName('Best Outcome', 'Card 3')) .replaceAll('{Card 3 Name}', getCardName('Foundation', 'Card 4')) .replaceAll('{Card 4 Name}', getCardName('Potential', 'Card 5')); return _buildBasePrompt( spreadName: spreadName, category: category, spread: spread, locale: locale, currentState: currentState, customPrompt: customPrompt, formatInstructions: populatedFormat, personaDescription: persona, analysisFocus: analysisFocus, ); }
  String _generatePromptForRelationshipSpread({ required String category, required Map<String, TarotCard> spread, String? customPrompt, required String locale, required TarotState currentState}) { final spreadName = "Relationship Spread"; final persona = "You are 'Astral Tarot', specializing in relationship dynamics, offering compassionate and clear insights."; final analysisFocus = "Analyze the perspectives of both individuals ('You', 'Partner'), the relationship's foundation (Past, Present, Future), and its dynamics (Strengths, Challenges) regarding the '$category' focus."; final format = '''### Your Perspective ({Card 0 Name})\n[Analyze your viewpoint, feelings, and contribution to the relationship dynamics in the '$category' context. Personalize.]\n\n### Partner's Perspective ({Card 1 Name})\n[Analyze your partner's viewpoint, feelings, and contribution as suggested by the card. Personalize.]\n\n### Relationship Foundation - Past ({Card 2 Name})\n[Analyze past influences shaping the current relationship state related to '$category'.]\n\n### Relationship Foundation - Present ({Card 3 Name})\n[Analyze the current core energy and status of the relationship regarding '$category'.]\n\n### Relationship Foundation - Future ({Card 4 Name})\n[Analyze the potential direction the relationship is heading regarding '$category'.]\n\n### Relationship Strengths ({Card 5 Name})\n[Identify the key strengths and positive aspects supporting the relationship.]\n\n### Relationship Challenges ({Card 6 Name})\n[Identify the main challenges or areas needing attention.]\n\n### Synthesis and Relationship Guidance\n[Summarize the overall dynamic. Provide advice for nurturing strengths, addressing challenges, and improving communication or understanding within the '$category' context. Address the custom prompt.]\n'''; String getCardName(String key, String defaultName) => spread[key]?.name ?? defaultName; final populatedFormat = format .replaceAll('{Card 0 Name}', getCardName('You', 'You')) .replaceAll('{Card 1 Name}', getCardName('Partner', 'Partner')) .replaceAll('{Card 2 Name}', getCardName('Relationship', 'Relationship')) // Assuming 'Relationship' is the key for the 3rd card
      .replaceAll('{Card 3 Name}', getCardName('Strengths', 'Strengths')) // Assuming 'Strengths' is the key for the 4th card
      .replaceAll('{Card 4 Name}', getCardName('Weaknesses', 'Weaknesses')) // Assuming 'Weaknesses' is the key for the 5th card
      .replaceAll('{Card 5 Name}', getCardName('Actions Needed', 'Actions Needed')) // Assuming 'Actions Needed' is the key for the 6th card
      .replaceAll('{Card 6 Name}', getCardName('Outcome', 'Outcome')); // Assuming 'Outcome' is the key for the 7th card
  return _buildBasePrompt( spreadName: spreadName, category: category, spread: spread, locale: locale, currentState: currentState, customPrompt: customPrompt, formatInstructions: populatedFormat, personaDescription: persona, analysisFocus: analysisFocus, ); }
  String _generatePromptForCelticCross({ required String category, required Map<String, TarotCard> spread, String? customPrompt, required String locale, required TarotState currentState}) { final spreadName = "Celtic Cross Spread"; final persona = "You are 'Astral Tarot', a master Tarot reader providing deep, comprehensive insights using the traditional Celtic Cross."; final analysisFocus = "Provide a detailed, position-by-position analysis of the Celtic Cross spread, synthesizing the insights to illuminate the user's situation regarding the '$category' category."; final format = '''### 1. The Heart of the Matter / Present Situation ({Card 0 Name})\n[Analyze the central issue or current energy regarding '$category'.]\n\n### 2. The Challenge ({Card 1 Name})\n[Analyze the immediate obstacle or conflicting force regarding '$category'.]\n\n### 3. The Foundation / Subconscious ({Card 2 Name})\n[Analyze the underlying factors, roots of the situation, or subconscious influences regarding '$category'.]\n\n### 4. The Recent Past ({Card 3 Name})\n[Analyze past events or influences that led to the present situation regarding '$category'.]\n\n### 5. The Crown / Conscious Goals / Best Outcome ({Card 4 Name})\n[Analyze conscious goals, awareness, or the best possible outcome in the current circumstances regarding '$category'.]\n\n### 6. The Near Future ({Card 5 Name})\n[Analyze events or energies likely to emerge soon regarding '$category'.]\n\n### 7. Your Stance / Personal Influence ({Card 6 Name})\n[Analyze the user's own attitude, perspective, or influence on the situation regarding '$category'.]\n\n### 8. External Environment / Others' Influence ({Card 7 Name})\n[Analyze external factors, people, or environmental influences regarding '$category'.]\n\n### 9. Hopes and Fears ({Card 8 Name})\n[Analyze the user's hopes, fears, or hidden expectations related to the situation regarding '$category'.]\n\n### 10. The Final Outcome ({Card 9 Name})\n[Analyze the likely long-term result or culmination of the situation based on the preceding cards regarding '$category'.]\n\n### Overall Synthesis and Guidance\n[Summarize the key messages from the spread. Connect the positions and provide holistic guidance and actionable advice specifically for the '$category' context. Address the custom prompt.]\n'''; String getCardName(String key, String defaultName) => spread[key]?.name ?? defaultName; final populatedFormat = format .replaceAll('{Card 0 Name}', getCardName('Current Situation', 'Card 1')) .replaceAll('{Card 1 Name}', getCardName('Challenge', 'Card 2')) .replaceAll('{Card 2 Name}', getCardName('Subconscious', 'Card 3')) .replaceAll('{Card 3 Name}', getCardName('Past', 'Card 4')) .replaceAll('{Card 4 Name}', getCardName('Possible Future', 'Card 5')) .replaceAll('{Card 5 Name}', getCardName('Near Future', 'Card 6')) .replaceAll('{Card 6 Name}', getCardName('Personal Stance', 'Card 7')) .replaceAll('{Card 7 Name}', getCardName('External Influences', 'Card 8')) .replaceAll('{Card 8 Name}', getCardName('Hopes/Fears', 'Card 9')) .replaceAll('{Card 9 Name}', getCardName('Final Outcome', 'Card 10')); return _buildBasePrompt( spreadName: spreadName, category: category, spread: spread, locale: locale, currentState: currentState, customPrompt: customPrompt, formatInstructions: populatedFormat, personaDescription: persona, analysisFocus: analysisFocus, ); }
  String _generatePromptForYearlySpread({ required String category, required Map<String, TarotCard> spread, String? customPrompt, required String locale, required TarotState currentState}) { final spreadName = "Yearly Spread"; final persona = "You are 'Astral Tarot', foreseeing the themes and energies of the year ahead, month by month."; final analysisFocus = "Provide a month-by-month forecast for the '$category' context, followed by an overall summary and guidance for the year."; final formatBuffer = StringBuffer(); spread.forEach((position, card) { final cardName = card.name; formatBuffer.writeln("### $position ($cardName)"); formatBuffer.writeln("[Analyze this card's significance for this period/theme regarding '$category'. Personalize.]\n"); }); formatBuffer.writeln("### Guidance for the Year Ahead"); formatBuffer.writeln("[Synthesize the monthly insights. Offer overall guidance, identify key themes, challenges, and opportunities for the year regarding '$category'. Address the custom prompt.]"); final populatedFormat = formatBuffer.toString(); return _buildBasePrompt( spreadName: spreadName, category: category, spread: spread, locale: locale, currentState: currentState, customPrompt: customPrompt, formatInstructions: populatedFormat, personaDescription: persona, analysisFocus: analysisFocus, ); }
  String _generatePromptForMindBodySpirit({ required String category, required Map<String, TarotCard> spread, String? customPrompt, required String locale, required TarotState currentState}) { final spreadName = "Mind - Body - Spirit Spread"; final persona = "You are 'Astral Tarot', exploring the holistic connection between mind, body, and spirit."; final analysisFocus = "Analyze the state of the user's mind, body, and spirit, and their interplay, especially concerning the '$category' focus."; final format = '''### Mind ({Card 0 Name})\n[Analyze the card representing the user's current mental state, thoughts, and clarity regarding '$category'. Personalize.]\n\n### Body ({Card 1 Name})\n[Analyze the card representing the user's physical well-being, energy levels, and connection to their body regarding '$category'. Personalize.]\n\n### Spirit ({Card 2 Name})\n[Analyze the card representing the user's spiritual connection, intuition, and inner self regarding '$category'. Personalize.]\n\n### Holistic Balance and Advice\n[Discuss the interplay between mind, body, and spirit based on the cards. Offer guidance on achieving better balance and well-being in the '$category' context. Address the custom prompt.]\n'''; String getCardName(String key, String defaultName) => spread[key]?.name ?? defaultName; final populatedFormat = format .replaceAll('{Card 0 Name}', getCardName('Mind', 'Mind')) .replaceAll('{Card 1 Name}', getCardName('Body', 'Body')) .replaceAll('{Card 2 Name}', getCardName('Spirit', 'Spirit')); return _buildBasePrompt( spreadName: spreadName, category: category, spread: spread, locale: locale, currentState: currentState, customPrompt: customPrompt, formatInstructions: populatedFormat, personaDescription: persona, analysisFocus: analysisFocus, ); }
  String _generatePromptForAstroLogicalCross({ required String category, required Map<String, TarotCard> spread, String? customPrompt, required String locale, required TarotState currentState}) { final spreadName = "Astrological Cross Spread"; final persona = "You are 'Astral Tarot', blending tarot wisdom with astrological insights for a deeper understanding."; final analysisFocus = "Interpret the cards through an astrological lens, focusing on identity, emotions, external factors, challenges, and destiny related to '$category'."; final format = '''### 1. Identity / Self ({Card 0 Name})\n[Analyze how this card reflects the user's core identity or self-perception in the context of '$category'.]\n\n### 2. Emotional State / Inner World ({Card 1 Name})\n[Analyze the card representing the user's current emotional landscape regarding '$category'.]\n\n### 3. External Influences / Environment ({Card 2 Name})\n[Analyze the card showing external forces or environmental factors impacting the situation.]\n\n### 4. Challenges / Karmic Lessons ({Card 3 Name})\n[Analyze the primary challenge or potential karmic lesson presented.]\n\n### 5. Destiny / Potential Outcome ({Card 4 Name})\n[Analyze the card indicating the potential path or ultimate destiny related to the situation.]\n\n### Astrological Synthesis and Guidance\n[Integrate the insights from an astrological perspective (even if general). Provide guidance based on the cross spread for the '$category' context. Address the custom prompt.]\n'''; String getCardName(String key, String defaultName) => spread[key]?.name ?? defaultName; final populatedFormat = format .replaceAll('{Card 0 Name}', getCardName('Identity', 'Card 1')) .replaceAll('{Card 1 Name}', getCardName('Emotional State', 'Card 2')) .replaceAll('{Card 2 Name}', getCardName('External Influences', 'Card 3')) .replaceAll('{Card 3 Name}', getCardName('Challenges', 'Card 4')) .replaceAll('{Card 4 Name}', getCardName('Destiny', 'Card 5')); return _buildBasePrompt( spreadName: spreadName, category: category, spread: spread, locale: locale, currentState: currentState, customPrompt: customPrompt, formatInstructions: populatedFormat, personaDescription: persona, analysisFocus: analysisFocus, ); }
  String _generatePromptForBrokenHeart({ required String category, required Map<String, TarotCard> spread, String? customPrompt, required String locale, required TarotState currentState}) { final spreadName = "Broken Heart Spread"; final persona = "You are 'Astral Tarot', offering gentle guidance and support for emotional healing."; final analysisFocus = "Focus on understanding the source of pain, emotional impact, lessons learned, hope, and the path to healing regarding '$category'."; final format = '''### Source of Pain ({Card 0 Name})\n[Analyze the card representing the root cause or situation leading to the emotional pain in the '$category' context.]\n\n### Emotional Impact ({Card 1 Name})\n[Analyze the card describing the current emotional state and the depth of the hurt.]\n\n### Lesson to Learn ({Card 2 Name})\n[Analyze the card suggesting the key lesson or understanding to be gained from this experience.]\n\n### Glimmer of Hope ({Card 3 Name})\n[Analyze the card offering hope, potential positive outcomes, or strengths to draw upon.]\n\n### Path to Healing ({Card 4 Name})\n[Analyze the card providing guidance on the steps or mindset needed for emotional healing and moving forward.]\n\n### Compassionate Guidance for Healing\n[Summarize the reading with empathy. Offer gentle, actionable advice for the healing process concerning '$category'. Address the custom prompt.]\n'''; String getCardName(String key, String defaultName) => spread[key]?.name ?? defaultName; final populatedFormat = format .replaceAll('{Card 0 Name}', getCardName('Source of Pain', 'Card 1')) .replaceAll('{Card 1 Name}', getCardName('Emotional Wounds', 'Card 2')) .replaceAll('{Card 2 Name}', getCardName('Inner Conflict', 'Card 3')) .replaceAll('{Card 3 Name}', getCardName('Healing Process', 'Card 4')) .replaceAll('{Card 4 Name}', getCardName('New Beginning', 'Card 5')); return _buildBasePrompt( spreadName: spreadName, category: category, spread: spread, locale: locale, currentState: currentState, customPrompt: customPrompt, formatInstructions: populatedFormat, personaDescription: persona, analysisFocus: analysisFocus, ); }
  String _generatePromptForDreamInterpretation({ required String category, required Map<String, TarotCard> spread, String? customPrompt, required String locale, required TarotState currentState}) { final spreadName = "Dream Interpretation Spread"; final persona = "You are 'Astral Tarot', adept at unveiling the hidden meanings within dreams using tarot symbolism."; final analysisFocus = "Interpret the tarot cards as symbols reflecting the user's dream, connecting them to past influences, present feelings, and future messages related to '$category'."; final format = '''### Dream Connection - Past ({Card 0 Name})\n[Analyze how this card relates to past experiences or subconscious elements reflected in the dream, concerning '$category'.]\n\n### Dream Connection - Present Emotion ({Card 1 Name})\n[Analyze the card representing the core emotion or message the dream is conveying about the present situation regarding '$category'.]\n\n### Dream Connection - Future Guidance ({Card 2 Name})\n[Analyze the card offering insight or guidance for the future based on the dream's message.]\n\n### Unveiling the Dream's Message\n[Synthesize the interpretation. What is the overall message or insight the dream offers regarding '$category'? Provide guidance based on this understanding. Address the custom prompt.]\n'''; String getCardName(String key, String defaultName) => spread[key]?.name ?? defaultName; final populatedFormat = format .replaceAll('{Card 0 Name}', getCardName('Dream Symbol', 'Card 1')) .replaceAll('{Card 1 Name}', getCardName('Emotional Response', 'Card 2')) .replaceAll('{Card 2 Name}', getCardName('Message', 'Card 3')); return _buildBasePrompt( spreadName: spreadName, category: category, spread: spread, locale: locale, currentState: currentState, customPrompt: customPrompt, formatInstructions: populatedFormat, personaDescription: persona, analysisFocus: analysisFocus, ); }
  String _generatePromptForHorseshoeSpread({ required String category, required Map<String, TarotCard> spread, String? customPrompt, required String locale, required TarotState currentState}) { final spreadName = "Horseshoe Spread"; final persona = "You are 'Astral Tarot', providing a comprehensive overview of a situation using the Horseshoe spread."; final analysisFocus = "Analyze the situation regarding '$category' by examining past, present, future, internal factors (goals/fears), external influences, advice, and the likely outcome."; final format = '''### 1. Past Influence ({Card 0 Name})\n[Analyze relevant past factors influencing the current '$category' situation.]\n\n### 2. Present Situation ({Card 1 Name})\n[Analyze the core energy and circumstances of the present regarding '$category'.]\n\n### 3. Near Future Developments ({Card 2 Name})\n[Analyze potential events or shifts likely to occur soon regarding '$category'.]\n\n### 4. The User / Goals / Fears ({Card 3 Name})\n[Analyze the user's role, attitude, goals, or fears concerning the situation.]\n\n### 5. External Environment / Others' Influence ({Card 4 Name})\n[Analyze how external factors or other people are impacting the situation.]\n\n### 6. Recommended Course of Action / Advice ({Card 5 Name})\n[Analyze the card offering the best advice or course of action.]\n\n### 7. Final Outcome ({Card 6 Name})\n[Analyze the most likely outcome based on the spread.]\n\n### Horseshoe Synthesis and Guidance\n[Summarize the key insights from each position. Provide integrated guidance and actionable advice for navigating the situation concerning '$category'. Address the custom prompt.]\n'''; String getCardName(String key, String defaultName) => spread[key]?.name ?? defaultName; final populatedFormat = format .replaceAll('{Card 0 Name}', getCardName('Past', 'Card 1')) .replaceAll('{Card 1 Name}', getCardName('Present', 'Card 2')) .replaceAll('{Card 2 Name}', getCardName('Future', 'Card 3')) .replaceAll('{Card 3 Name}', getCardName('Goals/Fears', 'Card 4')) .replaceAll('{Card 4 Name}', getCardName('External Influences', 'Card 5')) .replaceAll('{Card 5 Name}', getCardName('Advice', 'Card 6')) .replaceAll('{Card 6 Name}', getCardName('Outcome', 'Card 7')); return _buildBasePrompt( spreadName: spreadName, category: category, spread: spread, locale: locale, currentState: currentState, customPrompt: customPrompt, formatInstructions: populatedFormat, personaDescription: persona, analysisFocus: analysisFocus, ); }
  String _generatePromptForCareerPathSpread({ required String category, required Map<String, TarotCard> spread, String? customPrompt, required String locale, required TarotState currentState}) { final spreadName = "Career Path Spread"; final persona = "You are 'Astral Tarot', offering guidance and clarity on professional journeys and career decisions."; final analysisFocus = "Analyze the user's career situation regarding '$category', focusing on the current state, obstacles, opportunities, inherent strengths, and potential outcome."; final format = '''### Current Career Situation ({Card 0 Name})\n[Analyze the card reflecting the user's present professional circumstances related to '$category'.]\n\n### Obstacles and Challenges ({Card 1 Name})\n[Analyze the main obstacles or challenges hindering career progress in the '$category' context.]\n\n### Opportunities and Potential ({Card 2 Name})\n[Analyze the card highlighting potential opportunities, new paths, or areas for growth.]\n\n### Strengths and Resources ({Card 3 Name})\n[Analyze the inherent strengths, skills, or resources the user possesses related to their career.]\n\n### Likely Outcome / Future Path ({Card 4 Name})\n[Analyze the card suggesting the likely outcome or direction of the user's career path.]\n\n### Career Path Synthesis and Strategy\n[Summarize the reading. Provide strategic advice for overcoming obstacles, seizing opportunities, and leveraging strengths in the '$category' field. Address the custom prompt.]\n'''; String getCardName(String key, String defaultName) => spread[key]?.name ?? defaultName; final populatedFormat = format .replaceAll('{Card 0 Name}', getCardName('Current Situation', 'Card 1')) .replaceAll('{Card 1 Name}', getCardName('Obstacles', 'Card 2')) .replaceAll('{Card 2 Name}', getCardName('Opportunities', 'Card 3')) .replaceAll('{Card 3 Name}', getCardName('Strengths', 'Card 4')) .replaceAll('{Card 4 Name}', getCardName('Outcome', 'Card 5')); return _buildBasePrompt( spreadName: spreadName, category: category, spread: spread, locale: locale, currentState: currentState, customPrompt: customPrompt, formatInstructions: populatedFormat, personaDescription: persona, analysisFocus: analysisFocus, ); }
  String _generatePromptForFullMoonSpread({ required String category, required Map<String, TarotCard> spread, String? customPrompt, required String locale, required TarotState currentState}) { final spreadName = "Full Moon Spread"; final persona = "You are 'Astral Tarot', attuned to lunar cycles, revealing insights brought to light by the Full Moon."; final analysisFocus = "Interpret the cards in the context of the Full Moon's energy (illumination, culmination, release) regarding '$category'. Focus on past cycle completion, present energies, subconscious messages, obstacles, actions, and resulting energy."; final format = '''### Past Cycle / What is Culminating ({Card 0 Name})\n[Analyze what is coming to completion or being fully illuminated from the past cycle regarding '$category'.]\n\n### Present Energy / What is Revealed ({Card 1 Name})\n[Analyze the core energy or truth being revealed by the Full Moon now.]\n\n### Subconscious Message / What to Release ({Card 2 Name})\n[Analyze the subconscious patterns, emotions, or attachments that need to be acknowledged or released.]\n\n### Obstacles to Release / Illumination ({Card 3 Name})\n[Analyze the main challenge hindering release or full understanding.]\n\n### Recommended Action / Integration ({Card 4 Name})\n[Analyze the advised action or focus for integrating the Full Moon's insights.]\n\n### Resulting Energy / Moving Forward ({Card 5 Name})\n[Analyze the energy state or potential after integrating the Full Moon's lessons.]\n\n### Full Moon Synthesis and Ritual Suggestion\n[Summarize the key themes of release and culmination. Offer a simple ritual or reflection suggestion aligned with the Full Moon energy and the reading for the '$category' context. Address the custom prompt.]\n'''; String getCardName(String key, String defaultName) => spread[key]?.name ?? defaultName; final populatedFormat = format .replaceAll('{Card 0 Name}', getCardName('Past Cycle', 'Card 1')) .replaceAll('{Card 1 Name}', getCardName('Current Energy', 'Card 2')) .replaceAll('{Card 2 Name}', getCardName('Subconscious Message', 'Card 3')) .replaceAll('{Card 3 Name}', getCardName('Obstacles', 'Card 4')) .replaceAll('{Card 4 Name}', getCardName('Recommended Action', 'Card 5')) .replaceAll('{Card 5 Name}', getCardName('Resulting Energy', 'Card 6')); return _buildBasePrompt( spreadName: spreadName, category: category, spread: spread, locale: locale, currentState: currentState, customPrompt: customPrompt, formatInstructions: populatedFormat, personaDescription: persona, analysisFocus: analysisFocus, ); }
  String _generatePromptForCategoryReading({ required String category, required Map<String, TarotCard> spread, String? customPrompt, required String locale, required TarotState currentState}) { final spreadName = "$category Category Reading (${spread.length} cards)"; final persona = "You are 'Astral Tarot', providing focused insights specifically for the chosen category: '$category'."; final analysisFocus = "Analyze how these cards specifically relate to the '$category' context for the user."; final formatBuffer = StringBuffer(); formatBuffer.writeln("### Card Insights for $category"); int i = 1; spread.forEach((position, card) { final cardName = card.name; formatBuffer.writeln("- Position: $position ($cardName)"); formatBuffer.writeln("  [Analyze this card's relevance to the '$category' situation. Personalize if possible.]"); i++; }); formatBuffer.writeln("\n### Overall Guidance for $category"); formatBuffer.writeln("[Synthesize the reading and provide actionable advice focused solely on the '$category' context. Address the custom prompt.]"); final populatedFormat = formatBuffer.toString(); return _buildBasePrompt( spreadName: spreadName, category: category, spread: spread, locale: locale, currentState: currentState, customPrompt: customPrompt, formatInstructions: populatedFormat, personaDescription: persona, analysisFocus: analysisFocus, ); }
// --- Bitiş: Prompt Oluşturma Metotları ---

} // TarotBloc Sınıfı Sonu