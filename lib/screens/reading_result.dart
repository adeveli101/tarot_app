import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/models/tarot_card.dart';
import 'package:tarot_fal/screens/settings_screen.dart';
import 'package:tarot_fal/screens/tarot_fortune_reading_screen.dart';
import '../data/tarot_bloc.dart';
import '../data/tarot_event_state.dart';
import '../main.dart';
import '../models/animations/tap_animations_scale.dart';

class ReadingResultScreen extends StatefulWidget {
  const ReadingResultScreen({super.key});

  @override
  State<ReadingResultScreen> createState() => _ReadingResultScreenState();
}

class _ReadingResultScreenState extends State<ReadingResultScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _glowController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _glowController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _shareReading(String content) {
    Share.share(content);
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => TarotReadingScreen(
          onSettingsTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(
                  onLocaleChange: (locale, ctx) {
                    final myAppState = context.findAncestorStateOfType<MyAppState>();
                    myAppState?.changeLocale(locale, ctx);
                  },
                  currentLocale: Localizations.localeOf(context),
                ),
              ),
            );
          },
        ),
      ),
          (route) => false,
    );
  }

  void _showCardDetails(TarotCard card) {
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
                        _buildDetailSection("Fortune Telling", card.fortuneTelling.join("\n\n")),
                        _buildDetailSection("Light Meanings", card.meanings.light.join("\n\n")),
                        _buildDetailSection("Shadow Meanings", card.meanings.shadow.join("\n\n")),
                        if (card.archetype != null) _buildDetailSection("Archetype", card.archetype!),
                        if (card.hebrewAlphabet != null) _buildDetailSection("Hebrew Alphabet", card.hebrewAlphabet!),
                        if (card.numerology != null) _buildDetailSection("Numerology", card.numerology!),
                        if (card.mythicalSpiritual != null) _buildDetailSection("Mythical/Spiritual", card.mythicalSpiritual!),
                        if (card.questionsToAsk != null) _buildDetailSection("Questions to Ask", card.questionsToAsk!.join("\n\n")),
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
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPage(String position, TarotCard card, SpreadDrawn? state) {
    final loc = S.of(context);
    return SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    const SizedBox(height: 80),
    AnimatedBuilder(
    animation: _glowController,
    builder: (context, child) {
    return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [Colors.amber[300]!.withOpacity(0.8), Colors.deepPurple[900]!.withOpacity(0.9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
    BoxShadow(
    color: Colors.amber[300]!.withOpacity(0.5 + _glowController.value * 0.3),
    blurRadius: 10 + _glowController.value * 5,
    spreadRadius: 2,
    ),
    ],
    ),
    child: Text(
    position,
    style: GoogleFonts.cinzel(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontStyle: FontStyle.italic, // Pozisyon ismi italik
    ),
    textAlign: TextAlign.center,
    ),
    );
    },
    ),
    const SizedBox(height: 20),
    GestureDetector(
    onTap: () => _showCardDetails(card),
    child: Container(
    height: 360,
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
    BoxShadow(
    color: Colors.purpleAccent.withOpacity(0.4),
    blurRadius: 15,
    spreadRadius: 2,
    ),
    ],
    ),
    child: ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Stack(
    fit: StackFit.expand,
    children: [
    Image.asset(
    'assets/tarot_card_images/${card.img}',
    fit: BoxFit.contain,
    ),
    Container(
    decoration: BoxDecoration(
    gradient: RadialGradient(
    center: Alignment.center,
    radius: 1.5,
    colors: [
    Colors.transparent,
    Colors.deepPurple[900]!.withOpacity(0.4),
    ],
    ),
    ),
    ),
    ],
    ),
    ),
    ),
    ),
    const SizedBox(height: 20),
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text(
    'Position: ',
    style: GoogleFonts.cinzel(
    fontSize: 18,
    color: Colors.amber[300]!,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic, // Etiket italik
    ),
    ),
    const SizedBox(width: 5), // Etiket ile pozisyon ismi arasında boşluk
    Text(
    position,
    style: GoogleFonts.cinzel(
    fontSize: 18,
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic, // Pozisyon ismi italik
    ),
    ),
    ],
    ),
    const SizedBox(height: 10), // Kart adı ile pozisyon arasında boşluk
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text(
    'Card: ',
    style: GoogleFonts.cinzel(
    fontSize: 18,
    color: Colors.purple[300]!,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic, // Etiket italik
    ),
    ),
    const SizedBox(width: 5), // Etiket ile kart ismi arasında boşluk
    Text(
    card.name,
    style: GoogleFonts.cinzel(
    fontSize: 18,
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic, // Kart ismi italik
    ),
    ),
    const SizedBox(width: 8),
    GestureDetector(
    onTap: () => _showCardDetails(card),
    child: Icon(
    Icons.info_outline,
    color: Colors.purpleAccent,
    size: 18,
    ),
    ),
    ],
    ),
    const SizedBox(height: 10),
    Text(
    '- MEANING: ',
    style: GoogleFonts.cinzel(
    fontSize: 18,
    color: Colors.teal[300]!,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
    ),
    ),
    const SizedBox(height: 5),
    _buildKeywords(card.keywords),
    const SizedBox(height: 20),
    _buildFortuneTelling(card.fortuneTelling),
    const SizedBox(height: 20),
    _buildMeanings(card),
    const SizedBox(height: 40),
    if (state != null) _buildPageIndicator(state.spread.length),
    ],
    ));
  }
  Widget _buildPageIndicator(int pageCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: _currentPage == index ? 16 : 10,
          height: _currentPage == index ? 16 : 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.purpleAccent : Colors.white.withOpacity(0.4),
            boxShadow: [
              if (_currentPage == index)
                BoxShadow(
                  color: Colors.purpleAccent.withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeywords(List<String> keywords) {
    final loc = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: keywords.map((keyword) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            '✦ $keyword',
            style: GoogleFonts.cinzel(fontSize: 16, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFortuneTelling(List<String> fortuneTelling) {
    final loc = S.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple[800]!.withOpacity(0.9),
            Colors.black.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fortuneTelling.map((fortune) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '✦ $fortune',
              style: GoogleFonts.cinzel(fontSize: 16, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMeanings(TarotCard card) {
    final loc = S.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple[900]!.withOpacity(0.9),
            Colors.black.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc!.meaning,
            style: GoogleFonts.cinzel(fontSize: 20, color: Colors.teal[300]!, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildMeaningSection(
            title: loc.lightMeaning,
            meanings: card.meanings.light,
            icon: Icons.lightbulb_outline,
            color: Colors.green[300]!,
          ),
          const SizedBox(height: 12),
          _buildMeaningSection(
            title: loc.shadowMeaning,
            meanings: card.meanings.shadow,
            icon: Icons.nightlight_round,
            color: Colors.red[300]!,
          ),
        ],
      ),
    );
  }

  Widget _buildMeaningSection({
    required String title,
    required List<String> meanings,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.cinzel(fontSize: 18, color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...meanings.map(
              (meaning) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '✧ $meaning',
              style: GoogleFonts.cinzel(fontSize: 16, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFortuneTellingPage(String yorum) {
    final loc = S.of(context);
    final sections = yorum.split(RegExp(r'\n\n### '));

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          itemCount: sections.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
            HapticFeedback.lightImpact();
          },
          itemBuilder: (context, index) {
            String sectionText = sections[index];
            if (index != 0) sectionText = "### $sectionText";

            final List<String> lines = sectionText.split('\n\n');
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
                        const SizedBox(height: 80),
                        AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _getTitleColor(title).withOpacity(0.7),
                                    Colors.deepPurple[900]!.withOpacity(0.9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getTitleColor(title).withOpacity(0.3 + _glowController.value * 0.3),
                                    blurRadius: 10 + _glowController.value * 5,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                title.replaceAll('###', '').trim(),
                                style: GoogleFonts.cinzel(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.deepPurple[900]!.withOpacity(0.7),
                                Colors.indigo[900]!.withOpacity(0.8),
                                Colors.black.withOpacity(0.7),
                              ],
                              stops: const [0.1, 0.5, 0.9],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.purple[300]!.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.cinzel(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                              children: _formatText(content),
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (index == 0 && content.length < 150)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.yellowAccent.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.swipe_left,
                                  color: Colors.yellowAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  loc!.swipeForMore,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cinzel(
                                    color: Colors.yellowAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
          bottom: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              sections.length,
                  (index) => TweenAnimationBuilder(
                tween: Tween<double>(
                  begin: 0.0,
                  end: _currentPage == index ? 1.0 : 0.0,
                ),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 12 + (value * 8),
                    height: 12 + (value * 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.lerp(
                        Colors.white54,
                        Colors.deepOrangeAccent,
                        value,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepOrangeAccent.withOpacity(0.5 * value),
                          blurRadius: 8 * value,
                          spreadRadius: 2 * value,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 2,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildActionButton(
                  context: context,
                  label: S.of(context)!.share,
                  icon: Icons.share,
                  onPressed: () => _shareReading(yorum),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  context: context,
                  label: S.of(context)!.returnToHome,
                  icon: Icons.home,
                  onPressed: () => _navigateToHome(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getTitleColor(String title) {
    if (RegExp(r'(Kart Dizilimi|Card Layout|The Divine Symphony of the Cards|The Layout of the Cards)').hasMatch(title)) {
      return Colors.amber[300]!;
    } else if (RegExp(r'(Analiz|Analysis|Interpretation|Analysis & Diagnosis|Deep Analysis|Reflections of Unified Destiny)').hasMatch(title)) {
      return Colors.purple[300]!;
    } else if (RegExp(r'(Rehberlik|Guidance|Recommendations|Strategic Recommendations|Guiding Whispers & Suggestions)').hasMatch(title)) {
      return Colors.teal[300]!;
    } else if (RegExp(r'(Sonuç|Conclusion|Concluding Thoughts|Final Summary|Summary Reflection)').hasMatch(title)) {
      return Colors.deepOrange[300]!;
    } else {
      return Colors.white;
    }
  }

  List<TextSpan> _formatText(String text) {
    List<TextSpan> spans = [];
    final paragraphs = text.split('\n\n');

    for (var paragraph in paragraphs) {
      paragraph = paragraph.trim();
      if (paragraph.isEmpty) {
        spans.add(const TextSpan(text: "\n\n"));
        continue;
      }

      final subheadingRegex = RegExp(r'(Position|Card|Meaning|Mystical Interpretation|Timeline & Suggestions|Points to Watch Out For|Category-Specific Tips|Category-Specific Insight|Combined Evaluation of the Cards|Kartların Birleşik Değerlendirmesi|Special Note|Özel Not|General Analysis|Genel Analiz|Emotional Analysis|Duygusal Analiz|Healing Suggestions|İyileşme Önerileri|Symbolic Analysis|Sembolik Analiz|Astrological Insights|Astrolojik İçgörüler|Lunar Analysis|Ay Analizi|Holistic Analysis|Bütünsel Analiz):.*?(?=\n\n|$)', caseSensitive: false);
      final starRegex = RegExp(r'\*(.*?)\*');

      if (subheadingRegex.hasMatch(paragraph)) {
        spans.add(TextSpan(
          text: "$paragraph\n\n",
          style: TextStyle(
            color: _getSubheadingColor(paragraph),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ));
      } else if (starRegex.hasMatch(paragraph)) {
        StringBuffer buffer = StringBuffer();
        int lastEnd = 0;
        for (Match match in starRegex.allMatches(paragraph)) {
          buffer.write(paragraph.substring(lastEnd, match.start));
          buffer.write(match.group(0));
          lastEnd = match.end;
        }
        buffer.write(paragraph.substring(lastEnd));

        String processedText = buffer.toString();
        List<String> parts = processedText.split(starRegex);
        for (int j = 0; j < parts.length; j++) {
          if (j % 2 == 0) {
            spans.add(TextSpan(text: parts[j]));
          } else {
            spans.add(TextSpan(
              text: parts[j],
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ));
          }
        }
        spans.add(const TextSpan(text: "\n\n"));
      } else {
        spans.add(TextSpan(text: "$paragraph\n\n"));
      }
    }
    return spans;
  }

  Color _getSubheadingColor(String text) {
    if (text.contains('Position')) return Colors.amber[300]!;
    if (text.contains('Card')) return Colors.purple[300]!;
    if (text.contains('Meaning')) return Colors.teal[300]!;
    if (text.contains('Mystical Interpretation')) return Colors.deepOrange[300]!;
    if (text.contains('Timeline & Suggestions')) return Colors.cyan[300]!;
    if (text.contains('Points to Watch Out For')) return Colors.red[300]!;
    if (text.contains('Category-Specific Tips')) return Colors.green[300]!;
    if (text.contains('Category-Specific Insight')) return Colors.blue[300]!;
    if (text.contains('Combined Evaluation of the Cards') || text.contains('Kartların Birleşik Değerlendirmesi')) return Colors.purpleAccent;
    if (text.contains('Special Note') || text.contains('Özel Not')) return Colors.yellow[300]!;
    if (text.contains('General Analysis') || text.contains('Genel Analiz')) return Colors.indigo[300]!;
    if (text.contains('Emotional Analysis') || text.contains('Duygusal Analiz')) return Colors.pink[300]!;
    if (text.contains('Healing Suggestions') || text.contains('İyileşme Önerileri')) return Colors.lime[300]!;
    if (text.contains('Symbolic Analysis') || text.contains('Sembolik Analiz')) return Colors.orange[300]!;
    if (text.contains('Astrological Insights') || text.contains('Astrolojik İçgörüler')) return Colors.deepPurple[300]!;
    if (text.contains('Lunar Analysis') || text.contains('Ay Analizi')) return Colors.grey[300]!;
    if (text.contains('Holistic Analysis') || text.contains('Bütünsel Analiz')) return Colors.teal[400]!;
    return Colors.white.withOpacity(0.9);
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return TapAnimatedScale(
      onTap: onPressed,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple[700]!, Colors.purple[900]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                Icon(icon, size: 16, color: Colors.white),
                Text(
                  label,
                  style: GoogleFonts.cinzel(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Colors.deepPurple[900]!.withOpacity(0.9),
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        child: BlocConsumer<TarotBloc, TarotState>(
          listener: (context, state) {
            if (state is TarotError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc!.errorMessage(state.message)),
                  action: SnackBarAction(
                    label: loc.tryAgain,
                    onPressed: () {
                      context.read<TarotBloc>().add(LoadTarotCards());
                    },
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is TarotLoading) {
              return Center(
                child: Lottie.asset(
                  'assets/animations/tarot_loading.json',
                  width: 200,
                  height: 200,
                  frameRate: FrameRate(60),
                ),
              );
            } else if (state is TarotInitial) {
              return Center(
                child: Text(
                  loc!.pleaseWait,
                  style: GoogleFonts.cinzel(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              );
            } else if (state is SingleCardDrawn) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(_fadeAnimation),
                  child: Stack(
                    children: [
                      _buildCardPage(loc!.singleCard, state.card, null),
                      _buildActionButtons(context, state.card.name, null),
                    ],
                  ),
                ),
              );
            } else if (state is SpreadDrawn) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(_fadeAnimation),
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: state.spread.length,
                        itemBuilder: (context, index) => _buildCardPage(
                          state.spread.keys.elementAt(index),
                          state.spread.values.elementAt(index),
                          state,
                        ),
                      ),
                      _buildActionButtons(context, state.spread.values.elementAt(_currentPage).name, state),
                    ],
                  ),
                ),
              );
            } else if (state is FalYorumuLoaded) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(_fadeAnimation),
                  child: Stack(
                    children: [
                      _buildFortuneTellingPage(state.yorum),
                      _buildActionButtons(context, 'Fortune Telling', null, yorum: state.yorum),
                    ],
                  ),
                ),
              );
            } else if (state is TarotError) {
              return Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        loc!.errorMessage(state.message),
                        style: GoogleFonts.cinzel(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }
            return Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      loc!.errorMessage('Unexpected state: $state'),
                      style: GoogleFonts.cinzel(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String title, SpreadDrawn? state, {String? yorum}) {
    return Positioned(
      bottom: 2,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _buildActionButton(
              context: context,
              label: S.of(context)!.share,
              icon: Icons.share,
              onPressed: () => _shareReading(yorum ?? '$title Result: ${state?.spread.values.map((c) => c.name).join(', ') ?? ''}'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              context: context,
              label: S.of(context)!.returnToHome,
              icon: Icons.home,
              onPressed: () => _navigateToHome(context),
            ),
          ),
        ],
      ),
    );
  }
}