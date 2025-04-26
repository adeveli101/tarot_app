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







/// Kullanıcının kartları çekmek için yatay olarak kaydırması gereken buton.
class SlideToDrawButton extends StatefulWidget {
  final VoidCallback onDrawComplete; // Kaydırma tamamlandığında tetiklenir

  const SlideToDrawButton({
    super.key,
    required this.onDrawComplete,
  });

  @override
  SlideToDrawButtonState createState() => SlideToDrawButtonState();
}

class SlideToDrawButtonState extends State<SlideToDrawButton> with TickerProviderStateMixin {
  // --- State ve Animasyon Değişkenleri ---
  double _dragValue = 0.0; // 0.0 (başlangıç) ile 1.0 (bitiş) arası kaydırma değeri
  bool _isDragging = false; // Kullanıcı şu anda butonu kaydırıyor mu?

  // Animasyon kontrolcüleri
  late AnimationController _pulseController; // Bekleme durumundaki hafif parlama efekti için
  late AnimationController _resetController; // Başarısız kaydırma sonrası geri dönüş animasyonu için
  late AnimationController _successController; // Başarılı kaydırma sonrası efekt için

  // Animasyonlar
  late Animation<double> _pulseAnimation;
  late Animation<double> _resetAnimation;
  late Animation<double> _successScaleAnimation; // Başarıda hafif büyüme
  late Animation<double> _successGlowAnimation; // Başarıda parlama

  // Buton boyutları ve animasyon süreleri
  final double _buttonWidth = 280.0; // Buton genişliği
  final double _handleSize = 60.0; // Kaydırılan dairenin boyutu
  final Duration _resetDuration = const Duration(milliseconds: 350); // Geri dönüş süresi
  final Duration _successDuration = const Duration(milliseconds: 500); // Başarı animasyon süresi

  @override
  void initState() {
    super.initState();

    // Pulse Animasyonu (bekleme durumu)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500), // Daha yavaş bir pulse
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);

    // Reset Animasyonu (başarısız kaydırma)
    _resetController = AnimationController(duration: _resetDuration, vsync: this);
    // _resetAnimation, _onDragEnd içinde dinamik olarak oluşturulur (başlangıç değeri için)
    _resetAnimation = CurvedAnimation(parent: _resetController, curve: Curves.easeOutCirc)
      ..addListener(() {
        if (mounted) {
          // Geri dönüş animasyonu sırasında _dragValue'yu güncelle
          setState(() => _dragValue = lerpDouble(_resetAnimation.value, 0.0, _resetController.value)!);
        }
      })
      ..addStatusListener((status) {
        // Reset bittiğinde ve sürüklenmiyorsa pulse animasyonunu tekrar başlat
        if (status == AnimationStatus.completed) {
          if (mounted && !_isDragging) _pulseController.repeat(reverse: true);
        }
      });

    // Success Animasyonu (başarılı kaydırma)
    _successController = AnimationController(duration: _successDuration, vsync: this);
    _successScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate( // Biraz daha belirgin büyüme
        CurvedAnimation(parent: _successController, curve: Curves.elasticOut) // Elastik efekt
    );
    _successGlowAnimation = TweenSequence<double>([ // Parlama efekti (hızlı artıp yavaş sönme)
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.8), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 0.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _successController, curve: Curves.easeOut));

    // Başarı animasyonu bittiğinde onDrawComplete callback'ini çağır ve resetle
    _successController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDrawComplete();
        // Kısa bir bekleme sonrası reset animasyonunu başlat
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _resetAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
                CurvedAnimation(parent: _resetController, curve: Curves.easeOutCirc)
            );
            _resetController.forward(from: 0.0);
            // Başarı animasyonunu sıfırla
            _successController.reset();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _resetController.dispose();
    _successController.dispose();
    super.dispose();
  }

  // --- Sürükleme Olay Yöneticileri ---

  void _onDragStart(DragStartDetails details) {
    // Eğer zaten sürükleniyorsa veya animasyonlar aktifse yeni sürüklemeyi başlatma
    if (_isDragging || _resetController.isAnimating || _successController.isAnimating) return;
    if (mounted) {
      setState(() {
        _isDragging = true;
        _resetController.stop(); // Reset animasyonunu durdur
        _pulseController.stop(); // Pulse animasyonunu durdur
      });
    }
    HapticFeedback.lightImpact(); // Hafif titreşim
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging || !mounted) return;
    setState(() {
      // Sürükleme mesafesini hesapla ve _dragValue'yu güncelle (0.0 - 1.0 arasında)
      final currentDragPixels = _dragValue * (_buttonWidth - _handleSize);
      final newDragPixels = (currentDragPixels + details.delta.dx).clamp(0.0, _buttonWidth - _handleSize);
      _dragValue = newDragPixels / (_buttonWidth - _handleSize);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging || !mounted) return;

    // Başarı eşiğini kontrol et (%85'ten fazla kaydırıldıysa başarılı say)
    final bool success = _dragValue > 0.85;

    if (success) {
      HapticFeedback.heavyImpact(); // Başarıda güçlü titreşim
      setState(() { _dragValue = 1.0; }); // Tamamla
      _successController.forward(from: 0.0); // Başarı animasyonunu başlat
    } else {
      // Başarısızsa, mevcut pozisyondan başa dönme animasyonunu başlat
      HapticFeedback.lightImpact();
      // Reset animasyonunu mevcut _dragValue'dan başlatacak şekilde ayarla
      _resetAnimation = Tween<double>(begin: _dragValue, end: 0.0).animate(
          CurvedAnimation(parent: _resetController, curve: Curves.easeOutCirc)
      );
      _resetController.forward(from: 0.0);
    }
    setState(() => _isDragging = false); // Sürükleme bitti
  }

  // --- Build Metodu ---

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context); // Yerelleştirme
    // Kaydırılan dairenin anlık yatay pozisyonu
    final handlePosition = _dragValue * (_buttonWidth - _handleSize);

    // Başlangıçtaki "Kaydır..." metninin opaklığı ve pozisyonu (kaydırdıkça kaybolur)
    final initialTextOpacity = math.max(0.0, 1.0 - _dragValue * 3.5); // Daha hızlı kaybolsun
    final initialTextOffset = lerpDouble(0, -50, _dragValue)!; // Biraz daha fazla kaysın
    final initialTextLeftPadding = _handleSize + 15.0; // Daireden sonraki boşluk

    // Ortaya çıkan "Mistik..." metninin opaklığı (belirli bir noktadan sonra görünür olur)
    final mysticTextOpacity = math.max(0.0, (_dragValue - 0.3) * 2.0).clamp(0.0, 1.0); // Daha belirgin geçiş

    // Ana Buton Widget'ı
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _successController, // Başarı animasyonunu dinle
        builder: (context, child) {
          final successScale = _successScaleAnimation.value; // Başarıdaki ölçek değeri
          final successGlow = _successGlowAnimation.value; // Başarıdaki parlama değeri

          // Başarı animasyonu için Transform.scale
          return Transform.scale(
            scale: successScale,
            child: Container(
              width: _buttonWidth,
              height: _handleSize,
              // Kenarlardan taşan efektleri gizle (özellikle gradient geçişi için)
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                // Arka plan gradient'i (kaydırmaya göre renk değiştirir)
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade800.withOpacity(0.8),
                      // Renk geçişi (mordan pembeye)
                      Color.lerp(Colors.deepPurple.shade800, Colors.pinkAccent.shade400, _dragValue)!
                    ],
                    stops: [0.0, _dragValue + 0.1], // Gradient'in nerede biteceğini ayarla
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(_handleSize / 2), // Yuvarlak kenarlar
                  boxShadow: [ // Gölge (kaydırmaya ve başarıya göre değişir)
                    BoxShadow(
                      color: Color.lerp(Colors.purple, Colors.pinkAccent, _dragValue)!.withOpacity(lerpDouble(0.2, 0.5, _dragValue)!),
                      blurRadius: lerpDouble(8, 15, _dragValue)!,
                      offset: const Offset(0, 4),
                    ),
                    // Başarı parlaması
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(successGlow * 0.8),
                      blurRadius: 25 * successGlow,
                      spreadRadius: 8 * successGlow,
                    ),
                  ],
                  // Kenarlık (başarıda daha belirgin)
                  border: Border.all(color: Colors.purpleAccent.withOpacity(0.3 + successGlow * 0.5), width: 1.5)
              ),
              // İçerik Katmanları (Stack ile)
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // 1. Katman: Başlangıç metni ("Kaydır...")
                  Positioned(
                    left: initialTextLeftPadding,
                    right: _handleSize * 0.05, // Sağdan hafif boşluk
                    top: 0, bottom: 0, // Dikeyde ortala
                    child: Center(
                      child: Opacity(
                        opacity: initialTextOpacity, // Kaydırdıkça kaybolur
                        child: Transform.translate(
                          offset: Offset(initialTextOffset, 0), // Sola doğru kayar
                          child: Text(
                            loc?.slideToDrawCards ?? 'Kart Çekmek İçin Kaydır', // Yerelleştirme
                            style: GoogleFonts.cinzel(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                                decoration: TextDecoration.none // Önemli: Stack içinde alt çizgi olmasın
                            ),
                            overflow: TextOverflow.clip, // Taşmayı engelle
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. Katman: Kaydırma alanının dolgu efekti ve ortaya çıkan metin
                  Positioned.fill(
                    child: ClipRect(
                      // Sadece kaydırılan alan kadarını göster
                      clipper: _SlideAreaClipper(
                          clipAmount: handlePosition + (_handleSize * 0.6), // Dairenin biraz ötesine kadar
                          handleSize: _handleSize
                      ),
                      child: Container(
                        // Dolgu efekti gradient'i
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purpleAccent.withOpacity(0.3),
                              Colors.pinkAccent.withOpacity(0.5),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(_handleSize / 2),
                        ),
                        alignment: Alignment.center,
                        // Ortaya çıkan metin ("Mistik...")
                        child: Padding(
                          padding: EdgeInsets.only(right: _handleSize * 0.4), // Dairenin üzerine gelmesin
                          child: Opacity(
                            opacity: mysticTextOpacity, // Belirli bir noktadan sonra görünür olur
                            child: Text(
                              // loc.unveilTheStars gibi bir anahtar kullanın
                              loc?.unveilTheStars ?? 'Yıldızları Açığa Çıkar',
                              style: GoogleFonts.cinzelDecorative(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  decoration: TextDecoration.none
                              ),
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. Katman: Kaydırılan Daire (Handle) ve Pulse Efekti
                  AnimatedBuilder(
                    animation: _pulseAnimation, // Pulse animasyonunu dinle
                    builder: (context, child) {
                      // Sadece bekleme durumunda pulse efekti uygula
                      final bool canPulse = !_isDragging && !_resetController.isAnimating && !_successController.isAnimating;
                      final double pulseScale = canPulse ? (1.0 + (_pulseAnimation.value * 0.08)) : 1.0; // Biraz daha belirgin pulse scale
                      final double pulseGlow = canPulse ? (_pulseAnimation.value * 0.25) : 0.0; // Biraz daha belirgin pulse glow

                      // Dairenin anlık pozisyonu
                      return Positioned(
                        left: handlePosition,
                        child: Transform.scale(
                          scale: pulseScale, // Pulse ölçeklemesi
                          child: Container(
                            width: _handleSize,
                            height: _handleSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // Daire gradient'i
                              gradient: RadialGradient(
                                colors: [
                                  Colors.pinkAccent.shade100, // İç renk
                                  Colors.purpleAccent.shade400, // Dış renk
                                ],
                                stops: const [0.2, 1.0],
                                radius: 0.7,
                              ),
                              // Gölge (kaydırma ve pulse'a göre değişir)
                              boxShadow: [
                                BoxShadow(
                                    color: Color.lerp(Colors.purpleAccent, Colors.pinkAccent, _dragValue)!.withOpacity(
                                        lerpDouble(0.5, 0.8, _dragValue)! + pulseGlow // Parlama ekle
                                    ),
                                    blurRadius: lerpDouble(10, 16, _dragValue)! + (pulseGlow * 12),
                                    spreadRadius: lerpDouble(2, 4, _dragValue)! + (pulseGlow * 3)
                                )
                              ],
                            ),
                            // Daire içindeki ikon
                            child: Center(
                              child: Icon(
                                Icons.auto_awesome, // Yıldız ikonu
                                // İkon rengi ve boyutu kaydırmaya göre değişir
                                color: Color.lerp(Colors.deepPurple.shade900, Colors.white, _dragValue * 1.8)!.withOpacity(0.9),
                                size: lerpDouble(28, 34, _dragValue)!,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- Custom Clipper (Alan Kırpıcı - Slide Butonu İçin Gerekli) ---
class _SlideAreaClipper extends CustomClipper<Rect> {
  final double clipAmount; // Ne kadar alanın gösterileceği (piksel)
  final double handleSize; // Dairenin boyutu (kırpma buna göre ayarlanır)

  _SlideAreaClipper({required this.clipAmount, required this.handleSize});

  @override
  Rect getClip(Size size) {
    // Soldan başlayarak 'clipAmount' genişliğinde bir dikdörtgen alanı görünür kıl
    return Rect.fromLTWH(0, 0, clipAmount.clamp(0.0, size.width), size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    // Sadece clipAmount değiştiğinde tekrar kırpma yap
    return oldClipper is! _SlideAreaClipper || oldClipper.clipAmount != clipAmount;
  }
}