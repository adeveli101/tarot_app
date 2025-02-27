import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/models/tarot_card.dart';

class ReadingDetailScreen extends StatelessWidget {
  final String spreadType;
  final String yorum;
  final Map<String, dynamic> spread;
  final DateTime timestamp;

  const ReadingDetailScreen({
    super.key,
    required this.spreadType,
    required this.yorum,
    required this.spread,
    required this.timestamp,
  });

  void _shareReading(BuildContext context) {
    Share.share("$spreadType\n${S.of(context)!.dateLabel} ${timestamp.toString().substring(0, 16)}\n\n$yorum");
  }

  List<TarotCard> _convertSpreadToTarotCards(Map<String, dynamic> spreadData) {
    return spreadData.entries.map((entry) {
      final cardData = entry.value as Map<String, dynamic>;
      return TarotCard(
        name: cardData['name'] as String? ?? "Unknown",
        arcana: cardData['arcana'] as String? ?? "",
        suit: cardData['suit'] as String? ?? "",
        number: cardData['number']?.toString() ?? "0",
        keywords: (cardData['keywords'] as List<dynamic>?)?.cast<String>() ?? [],
        meanings: Meanings(
          light: (cardData['meanings']['light'] as List<dynamic>?)?.cast<String>() ?? [],
          shadow: (cardData['meanings']['shadow'] as List<dynamic>?)?.cast<String>() ?? [],
        ),
        fortuneTelling: (cardData['fortuneTelling'] as List<dynamic>?)?.cast<String>() ?? [],
        img: cardData['img'] as String? ?? "",
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Container(
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
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 50),
                  TabBar(
                    labelStyle: GoogleFonts.cinzel(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    unselectedLabelStyle: GoogleFonts.cinzel(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    indicatorColor: Colors.deepOrangeAccent,
                    tabs: [
                      Tab(text: loc!.customPromptTitle),
                      Tab(text: loc.cardSelection),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildFortuneTellingPage(context, loc),
                        _buildSpreadCards(context, loc),
                      ],
                    ),
                  ),
                ],
              ),
              _buildCloseButton(context),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFortuneTellingPage(BuildContext context, S loc) {
    final sections = yorum.split(RegExp(r'\n### '));
    final PageController fortunePageController = PageController();
    int currentPage = 0;

    return StatefulBuilder(
      builder: (context, setState) {
        return Stack(
          children: [
            PageView.builder(
              controller: fortunePageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemCount: sections.length,
              itemBuilder: (context, index) {
                String sectionText = sections[index];
                if (index != 0) sectionText = "### $sectionText";

                final List<String> lines = sectionText.split('\n');
                String title = lines.firstWhere((line) => line.trim().isNotEmpty, orElse: () => '');
                String content = lines.skipWhile((line) => line == title).join('\n').trim();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (title.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 24, bottom: 16),
                                child: Text(
                                  title.replaceAll('###', '').trim(),
                                  style: TextStyle(
                                    color: Colors.deepOrangeAccent,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      BoxShadow(
                                        color: Colors.black54,
                                        offset: const Offset(2, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.deepPurple[900]!.withOpacity(0.8),
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                content,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.5,
                                  fontFamily: 'Arial',
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (index == 0 && content.length < 150)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  loc.swipeForMore,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.yellowAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  sections.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentPage == index ? Colors.deepOrangeAccent : Colors.white54,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpreadCards(BuildContext context, S loc) {
    final cards = _convertSpreadToTarotCards(spread);
    final List<bool> revealed = List<bool>.filled(cards.length, false);

    if (cards.isEmpty) {
      return Center(
        child: Text(
          loc.cardDeckEmpty,
          style: GoogleFonts.cinzel(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      );
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Wrap(
              spacing: 12,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              children: List.generate(cards.length, (index) {
                final card = cards[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      revealed[index] = !revealed[index];
                    });
                  },
                  onLongPress: () => _showCardDetails(context, card, loc),
                  child: AnimatedScale(
                    scale: revealed[index] ? 1.1 : 1.0,
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
                      child: revealed[index]
                          ? _buildCardFront(card, key: ValueKey("front_$index"))
                          : _buildCardBack(key: ValueKey("back_$index")),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
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
          style: GoogleFonts.cinzel(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showCardDetails(BuildContext context, TarotCard card, S loc) {
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
                  loc.fortuneTelling,
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
                  loc.keywords,
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
                  loc.meaning,
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
                child: Text(loc.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Positioned(
      top: 40,
      right: 16,
      child: TapAnimatedScale(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.purple[300]!.withOpacity(0.5)),
          ),
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: null,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final loc = S.of(context);
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionButton(
            context: context,
            label: loc!.share,
            icon: Icons.share,
            onPressed: () => _shareReading(context),
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            context: context,
            label: loc.returnToHome,
            icon: Icons.home,
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(
        label,
        style: GoogleFonts.cinzel(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple[900]!.withOpacity(0.9),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: Colors.black54,
      ),
    );
  }
}

// TapAnimatedScale sınıfı
class TapAnimatedScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const TapAnimatedScale({super.key, required this.child, required this.onTap});

  @override
  TapAnimatedScaleState createState() => TapAnimatedScaleState();
}

class TapAnimatedScaleState extends State<TapAnimatedScale> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.reverse();
  void _onTapUp(TapUpDetails details) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _controller,
        child: widget.child,
      ),
    );
  }
}