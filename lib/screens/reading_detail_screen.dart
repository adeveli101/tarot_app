// lib/screens/reading_detail_screen.dart

import 'dart:math';
// import 'dart:ui'; // Kullanılmadığı için kaldırıldı (unnecessary_import)
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HapticFeedback için
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için
import 'package:provider/provider.dart'; // RepositoryProvider için
import 'package:share_plus/share_plus.dart';
import 'package:tarot_fal/data/tarot_repository.dart'; // Repository için
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/models/tarot_card.dart';
import 'package:tarot_fal/models/animations/tap_animations_scale.dart';

// Diğer gerekli importlar (reading_result'tan alınan yapı için)
import 'package:lottie/lottie.dart'; // Gerekirse loading için
import 'package:tarot_fal/screens/tarot_fortune_reading_screen.dart'; // Ana ekrana dönüş için
import '../data/tarot_event_state.dart'; // SpreadType enum için (gerekirse)

class ReadingDetailScreen extends StatefulWidget {
  final String spreadType;
  final String yorum;
  final Map<String, dynamic> spread; // Firestore'dan gelen map
  final DateTime timestamp;

  const ReadingDetailScreen({
    super.key,
    required this.spreadType,
    required this.yorum,
    required this.spread,
    required this.timestamp,
  });

  @override
  State<ReadingDetailScreen> createState() => _ReadingDetailScreenState();
}

class _ReadingDetailScreenState extends State<ReadingDetailScreen> with TickerProviderStateMixin {
  // --- State Değişkenleri ---
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _glowController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation; // Kullanılacak (warning giderildi)

  List<MapEntry<String, TarotCard>> _spreadCards = [];
  List<String> _interpretationSections = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // TabController kaldırıldı

    _parseInterpretation();
    _convertSpreadMap();

    // onPageChanged build metodundaki PageView'a eklenecek

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward(); // Animasyonu başlat
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _glowController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // --- Veri İşleme Metotları ---
  void _parseInterpretation() {
    // Önceki cevaptaki _parseInterpretation metodu buraya gelecek (içerik aynı)
    _interpretationSections = widget.yorum
        .split(RegExp(r'\n\n### ')) // Bölümleri ayır
        .where((s) => s.trim().isNotEmpty) // Boşları kaldır
        .map((s) {
      if (!s.trim().startsWith('###') && _interpretationSections.isEmpty) {
        return s.trim();
      }
      return s.trim();
    })
        .toList();

    if (_interpretationSections.isNotEmpty && _interpretationSections[0].startsWith('### ')) {
      _interpretationSections[0] = _interpretationSections[0].substring(4).trim();
    }

    if (_interpretationSections.isEmpty && widget.yorum.trim().isNotEmpty) {
      _interpretationSections.add(widget.yorum.trim());
    }
  }

  void _convertSpreadMap() {
    // Önceki cevaptaki _convertSpreadMap metodu buraya gelecek (içerik aynı)
    _spreadCards = widget.spread.entries.map((entry) {
      final position = entry.key;
      final cardData = entry.value as Map<String, dynamic>? ?? {};
      final card = TarotCard(
        name: cardData['name'] as String? ?? "Bilinmeyen Kart",
        img: cardData['img'] as String? ?? "",
        arcana: "", suit: "", number: "0", keywords: [],
        meanings: Meanings(light: [], shadow: []),
        fortuneTelling: [],
      );
      return MapEntry(position, card);
    }).toList();
  }

  // --- Yardımcı Metotlar ---
  int _getTotalPageCount() {
    int count = 0;
    if (_spreadCards.isNotEmpty) {
      count++;
    }
    count += _interpretationSections.length;
    return count.clamp(1, 100);
  }

  void _shareReading(BuildContext context) {
    // Önceki cevaptaki _shareReading metodu buraya gelecek (içerik aynı)
    final loc = S.of(context);
    final String dateStr = DateFormat.yMd(Localizations.localeOf(context).toString())
        .add_jm()
        .format(widget.timestamp);

    final String formattedSpreadType = widget.spreadType.replaceAllMapped(
        RegExp(r'(?=[A-Z])'), (match) => ' ');

    final String shareTitle = loc!.shareTitle(formattedSpreadType, dateStr);

    final String cleanYorum = widget.yorum.replaceAllMapped(
      RegExp(r'^###\s*(.*?)\s*$', multiLine: true),
          (Match match) {
        final title = match.group(1)?.trim() ?? '';
        return '\n--- $title ---\n';
      },
    ).trim();

    Share.share("$shareTitle\n\n$cleanYorum");
    HapticFeedback.mediumImpact();
  }

  // _navigateToHome metodu kaldırıldı (unused_element)

  void _showCardDetails(TarotCard basicCard) {
    // Önceki cevaptaki _showCardDetails metodu buraya gelecek (içerik aynı)
    HapticFeedback.lightImpact();
    TarotCard? fullCard;
    String? loadingError;
    try {
      fullCard = Provider.of<TarotRepository>(context, listen: false)
          .getCardByName(basicCard.name);
    } catch (e) {
      if (kDebugMode) { print("Kart detayı alınırken hata: $e"); }
      loadingError = S.of(context)!.errorLoadingCardDetails;
    }
    final TarotCard cardToShow = fullCard ?? basicCard;
    final bool detailsCouldNotBeLoaded = fullCard == null;

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
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Colors.indigo[900]!, Colors.purple[800]!, Colors.black87],
                  stops: const [0.0, 0.6, 1.0],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [ BoxShadow( color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 25, spreadRadius: 3,),],
                border: Border.all(color: Colors.purpleAccent.withOpacity(0.4), width: 1.5),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // <<< HATA DÜZELTME: _buildCardDetailContent çağrısı düzeltildi >>>
                          _buildCardDetailContent(context, S.of(context), cardToShow),
                          if (detailsCouldNotBeLoaded || loadingError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                loadingError ?? S.of(context)!.errorLoadingCardDetails,
                                style: GoogleFonts.cabin(color: Colors.orangeAccent),
                                textAlign: TextAlign.center,
                              ),
                            ),
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
                          boxShadow: [ BoxShadow( color: Colors.purpleAccent.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4),),],
                        ),
                        child: Text(
                          S.of(context)!.close.toUpperCase(),
                          style: GoogleFonts.cinzel( fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold, letterSpacing: 1,),
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

  Widget _buildCardDetailContent(BuildContext context, S? loc, TarotCard card) {
    loc ??= S.of(context);
    final fullCardData = Provider.of<TarotRepository>(context, listen: false)
        .getCardByName(card.name); // Tam kart verisini al

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          card.name.toUpperCase(),
          style: GoogleFonts.cinzelDecorative( fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5, shadows: [ Shadow( color: Colors.purpleAccent.withOpacity(0.6), offset: const Offset(1, 1), blurRadius: 5, ),], ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration( borderRadius: BorderRadius.circular(16), boxShadow: [ BoxShadow( color: Colors.white.withOpacity(0.15), blurRadius: 15, spreadRadius: 2 )] ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/tarot_card_images/${card.img}',
              height: MediaQuery.of(context).size.height * 0.4, fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon( Icons.broken_image, color: Colors.white54, size: 100,),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // <<< HATA DÜZELTME: Tam kart verisi varsa detayları göster >>>
        if (fullCardData != null) ...[
          _buildDetailSection(loc!.arcana, fullCardData.arcana),
          _buildDetailSection(loc.suit, fullCardData.suit),
          if (fullCardData.elemental != null && fullCardData.elemental!.isNotEmpty) _buildDetailSection("Element", fullCardData.elemental!),
          _buildDetailSection(loc.keywords, fullCardData.keywords.join(", ")),
          _buildDetailSection(loc.fortuneTelling, fullCardData.fortuneTelling.join("\n\n")),
          _buildDetailSection(loc.lightMeaning, fullCardData.meanings.light.join("\n\n")),
          _buildDetailSection(loc.shadowMeaning, fullCardData.meanings.shadow.join("\n\n")),
          if (fullCardData.archetype != null && fullCardData.archetype!.isNotEmpty) _buildDetailSection("Archetype", fullCardData.archetype!),
          if (fullCardData.hebrewAlphabet != null && fullCardData.hebrewAlphabet!.isNotEmpty) _buildDetailSection("Hebrew Alphabet", fullCardData.hebrewAlphabet!),
          if (fullCardData.numerology != null && fullCardData.numerology!.isNotEmpty) _buildDetailSection("Numerology", fullCardData.numerology!),
          if (fullCardData.mythicalSpiritual != null && fullCardData.mythicalSpiritual!.isNotEmpty) _buildDetailSection("Mythical/Spiritual", fullCardData.mythicalSpiritual!),
          if (fullCardData.questionsToAsk != null && fullCardData.questionsToAsk!.isNotEmpty)
            _buildDetailSection(loc.questionsToAsk, fullCardData.questionsToAsk!.join("\n\n")),
        ] else ...[
          // <<< HATA DÜZELTME: `loc.name` yerine sabit string kullan >>>
          _buildDetailSection("İsim", card.name), // Sabit string veya loc.cardName gibi bir anahtar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(loc!.errorLoadingCardDetails, style: TextStyle(color: Colors.orangeAccent)),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetailSection(String title, String? content) {
    if (content == null || content.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.cinzel( fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purpleAccent[100], letterSpacing: 1.2,),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.cabin( fontSize: 15, color: Colors.white.withOpacity(0.85), height: 1.5, fontWeight: FontWeight.w400,),
            textAlign: TextAlign.left,
          ),
          Divider(color: Colors.purpleAccent.withOpacity(0.2), thickness: 1, height: 30),
        ],
      ),
    );
  }

  // --- Metin Formatlama Metotları ---
  List<TextSpan> _formatText(String text) {
    // Önceki cevaptaki _formatText metodu buraya gelecek (içerik aynı)
    List<TextSpan> spans = [];
    final paragraphs = text.split(RegExp(r'\n{2,}'));
    final starRegex = RegExp('\\*(.*?)\\*');
    final subheadingRegex = RegExp('^\\s*(-?\\s*[\\w\\s\'&]+):\\s*(.*)', dotAll: true);

    for (var paragraph in paragraphs) {
      paragraph = paragraph.trim();
      if (paragraph.isEmpty) continue;
      var match = subheadingRegex.firstMatch(paragraph);
      if (match != null) {
        final String subheadingKey = match.group(1)?.trim() ?? '';
        final String subheadingContent = match.group(2)?.trim() ?? '';
        spans.add(TextSpan( text: "$subheadingKey:\n", style: TextStyle( color: _getSubheadingColor(subheadingKey), fontWeight: FontWeight.bold, fontSize: 17, height: 1.8,),));
        if (subheadingContent.isNotEmpty) {
          spans.addAll(_processStars(subheadingContent, starRegex));
          spans.add(const TextSpan(text: "\n\n"));
        }
      } else {
        spans.addAll(_processStars(paragraph, starRegex));
        spans.add(const TextSpan(text: "\n\n"));
      }
    }
    if (spans.isNotEmpty && spans.last.text == "\n\n") {
      spans.removeLast();
    }
    return spans;
  }

  List<TextSpan> _processStars(String text, RegExp starRegex) {
    // Önceki cevaptaki _processStars metodu buraya gelecek (içerik aynı)
    List<TextSpan> starSpans = [];
    int lastEnd = 0;
    for (Match match in starRegex.allMatches(text)) {
      if (match.start > lastEnd) {
        starSpans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      if (match.group(1) != null) {
        starSpans.add(TextSpan( text: match.group(1), style: const TextStyle( color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic,),));
      }
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      starSpans.add(TextSpan(text: text.substring(lastEnd)));
    }
    return starSpans;
  }

  Color _getSubheadingColor(String text) {
    // Önceki cevaptaki _getSubheadingColor metodu buraya gelecek (içerik aynı)
    text = text.toLowerCase().replaceAll('-', '').trim();
    if (text.contains('position')) return Colors.amber[300]!;
    if (text.contains('card')) return Colors.purple[300]!;
    if (text.contains('meaning')) return Colors.teal[300]!;
    if (text.contains('mystical interpretation')) return Colors.deepOrange[300]!;
    if (text.contains('timeline') || text.contains('suggestions')) return Colors.cyan[300]!;
    if (text.contains('watch out') || text.contains('pitfall')) return Colors.red[300]!;
    if (text.contains('tips') || text.contains('advice')) return Colors.green[300]!;
    if (text.contains('insight')) return Colors.blue[300]!;
    if (text.contains('evaluation') || text.contains('değerlendirme')) return Colors.purpleAccent;
    if (text.contains('special note') || text.contains('özel not')) return Colors.yellow[300]!;
    if (text.contains('general analysis') || text.contains('genel analiz')) return Colors.indigo[300]!;
    if (text.contains('emotional analysis') || text.contains('duygusal analiz')) return Colors.pink[300]!;
    if (text.contains('healing') || text.contains('iyileşme')) return Colors.lime[300]!;
    if (text.contains('symbolic') || text.contains('sembolik')) return Colors.orange[300]!;
    if (text.contains('astrological') || text.contains('astrolojik')) return Colors.deepPurple[300]!;
    if (text.contains('lunar') || text.contains('ay analizi')) return Colors.grey[300]!;
    if (text.contains('holistic') || text.contains('bütünsel')) return Colors.teal[400]!;
    if (text.contains('keywords') || text.contains('anahtar kelimeler')) return Colors.lightBlue[200]!;
    if (text.contains('fortune telling') || text.contains('kehanet')) return Colors.lightGreen[300]!;
    return Colors.white.withOpacity(0.9);
  }

  Color _getTitleColor(String title) {
    // Önceki cevaptaki _getTitleColor metodu buraya gelecek (içerik aynı)
    title = title.toLowerCase();
    if (RegExp(r'(dizilim|layout|symphony|elements|dynamics|cards|kartlar)').hasMatch(title)) {
      return Colors.amber[400]!;
    } else if (RegExp(r'(analiz|analysis|yorum|reflections|diagnosis|insight|evaluation|commentary|interpretation|genel bakış|overview)').hasMatch(title)) {
      return Colors.purpleAccent[100]!;
    } else if (RegExp(r'(rehberlik|guidance|öneri|recommendations|whispers|suggestions|advice|tips)').hasMatch(title)) {
      return Colors.tealAccent[100]!;
    } else if (RegExp(r'(sonuç|conclusion|summary|outcome|thoughts)').hasMatch(title)) {
      return Colors.orangeAccent[100]!;
    } else {
      return Colors.white; // Default
    }
  }
  // --- Bitiş: Metin Formatlama Metotları ---

  // --- Sayfa Oluşturma Widget'ları ---
  Widget _buildDrawnCardsSummaryPage(List<MapEntry<String, TarotCard>> spreadCards) {
    // Önceki cevaptaki _buildDrawnCardsSummaryPage metodu buraya gelecek (içerik aynı)
    final loc = S.of(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: 20,
      ).copyWith(top: kToolbarHeight + 20), // AppBar altından başla
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            loc!.drawCards.toUpperCase(), // Yerelleştirilmiş başlık
            style: GoogleFonts.cinzelDecorative( fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2, shadows: [ Shadow(color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 5)],),
          ),
          const SizedBox(height: 10),
          Text( loc.tapCardForDetails, style: GoogleFonts.cabin(fontSize: 14, color: Colors.white70),),
          Divider(color: Colors.purpleAccent.withOpacity(0.2), height: 30, thickness: 1),
          const SizedBox(height: 10),
          Wrap(
            spacing: 15.0, runSpacing: 25.0, alignment: WrapAlignment.center,
            children: spreadCards.map((entry) {
              return _buildMiniCard(entry.value, entry.key);
            }).toList(),
          ),
          const SizedBox(height: 80), // Alt bar için boşluk
        ],
      ),
    );
  }

  Widget _buildMiniCard(TarotCard card, String position) {
    // Önceki cevaptaki _buildMiniCard metodu buraya gelecek (içerik aynı)
    final double cardWidth = MediaQuery.of(context).size.width * 0.28;
    final double cardHeight = cardWidth * 1.5;
    return TapAnimatedScale(
      onTap: () => _showCardDetails(card), // Show details on tap
      child: SizedBox(
        width: cardWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage('assets/tarot_card_images/${card.img}'),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    debugPrint("Error loading image: ${card.img} - $exception");
                  },
                ),
                boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.5), blurRadius: 8, offset: const Offset(2, 4),),],
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              position.replaceAll('_', ' ').splitMapJoin(RegExp(r'(?=[A-Z])'), onMatch: (m) => ' ', onNonMatch: (n) => n),
              style: GoogleFonts.cinzel( fontSize: 11, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500,),
              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFortuneTellingSectionPage(String sectionText) {
    // Önceki cevaptaki _buildFortuneTellingSectionPage metodu buraya gelecek (içerik aynı, hata düzeltmesi yapıldı)
    final loc = S.of(context);
    String title = loc!.interpretation; // Default title
    String content = sectionText;

    final titleMatch = RegExp(r'^###\s*(.*?)\s*\n', multiLine: true).firstMatch(sectionText);

    if (titleMatch != null) {
      title = titleMatch.group(1)?.trim() ?? loc.interpretationSection;
      content = sectionText.substring(titleMatch.end).trim();
    } else if (sectionText.trim().startsWith('### ')) {
      // Eğer ### başta ama newline yoksa (split sonrası ilk eleman)
      title = sectionText.trim().substring(4).split('\n').first;
      content = sectionText.substring(sectionText.indexOf('\n') + 1).trim();
      if (content.trim().isEmpty) content = title; // Başlık içerik olduysa
    } else {
      // Başlık bulunamadı, ilk bölümse "Genel Bakış" olabilir
      if (_interpretationSections.isNotEmpty && sectionText == _interpretationSections[0] && !sectionText.contains(':') && sectionText.length < 100) { // Heuristic check for intro
        title = loc.overview; // Genel Bakış
        content = sectionText;
      } else {
        // Veya sadece yorum bölümü
        title = loc.interpretationSection;
        content = sectionText;
      }
    }

    // İçerik boşsa bir mesaj göster
    if (content.trim().isEmpty && title != loc.overview) {
      // <<< HATA DÜZELTME: loc.noContentForSection yerine sabit string >>>
      return Center(child: Text("Bu bölüm için içerik bulunamadı.", style: GoogleFonts.cabin(color: Colors.white70)));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: 20,
          ).copyWith(top: kToolbarHeight + 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - (kToolbarHeight + 40)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    final Color titleColor = _getTitleColor(title);
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient( colors: [ titleColor.withOpacity(0.7), Colors.deepPurple[900]!.withOpacity(0.9),], begin: Alignment.topLeft, end: Alignment.bottomRight,),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [ BoxShadow( color: titleColor.withOpacity(0.3 + _glowController.value * 0.3), blurRadius: 10 + _glowController.value * 5, spreadRadius: 2, ),],
                      ),
                      child: Text(
                        title,
                        style: GoogleFonts.cinzelDecorative( color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5,),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient( begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [ Colors.deepPurple[900]!.withOpacity(0.8), Colors.indigo[900]!.withOpacity(0.85), Colors.black.withOpacity(0.75),], stops: const [0.1, 0.5, 0.9],),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [ BoxShadow( color: Colors.purple.withOpacity(0.3), blurRadius: 12, spreadRadius: 1, ),],
                    border: Border.all( color: Colors.purple[300]!.withOpacity(0.3), width: 1,),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.cabin( color: Colors.white.withOpacity(0.9), fontSize: 16, height: 1.6, fontWeight: FontWeight.w400,),
                      children: _formatText(content),
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Alt Bar Widget'ları ---
  Widget _buildBottomBar(BuildContext context) {
    // Önceki cevaptaki _buildBottomBar metodu buraya gelecek (içerik aynı, loc.goBack düzeltmesi yapılacak)
    final loc = S.of(context);
    final totalPages = _getTotalPageCount();

    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 10, // Sistem padding'i + ek boşluk
            top: 10, left: 16, right: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient( colors: [ Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.7), Colors.black.withOpacity(0.9),], begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: const [0.0, 0.4, 1.0],),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (totalPages > 1) ...[
              _buildPageIndicator(totalPages),
              const SizedBox(height: 15),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded( child: _buildActionButton( context: context, label: loc!.share, icon: Icons.share, onPressed: () => _shareReading(context),),),
                const SizedBox(width: 16),
                // <<< HATA DÜZELTME: loc.goBack yerine loc.back veya sabit string kullan >>>
                Expanded( child: _buildActionButton( context: context, label: loc.close, icon: Icons.arrow_back_ios_new, onPressed: () => Navigator.pop(context),),), // "Geri Dön"
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int pageCount) {
    // Önceki cevaptaki _buildPageIndicator metodu buraya gelecek (içerik aynı)
    if (pageCount <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate( pageCount, (index) => AnimatedContainer(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: _currentPage == index ? 12 : 8, height: _currentPage == index ? 12 : 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _currentPage == index ? Colors.purpleAccent : Colors.white.withOpacity(0.4),
          boxShadow: [ if (_currentPage == index) BoxShadow( color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 6, spreadRadius: 1,),],
        ),
      ),),
    );
  }

  Widget _buildActionButton({ required BuildContext context, required String label, required IconData icon, required VoidCallback onPressed,}) {
    // Önceki cevaptaki _buildActionButton metodu buraya gelecek (içerik aynı)
    return TapAnimatedScale(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient( colors: [Colors.deepPurple[600]!, Colors.purple[800]!], begin: Alignment.topLeft, end: Alignment.bottomRight,),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3), ),],
          border: Border.all(color: Colors.purpleAccent.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white.withOpacity(0.9)),
            const SizedBox(width: 8),
            Flexible( child: Text( label, style: GoogleFonts.cabin( fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600,), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 1,),),
          ],
        ),
      ),
    );
  }

  // --- Ana Build Metodu ---
  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final totalPages = _getTotalPageCount();
    final String formattedSpreadType = widget.spreadType
        .replaceAllMapped(RegExp(r'(?=[A-Z])'), (match) => ' ')
        .toUpperCase();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text( formattedSpreadType, style: GoogleFonts.cinzelDecorative( color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5 ),),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        // TabBar kaldırıldı
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple[900]!, Colors.black],
            stops: const [0.0, 0.8],
          ),
        ),
        // <<< DEĞİŞİKLİK: FadeTransition eklendi >>>
        child: FadeTransition(
          opacity: _fadeAnimation, // Animasyonu uygula
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: totalPages,
                onPageChanged: (int page) {
                  if (mounted) {
                    setState(() { _currentPage = page; });
                    HapticFeedback.lightImpact();
                  }
                },
                itemBuilder: (context, index) {
                  // Sayfa 0: Kart Özeti
                  if (_spreadCards.isNotEmpty && index == 0) {
                    return _buildDrawnCardsSummaryPage(_spreadCards);
                  }
                  // Diğer Sayfalar: Yorum Bölümleri
                  else {
                    int interpretationIndex = index;
                    if (_spreadCards.isNotEmpty) {
                      interpretationIndex = index - 1;
                    }
                    if (interpretationIndex >= 0 && interpretationIndex < _interpretationSections.length) {
                      return _buildFortuneTellingSectionPage(_interpretationSections[interpretationIndex]);
                    } else {
                      return Center(child: Text(loc!.invalidPage, style: TextStyle(color: Colors.red)));
                    }
                  }
                },
              ),
              _buildBottomBar(context), // Alt Bar
            ],
          ),
        ),
      ),
    );
  }
} // State Sınıfı Sonu