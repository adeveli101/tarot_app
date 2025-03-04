// ignore_for_file: unused_field

import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
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
import '../data/payment_maganer.dart';
import '../models/animations/tap_animations_scale.dart';
import 'package:intl/intl.dart';

class CardSelectionAnimationScreen extends StatefulWidget {
  final int cardCount;

  const CardSelectionAnimationScreen({super.key, required this.cardCount});

  @override
  CardSelectionAnimationScreenState createState() => CardSelectionAnimationScreenState();
}

class CardSelectionAnimationScreenState extends State<CardSelectionAnimationScreen> with TickerProviderStateMixin {
  final TarotRepository repository = TarotRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late List<AnimationController> _flipControllers;
  late List<AnimationController> _zoomControllers; // For zoom-in animation
  List<TarotCard> selectedCards = [];
  List<bool> revealed = [];
  bool isLoading = true;
  bool isFlippingAll = false;
  bool cardsDrawn = false;
  late DateTime readingDate;
  late String locale;


  @override
  void initState() {
    super.initState();
    readingDate = DateTime.now();
    _flipControllers = List.generate(widget.cardCount, (_) => AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    ));
    _zoomControllers = List.generate(widget.cardCount, (_) => AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    ));
    _loadAudioAssets();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    locale = Localizations.localeOf(context).languageCode;
    repository.setLocale(locale);
    setState(() => isLoading = false);
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
    await _audioPlayer.setSource(AssetSource('audio/card_flip.mp3'));
    await _audioPlayer.setSource(AssetSource('audio/shuffle.mp3'));
  }

  Future _reshuffleCards() async {
    setState(() => isLoading = true);
    try {
      await repository.loadCards();
      if (mounted) {
        setState(() {
          selectedCards = repository.drawRandomCards(widget.cardCount);
          revealed = List.filled(widget.cardCount, false);
          cardsDrawn = true;
          isLoading = false;
        });
        _audioPlayer.play(AssetSource('audio/shuffle.mp3'));
        HapticFeedback.mediumImpact();

        // Tüm kartları sırayla animate et
        for (int i = 0; i < widget.cardCount; i++) {
          if (mounted) {
            _zoomControllers[i].reset();
            // Kartlar arasında hafif gecikme ile animate et
            Future.delayed(Duration(milliseconds: i * 130), () {
              if (mounted) {
                _zoomControllers[i].forward(from: 0);
              }
            });
          }
        }

        // Çarpma sesi için kısa bir gecikme
        await Future.delayed(const Duration(milliseconds: 600));
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _flipCard(int index) {
    if (!isFlippingAll && index < revealed.length && cardsDrawn) {
      _audioPlayer.play(AssetSource('audio/card_flip.mp3'));
      HapticFeedback.lightImpact();
      if (!revealed[index]) {
        _flipControllers[index].forward(from: 0).then((_) {
          setState(() => revealed[index] = true);
        });
      } else {
        _flipControllers[index].reverse(from: 1).then((_) {
          setState(() => revealed[index] = false);
        });
      }
    }
  }

  Future<void> _flipAllCards() async {
    if (isFlippingAll || !cardsDrawn) return;

    setState(() => isFlippingAll = true);
    _audioPlayer.play(AssetSource('audio/card_flip.mp3'));
    HapticFeedback.heavyImpact();

    // Tüm kartlar açıksa hepsini kapat, değilse kapalı olanları aç
    bool allRevealed = revealed.every((r) => r);

    if (allRevealed) {
      // Tüm kartları kapat
      for (int i = 0; i < widget.cardCount; i++) {
        _flipControllers[i].reverse(from: 1).then((_) {
          setState(() => revealed[i] = false);
        });
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } else {
      // Sadece kapalı kartları aç
      for (int i = 0; i < widget.cardCount; i++) {
        if (!revealed[i]) {
          _flipControllers[i].forward(from: 0).then((_) {
            setState(() => revealed[i] = true);
          });
          await Future.delayed(const Duration(milliseconds: 400));
        }
      }
    }

    setState(() => isFlippingAll = false);
  }


  Future<void> _navigateToResults() async {
    if (!cardsDrawn) return;
    final bloc = context.read<TarotBloc>();
    if (bloc.state is InsufficientResources) {
      _showPaymentDialog(context, (bloc.state as InsufficientResources).requiredTokens);
      return;
    }

    switch (bloc.currentSpreadType) {
      case SpreadType.singleCard:
        bloc.add(DrawSingleCard());
        break;
      case SpreadType.pastPresentFuture:
        bloc.add(DrawPastPresentFuture());
        break;
      case SpreadType.celticCross:
        bloc.add(DrawCelticCross());
        break;
      case SpreadType.yearlySpread:
        bloc.add(DrawYearlySpread());
        break;
      case SpreadType.problemSolution:
        bloc.add(DrawProblemSolution());
        break;
      case SpreadType.fiveCardPath:
        bloc.add(DrawFiveCardPath());
        break;
      case SpreadType.relationshipSpread:
        bloc.add(DrawRelationshipSpread());
        break;
      case SpreadType.mindBodySpirit:
        bloc.add(DrawMindBodySpirit());
        break;
      case SpreadType.astroLogicalCross:
        bloc.add(DrawAstroLogicalCross());
        break;
      case SpreadType.brokenHeart:
        bloc.add(DrawBrokenHeart());
        break;
      case SpreadType.dreamInterpretation:
        bloc.add(DrawDreamInterpretation());
        break;
      case SpreadType.horseshoeSpread:
        bloc.add(DrawHorseshoeSpread());
        break;
      case SpreadType.careerPathSpread:
        bloc.add(DrawCareerPathSpread());
        break;
      case SpreadType.fullMoonSpread:
        bloc.add(DrawFullMoonSpread());
        break;
      default:
        break;
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ReadingResultScreenWithTransition()),
      );
    }
  }

  void _showPaymentDialog(BuildContext context, double requiredTokens) {
    PaymentManager.showPaymentDialog(
      context,
      requiredTokens: requiredTokens,
      onSuccess: () {},
    );
  }

  void _showDetailedCardInfo(TarotCard card, int index) {
    if (!cardsDrawn) return;
    if (!revealed[index]) {
      _flipCard(index);
      Future.delayed(const Duration(milliseconds: 400), () {
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
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.deepPurple[900]!, Colors.black87],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.6),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          card.name,
                          style: GoogleFonts.cinzel(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.purpleAccent.withOpacity(0.5),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/tarot_card_images/${card.img}',
                            height: 350,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.broken_image,
                              color: Colors.white70,
                              size: 80,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildDetailSection(S.of(context)!.position, card.arcana),
                        _buildDetailSection(S.of(context)!.meaning, card.suit),
                        if (card.elemental != null) _buildDetailSection("Element", card.elemental!),
                        _buildDetailSection("Keywords", card.keywords.join(", ")),
                        _buildDetailSection("Fortune Telling", card.fortuneTelling.join("\n")),
                        _buildDetailSection("Light Meanings", card.meanings.light.join("\n")),
                        _buildDetailSection("Shadow Meanings", card.meanings.shadow.join("\n")),
                        if (card.archetype != null) _buildDetailSection("Archetype", card.archetype!),
                        if (card.hebrewAlphabet != null) _buildDetailSection("Hebrew Alphabet", card.hebrewAlphabet!),
                        if (card.numerology != null) _buildDetailSection("Numerology", card.numerology!),
                        if (card.mythicalSpiritual != null) _buildDetailSection("Mythical/Spiritual", card.mythicalSpiritual!),
                        if (card.questionsToAsk != null) _buildDetailSection("Questions to Ask", card.questionsToAsk!.join("\n")),
                        const SizedBox(height: 20),
                        TapAnimatedScale(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              S.of(context)!.close,
                              style: GoogleFonts.cinzel(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _buildCloseButton(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeInOut),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeInOut),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.6),
          boxShadow: [
            BoxShadow(
              color: Colors.purple[300]!.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 16),
      ),
    );
  }


  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purpleAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.cinzel(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          Divider(color: Colors.purple.withOpacity(0.3)),
        ],
      ),
    );
  }

  Widget _buildCardWidget(int index, String positionLabel) {
    if (!cardsDrawn || index >= selectedCards.length) return const SizedBox.shrink();
    final TarotCard card = selectedCards[index];
    final bool isRevealed = revealed[index];

    return GestureDetector(
      onTap: () => _flipCard(index),
      onLongPress: () => _showDetailedCardInfo(card, index),
      child: AnimatedBuilder(
        animation: Listenable.merge([_flipControllers[index], _zoomControllers[index]]),
        builder: (context, child) {
          final flipValue = _flipControllers[index].value;
          final zoomValue = _zoomControllers[index].value;
          final isBack = flipValue >= 0.6;

          // Kartın ekrana gelme animasyonu için değerler
          double scale = 1.0;
          double offsetY = 0;
          double offsetX = 0;
          double rotation = 0;

          // Kart henüz çevrilmemişse ve animasyon devam ediyorsa
          if (!isBack && zoomValue < 1.0) {
            // Kartların aşağıdan tek bir desteden gelme efekti
            final progress = zoomValue; // 0 -> 1

            // Tüm kartlar ekranın altından gelir
            offsetY = (1.0 - progress) * 300; // 300 -> 0

            // Kartlar tek bir noktadan yayılır
            offsetX = (1.0 - progress) * (index - widget.cardCount / 2) * -30;

            // Kartlar hafif dönerek gelir
            rotation = (1.0 - progress) * 0.3 * (index % 2 == 0 ? 1 : -1);

            // Çarpma efekti (animasyonun son kısmında)
            if (progress > 0.8) {
              final bounceProgress = (progress - 0.8) * 5; // 0 -> 1
              final bounce = sin(bounceProgress * pi) * (1.0 - bounceProgress) * 0.2;
              rotation += bounce * (index % 2 == 0 ? 1 : -1) * 0.3;
              scale += bounce * 0.1;
            }
          }

          // Kart çevrildiğinde normal boyutta kalır
          if (isBack) {
            scale = 1.0;
            rotation = 0;
            offsetY = 0;
            offsetX = 0;
          }

          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..translate(offsetX, offsetY)
            ..rotateY(flipValue * pi)
            ..rotateZ(rotation)
            ..scale(scale);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sadece kart ön yüzü gösterildiğinde pozisyon etiketini göster
              if (isBack)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    positionLabel,
                    style: GoogleFonts.cinzel(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Transform(
                transform: transform,
                alignment: Alignment.center,
                child: isBack
                    ? Transform(
                  transform: Matrix4.identity()..rotateY(pi),
                  alignment: Alignment.center,
                  child: _buildCardFront(card, flipValue),
                )
                    : _buildCardBack(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCardFront(TarotCard card, double flipValue) {
    final double textOpacity = flipValue > 0.9 ? (flipValue - 0.9) * 10 : 0.0;

    return Container(
      width: 100,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: [Colors.purpleAccent.shade100, Colors.deepPurple.shade700]),
        image: DecorationImage(
          image: AssetImage('assets/tarot_card_images/${card.img}'),
          fit: BoxFit.contain,
          onError: (exception, stackTrace) => const Icon(Icons.broken_image, color: Colors.white70, size: 40),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Opacity(
          opacity: textOpacity,
          child: Container(
            padding: const EdgeInsets.all(2),
            color: Colors.black.withOpacity(0.4),
            child: Text(
              card.name,
              style: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      width: 100,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: [Colors.deepPurple.shade700, Colors.purpleAccent.shade100]),
        image: const DecorationImage(
          image: AssetImage('assets/tarot_card_images/card_back.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
    );
  }


  //select to draw
  Widget _buildCardLayout(BuildContext context) {
    final bloc = context.read<TarotBloc>();
    final spreadType = bloc.currentSpreadType ?? SpreadType.singleCard;
    final loc = S.of(context)!;

    if (!cardsDrawn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              loc.selectToDraw,
              style: GoogleFonts.cinzel(fontSize: 20, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SlideToDrawButton(
              onDrawComplete: _reshuffleCards,
            ),
          ],
        ),
      );
    }

    Widget buildSpreadLayout(List<int> indices, List<String> positions) {
      switch (spreadType) {
        case SpreadType.celticCross:
          return _buildCelticCrossLayout(indices, positions);
        case SpreadType.fiveCardPath:
          return _buildFiveCardPathLayout(indices, positions);
        case SpreadType.relationshipSpread:
          return _buildRelationshipSpreadLayout(indices, positions);
        default:
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
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
      for (int i = 0; i < widget.cardCount; i++) {
        final date = DateTime(readingDate.year, readingDate.month + i, readingDate.day);
        final monthName = DateFormat('MMMM', locale).format(date);
        months.add(monthName);
      }
      return months;
    }

    switch (spreadType) {
      case SpreadType.singleCard:
        return buildSpreadLayout([0], [loc.singleCard]);
      case SpreadType.pastPresentFuture:
        return buildSpreadLayout(
          [0, 1, 2],
          [loc.celticCrossPast, loc.celticCrossCurrentSituation, loc.celticCrossFuture],
        );
      case SpreadType.problemSolution:
        return buildSpreadLayout(
          [0, 1],
          [loc.problem, loc.solution],
        );
      case SpreadType.celticCross:
        return buildSpreadLayout(
          [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
          [
            loc.celticCrossSubconscious,
            loc.celticCrossChallenge,
            loc.celticCrossPast,
            loc.celticCrossCurrentSituation,
            loc.celticCrossFuture,
            loc.celticCrossNearFuture,
            loc.celticCrossPersonalStance,
            loc.celticCrossExternalInfluences,
            loc.celticCrossHopesFears,
            loc.celticCrossFinalOutcome,
          ],
        );
      case SpreadType.yearlySpread:
        return buildSpreadLayout(
          List.generate(widget.cardCount, (i) => i),
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
          [0, 1, 2, 3, 4, 5, 6],
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
          [loc.dreamPast, loc.dreamPresent, loc.dreamFuture],
        );
      case SpreadType.horseshoeSpread:
        return buildSpreadLayout(
          [0, 1, 2, 3, 4, 5, 6],
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
      default:
        return buildSpreadLayout(
          List.generate(widget.cardCount, (i) => i),
          List.generate(widget.cardCount, (i) => "Card ${i + 1}"),
        );
    }
  }


  Widget _buildCelticCrossLayout(List<int> indices, List<String> positions) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCardWidget(indices[0], positions[0]),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(indices[1], positions[1]),
                const SizedBox(width: 20),
                Column(
                  children: [
                    _buildCardWidget(indices[2], positions[2]),
                    const SizedBox(height: 20),
                    _buildCardWidget(indices[3], positions[3]),
                    const SizedBox(height: 20),
                    _buildCardWidget(indices[4], positions[4]),
                  ],
                ),
                const SizedBox(width: 20),
                _buildCardWidget(indices[5], positions[5]),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 20,
              children: [
                _buildCardWidget(indices[6], positions[6]),
                _buildCardWidget(indices[7], positions[7]),
                _buildCardWidget(indices[8], positions[8]),
                _buildCardWidget(indices[9], positions[9]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiveCardPathLayout(List<int> indices, List<String> positions) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCardWidget(indices[0], positions[0]),
            const SizedBox(width: 20),
            Column(
              children: [
                _buildCardWidget(indices[1], positions[1]),
                const SizedBox(height: 20),
                _buildCardWidget(indices[2], positions[2]),
                const SizedBox(height: 20),
                _buildCardWidget(indices[3], positions[3]),
              ],
            ),
            const SizedBox(width: 20),
            _buildCardWidget(indices[4], positions[4]),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationshipSpreadLayout(List<int> indices, List<String> positions) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(indices[0], positions[0]),
                const SizedBox(width: 20),
                _buildCardWidget(indices[1], positions[1]),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(indices[2], positions[2]),
                const SizedBox(width: 20),
                _buildCardWidget(indices[3], positions[3]),
                const SizedBox(width: 20),
                _buildCardWidget(indices[4], positions[4]),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(indices[5], positions[5]),
                const SizedBox(width: 20),
                _buildCardWidget(indices[6], positions[6]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final loc = S.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border(top: BorderSide(color: Colors.purple.withOpacity(0.5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(loc.flipAllCards, _flipAllCards, Icons.flip, Colors.purple),
          _buildActionButton(loc.drawCards, _reshuffleCards, Icons.shuffle, Colors.deepPurple),
          _buildActionButton(loc.viewResults, _navigateToResults, Icons.arrow_forward, Colors.purpleAccent),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed, IconData icon, Color color) {
    return TapAnimatedScale(
      onTap: onPressed,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.cinzel(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final loc = S.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(loc.cardSelectionInstructions, style: GoogleFonts.cinzel(color: Colors.white, fontSize: 18)),
        content: Text(
          "${loc.flipAllCards}: ${loc.instructionsFlipAll}\n"
              "${loc.drawCards}: ${loc.instructionsDrawCards}\n"
              "${loc.viewResults}: ${loc.instructionsViewResults}",
          style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.close, style: GoogleFonts.cinzel(color: Colors.purpleAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Lottie.asset('assets/animations/tarot_loading.json', width: 200, height: 200),
        ),
      );
    }

    return BlocConsumer<TarotBloc, TarotState>(
      listener: (context, state) {
        if (state is InsufficientResources) {
          _showPaymentDialog(context, state.requiredTokens);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(loc!.cardSelection, style: GoogleFonts.cinzel(color: Colors.white, fontSize: 20)),
            backgroundColor: Colors.deepPurple[900],
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () => _showHelpDialog(context),
              ),
            ],
          ),
          body: Stack(
            children: [
              Lottie.asset('assets/animations/tarot_shuffle.json', fit: BoxFit.cover, repeat: true),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.deepPurple[900]!.withOpacity(0.7),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Expanded(child: _buildCardLayout(context)),
                  _buildActionButtons(),
                ],
              ),
            ],
          ),
        );
      },
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
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
    await _animationController.forward();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ReadingResultScreen()),
      );
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
            colors: [Colors.deepPurple[900]!.withOpacity(0.7), Colors.black.withOpacity(0.9)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/tarot_loading.json',
                controller: _animationController,
                height: 200,
                fit: BoxFit.cover,
                repeat: false,
              ),
              const SizedBox(height: 20),
              Text(
                loc?.unveilingMysticalPath ?? 'Unveiling the Mystical Path...',
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  color: Colors.white70,
                  shadows: [
                    Shadow(
                      color: Colors.purpleAccent.withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
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

class SlideToDrawButtonState extends State<SlideToDrawButton> with SingleTickerProviderStateMixin {
  double _dragValue = 0.0;
  bool _isDragging = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = 280.0;
    final handleSize = 60.0;

    // Kaydırma ilerlemesine göre renk değişimi
    final Color trackColor = Color.lerp(
        Colors.deepPurple.shade900,
        Colors.purpleAccent.shade700,
        _dragValue
    )!;

    // Kaydırma ilerlemesine göre parlaklık efekti
    final double glowIntensity = 0.3 + (_dragValue * 0.7);

    return Container(
      width: buttonWidth,
      height: handleSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade900,
            Color.lerp(Colors.deepPurple.shade900, Colors.purpleAccent.shade700, _dragValue)!
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3 + (_dragValue * 0.4)),
            blurRadius: 10 + (_dragValue * 10),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Mistik semboller (tarot temalı)
          ...List.generate(5, (index) {
            final position = (index * 50.0) + 20.0;
            final adjustedPosition = position + (_dragValue * 20); // Kaydırma ile hareket
            final opacity = 0.2 + (_dragValue * 0.3); // Kaydırma ile opaklık artışı

            return Positioned(
              left: adjustedPosition,
              top: handleSize / 2 - 10,
              child: Opacity(
                opacity: opacity,
                child: Icon(
                  [Icons.auto_awesome_motion, Icons.star, Icons.brightness_2, Icons.wb_sunny_outlined, Icons.ac_unit][index % 5],
                  color: Colors.white,
                  size: 20,
                ),
              ),
            );
          }),

          // İlerleme göstergesi
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: _dragValue * buttonWidth,
                height: handleSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purpleAccent.withOpacity(0.3),
                      Colors.purpleAccent.withOpacity(0.5),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),

          // Kaydırma işaretçisi
          AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Positioned(
                  left: _dragValue * (buttonWidth - handleSize),
                  top: 0,
                  child: GestureDetector(
                    onHorizontalDragStart: (_) {
                      setState(() => _isDragging = true);
                      HapticFeedback.lightImpact();
                    },
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _dragValue += details.delta.dx / (buttonWidth - handleSize);
                        _dragValue = _dragValue.clamp(0.0, 1.0);

                        // İlerleme durumuna göre titreşim geri bildirimi
                        if (_dragValue > 0.25 && _dragValue < 0.27 ||
                            _dragValue > 0.5 && _dragValue < 0.52 ||
                            _dragValue > 0.75 && _dragValue < 0.77) {
                          HapticFeedback.selectionClick();
                        }
                      });
                    },
                    onHorizontalDragEnd: (_) {
                      if (_dragValue > 0.9) {
                        HapticFeedback.heavyImpact();
                        widget.onDrawComplete();
                        setState(() => _dragValue = 0.0);
                      } else {
                        setState(() {
                          // Animasyonlu geri dönüş
                          Future.delayed(const Duration(milliseconds: 50), () {
                            if (mounted) {
                              setState(() => _dragValue = _dragValue * 0.9);
                            }
                          });
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (mounted) {
                              setState(() => _dragValue = _dragValue * 0.8);
                            }
                          });
                          Future.delayed(const Duration(milliseconds: 150), () {
                            if (mounted) {
                              setState(() => _dragValue = _dragValue * 0.6);
                            }
                          });
                          Future.delayed(const Duration(milliseconds: 200), () {
                            if (mounted) {
                              setState(() => _dragValue = 0.0);
                            }
                          });
                        });
                      }
                      setState(() => _isDragging = false);
                    },
                    child: Container(
                      width: handleSize,
                      height: handleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white,
                            Colors.white.withOpacity(0.9),
                          ],
                          radius: 0.7,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purpleAccent.withOpacity(glowIntensity * (_pulseController.value * 0.5 + 0.5)),
                            blurRadius: 12 + (_pulseController.value * 8),
                            spreadRadius: 2 + (_pulseController.value * 2 * _dragValue),
                          )
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.auto_awesome,
                          color: Color.lerp(Colors.deepPurple, Colors.purpleAccent, _dragValue),
                          size: 30 + (_dragValue * 5), // Kaydırma ile boyut artışı
                        ),
                      ),
                    ),
                  ),
                );
              }
          ),
        ],
      ),
    );
  }
}
