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
import '../data/payment_manager.dart'; // Import PaymentManager
import '../models/animations/tap_animations_scale.dart';
import 'package:intl/intl.dart';

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

class CardSelectionAnimationScreenState extends State<CardSelectionAnimationScreen> with TickerProviderStateMixin {
  final TarotRepository repository = TarotRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<AnimationController> _flipControllers = [];
  List<AnimationController> _zoomControllers = [];

  List<TarotCard> selectedCards = [];
  List<bool> revealed = [];
  bool isLoading = false;
  bool isFlippingAll = false;
  bool cardsDrawn = false;
  late DateTime readingDate;
  late String locale;

  // --- Resource Check State ---
  bool _hasCheckedInitialResources = false;
  bool _hasSufficientInitialResources = true; // Assume true initially
  double _requiredTokensForSpread = 0.0;
  // ---------------------------

  int get cardCount => widget.spreadType.cardCount;

  @override
  void initState() {
    super.initState();
    readingDate = DateTime.now();
    _requiredTokensForSpread = widget.spreadType.costInCredits; // Calculate required cost once

    _flipControllers = List.generate(cardCount, (_) => AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    ));
    _zoomControllers = List.generate(cardCount, (_) => AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    ));

    _loadAudioAssets();
    // Initial resource check will be done in the first build cycle via BlocBuilder
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    locale = Localizations.localeOf(context).languageCode;
    repository.setLocale(locale);
  }

  @override
  void dispose() {
    for (var controller in _flipControllers) {
      controller.dispose();
    }
    for (var controller in _zoomControllers) {
      controller.dispose();
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadAudioAssets() async {
    // No changes needed here assuming AssetSource works
    try {
      if (kDebugMode) {
        print("Ses dosyaları için kaynaklar ayarlandı.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Ses dosyası kaynağı ayarlanırken hata: $e");
      }
    }
  }

  Future<void> _playSound(String assetPath) async {
    // No changes needed here
    try {
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      if (kDebugMode) {
        print("Ses çalınırken hata ($assetPath): $e");
      }
    }
  }

  // --- Resource Check Logic ---
  void _performInitialResourceCheck(TarotState state) {
    if (_hasCheckedInitialResources) return; // Only run once

    final currentTokens = state.userTokens;
    final cost = _requiredTokensForSpread;

    bool sufficient = true;

      if (cost > 0 && currentTokens < cost) {
        sufficient = false;
      }


    // Use mounted check before calling setState
    if (mounted) {
      setState(() {
        _hasSufficientInitialResources = sufficient;
        _hasCheckedInitialResources = true;
      });
    } else {
      // If not mounted when check completes, store result but don't call setState
      _hasSufficientInitialResources = sufficient;
      _hasCheckedInitialResources = true;
      return; // Exit if not mounted
    }


    if (!sufficient) {
      // Use addPostFrameCallback to ensure the dialog is shown after the build cycle
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Check mounted again inside the callback
        if (mounted) {
          _showPaymentDialog(context, cost); // Call corrected dialog function
        }
      });
    }
  }
  // ---------------------------


  Future _reshuffleCards() async {
    if (!mounted || isLoading || !_hasSufficientInitialResources) return;

    setState(() => isLoading = true);
    try {
      if(repository.getAllCards().isEmpty) {
        await repository.loadCards();
      }

      if (mounted) {
        setState(() {
          selectedCards = repository.drawRandomCards(cardCount);
          revealed = List.filled(cardCount, false);
          cardsDrawn = true;
          isLoading = false;
        });

        _playSound('audio/shuffle.mp3');
        HapticFeedback.mediumImpact();

        for (int i = 0; i < cardCount; i++) {
          if (mounted) {
            _zoomControllers[i].reset();
            await Future.delayed(Duration(milliseconds: i * 100 + 50));
            if (mounted) {
              _zoomControllers[i].forward(from: 0.0);
            }
          } else {
            break;
          }
        }
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) HapticFeedback.heavyImpact();

      }
    } catch (e) {
      if (kDebugMode) {
        print("Kart çekme hatası: $e");
      }
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error drawing cards: ${e.toString()}'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _flipCard(int index) {
    if (!mounted || isFlippingAll || !cardsDrawn || index >= revealed.length || !_hasSufficientInitialResources) return;

    _playSound('audio/card_flip.mp3');
    HapticFeedback.lightImpact();

    final controller = _flipControllers[index];
    if (controller.isAnimating) return;

    final newState = !revealed[index];

    if (mounted) {
      setState(() => revealed[index] = newState);
      if (newState) {
        controller.forward(from: 0.0);
      } else {
        controller.reverse(from: 1.0);
      }
    }
  }

  Future<void> _flipAllCards() async {
    if (!mounted || isFlippingAll || !cardsDrawn || !_hasSufficientInitialResources) return;

    setState(() => isFlippingAll = true);
    _playSound('audio/card_flip.mp3');
    HapticFeedback.heavyImpact();

    bool anyRevealed = revealed.any((r) => r);
    bool flipToRevealed = !anyRevealed || revealed.contains(false);

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

  Future<void> _navigateToResults() async {
    final loc = S.of(context)!;
    if (!mounted) return;

    if (!cardsDrawn) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.drawCards), backgroundColor: Colors.orangeAccent,)
      );
      return;
    }

    final bloc = context.read<TarotBloc>();
    final currentState = bloc.state;
    final cost = _requiredTokensForSpread;
    final double currentTokens = currentState.userTokens;

    bool sufficientNow = true;

      if (cost > 0 && currentTokens < cost) {
        sufficientNow = false;
      }



    if (!sufficientNow) {
      _showPaymentDialog(context, cost); // Show dialog again if needed
      return;
    }

    // --- Dispatch Event based on Spread Type ---
    TarotEvent eventToDispatch;
    switch (widget.spreadType) {
      case SpreadType.singleCard:
        eventToDispatch = DrawSingleCard();
        break;
      case SpreadType.pastPresentFuture:
        eventToDispatch = DrawPastPresentFuture();
        break;
      case SpreadType.celticCross:
        eventToDispatch = DrawCelticCross();
        break;
      case SpreadType.yearlySpread:
        eventToDispatch = DrawYearlySpread();
        break;
      case SpreadType.problemSolution:
        eventToDispatch = DrawProblemSolution();
        break;
      case SpreadType.fiveCardPath:
        eventToDispatch = DrawFiveCardPath();
        break;
      case SpreadType.relationshipSpread:
        eventToDispatch = DrawRelationshipSpread();
        break;
      case SpreadType.mindBodySpirit:
        eventToDispatch = DrawMindBodySpirit();
        break;
      case SpreadType.astroLogicalCross:
        eventToDispatch = DrawAstroLogicalCross();
        break;
      case SpreadType.brokenHeart:
        eventToDispatch = DrawBrokenHeart();
        break;
      case SpreadType.dreamInterpretation:
        eventToDispatch = DrawDreamInterpretation();
        break;
      case SpreadType.horseshoeSpread:
        eventToDispatch = DrawHorseshoeSpread();
        break;
      case SpreadType.careerPathSpread:
        eventToDispatch = DrawCareerPathSpread();
        break;
      case SpreadType.fullMoonSpread:
        eventToDispatch = DrawFullMoonSpread();
        break;
      case SpreadType.categoryReading:
        if (kDebugMode) {
          print("DrawCategoryReading tetikleniyor. Kategori: ${widget.categoryKey}");
        }
        eventToDispatch = DrawCategoryReading(
            category: widget.categoryKey,
            cardCount: widget.spreadType.cardCount
        );
        break;
    }

    bloc.add(eventToDispatch);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ReadingResultScreenWithTransition(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  // --- CORRECTED based on PaymentManager ---
  void _showPaymentDialog(BuildContext context, double requiredTokens) {
    PaymentManager.showPaymentDialog(
      context,
      requiredTokens: requiredTokens,
      onSuccess: () {
        // This code runs ONLY if the PaymentManager's _handlePurchaseUpdates
        // successfully processes a purchase and calls its internal onPurchaseSuccess.
        if(mounted) {
          // Optional: Show a success message here if PaymentManager doesn't already
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text(S.of(context)!.paymentSuccessful), backgroundColor: Colors.green),
          // );

          // If the initial check failed, update the state to allow interaction now
          if (!_hasSufficientInitialResources) {
            setState(() {
              _hasSufficientInitialResources = true; // Assume success allows proceeding
            });
          }
        }
      },
      // onFailure and onCancel parameters are removed as they don't exist in PaymentManager.showPaymentDialog
    );

    // Since failure/cancel isn't explicitly signaled back here,
    // the screen relies on the BlocBuilder reacting to the TarotBloc state
    // (which *is* updated on success by PaymentManager) to re-enable buttons if needed.
    // If the user cancels, they return here, and buttons remain disabled if resources are still low.
  }
  // --- END CORRECTION ---

  void _showDetailedCardInfo(TarotCard card, int index) {
    if (!mounted || !cardsDrawn || index >= revealed.length || !_hasSufficientInitialResources) return;

    if (!revealed[index]) {
      _playSound('audio/card_flip.mp3');
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
    // Basic check to prevent opening multiple dialogs rapidly
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, anim1, anim2) {
        // --- Card Detail Dialog UI (kept as is) ---
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
                          _buildDetailSection(S.of(context)!.suit, card.suit), // Handle null suit
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
                            _buildDetailSection("Questions to Ask", card.questionsToAsk!.join("\n\n")),
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
        // --- End Card Detail Dialog UI ---
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
            style: GoogleFonts.lato(
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

  // --- Card Widget Rendering (kept as is) ---
  Widget _buildCardWidget(int index, String positionLabel) {
    if (!cardsDrawn || index < 0 || index >= selectedCards.length || index >= _flipControllers.length || index >= _zoomControllers.length) {
      return const SizedBox(width: 100, height: 150); // Placeholder size
    }

    final TarotCard card = selectedCards[index];
    final flipController = _flipControllers[index];
    final zoomController = _zoomControllers[index];

    return GestureDetector(
      onTap: () => _flipCard(index),
      onLongPress: () => _showDetailedCardInfo(card, index),
      child: AnimatedBuilder(
        animation: Listenable.merge([flipController, zoomController]),
        builder: (context, child) {
          final flipValue = flipController.value;
          final zoomValue = Curves.easeOutExpo.transform(zoomController.value);
          final isVisuallyBack = flipValue < 0.5;

          double scale = zoomValue;
          double opacity = zoomValue;
          double initialOffsetY = MediaQuery.of(context).size.height * 0.4;
          double offsetY = (1.0 - zoomValue) * initialOffsetY;

          final centerIndex = (cardCount - 1) / 2.0;
          double offsetX = (index - centerIndex) * 50 * (1.0 - zoomValue);

          double rotationZ = (1.0 - zoomValue) * 0.15 * (index - centerIndex).sign;

          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..translate(offsetX, offsetY)
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
    const double cardWidth = 100;
    const double cardHeight = 150;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
        image: DecorationImage(
          image: AssetImage('assets/tarot_card_images/${card.img}'),
          fit: BoxFit.cover,
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
    const double cardWidth = 100;
    const double cardHeight = 150;

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

  // --- Layout Building (Scrollable versions included) ---
  Widget _buildCardLayout(BuildContext context) {
    final SpreadType currentSpreadType = widget.spreadType;
    final loc = S.of(context)!;

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
                ? SlideToDrawButton(onDrawComplete: _reshuffleCards)
                : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                loc.checkingResources ,
                style: GoogleFonts.cinzel(fontSize: 16, color: Colors.white54),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    Widget buildSpreadLayoutWrapper(List<int> indices, List<String> positions) {
      if (indices.length != cardCount || positions.length != cardCount) {
        if (kDebugMode) {
          print("Layout Error: indices (${indices.length}) or positions (${positions.length}) length does not match cardCount ($cardCount) for ${widget.spreadType}");
        }
        return Center(child: Text("Layout configuration error.", style: TextStyle(color: Colors.red)));
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
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 15,
                runSpacing: 30,
                children: List.generate(indices.length, (index) {
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
        final monthName = DateFormat('MMMM yyyy', locale).format(date);
        months.add(monthName);
      }
      if (cardCount == 13 && count == 13) {
        months[12] = loc.yearlySpreadReading;
      } else if (cardCount > count) {
        for (int i = count; i < cardCount; i++) {
          months.add("Card ${i + 1}");
        }
      }
      return months;
    }

    switch (currentSpreadType) {
      case SpreadType.singleCard:
        return buildSpreadLayoutWrapper([0], [loc.singleCard]);
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
          [loc.mindBody, loc.mindSpirit, loc.bodySpirit],
        );
      case SpreadType.astroLogicalCross:
        return buildSpreadLayoutWrapper(
          [0, 1, 2, 3, 4],
          [
            loc.astroPast, loc.astroPresent, loc.astroFuture,
            loc.astroChallenge, loc.astroOutcome,
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
            loc.dreamPast, loc.dreamPresent, loc.dreamFuture,
          ],
        );
      case SpreadType.horseshoeSpread:
        return buildSpreadLayoutWrapper(
          List.generate(7, (i) => i),
          [
            loc.horseshoePast, loc.horseshoePresent, loc.horseshoeFuture,
            loc.horseshoeStrengths, loc.horseshoeObstacles, loc.horseshoeAdvice,
            loc.horseshoeOutcome,
          ],
        );
      case SpreadType.careerPathSpread:
        return buildSpreadLayoutWrapper(
          [0, 1, 2, 3, 4],
          [
            loc.careerPast, loc.careerPresent, loc.careerChallenge,
            loc.careerPotential, loc.careerOutcome,
          ],
        );
      case SpreadType.fullMoonSpread:
        return buildSpreadLayoutWrapper(
          [0, 1, 2, 3, 4],
          [
            loc.fullMoonPast, loc.fullMoonPresent, loc.fullMoonChallenge,
            loc.fullMoonHope, loc.fullMoonOutcome,
          ],
        );
      case SpreadType.categoryReading:
        return buildSpreadLayoutWrapper(
          List.generate(cardCount, (i) => i),
          List.generate(cardCount, (i) => "${widget.categoryKey} - Card ${i + 1}"),
        );
    }
  }

  // --- Celtic Cross Layout (Scrollable) ---
  Widget _buildCelticCrossLayout(List<int> indices, List<String> positions) {
    if (indices.length < 10 || positions.length < 10) {
      return const Center(child: Text("Not enough cards/positions for Celtic Cross", style: TextStyle(color: Colors.red)));
    }
    const double cardWidth = 100;
    const double cardHeight = 150;
    const double cardSpacing = 15.0;
    const double columnSpacing = 25.0;

    final double contentWidth = cardWidth * 3 + columnSpacing * 2 + cardSpacing * 3;
    final double contentHeight = cardHeight * 4 + cardSpacing * 3 + 30;

    return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: contentWidth,
                  minHeight: contentHeight,
                  maxWidth: max(contentWidth, constraints.maxWidth),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCardWidget(indices[9], positions[9]),
                          const SizedBox(height: cardSpacing),
                          _buildCardWidget(indices[8], positions[8]),
                          const SizedBox(height: cardSpacing),
                          _buildCardWidget(indices[7], positions[7]),
                          const SizedBox(height: cardSpacing),
                          _buildCardWidget(indices[6], positions[6]),
                        ],
                      ),
                      const SizedBox(width: columnSpacing),
                      SizedBox(
                        width: cardWidth * 2 + cardSpacing,
                        height: cardHeight * 3 + cardSpacing * 2,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              bottom: 0,
                              left: (cardWidth + cardSpacing) / 2,
                              child: _buildCardWidget(indices[2], positions[2]),
                            ),
                            Positioned(
                              left: 0,
                              top: cardHeight + cardSpacing,
                              child: _buildCardWidget(indices[3], positions[3]),
                            ),
                            Positioned(
                              right: 0,
                              top: cardHeight + cardSpacing,
                              child: _buildCardWidget(indices[5], positions[5]),
                            ),
                            Positioned(
                              top: 0,
                              left: (cardWidth + cardSpacing) / 2,
                              child: _buildCardWidget(indices[4], positions[4]),
                            ),
                            Positioned(
                              top: cardHeight + cardSpacing,
                              left: (cardWidth + cardSpacing) / 2,
                              child: _buildCardWidget(indices[0], positions[0]),
                            ),
                            Positioned(
                              top: cardHeight + cardSpacing,
                              left: (cardWidth + cardSpacing) / 2,
                              child: Transform.rotate(
                                angle: -pi / 2,
                                child: _buildCardWidget(indices[1], positions[1]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );
  }

  // --- Five Card Path Layout (Scrollable Horizontally) ---
  Widget _buildFiveCardPathLayout(List<int> indices, List<String> positions) {
    if (indices.length < 5 || positions.length < 5) {
      return const Center(child: Text("Not enough cards/positions for Five Card Path", style: TextStyle(color: Colors.red)));
    }
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(indices.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: _buildCardWidget(indices[i], positions[i]),
            );
          }),
        ),
      ),
    );
  }

  // --- Relationship Spread Layout (Scrollable Vertically) ---
  Widget _buildRelationshipSpreadLayout(List<int> indices, List<String> positions) {
    if (indices.length < 7 || positions.length < 7) {
      return const Center(child: Text("Not enough cards/positions for Relationship Spread", style: TextStyle(color: Colors.red)));
    }
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(indices[0], positions[0]),
                const SizedBox(width: 30),
                _buildCardWidget(indices[1], positions[1]),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(indices[2], positions[2]),
                const SizedBox(width: 25),
                _buildCardWidget(indices[3], positions[3]),
                const SizedBox(width: 25),
                _buildCardWidget(indices[4], positions[4]),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(indices[5], positions[5]),
                const SizedBox(width: 30),
                _buildCardWidget(indices[6], positions[6]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Yearly Spread Layout (Scrollable) ---
  Widget _buildYearlySpreadLayout(List<int> indices, List<String> positions) {
    if (indices.length < 12 || positions.length < indices.length) {
      return Center(child: Text("Not enough cards/positions for Yearly Spread (${indices.length})", style: TextStyle(color: Colors.red)));
    }

    final double cardWidth = 100;
    final double cardHeight = 150;
    final double radius = MediaQuery.of(context).size.width * 0.40;
    final double layoutDiameter = radius * 2 + cardWidth;
    final double layoutHeight = radius * 2 + cardHeight + 40;

    final int centerCardIndex = (cardCount == 13) ? 12 : -1;
    final int circleCardCount = (centerCardIndex != -1) ? 12 : cardCount;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SizedBox(
          width: layoutDiameter,
          height: layoutHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ...List.generate(circleCardCount, (index) {
                final double angle = (pi * 2 / circleCardCount) * index - (pi / 2);
                final double x = radius * cos(angle);
                final double y = radius * sin(angle);
                return Positioned(
                  left: radius + x - (cardWidth / 2),
                  top: radius + y - (cardHeight / 2),
                  child: _buildCardWidget(indices[index], positions[index]),
                );
              }),
              if (centerCardIndex != -1)
                Positioned(
                  left: radius - (cardWidth / 2),
                  top: radius - (cardHeight / 2),
                  child: _buildCardWidget(indices[centerCardIndex], positions[centerCardIndex]),
                ),
            ],
          ),
        ),
      ),
    );
  }


  // --- Action Buttons ---
  Widget _buildActionButtons() {
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

  // --- Help Dialog (kept as is) ---
  void _showHelpDialog(BuildContext context) {
    final loc = S.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900]?.withOpacity(0.95),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.purpleAccent.withOpacity(0.5))
        ),
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: Colors.purpleAccent),
            const SizedBox(width: 10),
            Text(loc.cardSelectionInstructions, style: GoogleFonts.cinzel(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                  style: GoogleFonts.lato(color: Colors.white70, fontSize: 13, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return BlocListener<TarotBloc, TarotState>(
      listener: (context, state) {
        if (state is TarotError) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent)
          );
          if (isLoading && mounted) setState(() => isLoading = false);
        }
        // Optional: Could listen for state changes here to update
        // _hasSufficientInitialResources if needed, but BlocBuilder handles button state.
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              widget.spreadType.name.replaceAllMapped( // Use .name for clarity
                  RegExp(r'(?<=[a-z])(?=[A-Z])'), (match) => ' ').capitalizeFirstofEach(), // <-- ADDED PARENTHESES HERE
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
              // Perform the initial resource check ONCE during the build phase
              // Check mounted before calling the check method
              if (!_hasCheckedInitialResources && mounted) {
                // We need the state from the builder here
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) { // Check mounted *again* inside callback
                    _performInitialResourceCheck(state);
                  }
                });
              }

              // Main screen content
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
                      _buildActionButtons(), // Buttons build using BlocBuilder internally
                    ],
                  ),
                  // Show overlay *only* if initial check is done AND resources are insufficient
                  if (!_hasSufficientInitialResources && _hasCheckedInitialResources)
                    Container(
                      color: Colors.black.withOpacity(0.6), // Slightly darker overlay
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.purpleAccent),
                            SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                loc.insufficientCreditsAndLimit,
                                style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 20),

                             //Add a button to retry showing the dialog?
                            ElevatedButton(
                                onPressed: () => _showPaymentDialog(context, _requiredTokensForSpread),
                               child: Text("Purchase Credits"),
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

// --- Reading Result Transition Screen (kept as is) ---
class ReadingResultScreenWithTransition extends StatefulWidget {
  const ReadingResultScreenWithTransition({super.key});

  @override
  ReadingResultScreenWithTransitionState createState() => ReadingResultScreenWithTransitionState();
}

class ReadingResultScreenWithTransitionState extends State<ReadingResultScreenWithTransition> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _transitioning = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1, milliseconds: 200),
      vsync: this,
    );
    _startTransition();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startTransition() async {
    if (_transitioning || !mounted) return;
    _transitioning = true;

    try {
      await _animationController.forward().orCancel;
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const ReadingResultScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } on TickerCanceled {
      if (kDebugMode) print("Transition animation cancelled.");
      _transitioning = false;
    }
    catch (e) {
      if (kDebugMode) {
        print("Geçiş animasyonu hatası: $e");
      }
      if (mounted) {
        // Handle error, maybe pop?
        // Navigator.pop(context);
      }
      _transitioning = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple[900]!, Colors.black],
            stops: const [0.0, 0.7],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animationController.drive(CurveTween(curve: Curves.easeOut)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/tarot_loading.json',
                  width: 180,
                  height: 180,
                  repeat: true,
                ),
                const SizedBox(height: 30),
                Text(
                  loc?.unveilingMysticalPath ?? 'Unveiling the Mystical Path...',
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.purpleAccent.withOpacity(0.4),
                        offset: const Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// --- Slide To Draw Button (kept as is) ---
class SlideToDrawButton extends StatefulWidget {
  final VoidCallback onDrawComplete;

  const SlideToDrawButton({
    super.key,
    required this.onDrawComplete,
  });

  @override
  SlideToDrawButtonState createState() => SlideToDrawButtonState();
}

class SlideToDrawButtonState extends State<SlideToDrawButton>
    with TickerProviderStateMixin {
  double _dragValue = 0.0;
  bool _isDragging = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _resetController;
  late Animation<double> _resetAnimation;

  late AnimationController _successController;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _successGlowAnimation;

  final double _buttonWidth = 280.0;
  final double _handleSize = 60.0;
  final Duration _resetDuration = const Duration(milliseconds: 300);
  final Duration _successDuration = const Duration(milliseconds: 450);


  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1300),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);

    _resetController = AnimationController(duration: _resetDuration, vsync: this);
    _resetAnimation = CurvedAnimation(parent: _resetController, curve: Curves.easeOutCirc)
      ..addListener(() {
        if (mounted) { // Add mounted check
          setState(() {
            _dragValue = lerpDouble(_resetAnimation.value, 0.0, _resetController.value)!;
          });
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted && !_isDragging) _pulseController.repeat(reverse: true);
        }
      });

    _successController = AnimationController(duration: _successDuration, vsync: this);
    _successScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _successController, curve: Curves.elasticOut)
    );
    _successGlowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.7), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _successController, curve: Curves.easeOut));

    _successController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDrawComplete();
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            _resetAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
                CurvedAnimation(parent: _resetController, curve: Curves.easeOutCirc)
            );
            _resetController.forward(from: 0.0);
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

  void _onDragStart(DragStartDetails details) {
    if (_isDragging || _resetController.isAnimating || _successController.isAnimating) return;
    if (mounted) { // Add mounted check
      setState(() {
        _isDragging = true;
        _resetController.stop();
        _pulseController.stop();
      });
    }
    HapticFeedback.lightImpact();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    if (mounted) { // Add mounted check
      setState(() {
        final currentDragPixels = _dragValue * (_buttonWidth - _handleSize);
        final newDragPixels = (currentDragPixels + details.delta.dx).clamp(0.0, _buttonWidth - _handleSize);
        _dragValue = newDragPixels / (_buttonWidth - _handleSize);
      });
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final bool success = _dragValue > 0.85;

    if (success) {
      HapticFeedback.heavyImpact();
      if (mounted) setState(() { _dragValue = 1.0; }); // Add mounted check
      _successController.forward(from: 0.0);
    } else {
      HapticFeedback.lightImpact();
      _resetAnimation = Tween<double>(begin: _dragValue, end: 0.0).animate(
          CurvedAnimation(parent: _resetController, curve: Curves.easeOutCirc)
      );
      _resetController.forward(from: 0.0);
    }
    if (mounted) setState(() => _isDragging = false); // Add mounted check
  }


  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final handlePosition = _dragValue * (_buttonWidth - _handleSize);

    final initialTextOpacity = math.max(0.0, 1.0 - _dragValue * 3.0);
    final initialTextOffset = lerpDouble(0, -40, _dragValue)!;
    final initialTextLeftPadding = _handleSize + 15.0;

    final mysticTextOpacity = math.max(0.0, (_dragValue - 0.3) * 1.8).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _successController,
        builder: (context, child) {
          final successScale = _successScaleAnimation.value;
          final successGlow = _successGlowAnimation.value;

          return Transform.scale(
            scale: successScale,
            child: Container(
              width: _buttonWidth,
              height: _handleSize,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade800.withOpacity(0.8),
                      Color.lerp(Colors.deepPurple.shade800, Colors.pinkAccent.shade400, _dragValue)!
                    ],
                    stops: [0.0, _dragValue + 0.1],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(_handleSize / 2),
                  boxShadow: [
                    BoxShadow(
                      color: Color.lerp(Colors.purple, Colors.pinkAccent, _dragValue)!.withOpacity(lerpDouble(0.2, 0.5, _dragValue)!),
                      blurRadius: lerpDouble(8, 15, _dragValue)!,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(successGlow * 0.8),
                      blurRadius: 25 * successGlow,
                      spreadRadius: 8 * successGlow,
                    ),
                  ],
                  border: Border.all(color: Colors.purpleAccent.withOpacity(0.3 + successGlow * 0.5), width: 1.5)
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Positioned(
                    left: initialTextLeftPadding,
                    right: _handleSize * 0.05,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Opacity(
                        opacity: initialTextOpacity,
                        child: Transform.translate(
                          offset: Offset(initialTextOffset, 0),
                          child: Text(
                            loc?.slideToDrawCards ?? 'Slide to Draw Cards',
                            style: GoogleFonts.cinzel(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
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

                  Positioned.fill(
                    child: ClipRect(
                      clipper: _SlideAreaClipper(
                          clipAmount: handlePosition + (_handleSize * 0.6),
                          handleSize: _handleSize
                      ),
                      child: Container(
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
                        child: Padding(
                          padding: EdgeInsets.only(right: _handleSize * 0.4),
                          child: Opacity(
                            opacity: mysticTextOpacity,
                            child: Text(
                              loc!.unveilTheStars, // TODO: Add localized string
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

                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      final bool canPulse = !_isDragging && !_resetController.isAnimating && !_successController.isAnimating;
                      final double pulseScale = canPulse ? (1.0 + (_pulseAnimation.value * 0.06)) : 1.0;
                      final double pulseGlow = canPulse ? (_pulseAnimation.value * 0.20) : 0.0;

                      return Positioned(
                        left: handlePosition,
                        child: Transform.scale(
                          scale: pulseScale,
                          child: Container(
                            width: _handleSize,
                            height: _handleSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.pinkAccent.shade100,
                                  Colors.purpleAccent.shade400,
                                ],
                                stops: const [0.2, 1.0],
                                radius: 0.7,
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.lerp(Colors.purpleAccent, Colors.pinkAccent, _dragValue)!.withOpacity(
                                        lerpDouble(0.5, 0.8, _dragValue)! + pulseGlow
                                    ),
                                    blurRadius: lerpDouble(10, 16, _dragValue)! + (pulseGlow * 12),
                                    spreadRadius: lerpDouble(2, 4, _dragValue)! + (pulseGlow * 3)
                                )
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.auto_awesome,
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

// --- Custom Clipper for Slide Button Reveal (kept as is) ---
class _SlideAreaClipper extends CustomClipper<Rect> {
  final double clipAmount;
  final double handleSize;

  _SlideAreaClipper({required this.clipAmount, required this.handleSize});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, clipAmount.clamp(0.0, size.width), size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return oldClipper is! _SlideAreaClipper || oldClipper.clipAmount != clipAmount;
  }
}

// Helper extension for capitalizing strings (kept as is)
extension StringExtension on String {
  String capitalizeFirstofEach() => replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}' : '')
      .join(" ");
}