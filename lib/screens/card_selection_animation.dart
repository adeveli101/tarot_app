import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/models/tarot_card.dart';
import 'package:tarot_fal/data/tarot_repository.dart';
import 'package:tarot_fal/screens/reading_result.dart';

import '../data/tarot_event_state.dart';
import '../models/animations/tap_animations_scale.dart';


class CardSelectionAnimationScreen extends StatefulWidget {
  final int cardCount;
  const CardSelectionAnimationScreen({super.key, this.cardCount = 10});

  @override
  CardSelectionAnimationScreenState createState() => CardSelectionAnimationScreenState();
}

class CardSelectionAnimationScreenState extends State<CardSelectionAnimationScreen> with SingleTickerProviderStateMixin {
  final TarotRepository repository = TarotRepository();
  List<TarotCard> selectedCards = [];
  late List<bool> revealed;
  bool loading = true;
  late AnimationController _cardAnimationController;

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _initializeCards();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeCards() async {
    try {
      await repository.loadCardsFromAsset();
      List<TarotCard> cards = repository.drawRandomCards(widget.cardCount);
      setState(() {
        selectedCards = cards;
        revealed = List<bool>.filled(widget.cardCount, false);
        loading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading cards: $e")),
        );
        setState(() {
          loading = false;
        });
      }
    }
  }

  void _flipCard(int index) {
    if (!revealed[index]) {
      setState(() {
        revealed[index] = true;
      });
      _cardAnimationController.forward().then((_) => _cardAnimationController.reverse());
    }
  }

  void _flipAllCards() {
    if (mounted) {
      setState(() {
        revealed = List<bool>.filled(widget.cardCount, true);
      });
      _cardAnimationController.forward().then((_) => _cardAnimationController.reverse());
    }
  }

  void _reshuffleCards() {
    if (mounted) {
      setState(() {
        selectedCards = repository.drawRandomCards(widget.cardCount);
        revealed = List<bool>.filled(widget.cardCount, false);
      });
      _cardAnimationController.forward().then((_) => _cardAnimationController.reverse());
    }
  }

  void _showPurchaseSheet(BuildContext context, double requiredCredits) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<TarotBloc>(context),
        child: InsufficientResourcesScreen(requiredCredits: requiredCredits),
      ),
    ).then((_) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    });
  }

  void _checkCreditsAndNavigate() {
    final bloc = context.read<TarotBloc>();
    if (!revealed.every((v) => v)) {
      _flipAllCards();
    }

    if (kDebugMode) {
      print("Checking credits: isPremium=${bloc.isPremium}, dailyFreeFalCount=${bloc.dailyFreeFalCount}, userCredits=${bloc.userCredits}, state=${bloc.state.runtimeType}");
    }
    if (bloc.state is InsufficientResources) {
      _showPurchaseSheet(context, (bloc.state as InsufficientResources).requiredCredits);
      return;
    }

    if (bloc.isPremium) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ReadingResultScreenWithTransition()),
      );
    } else if (bloc.dailyFreeFalCount < 5) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ReadingResultScreenWithTransition()),
      );
    } else if (bloc.userCredits >= (bloc.currentSpreadType?.costInCredits ?? 1.0)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ReadingResultScreenWithTransition()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context)!.dailyLimitReached),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: S.of(context)!.purchaseCredits,
            onPressed: () => _showPurchaseSheet(context, bloc.currentSpreadType?.costInCredits ?? 1.0),
          ),
        ),
      );
      _showNextFreeReadingInfo(context);
    }
  }

  void _showNextFreeReadingInfo(BuildContext context) {
    final bloc = context.read<TarotBloc>();
    final prefs = SharedPreferences.getInstance();
    prefs.then((prefs) {
      final lastReset = prefs.getInt('last_reset_${bloc.userId}') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
      final hoursUntilNext = lastReset < now ? 24 - (DateTime.now().hour % 24) : 24 - ((DateTime.now().hour - (lastReset % 24)) % 24);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context)!.nextFreeReadingInfo(hoursUntilNext)),
          duration: const Duration(seconds: 5),
        ),
      );
    });
  }

  void _showCardDetails(TarotCard card) {
    final loc = S.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (card.img.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/tarot_card_images/${card.img}',
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                card.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Arcana: ${card.arcana}, Suit: ${card.suit}, Number: ${card.number}",
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              if (card.fortuneTelling.isNotEmpty) ...[
                Text(
                  loc!.fortuneTelling,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                ...card.fortuneTelling.map(
                      (yorum) => Text(
                    yorum,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (card.keywords.isNotEmpty) ...[
                Text(
                  loc!.keywords,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: card.keywords
                      .map((kw) => Chip(
                    label: Text(kw, style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.deepPurple,
                  ))
                      .toList(),
                ),
                const SizedBox(height: 8),
              ],
              if (card.meanings.light.isNotEmpty || card.meanings.shadow.isNotEmpty) ...[
                Text(
                  loc!.meaning,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                if (card.meanings.light.isNotEmpty)
                  Text(
                    "${loc.lightMeaning} ${card.meanings.light.join(', ')}",
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                if (card.meanings.shadow.isNotEmpty)
                  Text(
                    "${loc.shadowMeaning} ${card.meanings.shadow.join(', ')}",
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                const SizedBox(height: 8),
              ],
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(loc!.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardWidget(int index) {
    final TarotCard card = selectedCards[index];
    final bool isRevealed = revealed[index];
    return GestureDetector(
      onTap: () => _flipCard(index),
      onLongPress: () => _showCardDetails(card),
      child: AnimatedScale(
        scale: isRevealed ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final rotateAnim = Tween(begin: pi, end: 0.0).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ));
            return AnimatedBuilder(
              animation: rotateAnim,
              child: child,
              builder: (context, child) {
                final angle = rotateAnim.value;
                return Transform(
                  transform: Matrix4.rotationY(angle),
                  alignment: Alignment.center,
                  child: child,
                );
              },
            );
          },
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[if (currentChild != null) currentChild, ...previousChildren],
            );
          },
          child: isRevealed
              ? _buildCardFront(card, key: ValueKey("front_$index"))
              : _buildCardBack(key: ValueKey("back_$index")),
        ),
      ),
    );
  }

  Widget _buildCardBack({Key? key}) {
    return Card(
      key: key,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 120,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.deepPurple[900]!, Colors.purple[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          image: const DecorationImage(
            image: AssetImage('assets/tarot_card_images/card_back.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.dstATop),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront(TarotCard card, {Key? key}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          key: key,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 130,
            height: 210,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.purple[900]!, Colors.deepPurple[700]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              image: DecorationImage(
                image: AssetImage('assets/tarot_card_images/${card.img}'),
                fit: BoxFit.contain,
                alignment: Alignment.center,
                onError: (exception, stackTrace) => const Icon(
                  Icons.broken_image,
                  color: Colors.white70,
                  size: 50,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          card.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Lottie.asset(
          'assets/animations/tarot_shuffle.json',
          fit: BoxFit.contain,
          frameRate: FrameRate(24),
          repeat: true,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple[900]!.withOpacity(0.4),
                Colors.black.withOpacity(0.9),
              ],
              stops: const [0.3, 0.9],
            ),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple[200]!.withOpacity(0.2),
              Colors.transparent,
              Colors.indigo[300]!.withOpacity(0.2),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    if (loading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(loc!.cardSelection),
        backgroundColor: Colors.deepPurple[900],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.black87,
                  title: Text(loc.cardSelection, style: const TextStyle(color: Colors.white)),
                  content: Text(loc.cardSelectionInstructions, style: const TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(loc.close, style: const TextStyle(color: Colors.deepPurple)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                  child: Text(
                    loc.cardSelectionInstructions,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      children: List.generate(widget.cardCount, (index) => _buildCardWidget(index)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _flipAllCards,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple[900],
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          loc.flipAllCards,
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _reshuffleCards,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple[900],
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          loc.reshuffleCards,
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _checkCreditsAndNavigate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple[900],
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          loc.viewResults,
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            colors: [
              Colors.deepPurple[900]!,
              Colors.black87,
            ],
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
              style: GoogleFonts.cinzel(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              loc.insufficientCreditsMessage(requiredCredits),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildPurchaseOption(context, "10 Credits", 0.99, '10_credits'),
            const SizedBox(height: 12),
            _buildPurchaseOption(context, "50 Credits", 4.99, '50_credits'),
            const SizedBox(height: 12),
            _buildPurchaseOption(context, "100 Credits", 9.99, '100_credits'),
            const SizedBox(height: 16),
            _buildPremiumOption(context),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                loc.cancel,
                style: const TextStyle(color: Colors.white70),
              ),
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
            colors: [
              Colors.purple[700]!.withOpacity(0.8),
              Colors.deepPurple[900]!.withOpacity(0.6),
            ],
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
              style: GoogleFonts.cinzel(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '\$$price',
              style: GoogleFonts.cinzel(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumOption(BuildContext context) {
    return TapAnimatedScale(
      onTap: () async {
        final purchaseParam = PurchaseParam(
          productDetails: ProductDetails(
            id: 'premium_subscription',
            title: 'Premium Subscription',
            description: 'Unlock premium features',
            price: '9.99 USD',
            rawPrice: 9.99,
            currencyCode: 'USD',
          ),
        );
        try {
          await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Premium purchase failed: $e')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple[700]!.withOpacity(0.8),
              Colors.deepPurple[900]!.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Get Premium',
              style: GoogleFonts.cinzel(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'USD 9.99',
              style: GoogleFonts.cinzel(
                fontSize: 16,
                color: Colors.white,
              ),
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2), // Animasyon süresi
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ReadingResultScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C1A4D), // Derin mor
              Color(0xFF0D0D0D), // Siyah
            ],
            stops: [0.3, 0.9],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/tarot_loading.json', // Mistik bir animasyon dosyası, assets'a eklemelisiniz
                controller: _animationController,
                height: 200,
                fit: BoxFit.cover,
                repeat: false,
              ),
              const SizedBox(height: 20),
              Text(
                'Unveiling the Mystical Path...',
                style: TextStyle(
                  fontFamily: 'Cinzel',
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