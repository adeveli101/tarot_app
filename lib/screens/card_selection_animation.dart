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

  int get cardCount => widget.spreadType.cardCount;

  @override
  void initState() {
    super.initState();
    readingDate = DateTime.now();

    _flipControllers = List.generate(cardCount, (_) => AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    ));
    _zoomControllers = List.generate(cardCount, (_) => AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    ));

    _loadAudioAssets();
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
    try {
      await _audioPlayer.setSource(AssetSource('audio/card_flip.mp3'));
      await _audioPlayer.setSource(AssetSource('audio/shuffle.mp3'));
      if (kDebugMode) {
        print("Ses dosyaları yüklendi.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Ses dosyası yüklenirken hata: $e");
      }
    }
  }

  Future<void> _playSound(String assetPath) async {
    try {
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      if (kDebugMode) {
        print("Ses çalınırken hata ($assetPath): $e");
      }
    }
  }

  Future _reshuffleCards() async {
    if (!mounted || isLoading) return;

    setState(() => isLoading = true);
    try {
      await repository.loadCards();

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
    if (!mounted || isFlippingAll || !cardsDrawn || index >= revealed.length) return;

    _playSound('audio/card_flip.mp3');
    HapticFeedback.lightImpact();

    final controller = _flipControllers[index];
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
    if (!mounted || isFlippingAll || !cardsDrawn) return;

    setState(() => isFlippingAll = true);
    _playSound('audio/card_flip.mp3');
    HapticFeedback.heavyImpact();

    bool anyRevealed = revealed.any((r) => r);

    if (!anyRevealed || revealed.contains(false)) {
      for (int i = 0; i < cardCount; i++) {
        if (mounted) {
          if (!revealed[i]) {
            setState(() => revealed[i] = true);
            _flipControllers[i].forward(from: _flipControllers[i].value);
            await Future.delayed(const Duration(milliseconds: 150));
          }
        } else {
          break;
        }
      }
    }
    else {
      for (int i = cardCount - 1; i >= 0; i--) {
        if (mounted) {
          if (revealed[i]) {
            setState(() => revealed[i] = false);
            _flipControllers[i].reverse(from: _flipControllers[i].value);
            await Future.delayed(const Duration(milliseconds: 100));
          }
        } else {
          break;
        }
      }
    }

    if (mounted) {
      setState(() => isFlippingAll = false);
    }
  }

  Future<void> _navigateToResults() async {
    if (!mounted || !cardsDrawn) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context)?.drawCards ?? 'Please draw cards first!'), backgroundColor: Colors.orangeAccent,)
      );
      return;
    }

    final bloc = context.read<TarotBloc>();

    if (bloc.state is InsufficientResources) {
      _showPaymentDialog(context, (bloc.state as InsufficientResources).requiredTokens);
      return;
    }

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
          pageBuilder: (_, __, ___) => const ReadingResultScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  void _showPaymentDialog(BuildContext context, double requiredTokens) {
    PaymentManager.showPaymentDialog(
      context,
      requiredTokens: requiredTokens,
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context)!.paymentSuccessful), backgroundColor: Colors.green),
        );
      },
    );
  }

  void _showDetailedCardInfo(TarotCard card, int index) {
    if (!mounted || !cardsDrawn || index >= revealed.length) return;

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

  Widget _buildCardWidget(int index, String positionLabel) {
    if (!cardsDrawn || index >= selectedCards.length) return const SizedBox.shrink();

    final TarotCard card = selectedCards[index];

    return GestureDetector(
      onTap: () => _flipCard(index),
      onLongPress: () => _showDetailedCardInfo(card, index),
      child: AnimatedBuilder(
        animation: Listenable.merge([_flipControllers[index], _zoomControllers[index]]),
        builder: (context, child) {
          final flipValue = _flipControllers[index].value;
          final zoomValue = Curves.easeOutExpo.transform(_zoomControllers[index].value);
          final isVisuallyBack = flipValue >= 0.5;

          double scale = zoomValue;
          double opacity = zoomValue;
          double initialOffsetY = 400;
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
                  opacity: isVisuallyBack && _flipControllers[index].isCompleted ? 1.0 : 0.0,
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
                      ? Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildCardFront(card),
                  )
                      : _buildCardBack(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardFront(TarotCard card) {
    return Container(
      width: 100,
      height: 150,
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
    return Container(
      width: 100,
      height: 150,
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
            SlideToDrawButton(
              onDrawComplete: _reshuffleCards,
            ),
          ],
        ),
      );
    }

    Widget buildSpreadLayout(List<int> indices, List<String> positions) {
      switch (currentSpreadType) {
        case SpreadType.celticCross:
          return _buildCelticCrossLayout(indices, positions);
        case SpreadType.fiveCardPath:
          return _buildFiveCardPathLayout(indices, positions);
        case SpreadType.relationshipSpread:
          return _buildRelationshipSpreadLayout(indices, positions);
        case SpreadType.yearlySpread:
          return _buildYearlySpreadLayout(indices, positions);
        default:
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 28,
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
      for (int i = 0; i < cardCount; i++) {
        final date = DateTime(readingDate.year, readingDate.month + i);
        final monthName = DateFormat('MMMM yyyy', locale).format(date);
        months.add(monthName);
      }
      return months;
    }

    switch (currentSpreadType) {
      case SpreadType.singleCard:
        return buildSpreadLayout([0], [loc.singleCard]);
      case SpreadType.pastPresentFuture:
        return buildSpreadLayout(
          [0, 1, 2],
          [loc.celticCrossPast, loc.celticCrossCurrentSituation, loc.celticCrossFuture],
        );
      case SpreadType.problemSolution:
        return buildSpreadLayout(
          [0, 1, 2],
          [loc.problem, "Obstacle/Advice", loc.solution],
        );
      case SpreadType.celticCross:
        return buildSpreadLayout(
          List.generate(10, (i) => i),
          [
            loc.celticCrossCurrentSituation,
            loc.celticCrossChallenge,
            loc.celticCrossSubconscious,
            loc.celticCrossPast,
            loc.celticCrossConscious,
            loc.celticCrossFuture,
            loc.celticCrossPersonalStance,
            loc.celticCrossExternalInfluences,
            loc.celticCrossHopesFears,
            loc.celticCrossFinalOutcome,
          ],
        );
      case SpreadType.yearlySpread:
        return buildSpreadLayout(
          List.generate(cardCount, (i) => i),
          getMonthNames(),
        );
      case SpreadType.fiveCardPath:
        return buildSpreadLayout(
          [0, 1, 2, 3, 4],
          [
            loc.fiveCardPathPast,
            loc.fiveCardPathPresent,
            loc.fiveCardPathChallenge,
            loc.fiveCardPathFuture,
            loc.fiveCardPathOutcome,
          ],
        );
      case SpreadType.relationshipSpread:
        return buildSpreadLayout(
          List.generate(7, (i) => i),
          [
            loc.relationshipSelf,
            loc.relationshipPartner,
            loc.relationshipPast,
            loc.relationshipPresent,
            loc.relationshipFuture,
            loc.relationshipStrengths,
            loc.relationshipChallenges,
          ],
        );
      case SpreadType.mindBodySpirit:
        return buildSpreadLayout(
          [0, 1, 2],
          [loc.mindBody, loc.mindSpirit, loc.bodySpirit],
        );
      case SpreadType.astroLogicalCross:
        return buildSpreadLayout(
          [0, 1, 2, 3, 4],
          [
            loc.astroPast,
            loc.astroPresent,
            loc.astroFuture,
            loc.astroChallenge,
            loc.astroOutcome,
          ],
        );
      case SpreadType.brokenHeart:
        return buildSpreadLayout(
          [0, 1, 2, 3, 4],
          [
            loc.brokenHeartCause,
            loc.brokenHeartEmotion,
            loc.brokenHeartLesson,
            loc.brokenHeartHope,
            loc.brokenHeartHealing,
          ],
        );
      case SpreadType.dreamInterpretation:
        return buildSpreadLayout(
          [0, 1, 2],
          [
            loc.dreamPast,
            loc.dreamPresent,
            loc.dreamFuture,
          ],
        );
      case SpreadType.horseshoeSpread:
        return buildSpreadLayout(
          List.generate(7, (i) => i),
          [
            loc.horseshoePast,
            loc.horseshoePresent,
            loc.horseshoeFuture,
            loc.horseshoeStrengths,
            loc.horseshoeObstacles,
            loc.horseshoeAdvice,
            loc.horseshoeOutcome,
          ],
        );
      case SpreadType.careerPathSpread:
        return buildSpreadLayout(
          [0, 1, 2, 3, 4],
          [
            loc.careerPast,
            loc.careerPresent,
            loc.careerChallenge,
            loc.careerPotential,
            loc.careerOutcome,
          ],
        );
      case SpreadType.fullMoonSpread:
        return buildSpreadLayout(
          [0, 1, 2, 3, 4],
          [
            loc.fullMoonPast,
            loc.fullMoonPresent,
            loc.fullMoonChallenge,
            loc.fullMoonHope,
            loc.fullMoonOutcome,
          ],
        );
      case SpreadType.categoryReading:
        return buildSpreadLayout(
          List.generate(cardCount, (i) => i),
          List.generate(cardCount, (i) => "${widget.categoryKey} - ${i + 1}"),
        );
    }
  }

  Widget _buildCelticCrossLayout(List<int> indices, List<String> positions) {
    if (indices.length < 10) return const Center(child: Text("Not enough cards for Celtic Cross"));
    const double cardSpacing = 10.0;
    const double columnSpacing = 20.0;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
              width: 100 * 2 + cardSpacing * 3,
              height: 150 * 3 + cardSpacing * 2,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 0,
                    left: 100 + cardSpacing * 1.5,
                    child: _buildCardWidget(indices[2], positions[2]),
                  ),
                  Positioned(
                    left: 0,
                    top: 150 + cardSpacing,
                    child: _buildCardWidget(indices[3], positions[3]),
                  ),
                  Positioned(
                    right: 0,
                    top: 150 + cardSpacing,
                    child: _buildCardWidget(indices[5], positions[5]),
                  ),
                  Positioned(
                    top: 0,
                    left: 100 + cardSpacing * 1.5,
                    child: _buildCardWidget(indices[4], positions[4]),
                  ),
                  Positioned(
                    top: 150 + cardSpacing,
                    left: 100 + cardSpacing * 1.5,
                    child: _buildCardWidget(indices[0], positions[0]),
                  ),
                  Positioned(
                    top: 150 + cardSpacing,
                    left: 100 + cardSpacing * 1.5,
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
    );
  }


  Widget _buildFiveCardPathLayout(List<int> indices, List<String> positions) {
    if (indices.length < 5) return const Center(child: Text("Not enough cards for Five Card Path"));
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(indices.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildCardWidget(indices[i], positions[i]),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildRelationshipSpreadLayout(List<int> indices, List<String> positions) {
    if (indices.length < 7) return const Center(child: Text("Not enough cards for Relationship Spread"));
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(indices[0], positions[0]),
                const SizedBox(width: 25),
                _buildCardWidget(indices[1], positions[1]),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(indices[2], positions[2]),
                const SizedBox(width: 20),
                _buildCardWidget(indices[3], positions[3]),
                const SizedBox(width: 25),
                _buildCardWidget(indices[4], positions[4]),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(indices[5], positions[5]),
                const SizedBox(width: 25),
                _buildCardWidget(indices[6], positions[6]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlySpreadLayout(List<int> indices, List<String> positions) {
    if (indices.length < 12) return const Center(child: Text("Not enough cards for Yearly Spread"));

    final double radius = MediaQuery.of(context).size.width * 0.35;
    final double cardWidth = 100;
    final double cardHeight = 150;

    return Center(
      child: SizedBox(
        width: radius * 2 + cardWidth,
        height: radius * 2 + cardHeight + 30,
        child: Stack(
          alignment: Alignment.center,
          children: List.generate(indices.length, (index) {
            final double angle = (pi * 2 / 12) * index - (pi / 2);

            final double x = radius * cos(angle);
            final double y = radius * sin(angle);

            return Positioned(
              left: radius + x,
              top: radius + y,
              child: _buildCardWidget(indices[index], positions[index]),
            );
          }),
        ),
      ),
    );
  }


  Widget _buildActionButtons() {
    final loc = S.of(context)!;
    final bool canFlip = cardsDrawn && !isFlippingAll;
    final bool canReshuffle = !isLoading;
    final bool canViewResults = cardsDrawn && !isLoading && !isFlippingAll;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          boxShadow: [
            BoxShadow(color: Colors.purple.withOpacity(0.4), blurRadius: 10, spreadRadius: -5, offset: const Offset(0, -5))
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
            onPressed: canViewResults ? _navigateToResults : (){},
            icon: Icons.visibility_outlined,
            color: Colors.purpleAccent.shade400,
            isEnabled: canViewResults,
          ),
        ],
      ),
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
        if (state is InsufficientResources) {
          if (kDebugMode) {
            print("Listener (CardSelection): InsufficientResources detected.");
          }
        } else if (state is TarotError) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent)
          );
          if (isLoading) setState(() => isLoading = false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              widget.spreadType.toString().split('.').last.replaceAllMapped(
                  RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trim(),
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
        body: Stack(
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
          ],
        ),
      ),
    );
  }
}

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
      duration: const Duration(seconds: 1, milliseconds: 500),
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
    } catch (e) {
      if (kDebugMode) {
        print("Geçiş animasyonu iptal edildi veya hata oluştu: $e");
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
        setState(() {
          _dragValue = lerpDouble(_resetAnimation.value, 0.0, _resetController.value)!;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _pulseController.repeat(reverse: true);
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
            _dragValue = 1.0;
            _resetAnimation = Tween<double>(begin: _dragValue, end: 0.0).animate(
                CurvedAnimation(parent: _resetController, curve: Curves.easeOut)
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
    setState(() {
      _isDragging = true;
      _resetController.stop();
      _pulseController.stop();
    });
    HapticFeedback.lightImpact();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      final currentDrag = _dragValue * (_buttonWidth - _handleSize);
      final newDrag = (currentDrag + details.delta.dx).clamp(0.0, _buttonWidth - _handleSize);
      _dragValue = newDrag / (_buttonWidth - _handleSize);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final bool success = _dragValue > 0.85;

    if (success) {
      HapticFeedback.heavyImpact();
      setState(() { _dragValue = 1.0; });
      _successController.forward(from: 0.0);
    } else {
      HapticFeedback.lightImpact();
      _resetAnimation = Tween<double>(begin: _dragValue, end: 0.0).animate(
          CurvedAnimation(parent: _resetController, curve: Curves.easeOutCirc)
      );
      _resetController.forward(from: 0.0);
    }
    setState(() => _isDragging = false);
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
                              loc!.unveilTheStars ,
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

class _SlideAreaClipper extends CustomClipper<Rect> {
  final double clipAmount;
  final double handleSize;

  _SlideAreaClipper({required this.clipAmount, required this.handleSize});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, clipAmount, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return oldClipper is! _SlideAreaClipper || oldClipper.clipAmount != clipAmount;
  }
}