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
                                      Shadow(
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
    final PageController cardPageController = PageController();
    int currentPage = 0;

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
        return Stack(
          children: [
            PageView.builder(
              controller: cardPageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                final position = spread.keys.elementAt(index);
                return SingleChildScrollView(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        position,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrangeAccent,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 350,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/tarot_card_images/${card.img}',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.broken_image, color: Colors.white70, size: 50),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.black.withOpacity(0.2),
                                      Colors.deepPurple.withOpacity(0.3),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        card.name,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: const Offset(1, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      _buildKeywords(card.keywords, loc),
                      const SizedBox(height: 16),
                      _buildFortuneTelling(card.fortuneTelling, loc),
                      const SizedBox(height: 16),
                      _buildMeanings(card, loc),
                      const SizedBox(height: 16),
                    ],
                  ),
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
                  cards.length,
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

  Widget _buildKeywords(List<String> keywords, S loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          loc.keywords,
          style: TextStyle(
            fontSize: 18,
            color: Colors.yellowAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: keywords.map((keyword) => Chip(
            label: Text(keyword),
            backgroundColor: Colors.orange[700],
            labelStyle: const TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildMeanings(TarotCard card, S loc) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.deepPurple[900]!.withOpacity(0.7),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.meaning,
            style: TextStyle(
              fontSize: 20,
              color: Colors.yellowAccent,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.transparent,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.thumb_up, color: Colors.green[400]),
                      const SizedBox(width: 8),
                      Text(
                        loc.lightMeaning,
                        style: TextStyle(
                          color: Colors.green[400],
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Arial',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...card.meanings.light.map(
                        (meaning) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '* $meaning',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: 'Arial',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.thumb_down, color: Colors.red[400]),
                      const SizedBox(width: 8),
                      Text(
                        loc.shadowMeaning,
                        style: TextStyle(
                          color: Colors.red[400],
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Arial',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...card.meanings.shadow.map(
                        (meaning) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '* $meaning',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: 'Arial',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneTelling(List<String> fortuneTelling, S loc) {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.fortuneTelling,
            style: TextStyle(
              fontSize: 20,
              color: Colors.yellowAccent,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
            ),
          ),
          const SizedBox(height: 12),
          ...fortuneTelling.map(
                (fortune) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '• $fortune',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontFamily: 'Arial',
                ),
              ),
            ),
          ),
        ],
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