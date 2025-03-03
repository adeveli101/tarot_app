import 'dart:math';
import 'dart:ui';
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
import 'package:vector_math/vector_math.dart' show lerpDouble;

class CardSelectionAnimationScreen extends StatefulWidget {
  final int cardCount;

  const CardSelectionAnimationScreen({super.key, required this.cardCount});

  @override
  CardSelectionAnimationScreenState createState() => CardSelectionAnimationScreenState();
}

class CardSelectionAnimationScreenState extends State<CardSelectionAnimationScreen> with TickerProviderStateMixin {
  final TarotRepository repository = TarotRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _cardFlipController;
  late AnimationController _entryController;
  late AnimationController _hoverController;
  late AnimationController _scaleController;
  List<TarotCard> selectedCards = [];
  List<bool> revealed = [];
  bool isLoading = true;
  bool isFlippingAll = false;

  @override
  void initState() {
    super.initState();
    _cardFlipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _initializeCards();
    _loadAudioAssets();
  }

  @override
  void dispose() {
    _cardFlipController.dispose();
    _entryController.dispose();
    _hoverController.dispose();
    _scaleController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadAudioAssets() async {
    await _audioPlayer.setSource(AssetSource('audio/card_flip.mp3'));
    await _audioPlayer.setSource(AssetSource('audio/card_flip_all.mp3'));
    await _audioPlayer.setSource(AssetSource('audio/shuffle.mp3'));
  }

  Future<void> _initializeCards() async {
    try {
      await repository.loadCardsFromAsset();
      if (mounted) {
        setState(() {
          selectedCards = repository.drawRandomCards(widget.cardCount);
          revealed = List<bool>.filled(widget.cardCount, false);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context)!.errorMessage("Error loading cards: $e"))),
        );
        setState(() => isLoading = false);
      }
    }
  }

  void _flipCard(int index) {
    if (!isFlippingAll) {
      if (!revealed[index]) {
        _audioPlayer.play(AssetSource('audio/card_flip.mp3'));
        HapticFeedback.lightImpact();
        _cardFlipController.forward(from: 0).then((_) {
          setState(() => revealed[index] = true);
          _scaleController.forward().then((_) => _scaleController.reverse());
          if (revealed.every((r) => r)) _navigateToResults();
        });
      } else {
        // Kartı tekrar ters çevir
        _audioPlayer.play(AssetSource('audio/card_flip.mp3'));
        HapticFeedback.lightImpact();
        _cardFlipController.reverse().then((_) {
          setState(() => revealed[index] = false);
        });
      }
    }
  }

  Future<void> _flipAllCards() async {
    if (isFlippingAll || revealed.every((r) => r)) return;
    setState(() => isFlippingAll = true);
    _audioPlayer.play(AssetSource('audio/card_flip_all.mp3'));
    HapticFeedback.heavyImpact();
    for (int i = 0; i < widget.cardCount; i++) {
      if (!revealed[i]) {
        _cardFlipController.forward(from: 0).then((_) {
          setState(() => revealed[i] = true);
          _scaleController.forward().then((_) => _scaleController.reverse());
        });
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
    setState(() => isFlippingAll = false);
    _navigateToResults();
  }

  void _reshuffleCards() {
    _audioPlayer.play(AssetSource('audio/shuffle.mp3'));
    HapticFeedback.mediumImpact();
    setState(() {
      selectedCards = repository.drawRandomCards(widget.cardCount);
      revealed = List<bool>.filled(widget.cardCount, false);
    });
    _entryController.reset();
    _entryController.forward();
  }

  Future<void> _navigateToResults() async {
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
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context)!.couponRedeemed("Tokens added successfully"))),
        );
      },
    );
  }

  void _showDetailedCardInfo(TarotCard card) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  card.name,
                  style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              if (card.img.isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/tarot_card_images/${card.img}',
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white70, size: 50),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              _buildDetailRow("Arcana", card.arcana),
              _buildDetailRow("Suit", card.suit),
              _buildDetailRow("Number", card.number.toString()),
              if (card.archetype != null) _buildDetailRow("Archetype", card.archetype!),
              if (card.hebrewAlphabet != null) _buildDetailRow("Hebrew Alphabet", card.hebrewAlphabet!),
              if (card.numerology != null) _buildDetailRow("Numerology", card.numerology!),
              if (card.elemental != null) _buildDetailRow("Elemental", card.elemental!),
              if (card.mythicalSpiritual != null) _buildDetailRow("Mythical/Spiritual", card.mythicalSpiritual!),
              const SizedBox(height: 12),
              Text("Keywords", style: GoogleFonts.cinzel(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: card.keywords.map((k) => Chip(label: Text(k, style: GoogleFonts.cinzel(color: Colors.white)))).toList(),
              ),
              const SizedBox(height: 12),
              Text("Fortune Telling", style: GoogleFonts.cinzel(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ...card.fortuneTelling.map((f) => Text("• $f", style: GoogleFonts.cinzel(fontSize: 14, color: Colors.white70))),
              const SizedBox(height: 12),
              Text("Meanings", style: GoogleFonts.cinzel(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              Text("Light: ${card.meanings.light.join(', ')}", style: GoogleFonts.cinzel(fontSize: 14, color: Colors.white70)),
              Text("Shadow: ${card.meanings.shadow.join(', ')}", style: GoogleFonts.cinzel(fontSize: 14, color: Colors.white70)),
              if (card.questionsToAsk != null) ...[
                const SizedBox(height: 12),
                Text("Questions to Ask", style: GoogleFonts.cinzel(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ...card.questionsToAsk!.map((q) => Text("• $q", style: GoogleFonts.cinzel(fontSize: 14, color: Colors.white70))),
              ],
              const SizedBox(height: 16),
              Center(
                child: TapAnimatedScale(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text("Close", style: GoogleFonts.cinzel(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: GoogleFonts.cinzel(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: GoogleFonts.cinzel(fontSize: 14, color: Colors.white70))),
        ],
      ),
    );
  }

  Widget _buildCardWidget(int index) {
    if (index >= selectedCards.length) return const SizedBox.shrink();
    final TarotCard card = selectedCards[index];
    final bool isRevealed = revealed[index];

    return GestureDetector(
      onTap: () => _flipCard(index),
      onLongPress: () => _showDetailedCardInfo(card),
      onPanUpdate: (_) => _hoverController.forward(),
      onPanEnd: (_) => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: _entryController,
        builder: (context, child) {
          final entryValue = _entryController.value;
          final offset = Offset.lerp(const Offset(0, 50), Offset.zero, Curves.easeOutBack.transform(entryValue))!;
          return Transform.translate(
            offset: offset,
            child: Opacity(
              opacity: entryValue,
              child: AnimatedBuilder(
                animation: _cardFlipController,
                builder: (context, child) {
                  final flipValue = _cardFlipController.value;
                  final angle = isRevealed ? 0.0 : pi;
                  final transform = Matrix4.rotationY(lerpDouble(pi, 0, flipValue) ?? 0.0 * (isRevealed ? 1 : -1))..setEntry(3, 2, 0.001);
                  return Transform(
                    transform: transform,
                    alignment: Alignment.center,
                    child: AnimatedBuilder(
                      animation: _hoverController,
                      builder: (context, child) {
                        final hoverScale = 1.0 + (_hoverController.value * 0.1);
                        return AnimatedBuilder(
                          animation: _scaleController,
                          builder: (context, child) {
                            final scale = 1.0 + (_scaleController.value * 0.05);
                            return Transform.scale(
                              scale: hoverScale * scale,
                              child: isRevealed ? _buildCardFront(card) : _buildCardBack(),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      width: 90,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]),
        image: const DecorationImage(
          image: AssetImage('assets/tarot_card_images/card_back.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black54, BlendMode.dstATop),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
    );
  }

  Widget _buildCardFront(TarotCard card) {
    return Container(
      width: 90,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.deepPurple]),
        image: DecorationImage(
          image: AssetImage('assets/tarot_card_images/${card.img}'),
          fit: BoxFit.contain,
          onError: (exception, stackTrace) => const Icon(Icons.broken_image, color: Colors.white70, size: 40),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            color: Colors.black.withOpacity(0.6),
            child: Text(
              card.name,
              style: GoogleFonts.cinzel(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bloc = context.read<TarotBloc>();
    final spreadType = bloc.currentSpreadType ?? SpreadType.singleCard;

    const double cardWidth = 90.0;
    const double cardHeight = 140.0;
    const double padding = 10.0;

    Widget buildCardGrid(List<int> indices, {double? customSpacing}) {
      final crossAxisCount = (screenWidth / (cardWidth + (customSpacing ?? padding) * 2)).floor().clamp(1, 6);
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: customSpacing ?? padding,
          crossAxisSpacing: customSpacing ?? padding,
          childAspectRatio: cardWidth / cardHeight,
        ),
        itemCount: indices.length,
        itemBuilder: (context, index) => _buildCardWidget(indices[index]),
      );
    }

    Widget buildSpreadLayout(List<int> indices, List<String> positions, {double? customSpacing, MainAxisAlignment alignment = MainAxisAlignment.center}) {
      return Row(
        mainAxisAlignment: alignment,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(indices.length, (index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: customSpacing ?? padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCardWidget(indices[index]),
                const SizedBox(height: 4),
                Container(
                  width: cardWidth,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    positions[index],
                    style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }),
      );
    }

    switch (spreadType) {
      case SpreadType.singleCard:
        return Center(child: buildCardGrid([0], customSpacing: 20));
      case SpreadType.pastPresentFuture:
        return Center(
          child: buildSpreadLayout(
            [0, 1, 2],
            [S.of(context)!.celticCrossPast, S.of(context)!.celticCrossCurrentSituation, S.of(context)!.celticCrossFuture],
            customSpacing: 20,
          ),
        );
      case SpreadType.celticCross:
        return _buildCelticCrossLayout(cardWidth, cardHeight, screenWidth, screenHeight, padding);
      case SpreadType.yearlySpread:
        return buildCardGrid(List.generate(widget.cardCount, (i) => i), customSpacing: 15);
      case SpreadType.problemSolution:
        return Center(
          child: buildSpreadLayout(
            [0, 1],
            [S.of(context)!.problem, S.of(context)!.solution],
            customSpacing: 30,
          ),
        );
      case SpreadType.fiveCardPath:
        return _buildFiveCardPathLayout(cardWidth, cardHeight, screenWidth, padding);
      case SpreadType.relationshipSpread:
        return _buildRelationshipSpreadLayout(cardWidth, cardHeight, screenWidth, padding);
      case SpreadType.mindBodySpirit:
        return _buildMindBodySpiritLayout(cardWidth, cardHeight, screenWidth, padding);
      case SpreadType.astroLogicalCross:
        return _buildAstrologicalCrossLayout(cardWidth, cardHeight, screenWidth, padding);
      case SpreadType.brokenHeart:
        return _buildBrokenHeartLayout(cardWidth, cardHeight, screenWidth, padding);
      case SpreadType.dreamInterpretation:
        return Center(
          child: buildSpreadLayout(
            [0, 1, 2],
            [S.of(context)!.dreamPast, S.of(context)!.dreamPresent, S.of(context)!.dreamFuture],
            customSpacing: 20,
          ),
        );
      case SpreadType.horseshoeSpread:
        return _buildHorseshoeSpreadLayout(cardWidth, cardHeight, screenWidth, padding);
      case SpreadType.careerPathSpread:
        return _buildCareerPathSpreadLayout(cardWidth, cardHeight, screenWidth, padding);
      case SpreadType.fullMoonSpread:
        return _buildFullMoonSpreadLayout(cardWidth, cardHeight, screenWidth, padding);
      default:
        return buildCardGrid(List.generate(widget.cardCount, (i) => i));
    }
  }

  Widget _buildCelticCrossLayout(double cardWidth, double cardHeight, double screenWidth, double screenHeight, double padding) {
    final loc = S.of(context)!;
    final maxWidth = min(screenWidth * 0.9, 500);
    final adjustedCardWidth = min(cardWidth, maxWidth / 5);
    final adjustedCardHeight = adjustedCardWidth * 1.4;

    Widget buildCardWithLabel(int index, String text) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCardWidget(index),
          const SizedBox(height: 4),
          Container(
            width: adjustedCardWidth,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              text,
              style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: SizedBox(
          width: maxWidth.toDouble(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: buildCardWithLabel(0, loc.celticCrossSubconscious),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildCardWithLabel(1, loc.celticCrossChallenge),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildCardWithLabel(2, loc.celticCrossPast),
                      const SizedBox(height: 8),
                      buildCardWithLabel(3, loc.celticCrossCurrentSituation),
                      const SizedBox(height: 8),
                      buildCardWithLabel(4, loc.celticCrossFuture),
                    ],
                  ),
                  const SizedBox(width: 8),
                  buildCardWithLabel(5, loc.celticCrossNearFuture),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCardWithLabel(6, loc.celticCrossPersonalStance),
                    buildCardWithLabel(7, loc.celticCrossExternalInfluences),
                    buildCardWithLabel(8, loc.celticCrossHopesFears),
                    buildCardWithLabel(9, loc.celticCrossFinalOutcome),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiveCardPathLayout(double cardWidth, double cardHeight, double screenWidth, double padding) {
    final loc = S.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(0),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCardWidget(1),
                    const SizedBox(height: 10),
                    _buildCardWidget(2),
                    const SizedBox(height: 10),
                    _buildCardWidget(3),
                  ],
                ),
                const SizedBox(width: 10),
                _buildCardWidget(4),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: cardWidth, child: Text(loc.fiveCardPathPast, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: cardWidth, child: Text(loc.fiveCardPathPresent, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                    const SizedBox(height: 10),
                    Container(width: cardWidth, child: Text(loc.fiveCardPathChallenge, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                    const SizedBox(height: 10),
                    Container(width: cardWidth, child: Text(loc.fiveCardPathFuture, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                  ],
                ),
                const SizedBox(width: 10),
                Container(width: cardWidth, child: Text(loc.fiveCardPathOutcome, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationshipSpreadLayout(double cardWidth, double cardHeight, double screenWidth, double padding) {
    final loc = S.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(0),
                const SizedBox(width: 10),
                _buildCardWidget(1),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(2),
                const SizedBox(width: 10),
                _buildCardWidget(3),
                const SizedBox(width: 10),
                _buildCardWidget(4),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(5),
                const SizedBox(width: 10),
                _buildCardWidget(6),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: cardWidth, child: Text(loc.relationshipSelf, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 10),
                Container(width: cardWidth, child: Text(loc.relationshipPartner, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: cardWidth, child: Text(loc.relationshipPast, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 10),
                Container(width: cardWidth, child: Text(loc.relationshipPresent, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 10),
                Container(width: cardWidth, child: Text(loc.relationshipFuture, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: cardWidth, child: Text(loc.relationshipStrengths, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 10),
                Container(width: cardWidth, child: Text(loc.relationshipChallenges, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMindBodySpiritLayout(double cardWidth, double cardHeight, double screenWidth, double padding) {
    final loc = S.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(0),
                const SizedBox(width: 20),
                _buildCardWidget(1),
                const SizedBox(width: 20),
                _buildCardWidget(2),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: cardWidth, child: Text(loc.mindBody, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 20),
                Container(width: cardWidth, child: Text(loc.mindSpirit, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 20),
                Container(width: cardWidth, child: Text(loc.bodySpirit, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAstrologicalCrossLayout(double cardWidth, double cardHeight, double screenWidth, double padding) {
    final loc = S.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(0),
                const SizedBox(width: 20),
                _buildCardWidget(1),
                const SizedBox(width: 20),
                _buildCardWidget(2),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 20),
                _buildCardWidget(3),
                const SizedBox(width: 20),
                _buildCardWidget(4),
                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: cardWidth, child: Text(loc.astroPast, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 20),
                Container(width: cardWidth, child: Text(loc.astroPresent, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 20),
                Container(width: cardWidth, child: Text(loc.astroFuture, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 20),
                Container(width: cardWidth, child: Text(loc.astroChallenge, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 20),
                Container(width: cardWidth, child: Text(loc.astroOutcome, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrokenHeartLayout(double cardWidth, double cardHeight, double screenWidth, double padding) {
    final loc = S.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(0),
                const SizedBox(width: 15),
                _buildCardWidget(1),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 15),
                _buildCardWidget(2),
                const SizedBox(width: 15),
                _buildCardWidget(3),
                const SizedBox(width: 15),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(4),
                const SizedBox(width: 15),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: cardWidth, child: Text(loc.brokenHeartCause, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 15),
                Container(width: cardWidth, child: Text(loc.brokenHeartEmotion, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 15),
                Container(width: cardWidth, child: Text(loc.brokenHeartLesson, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 15),
                Container(width: cardWidth, child: Text(loc.brokenHeartHope, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 15),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: cardWidth, child: Text(loc.brokenHeartHealing, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 15),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorseshoeSpreadLayout(double cardWidth, double cardHeight, double screenWidth, double padding) {
    final loc = S.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(0),
                const SizedBox(width: 15),
                _buildCardWidget(1),
                const SizedBox(width: 15),
                _buildCardWidget(2),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 15),
                _buildCardWidget(3),
                const SizedBox(width: 15),
                _buildCardWidget(4),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 30),
                _buildCardWidget(5),
                const SizedBox(width: 30),
                _buildCardWidget(6),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: cardWidth, child: Text(loc.horseshoePast, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 15),
                Container(width: cardWidth, child: Text(loc.horseshoePresent, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 15),
                Container(width: cardWidth, child: Text(loc.horseshoeFuture, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 15),
                Container(width: cardWidth, child: Text(loc.horseshoeStrengths, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 15),
                Container(width: cardWidth, child: Text(loc.horseshoeObstacles, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 30),
                Container(width: cardWidth, child: Text(loc.horseshoeAdvice, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 30),
                Container(width: cardWidth, child: Text(loc.horseshoeOutcome, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerPathSpreadLayout(double cardWidth, double cardHeight, double screenWidth, double padding) {
    final loc = S.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(0),
                const SizedBox(width: 15),
                _buildCardWidget(1),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 15),
                _buildCardWidget(2),
                const SizedBox(width: 15),
                _buildCardWidget(3),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(4),
                const SizedBox(width: 15),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: cardWidth, child: Text(loc.careerPast, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 15),
                Container(width: cardWidth, child: Text(loc.careerPresent, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 15),
                Container(width: cardWidth, child: Text(loc.careerChallenge, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 15),
                Container(width: cardWidth, child: Text(loc.careerPotential, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: cardWidth, child: Text(loc.careerOutcome, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 15),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullMoonSpreadLayout(double cardWidth, double cardHeight, double screenWidth, double padding) {
    final loc = S.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(0),
                const SizedBox(width: 15),
                _buildCardWidget(1),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 15),
                _buildCardWidget(2),
                const SizedBox(width: 15),
                _buildCardWidget(3),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCardWidget(4),
                const SizedBox(width: 15),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: cardWidth, child: Text(loc.fullMoonPast, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 15),
                Container(width: cardWidth, child: Text(loc.fullMoonPresent, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 15),
                Container(width: cardWidth, child: Text(loc.fullMoonChallenge, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 15),
                Container(width: cardWidth, child: Text(loc.fullMoonHope, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: cardWidth, child: Text(loc.fullMoonOutcome, style: GoogleFonts.cinzel(fontSize: 8, color: Colors.white70))),
                const SizedBox(width: 15),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final loc = S.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(loc!.flipAllCards, _flipAllCards, Icons.flip, Colors.purple),
          _buildActionButton(loc.reshuffleCards, _reshuffleCards, Icons.shuffle, Colors.deepPurple),
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
              "${loc.reshuffleCards}: ${loc.instructionsReshuffle}\n"
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
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildCardLayout(context),
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                    ],
                  ),
                ),
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