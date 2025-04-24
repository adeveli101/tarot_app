import 'dart:async';
import 'dart:math';
import 'dart:math' as math;
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/data/tarot_event_state.dart';
import 'package:tarot_fal/data/tarot_repository.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/models/tarot_card.dart';
import 'package:tarot_fal/screens/reading_result.dart';
import '../data/payment_manager.dart';
import '../models/animations/tap_animations_scale.dart';
import 'package:intl/intl.dart';

import 'helpers/helpers_for_screens.dart';

class CardSelectionAnimationScreen extends StatefulWidget {
  final SpreadType spreadType;
  final String categoryKey;

  const CardSelectionAnimationScreen({
    super.key,
    required this.spreadType,
    required this.categoryKey,
  });

  @override
  CardSelectionAnimationScreenState createState() => CardSelectionAnimationScreenState();
}

// --- WidgetsBindingObserver Eklendi ---
class CardSelectionAnimationScreenState extends State<CardSelectionAnimationScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver { // WidgetsBindingObserver eklendi
  final TarotRepository repository = TarotRepository();

  // --- İki Ayrı AudioPlayer Tanımlandı ---
  final AudioPlayer _effectAudioPlayer = AudioPlayer(); // Ses efektleri için
  final AudioPlayer _backgroundAudioPlayer = AudioPlayer(); // Arka plan müziği için

  // --- Arka Plan Müziği Ayarları ---
  final String _backgroundMusicPath = 'audios/ambient_background.mp3'; // ARKA PLAN MÜZİK DOSYANIZIN YOLU
  static const double _backgroundVolumeNormal = 0.3; // Normal ses seviyesi
  static const double _backgroundVolumeDucked = 0.05; // Efekt çalarkenki kısık ses seviyesi
  Timer? _duckingTimer; // Sesi geri yükseltmek için zamanlayıcı

  List<AnimationController> _flipControllers = [];
  List<AnimationController> _zoomControllers = [];

  List<TarotCard> selectedCards = [];
  List<bool> revealed = [];
  bool isLoading = false;
  bool isFlippingAll = false;
  bool cardsDrawn = false;
  late DateTime readingDate;
  late String locale;

  bool _hasCheckedInitialResources = false;
  bool _hasSufficientInitialResources = true;
  double _requiredTokensForSpread = 0.0;

  int get cardCount => widget.spreadType.cardCount;

  @override
  void initState() {
    super.initState();
    readingDate = DateTime.now();
    _requiredTokensForSpread = widget.spreadType.costInCredits;

    // --- WidgetsBinding Observer Kaydı ---
    WidgetsBinding.instance.addObserver(this);

    _flipControllers = List.generate(cardCount, (_) => AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    ));
    _zoomControllers = List.generate(cardCount, (_) => AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    ));

    // --- Sesleri Başlat ---
    _loadAndPlayBackgroundMusic();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    locale = Localizations.localeOf(context).languageCode;
    repository.setLocale(locale);
  }

  // --- Uygulama Yaşam Döngüsü Metodu Eklendi ---
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return; // Widget dispose edildiyse işlem yapma

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      // Uygulama arka plana alındığında veya kapandığında müziği duraklat
      _backgroundAudioPlayer.pause();
      if (kDebugMode) print("Background music paused due to app state: $state");
    } else if (state == AppLifecycleState.resumed) {
      // Uygulama ön plana geldiğinde müziği devam ettir
      _backgroundAudioPlayer.resume();
      if (kDebugMode) print("Background music resumed.");
    }
  }


  @override
  void dispose() {
    // --- Observer Kaldırıldı ---
    WidgetsBinding.instance.removeObserver(this);

    for (var controller in _flipControllers) { controller.dispose(); }
    for (var controller in _zoomControllers) { controller.dispose(); }

    // --- Zamanlayıcı İptal Edildi ve Player'lar Dispose Edildi ---
    _duckingTimer?.cancel(); // Zamanlayıcıyı iptal et
    _effectAudioPlayer.dispose();
    _backgroundAudioPlayer.stop(); // Önce durdur
    _backgroundAudioPlayer.dispose();

    super.dispose();
  }

  // --- Arka Plan Müziğini Yükle ve Oynat ---
  Future<void> _loadAndPlayBackgroundMusic() async {
    try {
      await _backgroundAudioPlayer.setReleaseMode(ReleaseMode.loop); // Döngü modunu ayarla
      await _backgroundAudioPlayer.setSource(AssetSource(_backgroundMusicPath));
      await _backgroundAudioPlayer.setVolume(_backgroundVolumeNormal); // Başlangıç ses seviyesi
      await _backgroundAudioPlayer.resume(); // Müziği başlat/devam ettir
      if (kDebugMode) print("Background music started: $_backgroundMusicPath");
    } catch (e) {
      if (kDebugMode) { print("Arka plan müziği yüklenirken/çalınırken hata: $e"); }
    }
  }


  // --- _playSound Fonksiyonu Ducking İçin Güncellendi ---
  Future<void> _playSound(String assetPath, {double volume = 1.0}) async {
    try {
      // 1. Arka plan müziğini kıs
      await _backgroundAudioPlayer.setVolume(_backgroundVolumeDucked);
      if (kDebugMode) print("Background music ducked.");

      // 2. Mevcut sesi geri yükseltme zamanlayıcısını iptal et (varsa)
      _duckingTimer?.cancel();

      // 3. Ses efektini çal
      await _effectAudioPlayer.play(AssetSource(assetPath), volume: volume);
      if (kDebugMode) print("Playing effect: $assetPath");

      // 4. Belirli bir süre sonra arka plan müziğini eski haline getir
      // (Efektin uzunluğuna göre ayarlanabilir)
      _duckingTimer = Timer(const Duration(milliseconds: 1500), () { // 1.5 saniye sonra
        if(mounted) { // Hala ekrandaysa sesi yükselt
          _backgroundAudioPlayer.setVolume(_backgroundVolumeNormal).then((_) {
            if (kDebugMode) print("Background music volume restored.");
          }).catchError((e){
            if (kDebugMode) print("Error restoring background music volume: $e");
          });
        }
      });

    } catch (e) {
      if (kDebugMode) { print("Ses çalınırken veya ducking sırasında hata ($assetPath): $e"); }
      // Hata durumunda bile sesi geri yükseltmeyi dene (isteğe bağlı)
      try { await _backgroundAudioPlayer.setVolume(_backgroundVolumeNormal); } catch (_) {}
    }
  }


  void _performInitialResourceCheck(TarotState state) {
    // ... (Bu fonksiyon aynı kalır)
    if (_hasCheckedInitialResources) return;

    final currentTokens = state.userTokens;
    final cost = _requiredTokensForSpread;

    bool sufficient = true;

    if (cost > 0 && currentTokens < cost) {
      sufficient = false;
    }


    if (mounted) {
      setState(() {
        _hasSufficientInitialResources = sufficient;
        _hasCheckedInitialResources = true;
      });
    } else {
      _hasSufficientInitialResources = sufficient;
      _hasCheckedInitialResources = true;
      return;
    }


    if (!sufficient) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showPaymentDialog(context, cost);
        }
      });
    }
  }

  Future _reshuffleCards() async {
    if (!mounted || isLoading || !_hasSufficientInitialResources) return;

    // --- Mevcut Kapatma Animasyonu ---
    final revealedIndices = <int>[];
    for (int i = 0; i < selectedCards.length; i++) {
      if (revealed.length > i && revealed[i]) {
        revealedIndices.add(i);
      }
    }

    if (revealedIndices.isNotEmpty) {
      setState(() => isFlippingAll = true);
      // Kapatma sesi için _playSound kullanılıyor (ducking otomatik)
      await _playSound('audios/shuffle_cards.mp3'); // Veya farklı bir kapatma sesi
      HapticFeedback.mediumImpact();

      List<Future<void>> flipFutures = [];
      for (int index in revealedIndices.reversed) {
        if (mounted) {
          setState(() => revealed[index] = false);
          flipFutures.add(_flipControllers[index].reverse(from: _flipControllers[index].value));
          await Future.delayed(const Duration(milliseconds: 50));
        } else { break; }
      }
      await Future.wait(flipFutures);
      if (!mounted) return;
      setState(() => isFlippingAll = false);
      await Future.delayed(const Duration(milliseconds: 150));
    }
    // --- Kapatma Animasyonu Sonu ---


    setState(() => isLoading = true);
    try {
      if(repository.getAllCards().isEmpty) {
        await repository.loadCards();
      }

      if (mounted) {
        setState(() {
          selectedCards = repository.drawRandomCards(cardCount);
          revealed = List.filled(cardCount, false);
          for (var controller in _flipControllers) { controller.reset(); }
          cardsDrawn = true;
          isLoading = false;
        });

        // Yeniden karıştırma sesi için _playSound kullan (ducking otomatik)
        await _playSound('audios/shuffle_cards.mp3');
        HapticFeedback.mediumImpact();

        // Zoom animasyonları
        for (int i = 0; i < cardCount; i++) {
          if (mounted) {
            _zoomControllers[i].reset();
            await Future.delayed(Duration(milliseconds: i * 100 + 50));
            if (mounted) {
              _zoomControllers[i].forward(from: 0.0);
            }
          } else { break; }
        }
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) HapticFeedback.heavyImpact();
      }
    } catch (e) {
      if (kDebugMode) { print("Kart çekme hatası: $e"); }
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: Kartlar çekilemedi. ${e.toString()}'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }


  void _flipCard(int index) {
    // ... (Bu fonksiyondaki _playSound çağrısı otomatik ducking yapar)
    if (!mounted || isFlippingAll || !cardsDrawn || index >= revealed.length || !_hasSufficientInitialResources) return;

    _playSound('audios/flip_card.mp3'); // Ducking otomatik
    HapticFeedback.lightImpact();

    final controller = _flipControllers[index];
    if (controller.isAnimating) return;

    if (mounted) {
      setState(() {
        revealed[index] = !revealed[index];
        if (revealed[index]) {
          controller.forward(from: 0.0);
        } else {
          controller.reverse(from: 1.0);
        }
      });
    }
  }

  Future<void> _flipAllCards() async {
    // ... (Bu fonksiyondaki _playSound çağrısı otomatik ducking yapar)
    if (!mounted || isFlippingAll || !cardsDrawn || !_hasSufficientInitialResources) return;

    setState(() => isFlippingAll = true);
    _playSound('audios/shuffle_cards.mp3'); // Ducking otomatik
    HapticFeedback.heavyImpact();

    bool anyRevealed = revealed.any((r) => r);
    bool flipToRevealed = !anyRevealed || revealed.contains(false);

    // Animasyonlar... (aynı kalır)
    if (flipToRevealed) {
      for (int i = 0; i < cardCount; i++) {
        if (mounted && !revealed[i]) {
          final controller = _flipControllers[i];
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) {
            setState(() => revealed[i] = true);
            controller.forward(from: controller.value);
          } else {
            break;
          }
        }
      }
    } else {
      for (int i = cardCount - 1; i >= 0; i--) {
        if (mounted && revealed[i]) {
          final controller = _flipControllers[i];
          await Future.delayed(const Duration(milliseconds: 80));
          if (mounted) {
            setState(() => revealed[i] = false);
            controller.reverse(from: controller.value);
          } else {
            break;
          }
        }
      }
    }

    if (mounted) {
      setState(() => isFlippingAll = false);
    }
  }

// lib/screens/card_selection_animation.dart



  Future<void> _navigateToResults() async {
    final loc = S.of(context)!;
    if (!mounted) return;

    if (!cardsDrawn) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.drawCards), backgroundColor: Colors.orangeAccent,)
      );
      return;
    }

    // --- Otomatik Kart Çevirme (Aynı kalır) ---
    final unrevealedIndices = <int>[];
    for (int i = 0; i < cardCount; i++) {
      if (revealed.length > i && !revealed[i]) {
        unrevealedIndices.add(i);
      } else if (revealed.length <= i) {
        if (kDebugMode) print("Error: revealed list length (${revealed.length}) is less than card index ($i).");
        // Opsiyonel: Hata durumunda işlemi durdur
        // return;
      }
    }

    if (unrevealedIndices.isNotEmpty) {
      setState(() => isFlippingAll = true);
      await _playSound('audios/shuffle_cards.mp3');
      HapticFeedback.mediumImpact();
      List<Future<void>> flipFutures = [];
      for (int index in unrevealedIndices) {
        if (mounted && index < _flipControllers.length) {
          setState(() => revealed[index] = true);
          flipFutures.add(_flipControllers[index].forward(from: _flipControllers[index].value));
          await Future.delayed(const Duration(milliseconds: 80));
        } else {
          if(mounted && kDebugMode) {if (kDebugMode) {
            print("Error: Invalid index ($index) for flip controllers.");
          }
          break;
        }}
      }
      await Future.wait(flipFutures);
      if (!mounted) return;
      setState(() => isFlippingAll = false);
      await Future.delayed(const Duration(milliseconds: 200));
    }
    // --- Otomatik Kart Çevirme Sonu ---


    final bloc = context.read<TarotBloc>();
    final currentState = bloc.state;
    final cost = _requiredTokensForSpread;
    final double currentTokens = currentState.userTokens;

    bool sufficientNow = true;
    if (cost > 0 && currentTokens < cost) {
      sufficientNow = false;
    }

    if (!sufficientNow) {
      _showPaymentDialog(context, cost);
      return;
    }

    // <<< DEĞİŞEN KISIM BAŞLIYOR >>>
    TarotEvent eventToDispatch;
    // State'den seçilen kartları al (kopyasını oluşturmak iyi bir pratik olabilir)
    final List<TarotCard> cardsToPass = List.from(selectedCards);

    // Spread tipine göre doğru event'i seçilen kartlarla birlikte oluştur
    switch (widget.spreadType) {
      case SpreadType.singleCard:
        eventToDispatch = DrawSingleCard(selectedCards: cardsToPass, customPrompt: null);
        break;
      case SpreadType.pastPresentFuture:
        eventToDispatch = DrawPastPresentFuture(selectedCards: cardsToPass, customPrompt: null);
        break;
      case SpreadType.problemSolution:
        eventToDispatch = DrawProblemSolution(selectedCards: cardsToPass, customPrompt: null);
        break;
      case SpreadType.fiveCardPath:
        eventToDispatch = DrawFiveCardPath(selectedCards: cardsToPass, customPrompt: null);
        break;
      case SpreadType.relationshipSpread:
        eventToDispatch = DrawRelationshipSpread(selectedCards: cardsToPass, customPrompt: null);
        break;
      case SpreadType.celticCross:
        eventToDispatch = DrawCelticCross(selectedCards: cardsToPass, customPrompt: null);
        break;
      case SpreadType.yearlySpread:
        eventToDispatch = DrawYearlySpread(selectedCards: cardsToPass, customPrompt: null);
        break;
      case SpreadType.mindBodySpirit:
        eventToDispatch = DrawMindBodySpirit(selectedCards: cardsToPass, customPrompt: null);
        break;
      case SpreadType.astroLogicalCross:
        eventToDispatch = DrawAstroLogicalCross(selectedCards: cardsToPass, customPrompt: null);
        break;
      case SpreadType.brokenHeart:
        eventToDispatch = DrawBrokenHeart(selectedCards: cardsToPass, customPrompt: null);
        break;
      case SpreadType.dreamInterpretation:
        eventToDispatch = DrawDreamInterpretation(selectedCards: cardsToPass, customPrompt: null);
        break;
      case SpreadType.horseshoeSpread:
        eventToDispatch = DrawHorseshoeSpread(selectedCards: cardsToPass, customPrompt: null);
        break;
      case SpreadType.careerPathSpread:
        eventToDispatch = DrawCareerPathSpread(selectedCards: cardsToPass, customPrompt: null);
        break;
      case SpreadType.fullMoonSpread:
        eventToDispatch = DrawFullMoonSpread(selectedCards: cardsToPass, customPrompt: null);
        break;
      case SpreadType.categoryReading:
        eventToDispatch = DrawCategoryReading(
          category: widget.categoryKey,
          cardCount: widget.spreadType.cardCount, // cardCount hala gerekli olabilir
          selectedCards: cardsToPass,             // Seçilen kartları gönder
          customPrompt: null,
        );
        break;
    // default: // Opsiyonel: Kapsanmayan durum için hata fırlat
    //   throw Exception("Unsupported SpreadType in _navigateToResults: ${widget.spreadType}");
    }
    // <<< DEĞİŞEN KISIM BİTİYOR >>>

    bloc.add(eventToDispatch); // Güncellenmiş event'i gönder

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          // reading_result.dart içindeki widget adını kullanın
          pageBuilder: (_, __, ___) => const ReadingResultScreenWithTransition(), // Veya ReadingResultScreenWithTransition() hangisiyse
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }


  void _showPaymentDialog(BuildContext context, double requiredTokens) {
    // ... (Bu fonksiyon aynı kalır)
    PaymentManager.showPaymentDialog(
      context,
      requiredTokens: requiredTokens,
      onSuccess: () {
        if(mounted) {
          if (!_hasSufficientInitialResources) {
            setState(() {
              _hasSufficientInitialResources = true;
            });
          }
        }
      },
    );
  }

  void _showDetailedCardInfo(TarotCard card, int index) {
    // ... (Bu fonksiyondaki _playSound çağrısı otomatik ducking yapar)
    if (!mounted || !cardsDrawn || index >= revealed.length || !_hasSufficientInitialResources) return;

    if (!revealed[index]) {
      _playSound('audios/flip_card.mp3'); // Ducking otomatik
      HapticFeedback.lightImpact();
      setState(() => revealed[index] = true);
      _flipControllers[index].forward(from: 0.0).then((_) {
        if (mounted) _openCardDetails(card);
      });
    } else {
      _openCardDetails(card);
    }
  }

  void _openCardDetails(TarotCard card) {
    // ... (Bu fonksiyon aynı kalır, içinde ses çalma yok)
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.92,
              height: MediaQuery.of(context).size.height * 0.88,
              padding: const EdgeInsets.only(top: 25, left: 20, right: 20, bottom: 15),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.indigo[900]!, Colors.purple[800]!, Colors.black87],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purpleAccent.withOpacity(0.5),
                      blurRadius: 25,
                      spreadRadius: 3,
                    ),
                  ],
                  border: Border.all(color: Colors.purpleAccent.withOpacity(0.4), width: 1.5)
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            card.name.toUpperCase(),
                            style: GoogleFonts.cinzelDecorative(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  color: Colors.purpleAccent.withOpacity(0.6),
                                  offset: const Offset(1, 1),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.white.withOpacity(0.15),
                                      blurRadius: 15,
                                      spreadRadius: 2
                                  )
                                ]
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/tarot_card_images/${card.img}',
                                height: MediaQuery.of(context).size.height * 0.4,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                  size: 100,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildDetailSection(S.of(context)!.arcana, card.arcana),
                          _buildDetailSection(S.of(context)!.suit, card.suit),
                          if (card.elemental != null && card.elemental!.isNotEmpty) _buildDetailSection("Element", card.elemental!),
                          _buildDetailSection("Keywords", card.keywords.join(", ")),
                          _buildDetailSection("Fortune Telling", card.fortuneTelling.join("\n\n")),
                          _buildDetailSection("Light Meanings", card.meanings.light.join("\n\n")),
                          _buildDetailSection("Shadow Meanings", card.meanings.shadow.join("\n\n")),
                          if (card.archetype != null && card.archetype!.isNotEmpty) _buildDetailSection("Archetype", card.archetype!),
                          if (card.hebrewAlphabet != null && card.hebrewAlphabet!.isNotEmpty) _buildDetailSection("Hebrew Alphabet", card.hebrewAlphabet!),
                          if (card.numerology != null && card.numerology!.isNotEmpty) _buildDetailSection("Numerology", card.numerology!),
                          if (card.mythicalSpiritual != null && card.mythicalSpiritual!.isNotEmpty) _buildDetailSection("Mythical/Spiritual", card.mythicalSpiritual!),
                          if (card.questionsToAsk != null && card.questionsToAsk!.isNotEmpty)
                            _buildDetailSection(S.of(context)!.questionsToAsk, card.questionsToAsk!.join("\n\n")),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: TapAnimatedScale(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.purpleAccent.shade100, Colors.purpleAccent.shade400]),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purpleAccent.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          S.of(context)!.close.toUpperCase(),
                          style: GoogleFonts.cinzel(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    // ... (Bu fonksiyon aynı kalır)
    if (content.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.cinzel(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purpleAccent[100],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.cabin(
              fontSize: 15,
              color: Colors.white.withOpacity(0.85),
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.left,
          ),
          Divider(color: Colors.purpleAccent.withOpacity(0.2), thickness: 1, height: 30),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    // ... (Bu fonksiyon aynı kalır)
    final loc = S.of(context)!;

    return BlocBuilder<TarotBloc, TarotState>(
      builder: (context, state) {
        final bool canFlip = cardsDrawn && !isFlippingAll && _hasSufficientInitialResources;
        final bool canReshuffle = !isLoading && _hasSufficientInitialResources;

        final cost = _requiredTokensForSpread;
        final double currentTokens = state.userTokens;
        bool sufficientForResults = true;

        if (cost > 0 && currentTokens < cost) {
          sufficientForResults = false;
        }


        final bool canViewResults = cardsDrawn && !isLoading && !isFlippingAll && sufficientForResults;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              boxShadow: [
                BoxShadow(
                    color: Colors.purple.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: -5,
                    offset: const Offset(0, -5))
              ]
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                label: loc.flipAllCards,
                onPressed: canFlip ? _flipAllCards : (){},
                icon: Icons.flip_camera_android_outlined,
                color: Colors.purple.shade400,
                isEnabled: canFlip,
              ),
              _buildActionButton(
                label: cardsDrawn ? loc.reshuffleCards : loc.drawCards,
                onPressed: canReshuffle ? _reshuffleCards : (){},
                icon: Icons.shuffle_rounded,
                color: Colors.deepPurple.shade500,
                isEnabled: canReshuffle,
              ),
              _buildActionButton(
                label: loc.viewResults,
                onPressed: canViewResults ? _navigateToResults : (){
                  if (cardsDrawn && !sufficientForResults) {
                    _showPaymentDialog(context, cost);
                  }
                },
                icon: Icons.visibility_outlined,
                color: Colors.purpleAccent.shade400,
                isEnabled: canViewResults,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    bool isEnabled = true,
  }) {
    // ... (Bu fonksiyon aynı kalır)
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: TapAnimatedScale(
        onTap: isEnabled ? onPressed : () {},
        child: Container(
          width: MediaQuery.of(context).size.width / 3.6,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: isEnabled
                      ? [color.withOpacity(0.8), color]
                      : [Colors.grey.shade700, Colors.grey.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(15),
              boxShadow: isEnabled ? const [
                BoxShadow(
                    color: Colors.black45,
                    blurRadius: 8,
                    offset: Offset(0, 4))
              ] : null,
              border: Border.all(color: Colors.white.withOpacity(isEnabled ? 0.2 : 0.1))
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white.withOpacity(isEnabled ? 1.0 : 0.6), size: 22),
              const SizedBox(height: 5),
              Text(
                label,
                style: GoogleFonts.cinzel(
                    fontSize: 11,
                    color: Colors.white.withOpacity(isEnabled ? 1.0 : 0.6),
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    // ... (Bu fonksiyon aynı kalır)
    final loc = S.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900]?.withOpacity(0.95),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.purpleAccent.withOpacity(0.5))
        ),
        title:Row(
          crossAxisAlignment: CrossAxisAlignment.start, // İkon ve metni dikeyde başa hizala
          children: [
            const Icon(Icons.help_outline, color: Colors.purpleAccent, size: 20), // İkon boyutunu ayarlayabilirsiniz
            const SizedBox(width: 10),
            Expanded( // Text widget'ını Expanded ile sar
              child: Text(
                loc.cardSelectionInstructions,
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  height: 1.3, // Satır yüksekliğini ayarlayabilirsiniz (isteğe bağlı)
                ),
                // softWrap: true, // Text widget'ı Expanded içindeyse bu genellikle gereksizdir
                // overflow: TextOverflow.visible, // Expanded ile sarıldığı için bu da gereksizdir
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInstructionRow(loc.flipAllCards, loc.instructionsFlipAll, Icons.flip_camera_android_outlined),
              _buildInstructionRow(cardsDrawn ? loc.reshuffleCards : loc.drawCards, loc.instructionsDrawCards, Icons.shuffle_rounded),
              _buildInstructionRow(loc.viewResults, loc.instructionsViewResults, Icons.visibility_outlined),
              const SizedBox(height: 15),
              Text(
                loc.longPressHint,
                style: GoogleFonts.cinzel(color: Colors.white.withOpacity(0.7), fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.purpleAccent.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(loc.close, style: GoogleFonts.cinzel(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionRow(String title, String description, IconData icon) {
    // ... (Bu fonksiyon aynı kalır)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.purpleAccent.withOpacity(0.8), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cinzel(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.cabin(color: Colors.white70, fontSize: 13, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// lib/screens/card_selection_animation.dart

// lib/screens/card_selection_animation.dart

  Widget _buildCardWidget(int index, String positionLabel) {
    if (!cardsDrawn || index < 0 || index >= selectedCards.length || index >= _flipControllers.length || index >= _zoomControllers.length) {
      return const SizedBox(width: 100, height: 150);
    }

    final TarotCard card = selectedCards[index];
    final flipController = _flipControllers[index];
    final zoomController = _zoomControllers[index];

    return GestureDetector(
      onTap: () => _flipCard(index),
      onLongPress: () => _showDetailedCardInfo(card, index),

      // <<< GÜNCELLEME: Kaydırma ile çevirme >>>
      onHorizontalDragEnd: (DragEndDetails details) {
        // Belirli bir hızın üzerindeki kaydırmaları algıla
        if (details.primaryVelocity != null && details.primaryVelocity!.abs() > 300.0) {
          // <<< DEĞİŞİKLİK: revealed kontrolü kaldırıldı >>>
          // Artık kart açık veya kapalıyken de kaydırma çalışacak
          _flipCard(index);
        }
      },
      // <<< GÜNCELLEME SONU >>>

      child: AnimatedBuilder(
        animation: Listenable.merge([flipController, zoomController]),
        builder: (context, child) {
          // ... (AnimatedBuilder içeriği aynı kalır) ...
          final flipValue = flipController.value;
          final zoomValue = Curves.easeOutExpo.transform(zoomController.value);
          final isVisuallyBack = flipValue < 0.5;

          double scale = zoomValue;
          double opacity = zoomValue;

          double initialOffsetY = MediaQuery.of(context).size.height * 0.4 * (1.0 - zoomValue);
          final centerIndex = (cardCount - 1) / 2.0;
          double offsetX = (index - centerIndex) * 50 * (1.0 - zoomValue);
          double rotationZ = (1.0 - zoomValue) * 0.15 * (index - centerIndex).sign;

          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..translate(offsetX, initialOffsetY)
            ..scale(scale)
            ..rotateZ(rotationZ)
            ..rotateY(flipValue * pi);

          return Opacity(
            opacity: opacity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedOpacity(
                  opacity: !isVisuallyBack && flipController.isCompleted ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      positionLabel,
                      style: GoogleFonts.cinzel(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Transform(
                  transform: transform,
                  alignment: Alignment.center,
                  child: isVisuallyBack
                      ? _buildCardBack()
                      : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildCardFront(card),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _buildCardFront(TarotCard card) {
    // ... (Bu fonksiyon aynı kalır)
    const double cardWidth = 100;
    const double cardHeight = 170;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
        image: DecorationImage(
          image: AssetImage('assets/tarot_card_images/${card.img}'),
          fit: BoxFit.contain,
          onError: (exception, stackTrace) {
            if (kDebugMode) {
              print("Resim yüklenemedi: ${card.img} - Hata: $exception");
            }
          },
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(2, 5),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
      ),
    );
  }

  Widget _buildCardBack() {
    // ... (Bu fonksiyon aynı kalır)
    const double cardWidth = 100;
    const double cardHeight = 170;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade800, Colors.indigo.shade900],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        image: const DecorationImage(
          image: AssetImage('assets/tarot_card_images/card_back.png'),
          fit: BoxFit.cover,
          opacity: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.3), width: 1),
      ),
    );
  }

  // --- Layout Fonksiyonları (_buildCardLayout, _buildCelticCrossLayout, vs.) ---
  // Bu fonksiyonların içeriği aynı kalır, sadece içlerindeki _buildCardWidget
  // çağrıları artık _playSound üzerinden ducking mekanizmasını tetikler.
  Widget _buildCardLayout(BuildContext context) {
    // ... (İçerik aynı, sadece _reshuffleCards çağrısı güncellendi)
    final SpreadType currentSpreadType = widget.spreadType;
    final loc = S.of(context)!;
    final int cardCount = widget.spreadType.cardCount;
    final bool cardsDrawn = this.cardsDrawn;
    final DateTime readingDate = this.readingDate;
    final String locale = this.locale;

    if (!cardsDrawn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                loc.selectToDraw,
                style: GoogleFonts.cinzel(fontSize: 20, color: Colors.white70, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            _hasSufficientInitialResources
                ? SlideToDrawButton(onDrawComplete: _reshuffleCards) // _reshuffleCards çağrısı burada
                : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                loc.checkingResources,
                style: GoogleFonts.cinzel(fontSize: 16, color: Colors.white54),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    // buildSpreadLayoutWrapper ve diğer layout fonksiyonları aynı kalır...
    Widget buildSpreadLayoutWrapper(List<int> indices, List<String> positions) {
      if (indices.length != cardCount || positions.length != cardCount) {
        if (kDebugMode) {
          print("Layout Hatası: indices (${indices.length}) veya positions "
              "(${positions.length}) uzunluğu cardCount ($cardCount) ile eşleşmiyor: ${widget.spreadType}");
        }
        return Center(child: Text("Layout yapılandırma hatası.", style: TextStyle(color: Colors.red)));
      }

      switch (currentSpreadType) {
        case SpreadType.celticCross:
          return _buildCelticCrossLayout(indices, positions);
        case SpreadType.yearlySpread:
          return _buildYearlySpreadLayout(indices, positions);
        case SpreadType.fiveCardPath:
          return _buildFiveCardPathLayout(indices, positions);
        case SpreadType.relationshipSpread:
          return _buildRelationshipSpreadLayout(indices, positions);
        default:
        // Özel layout olmayanlar için Wrap kullanarak 3'lü sıra oluştur
          return Center(
            child: SingleChildScrollView( // Dikey scroll için
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
              child: Wrap(
                alignment: WrapAlignment.center, // Ortala
                crossAxisAlignment: WrapCrossAlignment.center, // Dikeyde ortala
                spacing: 15, // Kartlar arası yatay boşluk
                runSpacing: 30, // Satırlar arası dikey boşluk
                children: List.generate(indices.length, (index) {
                  // Kart genişliği + spacing hesabı ile yaklaşık 3 kart sığacak şekilde ayarlanabilir.
                  // Ancak Wrap bunu genellikle otomatik yapar.
                  return _buildCardWidget(indices[index], positions[index]);
                }),
              ),
            ),
          );
      }
    }

    List<String> getMonthNames() {
      final List<String> months = [];
      final count = math.min(cardCount, 13);
      for (int i = 0; i < count; i++) {
        final date = DateTime(readingDate.year, readingDate.month + i);
        final monthName = DateFormat('MMMM', locale).format(date);
        months.add(monthName);
      }
      if (cardCount == 13 && count == 13) {
        months[12] = loc.yearlySpreadSummary;
      } else if (cardCount > count) {
        for (int i = count; i < cardCount; i++) {
          months.add(loc.cardLabel(i + 1));
        }
      }
      return months;
    }

    switch (currentSpreadType) {
      case SpreadType.singleCard:
      // `selectedCards` listesinin boş olmadığından ve index 0'ın geçerli olduğundan emin ol
        if (selectedCards.isNotEmpty) {
          // Pozisyon listesi olarak `loc.singleCard` yerine `selectedCards[0].name` kullan
          return buildSpreadLayoutWrapper([0], [selectedCards[0].name]);
        } else {
          // Eğer selectedCards boşsa (beklenmedik durum), hata göster veya varsayılanı kullan
          if (kDebugMode) { print("Hata: Tek kart açılımı için selectedCards boş!"); }
          return buildSpreadLayoutWrapper([0], [loc.singleCard]); // Varsayılana geri dön
        }
      case SpreadType.pastPresentFuture:
        return buildSpreadLayoutWrapper(
          [0, 1, 2],
          [loc.celticCrossPast, loc.celticCrossCurrentSituation, loc.celticCrossFuture],
        );
      case SpreadType.problemSolution:
        return buildSpreadLayoutWrapper(
          [0, 1, 2],
          [loc.problem, loc.obstacleAdvice, loc.solution],
        );
      case SpreadType.celticCross:
        return buildSpreadLayoutWrapper(
          List.generate(10, (i) => i),
          [
            loc.celticCrossCurrentSituation, loc.celticCrossChallenge, loc.celticCrossSubconscious,
            loc.celticCrossPast, loc.celticCrossConscious, loc.celticCrossFuture,
            loc.celticCrossPersonalStance, loc.celticCrossExternalInfluences, loc.celticCrossHopesFears,
            loc.celticCrossFinalOutcome,
          ],
        );
      case SpreadType.yearlySpread:
        return buildSpreadLayoutWrapper(
          List.generate(cardCount, (i) => i),
          getMonthNames(),
        );
      case SpreadType.fiveCardPath:
        return buildSpreadLayoutWrapper(
          [0, 1, 2, 3, 4],
          [
            loc.fiveCardPathPast, loc.fiveCardPathPresent, loc.fiveCardPathChallenge,
            loc.fiveCardPathFuture, loc.fiveCardPathOutcome,
          ],
        );
      case SpreadType.relationshipSpread:
        return buildSpreadLayoutWrapper(
          List.generate(7, (i) => i),
          [
            loc.relationshipSelf, loc.relationshipPartner, loc.relationshipPast,
            loc.relationshipPresent, loc.relationshipFuture, loc.relationshipStrengths,
            loc.relationshipChallenges,
          ],
        );
      case SpreadType.mindBodySpirit:
        return buildSpreadLayoutWrapper(
          [0, 1, 2],
          [loc.mindBodySpiritMind, loc.mindBodySpiritBody, loc.mindBodySpiritSpirit],
        );
      case SpreadType.astroLogicalCross:
        return buildSpreadLayoutWrapper(
          [0, 1, 2, 3, 4],
          [
            loc.astroLogicalCrossIdentity, loc.astroLogicalCrossEmotional, loc.astroLogicalCrossExternal,
            loc.astroLogicalCrossChallenge, loc.astroLogicalCrossDestiny
          ],
        );
      case SpreadType.brokenHeart:
        return buildSpreadLayoutWrapper(
          [0, 1, 2, 3, 4],
          [
            loc.brokenHeartCause, loc.brokenHeartEmotion, loc.brokenHeartLesson,
            loc.brokenHeartHope, loc.brokenHeartHealing,
          ],
        );
      case SpreadType.dreamInterpretation:
        return buildSpreadLayoutWrapper(
          [0, 1, 2],
          [
            loc.dreamInterpretationPast, loc.dreamInterpretationPresent, loc.dreamInterpretationFuture,
          ],
        );
      case SpreadType.horseshoeSpread:
        return buildSpreadLayoutWrapper(
          List.generate(7, (i) => i),
          [
            loc.horseshoePast, loc.horseshoePresent, loc.horseshoeFuture, loc.horseshoeUserAttitude,
            loc.horseshoeExternalInfluence, loc.horseshoeAdvice, loc.horseshoeOutcome
          ],
        );
      case SpreadType.careerPathSpread:
        return buildSpreadLayoutWrapper(
          [0, 1, 2, 3, 4],
          [
            loc.careerPathCurrent, loc.careerPathObstacles, loc.careerPathOpportunities,
            loc.careerPathStrengths, loc.careerPathOutcome
          ],
        );
      case SpreadType.fullMoonSpread:
        return buildSpreadLayoutWrapper(
          List.generate(6, (i) => i),
          [
            loc.fullMoonCulmination, loc.fullMoonRevealed, loc.fullMoonRelease,
            loc.fullMoonObstacles, loc.fullMoonAction, loc.fullMoonResultingEnergy
          ],
        );
      case SpreadType.categoryReading:
        return buildSpreadLayoutWrapper(
          List.generate(cardCount, (i) => i),
          List.generate(cardCount, (i) => "${widget.categoryKey.capitalizeFirstofEach()} - ${loc.cardLabel(i+1)}"),
        );
    }
  }

  Widget _buildCelticCrossLayout(List<int> indices, List<String> positions) {
    // ... (Aynı kalır)
    if (indices.length < 10 || positions.length < 10) {
      return const Center(
          child: Text("Celtic Cross için yeterli kart/pozisyon yok (10 adet gerekli)",
              style: TextStyle(color: Colors.red)));
    }

    const double cardWidth = 80;
    const double cardHeight = cardWidth * 1.7;
    const double hSpacing = 50.0;
    const double vSpacing = 50.0;
    const double staffSpacing = 10.0;
    const double staffLeftMargin = 20.0;

    final double crossVisualWidth = cardWidth + hSpacing + cardHeight + hSpacing + cardWidth;
    final double crossVisualHeight = cardHeight + vSpacing + cardHeight + vSpacing + cardHeight;

    final double staffHeight = cardHeight * 4 + staffSpacing * 3;

    final double stackWidth = crossVisualWidth;
    final double stackHeight = crossVisualHeight;

    final double totalContentWidth = stackWidth + staffLeftMargin + cardWidth;

    final double totalContentHeight = math.max(staffHeight, stackHeight);

    const double horizontalPadding = 20.0;
    const double verticalPadding = 20.0;

    final double verticalOffset = (cardHeight / 2) + vSpacing + (cardHeight / 2);
    final double horizontalOffset = (cardWidth / 2) + hSpacing + (cardHeight / 2);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: verticalPadding),
        child:
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: SizedBox(
            width: totalContentWidth*1.2,
            height: totalContentHeight*1.2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: stackWidth,
                  height: stackHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Transform.translate(
                        offset: Offset(0, verticalOffset),
                        child: _buildCardWidget(indices[2], positions[2]),
                      ),
                      Transform.translate(
                        offset: Offset(-horizontalOffset, 0),
                        child: _buildCardWidget(indices[3], positions[3]),
                      ),
                      Transform.translate(
                        offset: Offset(horizontalOffset, 0),
                        child: _buildCardWidget(indices[5], positions[5]),
                      ),
                      Transform.translate(
                        offset: Offset(0, -verticalOffset),
                        child: _buildCardWidget(indices[4], positions[4]),
                      ),
                      _buildCardWidget(indices[0], positions[0]),
                      Transform.rotate(
                        angle: -math.pi / 1.8,
                        child: _buildCardWidget(indices[1], positions[1]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: staffLeftMargin),

                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCardWidget(indices[9], positions[9]),
                    _buildCardWidget(indices[8], positions[8]),
                    _buildCardWidget(indices[7], positions[7]),
                    _buildCardWidget(indices[6], positions[6]),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFiveCardPathLayout(List<int> indices, List<String> positions) {
    // ... (Aynı kalır)
    if (indices.length < 5 || positions.length < 5) {
      // SpreadType.fiveCardPath 5 kart gerektirir, bu kontrol kalabilir.
      // Eğer başka kart sayıları ile de bu layout kullanılırsa, kontrol güncellenebilir.
      return const Center(child: Text("Five Card Path için yeterli kart/pozisyon yok (5 adet gerekli)", style: TextStyle(color: Colors.red)));
    }

    // --- GÜNCELLENMİŞ KISIM BAŞLANGICI ---
    // Wrap widget'ı kullanarak kartları düzenle
    return Center(
      child: SingleChildScrollView( // Dikeyde taşma olursa kaydırmak için
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
        child: Wrap(
          alignment: WrapAlignment.center, // Kartları satır içinde ve genel olarak ortala
          crossAxisAlignment: WrapCrossAlignment.center, // Dikeyde de ortalamayı dene
          spacing: 15.0, // Kartlar arasındaki yatay boşluk
          runSpacing: 30.0, // Satırlar arasındaki dikey boşluk
          children: List.generate(indices.length, (i) {
            // Her bir kart için _buildCardWidget'ı çağır
            return _buildCardWidget(indices[i], positions[i]);
          }),
        ),
      ),
    );
  }

  Widget _buildRelationshipSpreadLayout(List<int> indices, List<String> positions) {
    // ... (Aynı kalır)
    if (indices.length < 7 || positions.length < 7) {
      return const Center(child: Text("Relationship Spread için yeterli kart/pozisyon yok", style: TextStyle(color: Colors.red)));
    }

    const double hSpacing = 30.0;
    const double vSpacing = 30.0;
    const double midRowHSpacing = 25.0;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicWidth(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCardWidget(indices[0], positions[0]),
                    const SizedBox(width: hSpacing),
                    _buildCardWidget(indices[1], positions[1]),
                  ],
                ),
                const SizedBox(height: vSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCardWidget(indices[2], positions[2]),
                    const SizedBox(width: midRowHSpacing),
                    _buildCardWidget(indices[3], positions[3]),
                    const SizedBox(width: midRowHSpacing),
                    _buildCardWidget(indices[4], positions[4]),
                  ],
                ),
                const SizedBox(height: vSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCardWidget(indices[5], positions[5]),
                    const SizedBox(width: hSpacing),
                    _buildCardWidget(indices[6], positions[6]),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYearlySpreadLayout(List<int> indices, List<String> positions) {
    // ... (Aynı kalır)
    if (indices.length < 12 || positions.length < indices.length) {
      return Center(child: Text("Yıllık Açılım için yeterli kart/pozisyon yok (${indices.length})", style: TextStyle(color: Colors.red)));
    }

    const double cardWidth = 85;
    const double cardHeight = cardWidth * 1.6;
    const double centerCardPadding = 25.0;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double minScreenDim = math.min(screenWidth, screenHeight);
    final double radius = math.max(150.0, minScreenDim * 0.28);

    final bool hasCenterCard = (cardCount == 13);
    final double layoutDiameter = radius * 2 + cardWidth + centerCardPadding * (hasCenterCard ? 1 : 0);
    final double layoutHeight = radius * 2 + cardHeight + centerCardPadding * (hasCenterCard ? 1 : 0);

    final int centerCardIndex = hasCenterCard ? 12 : -1;
    final int circleCardCount = hasCenterCard ? 12 : cardCount;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: layoutDiameter + 40,
              minHeight: layoutHeight + 60,
            ),
            child: SizedBox(
              width: layoutDiameter,
              height: layoutHeight,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  ...List.generate(circleCardCount, (index) {
                    final double angle = (math.pi * 2 / circleCardCount) * index - (math.pi / 2);
                    final double x = radius * math.cos(angle);
                    final double y = radius * math.sin(angle);
                    return Positioned(
                      left: layoutDiameter / 2 + x - (cardWidth / 2),
                      top: layoutHeight / 2 + y - (cardHeight / 2),
                      child: _buildCardWidget(indices[index], positions[index]),
                    );
                  }),
                  if (centerCardIndex != -1)
                    Positioned(
                      left: layoutDiameter / 2 - (cardWidth / 2),
                      top: layoutHeight / 2 - (cardHeight / 2),
                      child: _buildCardWidget(indices[centerCardIndex], positions[centerCardIndex]),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return BlocListener<TarotBloc, TarotState>(
      listener: (context, state) {
        // ... (Listener aynı kalır)
        if (state is TarotError) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent)
          );
          if (isLoading && mounted) setState(() => isLoading = false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // ... (AppBar aynı kalır)
          title: Text(
              widget.spreadType.name.replaceAllMapped(
                  RegExp(r'(?<=[a-z])(?=[A-Z])'), (match) => ' ').capitalizeFirstofEach(),
              style: GoogleFonts.cinzel(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple[900]!, Colors.purple[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline_rounded, color: Colors.white70),
              tooltip: loc!.instructions,
              onPressed: () => _showHelpDialog(context),
            ),
          ],
        ),
        body: BlocBuilder<TarotBloc, TarotState>(
            builder: (context, state) {
              // ... (Resource check aynı kalır)
              if (!_hasCheckedInitialResources && mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _performInitialResourceCheck(state);
                  }
                });
              }
              // ... (Body yapısı aynı kalır)
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.deepPurple[900]!, Colors.black],
                        stops: const [0.0, 0.8],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Expanded(
                        child: isLoading
                            ? Center(child: Lottie.asset('assets/animations/tarot_loading.json', width: 150, height: 150))
                            : _buildCardLayout(context),
                      ),
                      _buildActionButtons(),
                    ],
                  ),
                  if (!_hasSufficientInitialResources && _hasCheckedInitialResources)
                    Container(
                      color: Colors.black.withOpacity(0.75),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline_rounded, color: Colors.orangeAccent[100], size: 50),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30.0),
                              child: Text(
                                loc.insufficientCreditsMessage(_requiredTokensForSpread.toStringAsFixed(0)),
                                style: GoogleFonts.cinzel(color: Colors.orangeAccent[100], fontSize: 17),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 25),
                            ElevatedButton.icon(
                              icon: Icon(Icons.shopping_cart_checkout_rounded, size: 18),
                              label: Text(loc.purchaseCredits),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purpleAccent.shade100,
                                  foregroundColor: Colors.black87,
                                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                                  textStyle: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 15)
                              ),
                              onPressed: () => _showPaymentDialog(context, _requiredTokensForSpread),
                            )
                          ],
                        ),
                      ),
                    ),
                ],
              );
            }
        ),
      ),
    );
  }
}



class SlideToDrawButton extends StatefulWidget {
  final VoidCallback onDrawComplete;

  const SlideToDrawButton({
    super.key,
    required this.onDrawComplete,
  });

  @override
  SlideToDrawButtonState createState() => SlideToDrawButtonState();
}

class SlideToDrawButtonState extends State<SlideToDrawButton> with TickerProviderStateMixin {
  double _dragValue = 0.0;
  bool _isDragging = false;

  late AnimationController _pulseController;
  late AnimationController _resetController;
  late AnimationController _successController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _resetAnimation; // Bu artık _startResetAnimation içinde tanımlanacak
  late Animation<double> _successScaleAnimation;
  late Animation<double> _successGlowAnimation;

  late final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioPlayerInitialized = false;
  bool _isSoundPlaying = false;
  final String _slideSoundPath = 'audios/transitional-swipe.mp3'; // Ses dosyasının yolu

  static const double _buttonWidth = 280.0;
  static const double _handleSize = 60.0;
  static const Duration _resetDuration = Duration(milliseconds: 350);
  static const Duration _successDuration = Duration(milliseconds: 500);
  static const Duration _pulseDuration = Duration(milliseconds: 1500);
  final double _draggableWidth = _buttonWidth - _handleSize;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeAudioPlayer();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(duration: _pulseDuration, vsync: this)
      ..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);

    _resetController = AnimationController(duration: _resetDuration, vsync: this)
    // Listener'ı _startResetAnimation içinde ekleyeceğiz
      ..addStatusListener(_handleResetStatus);

    _successController = AnimationController(duration: _successDuration, vsync: this);
    _successScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _successController, curve: Curves.elasticOut)
    );
    _successGlowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.8), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 0.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _successController, curve: Curves.easeOut))
      ..addStatusListener(_handleSuccessStatus);
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      // Gerekirse player ayarları (örn. low latency mode) burada yapılabilir
      _isAudioPlayerInitialized = true;
      if (kDebugMode) print("AudioPlayer initialized for SlideToDrawButton.");
    } catch (e) {
      if (kDebugMode) print("Error initializing AudioPlayer: $e");
      _isAudioPlayerInitialized = false;
    }
  }

  // Reset animasyonu tamamlandığında çağrılır
  void _handleResetStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (mounted && !_isDragging) {
        // Reset tamamlandığında _dragValue'nun 0 olduğundan emin ol
        // _startResetAnimation listener'ı zaten değeri güncelliyor olmalı
        // setState(() { _dragValue = 0.0; }); // Bu satır gereksiz olabilir
        _tryRepeatPulse(); // Pulse animasyonunu tekrar başlatmayı dene
      }
    }
  }

  // Başarı animasyonu tamamlandığında çağrılır
  void _handleSuccessStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onDrawComplete(); // Ana callback'i tetikle
      // Kısa bir gecikme sonrası butonu eski haline getir
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          // 1.0'dan başlayarak reset animasyonunu başlat
          _startResetAnimation(fromValue: 1.0);
          _successController.reset(); // Başarı kontrolcüsünü sıfırla
        }
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _resetController.dispose();
    _successController.dispose();
    _stopSlideSound(); // Sesi durdur
    _audioPlayer.dispose(); // Player'ı serbest bırak
    super.dispose();
  }

  // Kaydırma başladığında
  void _onDragStart(DragStartDetails details) {
    // Eğer başka bir animasyon çalışıyorsa veya zaten sürükleniyorsa işlem yapma
    if (_isDragging || _resetController.isAnimating || _successController.isAnimating) return;
    if (mounted) {
      setState(() {
        _isDragging = true;
        // Çalışan animasyonları durdur
        if (_resetController.isAnimating) _resetController.stop();
        if (_pulseController.isAnimating) _pulseController.stop();
      });
      HapticFeedback.lightImpact(); // Hafif titreşim
      _startSlideSound(); // Kaydırma sesini başlat
    }
  }

  // Kaydırma devam ederken
  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging || !mounted) return;
    setState(() {
      // Mevcut sürükleme değerini güncelle
      final currentDragPixels = _dragValue * _draggableWidth;
      // Yeni pozisyonu hesapla ve 0 ile sürükleme alanı genişliği arasında sınırla
      final newDragPixels = (currentDragPixels + details.delta.dx).clamp(0.0, _draggableWidth);
      // Yeni değeri 0.0 ile 1.0 arasına normalize et
      _dragValue = newDragPixels / _draggableWidth;
    });
  }

  // Kaydırma bittiğinde
  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging || !mounted) return;
    // Belirli bir eşiği (%85) geçtiyse başarılı say
    final bool isSuccess = _dragValue > 0.85;
    _stopSlideSound(); // Kaydırma sesini durdur

    if (isSuccess) {
      HapticFeedback.heavyImpact(); // Başarılı titreşim
      // Başarı animasyonunu başlat
      _successController.forward(from: 0.0);
    } else {
      HapticFeedback.lightImpact(); // Başarısız titreşim
      // Mevcut pozisyondan sıfıra dönme animasyonunu başlat
      _startResetAnimation(fromValue: _dragValue);
    }
    // Sürükleme bitti olarak işaretle
    setState(() => _isDragging = false);
  }

  // Reset animasyonunu BAŞLATIRKEN tween'i ve listener'ı oluştur/güncelle
  void _startResetAnimation({required double fromValue}) {
    if (!mounted) return;

    // Mevcut listener'ları temizle (önceki animasyondan kalmış olabilir)
    _resetAnimation.removeListener(_updateDragValueFromReset);
    _resetAnimation = Tween<double>(begin: fromValue, end: 0.0).animate(
        CurvedAnimation(parent: _resetController, curve: Curves.easeOutCirc)
    )
    // Yeni listener'ı ekle
      ..addListener(_updateDragValueFromReset);
    // Status listener zaten initState'te eklenmişti, tekrar eklemeye gerek yok

    _resetController.forward(from: 0.0); // Animasyonu başlat
  }

  // Reset animasyonu sırasında _dragValue'yu güncelleyen listener
  void _updateDragValueFromReset() {
    if (mounted) {
      setState(() {
        // Animasyonun mevcut değerini doğrudan _dragValue'ya ata
        _dragValue = _resetAnimation.value;
      });
    }
  }


  // Pulse animasyonunu güvenli bir şekilde tekrar başlatmayı dener
  void _tryRepeatPulse() {
    // Eğer widget hala ekranda ise, pulse animasyonu çalışmıyorsa,
    // sürükleme veya diğer animasyonlar aktif değilse başlat
    if (mounted && !_pulseController.isAnimating && !_isDragging && !_resetController.isAnimating && !_successController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  // Kaydırma sesini başlatır
  Future<void> _startSlideSound() async {
    if (!_isAudioPlayerInitialized || _isSoundPlaying) return;
    try {
      // Sadece durmuş veya tamamlanmışsa yeniden başlat
      if (_audioPlayer.state == PlayerState.stopped || _audioPlayer.state == PlayerState.completed ) {
        await _audioPlayer.setSource(AssetSource(_slideSoundPath)); // Kaynağı ayarla
        await _audioPlayer.play(AssetSource(_slideSoundPath), volume: 0.6, mode: PlayerMode.lowLatency);
        if (mounted) setState(() => _isSoundPlaying = true);
        if (kDebugMode) print("Slide sound started.");
      } else if (_audioPlayer.state == PlayerState.paused) {
        await _audioPlayer.resume();
        if (mounted) setState(() => _isSoundPlaying = true);
        if (kDebugMode) print("Slide sound resumed.");
      }
    } catch (e) {
      if (kDebugMode) print("Error starting slide sound: $e");
      if (mounted) setState(() => _isSoundPlaying = false);
    }
  }

  // Kaydırma sesini durdurur
  Future<void> _stopSlideSound() async {
    if (!_isAudioPlayerInitialized || _audioPlayer.state == PlayerState.stopped || _audioPlayer.state == PlayerState.completed) return;
    try {
      await _audioPlayer.stop(); // Stop kullanmak genellikle daha güvenli
      if (mounted) setState(() => _isSoundPlaying = false);
      if (kDebugMode) print("Slide sound stopped.");
    } catch (e) {
      if (kDebugMode) print("Error stopping slide sound: $e");
      if (mounted) setState(() => _isSoundPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build metodu içinde yerelleştirme nesnesini al
    final loc = S.of(context);
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        // Dinlenecek kontrolcüleri birleştir
        animation: Listenable.merge([_successController, _resetController, _pulseController]),
        builder: (context, child) {
          // Animasyon değerlerini al
          final successScale = _successScaleAnimation.value;
          final successGlow = _successGlowAnimation.value;
          // Handle pozisyonunu state'den al
          final handlePosition = _dragValue * _draggableWidth;

          // Başarı animasyonu için ölçeklendirme uygula
          return Transform.scale(
            scale: successScale,
            child: Container(
              width: _buttonWidth,
              height: _handleSize,
              clipBehavior: Clip.antiAlias, // Taşmaları engelle
              decoration: _buildBackgroundDecoration(successGlow), // Arka planı oluştur
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Metin katmanlarını oluştur (loc parametresi ile)
                  _buildTextOverlays(context, loc!),
                  // Sürüklenen handle'ı oluştur
                  _buildHandle(handlePosition),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Butonun arka planını oluşturan yardımcı metot
  BoxDecoration _buildBackgroundDecoration(double successGlow) {
    return BoxDecoration(
      // Soldan sağa değişen gradient
      gradient: LinearGradient(
        colors: [
          Colors.deepPurple.shade800.withOpacity(0.8),
          // Renk, sürükleme miktarına göre deepPurple ile pinkAccent arasında değişir
          Color.lerp(Colors.deepPurple.shade800, Colors.pinkAccent.shade400, _dragValue)!,
        ],
        // Gradient'in durma noktaları sürüklemeye göre ayarlanır
        stops: [0.0, (_dragValue + 0.1).clamp(0.0, 1.0)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      // Yuvarlak köşeler
      borderRadius: BorderRadius.circular(_handleSize / 2),
      // Gölgeler
      boxShadow: [
        // Normal gölge (sürüklemeye göre rengi ve boyutu değişir)
        BoxShadow(
          color: Color.lerp(Colors.purple, Colors.pinkAccent, _dragValue)!.withOpacity(lerpDouble(0.2, 0.5, _dragValue)!),
          blurRadius: lerpDouble(8, 15, _dragValue)!,
          offset: const Offset(0, 4),
        ),
        // Başarı durumunda parlama efekti
        BoxShadow(
          color: Colors.pinkAccent.withOpacity(successGlow * 0.8),
          blurRadius: 25 * successGlow,
          spreadRadius: 8 * successGlow,
        ),
      ],
      // Kenarlık
      border: Border.all(color: Colors.purpleAccent.withOpacity(0.3 + successGlow * 0.5), width: 1.5),
    );
  }

  // Buton üzerindeki metin katmanlarını oluşturan yardımcı metot
  Widget _buildTextOverlays(BuildContext context, S loc) {
    // Handle pozisyonu ve metin opaklık/konum hesaplamaları
    final handlePosition = _dragValue * _draggableWidth;
    final initialTextOpacity = math.max(0.0, 1.0 - _dragValue * 3.5);
    final initialTextOffset = lerpDouble(0, -50, _dragValue)!;
    final initialTextLeftPadding = _handleSize + 15.0; // Handle'ın sağından başla
    final mysticTextOpacity = math.max(0.0, (_dragValue - 0.3) * 2.0).clamp(0.0, 1.0);

    return Stack(
      children: [
        // Başlangıç metni ("Slide to Draw Cards")
        Positioned(
          left: initialTextLeftPadding,
          right: _handleSize * 0.05, // Sağdan hafif boşluk
          top: 0, bottom: 0,
          child: Center(
            child: Opacity(
              opacity: initialTextOpacity, // Sürükledikçe kaybolur
              child: Transform.translate(
                offset: Offset(initialTextOffset, 0), // Sola doğru kayar
                child: Text(
                  loc.slideToDrawCards, // Yerelleştirilmiş metin
                  style: GoogleFonts.cinzel( color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1, decoration: TextDecoration.none),
                  overflow: TextOverflow.clip, maxLines: 1, softWrap: false,
                ),
              ),
            ),
          ),
        ),
        // Kaydırma alanı üzerinde görünen metin ("Unveil the Stars")
        Positioned.fill(
          child: ClipRect(
            // Sadece handle'ın kapladığı alanı gösteren kırpıcı
            clipper: _SlideAreaClipper( clipAmount: handlePosition + (_handleSize * 0.6), handleSize: _handleSize ),
            child: Container(
              // Kırpılan alanın arka planı (gradient)
              decoration: BoxDecoration(
                gradient: LinearGradient( colors: [ Colors.purpleAccent.withOpacity(0.3), Colors.pinkAccent.withOpacity(0.5),], begin: Alignment.centerLeft, end: Alignment.centerRight,),
                borderRadius: BorderRadius.circular(_handleSize / 2),
              ),
              alignment: Alignment.center,
              child: Padding(
                // Metni handle'ın ortasına denk getirmek için padding
                padding: EdgeInsets.only(right: _handleSize * 0.4),
                child: Opacity(
                  opacity: mysticTextOpacity, // Sürükledikçe belirginleşir
                  child: Text(
                    loc.unveilTheStars, // Yerelleştirilmiş metin
                    style: GoogleFonts.cinzelDecorative( color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2, decoration: TextDecoration.none),
                    overflow: TextOverflow.clip, maxLines: 1, softWrap: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Sürüklenen handle (yuvarlak ikon) widget'ını oluşturan yardımcı metot
  Widget _buildHandle(double handlePosition) {
    // Pulse animasyonunun sadece dururken aktif olup olmadığını kontrol et
    final bool canPulse = !_isDragging && !_resetController.isAnimating && !_successController.isAnimating;
    // Pulse animasyon değerlerini hesapla
    final double pulseScale = canPulse ? (1.0 + (_pulseAnimation.value * 0.08)) : 1.0;
    final double pulseGlow = canPulse ? (_pulseAnimation.value * 0.25) : 0.0;

    // Handle'ı doğru pozisyonda konumlandır
    return Positioned(
      left: handlePosition,
      child: Transform.scale( // Pulse ölçeklendirmesi
        scale: pulseScale,
        child: Container(
          width: _handleSize,
          height: _handleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle, // Yuvarlak şekil
            // İç gradient
            gradient: RadialGradient( colors: [ Colors.pinkAccent.shade100, Colors.purpleAccent.shade400, ], stops: const [0.2, 1.0], radius: 0.7,),
            // Gölge (sürüklemeye ve pulse'a göre değişir)
            boxShadow: [
              BoxShadow( color: Color.lerp(Colors.purpleAccent, Colors.pinkAccent, _dragValue)!.withOpacity( lerpDouble(0.5, 0.8, _dragValue)! + pulseGlow ), blurRadius: lerpDouble(10, 16, _dragValue)! + (pulseGlow * 12), spreadRadius: lerpDouble(2, 4, _dragValue)! + (pulseGlow * 3))
            ],
          ),
          // Ortadaki ikon
          child: Center(
            child: Icon( Icons.auto_awesome, // Yıldız ikonu
              // İkon rengi ve boyutu sürüklemeye göre değişir
              color: Color.lerp(Colors.deepPurple.shade900, Colors.white, _dragValue * 1.8)!.withOpacity(0.9),
              size: lerpDouble(28, 34, _dragValue)!,
            ),
          ),
        ),
      ),
    );
  }
}


// --- Custom Clipper (Alan Kırpıcı - Slide Butonu İçin Gerekli) ---
// Belirtilen genişlik kadar olan alanı görünür kılar.
class _SlideAreaClipper extends CustomClipper<Rect> {
  final double clipAmount; // Ne kadar alanın gösterileceği (piksel)
  final double handleSize; // Handle boyutu (kırpma buna göre ayarlanır)

  _SlideAreaClipper({required this.clipAmount, required this.handleSize});

  @override
  Rect getClip(Size size) {
    // Soldan başlayarak 'clipAmount' genişliğinde bir dikdörtgen alanı görünür kıl.
    // clipAmount'ın 0 ile size.width arasında kalmasını sağla.
    return Rect.fromLTWH(0, 0, clipAmount.clamp(0.0, size.width), size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    // Sadece clipAmount veya handleSize değiştiğinde tekrar kırpma yap (performans için)
    return oldClipper is! _SlideAreaClipper ||
        oldClipper.clipAmount != clipAmount ||
        oldClipper.handleSize != handleSize;
  }
}

