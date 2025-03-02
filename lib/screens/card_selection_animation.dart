import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lottie/lottie.dart';
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/data/tarot_event_state.dart';
import 'package:tarot_fal/data/tarot_repository.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/models/tarot_card.dart';
import 'package:tarot_fal/screens/reading_result.dart';
import '../models/animations/tap_animations_scale.dart';




class CardSelectionAnimationScreen extends StatefulWidget {
  final int cardCount;

  const CardSelectionAnimationScreen({super.key, required this.cardCount});

  @override
  CardSelectionAnimationScreenState createState() => CardSelectionAnimationScreenState();
}

class CardSelectionAnimationScreenState extends State<CardSelectionAnimationScreen>
    with TickerProviderStateMixin {
  final TarotRepository repository = TarotRepository();
  late AnimationController _cardAnimationController;
  AnimationController? _entryAnimationController;
  List<TarotCard> selectedCards = [];
  late List<bool> revealed;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _entryAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeCards();
      }
    });
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _entryAnimationController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCards() async {
    try {
      await repository.loadCardsFromAsset();
      if (mounted) {
        setState(() {
          selectedCards = repository.drawRandomCards(widget.cardCount);
          revealed = List<bool>.filled(widget.cardCount, false);
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading cards: $e")),
        );
        setState(() => loading = false);
      }
    }
  }

  void _flipCard(int index) {
    if (!revealed[index]) {
      setState(() => revealed[index] = true);
      _cardAnimationController.forward().then((_) => _cardAnimationController.reverse());
    }
  }

  void _flipAllCards() {
    if (mounted) {
      setState(() => revealed = List<bool>.filled(widget.cardCount, true));
      _cardAnimationController.forward().then((_) => _cardAnimationController.reverse());
    }
  }

  void _reshuffleCards() {
    if (mounted) {
      setState(() {
        selectedCards = repository.drawRandomCards(widget.cardCount);
        revealed = List<bool>.filled(widget.cardCount, false);
      });
      _entryAnimationController?.reset();
      _entryAnimationController?.forward();
    }
  }

  Future<void> _navigateToResults() async {
    final bloc = context.read<TarotBloc>();
    if (!revealed.every((v) => v)) _flipAllCards();

    if (bloc.state is InsufficientResources) {
      _showPurchaseSheet(context, (bloc.state as InsufficientResources).requiredTokens);
      return;
    }

    if (bloc.currentSpreadType == SpreadType.singleCard) {
      bloc.add(DrawSingleCard());
    } else if (bloc.currentSpreadType == SpreadType.pastPresentFuture) {
      bloc.add(DrawPastPresentFuture());
    } else if (bloc.currentSpreadType == SpreadType.celticCross) {
      bloc.add(DrawCelticCross());
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ReadingResultScreenWithTransition()),
      );
    }
  }

  void _showPurchaseSheet(BuildContext context, double requiredTokens) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<TarotBloc>(context),
        child: InsufficientResourcesScreen(requiredCredits: requiredTokens),
      ),
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
                    child: Image.asset('assets/tarot_card_images/${card.img}', height: 150, fit: BoxFit.cover),
                  ),
                ),
              const SizedBox(height: 12),
              _buildDetailRow("Arcana", card.arcana),
              _buildDetailRow("Suit", card.suit),
              _buildDetailRow("Number", card.number),
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
                      gradient: LinearGradient(colors: [Colors.deepPurple[700]!, Colors.purple[900]!]),
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
        children: [
          Text("$label: ", style: GoogleFonts.cinzel(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
          Text(value, style: GoogleFonts.cinzel(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildCardWidget(int index, {required double cardWidth, required double cardHeight}) {
    if (index >= selectedCards.length) return const SizedBox.shrink();
    final TarotCard card = selectedCards[index];
    final bool isRevealed = revealed[index];

    return GestureDetector(
      onTap: () => _flipCard(index),
      onLongPress: () => _showDetailedCardInfo(card),
      child: AnimatedBuilder(
        animation: _entryAnimationController ?? AnimationController(vsync: this),
        builder: (context, child) {
          final animationValue = _entryAnimationController?.value ?? 0;
          final offset = Offset.lerp(
            const Offset(0, -1), // Ekran dışından yukarıdan gelme
            Offset.zero,
            Curves.easeOutBack.transform(animationValue),
          )!;
          return Transform.translate(
            offset: offset,
            child: Opacity(
              opacity: animationValue,
              child: AnimatedScale(
                scale: isRevealed ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: AnimatedBuilder(
                  animation: _cardAnimationController,
                  builder: (context, child) {
                    final angle = isRevealed ? 0.0 : pi;
                    final transform = Matrix4.rotationY(angle * _cardAnimationController.value);
                    return Transform(
                      transform: transform,
                      alignment: Alignment.center,
                      child: isRevealed ? _buildCardFront(card, cardWidth, cardHeight) : _buildCardBack(cardWidth, cardHeight),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardBack(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: [Colors.deepPurple[900]!, Colors.purple[700]!]),
        image: const DecorationImage(
          image: AssetImage('assets/tarot_card_images/card_back.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black54, BlendMode.dstATop),
        ),
      ),
    );
  }

  Widget _buildCardFront(TarotCard card, double width, double height) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(colors: [Colors.purple[900]!, Colors.deepPurple[700]!]),
            image: DecorationImage(
              image: AssetImage('assets/tarot_card_images/${card.img}'),
              fit: BoxFit.contain,
              onError: (exception, stackTrace) => const Icon(Icons.broken_image, color: Colors.white70, size: 50),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: width,
          child: Text(
            card.name,
            style: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCardLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height; // screenHeight eklenerek tanımlandı
    final bloc = context.read<TarotBloc>();
    final spreadType = bloc.currentSpreadType;

    // Simetrik kart boyutları
    double cardWidth = screenWidth * 0.25; // Ekranın %25’i, simetrik bir oran
    double cardHeight = cardWidth * 1.5;
    double padding = 16.0;

    // Celtic Cross için ek alan bırakma
    if (spreadType == SpreadType.celticCross && widget.cardCount == 10) {
      return _buildCelticCrossLayout(cardWidth, cardHeight, screenWidth, screenHeight, padding);
    } else if (spreadType == SpreadType.pastPresentFuture && widget.cardCount == 3) {
      return _buildPastPresentFutureLayout(cardWidth, cardHeight, screenWidth, padding);
    } else {
      return _buildGenericLayout(cardWidth, cardHeight, screenWidth, padding);
    }
  }

  Widget _buildGenericLayout(double cardWidth, double cardHeight, double screenWidth, double padding) {
    int maxCardsPerRow = (screenWidth / (cardWidth + padding * 2)).floor();
    if (maxCardsPerRow < 1) maxCardsPerRow = 1;

    if (widget.cardCount == 1) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.2), // screenHeight burada kullanılacak
          child: _buildCardWidget(0, cardWidth: cardWidth, cardHeight: cardHeight),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: padding,
        runSpacing: padding,
        children: List.generate(widget.cardCount, (index) => SizedBox(
          width: cardWidth,
          child: _buildCardWidget(index, cardWidth: cardWidth, cardHeight: cardHeight),
        )),
      ),
    );
  }

  Widget _buildPastPresentFutureLayout(double cardWidth, double cardHeight, double screenWidth, double padding) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.cardCount, (index) => Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: _buildCardWidget(index, cardWidth: cardWidth, cardHeight: cardHeight),
          )),
        ),
      ),
    );
  }

  Widget _buildCelticCrossLayout(double cardWidth, double cardHeight, double screenWidth, double screenHeight, double padding) {
    // Dil desteği için S sınıfını kullan
    final loc = S.of(context)!;

    // Ekran boyutlarına göre ayarlamalar
    final maxWidth = screenWidth * 0.9;

    // Kart boyutlarını ayarla
    final adjustedCardWidth = min(cardWidth, maxWidth / 4.5);
    final adjustedCardHeight = adjustedCardWidth * 1.5;

    // Etiket oluşturma fonksiyonu
    Widget buildLabel(String text) {
      return Container(
        width: adjustedCardWidth,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          text,
          style: GoogleFonts.cinzel(
            fontSize: 10,
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      );
    }

    // Kart ve etiket birleşimi
    Widget buildCardWithLabel(int index, String text) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCardWidget(index, cardWidth: adjustedCardWidth, cardHeight: adjustedCardHeight),
          const SizedBox(height: 4),
          buildLabel(text),
        ],
      );
    }

    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: maxWidth,
          child: Column(
            children: [
              // Üst kart - SUBCO
              Padding(
                padding: EdgeInsets.symmetric(vertical: padding * 2),
                child: buildCardWithLabel(0, loc.celticCrossSubconscious),
              ),

              // İkinci sıra - 4 kart yan yana
              Container(
                margin: EdgeInsets.symmetric(vertical: padding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCardWithLabel(1, loc.celticCrossChallenge),
                    buildCardWithLabel(2, loc.celticCrossPast),
                    buildCardWithLabel(3, loc.celticCrossCurrentSituation),
                    buildCardWithLabel(4, loc.celticCrossFuture),
                  ],
                ),
              ),

              // Orta kart - NEAR
              Padding(
                padding: EdgeInsets.symmetric(vertical: padding * 2),
                child: buildCardWithLabel(5, loc.celticCrossNearFuture),
              ),

              // Alt sıra - 4 kart yan yana
              Container(
                margin: EdgeInsets.only(bottom: padding * 2),
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



  Widget _buildActionButtons() {
    final loc = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(loc!.flipAllCards, _flipAllCards, Icons.flip),
          _buildActionButton(loc.reshuffleCards, _reshuffleCards, Icons.shuffle),
          _buildActionButton(loc.viewResults, _navigateToResults, Icons.arrow_forward),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed, IconData icon) {
    return TapAnimatedScale(
      onTap: onPressed,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.deepPurple[700]!, Colors.purple[900]!]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.cinzel(fontSize: 12, color: Colors.white),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    if (loading || _entryAnimationController == null) {
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
          _showPurchaseSheet(context, state.requiredTokens);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(loc!.cardSelection, style: GoogleFonts.cinzel(color: Colors.white)),
            backgroundColor: Colors.deepPurple[900],
            elevation: 0,
          ),
          body: Stack(
            children: [
              Lottie.asset('assets/animations/tarot_shuffle.json', fit: BoxFit.cover, repeat: true),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.deepPurple[900]!.withOpacity(0.7), Colors.black.withOpacity(0.9)],
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(child: SingleChildScrollView(child: Center(child: _buildCardLayout(context)))),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}




class InsufficientResourcesScreen extends StatelessWidget {
  final double requiredCredits;

  const InsufficientResourcesScreen({super.key, this.requiredCredits = 1.0});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.6,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple[900]!, Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc!.insufficientCreditsAndLimit,
              style: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              loc.insufficientCreditsMessage(requiredCredits),
              style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildPurchaseOption(context, "10 Credits", 0.99, '10_credits'),
            const SizedBox(height: 12),
            _buildPurchaseOption(context, "50 Credits", 4.99, '50_credits'),
            const SizedBox(height: 12),
            _buildPurchaseOption(context, "100 Credits", 9.99, '100_credits'),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.cancel, style: GoogleFonts.cinzel(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseOption(BuildContext context, String title, double price, String productId) {
    return TapAnimatedScale(
      onTap: () async {
        final purchaseParam = PurchaseParam(
          productDetails: ProductDetails(
            id: productId,
            title: title,
            description: 'Purchase $title',
            price: '$price USD',
            rawPrice: price,
            currencyCode: 'USD',
          ),
        );
        try {
          await InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Purchase failed: $e')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[700]!.withOpacity(0.8), Colors.deepPurple[900]!.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.cinzel(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
            ),
            Text('\$$price', style: GoogleFonts.cinzel(fontSize: 16, color: Colors.white)),
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

class ReadingResultScreenWithTransitionState extends State<ReadingResultScreenWithTransition>
    with SingleTickerProviderStateMixin {
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
                'Unveiling the Mystical Path...',
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  color: Colors.white70,
                  shadows: [
                    Shadow(
                      color: Colors.purple.withOpacity(0.5),
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