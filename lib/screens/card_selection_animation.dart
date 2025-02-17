import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tarot_fal/models/tarot_card.dart';
import 'package:tarot_fal/data/tarot_repository.dart';
import 'package:tarot_fal/screens/reading_result.dart';

class CardSelectionAnimationScreen extends StatefulWidget {
  final int cardCount; // Seçilmesi gereken toplam kart sayısı
  const CardSelectionAnimationScreen({Key? key, this.cardCount = 10}) : super(key: key);

  @override
  _CardSelectionAnimationScreenState createState() => _CardSelectionAnimationScreenState();
}

class _CardSelectionAnimationScreenState extends State<CardSelectionAnimationScreen> {
  final TarotRepository repository = TarotRepository();
  List<TarotCard> selectedCards = [];
  late List<bool> revealed; // Her kartın açılmış olma durumunu tutar
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
    // drawRandomCards metodu, desteden tekrarsız kart çekmenizi sağlar.
    List<TarotCard> cards = repository.drawRandomCards(widget.cardCount);
    setState(() {
      selectedCards = cards;
      revealed = List<bool>.filled(widget.cardCount, false);
      loading = false;
    });
  }

  /// Belirli indeksteki kartın açılmasını sağlar. Aynı kart birden fazla açılmaz.
  void _flipCard(int index) {
    if (!revealed[index]) {
      setState(() {
        revealed[index] = true;
      });
    }
  }

  /// Tüm kartların açılmasını sağlar.
  void _flipAllCards() {
    setState(() {
      revealed = List<bool>.filled(widget.cardCount, true);
    });
  }

  /// Kartları yeniden karıştırarak desteyi sıfırlar.
  void _reshuffleCards() {
    setState(() {
      selectedCards = repository.drawRandomCards(widget.cardCount);
      revealed = List<bool>.filled(widget.cardCount, false);
    });
  }

  /// Eğer bazı kartlar hâlâ kapalıysa, önce tümünü açar; ardından okuma sonuç ekranına yönlendirir.
  void _goToResultScreen() {
    if (!revealed.every((v) => v)) {
      _flipAllCards();
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ReadingResultScreen()),
      );
    });
  }

  /// Kart detaylarını gösteren modal dialog. Kart uzun basılı tutulduğunda çalışır.
  void _showCardDetails(TarotCard card) {
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
                // Kart görseli (img alanı boş değilse gösterilir)
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
                // Kart adı
                Text(
                  card.name,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Fal Yorumu (varsa)
                if (card.fortuneTelling.isNotEmpty) ...[
                  Text(
                    "Fal Yorumu:",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70),
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
                // Anahtar Kelimeler (varsa)
                if (card.keywords.isNotEmpty) ...[
                  Text(
                    "Anahtar Kelimeler:",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: card.keywords
                        .map((kw) => Chip(
                      label: Text(kw,
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.deepPurple,
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                // Anlamlar: Işık ve Gölge (varsa)
                if (card.meanings.light.isNotEmpty ||
                    card.meanings.shadow.isNotEmpty) ...[
                  Text(
                    "Anlamlar:",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  if (card.meanings.light.isNotEmpty)
                    Text(
                      "Işık: ${card.meanings.light.join(', ')}",
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  if (card.meanings.shadow.isNotEmpty)
                    Text(
                      "Gölge: ${card.meanings.shadow.join(', ')}",
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  const SizedBox(height: 8),
                ],
                // Kapat butonu
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text("Kapat"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  /// Kart widget’i: AnimatedSwitcher ve AnimatedScale kullanılarak kapalıdan açığa flip animasyonu sağlanır.
  /// Açılan kartlar, hafif ölçeklenme efektiyle vurgulanır.
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
            // Yatay flip animasyonu: Kartın Y ekseni etrafında dönmesi sağlanır.
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

  /// Kapalı kartın ön yüzü: Sabit arka yüz resmi kullanılır.
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

  /// Açılmış kartın ön yüzü: Kartın asset içindeki resmi getirilir ve tüm kart fotoğrafı görünür.
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
                fit: BoxFit.contain, // Tüm resmin görünmesi sağlanır.
                alignment: Alignment.center, // Resmin ortalanması sağlanır.
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



  /// Arka plan; Lottie animasyonu, gradient overlay ve shader mask ile tematik bir atmosfer oluşturur.
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
    if (loading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kart Seçimi"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Kart sayısı kadar kapalı kart ekranda görüntülenecektir.\nLütfen tek tek dokunarak açınız, uzun basarak kısa açıklamasını görün veya 'Bütün Kartları Çevir' seçeneğini kullanınız.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Kartların çok olduğu durumlarda kaydırılabilir ekran
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
                // Alt kısım: İşlem butonları
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
                        child: const Text(
                          "Bütün Kartları Çevir",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _reshuffleCards,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
                        ),
                        child: const Text(
                          "Kartları Yeniden Karıştır",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _goToResultScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        ),
                        child: const Text(
                          "Sonuçları Gör",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
