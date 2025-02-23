import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tarot_fal/generated/l10n.dart'; // S sınıfını import ediyoruz
import 'package:tarot_fal/models/tarot_card.dart';
import 'package:tarot_fal/data/tarot_repository.dart';
import 'package:tarot_fal/screens/reading_result.dart';

class CardSelectionAnimationScreen extends StatefulWidget {
  final int cardCount;
  const CardSelectionAnimationScreen({super.key, this.cardCount = 10});

  @override
  CardSelectionAnimationScreenState createState() => CardSelectionAnimationScreenState();
}

class CardSelectionAnimationScreenState extends State<CardSelectionAnimationScreen> {
  final TarotRepository repository = TarotRepository();
  List<TarotCard> selectedCards = [];
  late List<bool> revealed;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }

  Future<void> _initializeCards() async {
    try {
      await repository.loadCardsFromAsset();
    } catch (e) {
      // Hata durumunda loglama yapılabilir ya da zaten yüklenmişse devam edilebilir.
    }
    List<TarotCard> cards = repository.drawRandomCards(widget.cardCount);
    setState(() {
      selectedCards = cards;
      revealed = List<bool>.filled(widget.cardCount, false);
      loading = false;
    });
  }

  void _flipCard(int index) {
    if (!revealed[index]) {
      setState(() {
        revealed[index] = true;
      });
    }
  }

  void _flipAllCards() {
    setState(() {
      revealed = List<bool>.filled(widget.cardCount, true);
    });
  }

  void _reshuffleCards() {
    setState(() {
      selectedCards = repository.drawRandomCards(widget.cardCount);
      revealed = List<bool>.filled(widget.cardCount, false);
    });
  }

  void _goToResultScreen() {
    if (!revealed.every((v) => v)) {
      _flipAllCards();
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) { // Widget hala aktif mi kontrol et
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ReadingResultScreen()),
        );
      }
    });
  }

  void _showCardDetails(TarotCard card) {
    final loc = S.of(context); // Lokalizasyon için S sınıfını kullanıyoruz
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
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
        );
      },
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
        curve: Curves.easeOut,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
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
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
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
          image: const DecorationImage(
            image: AssetImage('assets/tarot_card_images/card_back.png'),
            fit: BoxFit.cover,
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
              image: DecorationImage(
                image: AssetImage('assets/tarot_card_images/${card.img}'),
                fit: BoxFit.contain,
                alignment: Alignment.center,
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
        Lottie.asset('assets/animations/tarot_shuffle.json', fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.indigo[900]!.withOpacity(0.4),
                Colors.deepPurple[800]!.withOpacity(0.3),
                Colors.purple[700]!.withOpacity(0.5),
                Colors.black.withOpacity(0.9),
              ],
              stops: const [0.1, 0.4, 0.7, 0.9],
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
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(loc!.cardSelection),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    loc.cardSelectionInstructions,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: List.generate(widget.cardCount, (index) => _buildCardWidget(index)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _flipAllCards,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
                        ),
                        child: Text(
                          loc.flipAllCards,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _reshuffleCards,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
                        ),
                        child: Text(
                          loc.reshuffleCards,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _goToResultScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        ),
                        child: Text(
                          loc.viewResults,
                          style: const TextStyle(fontSize: 16),
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