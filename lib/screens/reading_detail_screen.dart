// lib/screens/reading_detail_screen.dart

import 'dart:math';
import 'dart:ui'; // BackdropFilter için
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
import 'package:tarot_fal/models/animations/tap_animations_scale.dart'; // Tek import

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
  // State değişkenleri
  List<MapEntry<String, String>> _interpretationPages = []; // Ayrıştırılmış yorum sayfaları (Başlık, İçerik)
  List<MapEntry<String, TarotCard>> _spreadCards = []; // Dönüştürülmüş kartlar (Pozisyon, Kart)
  late PageController _pageController; // Yorum sayfaları için controller
  int _currentPage = 0; // Aktif yorum sayfası indeksi
  late TabController _tabController; // Sekmeler için controller

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 2, vsync: this); // 2 sekme: Yorum, Kartlar

    _parseInterpretation(); // Yorumu başlangıçta ayrıştır
    _convertSpreadMap(); // Spread map'ini dönüştür

    // Sayfa değişimini dinle (PageView için)
    _pageController.addListener(() {
      final page = _pageController.page;
      if (page != null && page == page.roundToDouble()) {
        final newPage = page.round();
        if (_currentPage != newPage) {
          if (mounted) {
            setState(() { _currentPage = newPage; });
            HapticFeedback.lightImpact();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose(); // TabController'ı dispose et
    super.dispose();
  }

  // Yorumu ### Başlık formatına göre ayrıştıran metot
  void _parseInterpretation() {
    _interpretationPages = [];
    final String yorumText = widget.yorum;
    final RegExp sectionRegex = RegExp(r'^###\s*(.*?)\s*\n(.*?)(?=\n###|\Z)', multiLine: true, dotAll: true);

    int lastMatchEnd = 0;
    final matches = sectionRegex.allMatches(yorumText);

    // İlk bölüm (başlıksız giriş metni olabilir)
    final firstMatchStart = matches.isNotEmpty ? matches.first.start : yorumText.length;
    final introText = yorumText.substring(0, firstMatchStart).trim();
    if (introText.isNotEmpty) {
      _interpretationPages.add(MapEntry("Genel Bakış", introText)); // TODO: Yerelleştir (loc.overview)
    }

    // Eşleşen bölümler
    for (var match in matches) {
      final title = match.group(1)?.trim() ?? "Bölüm"; // TODO: Yerelleştir (loc.section)
      final content = match.group(2)?.trim() ?? ""; // İçerik
      if (content.isNotEmpty) {
        _interpretationPages.add(MapEntry(title, content));
      }
      lastMatchEnd = match.end;
    }

    // Başlık regex'i ile eşleşmeyen ve sonda kalan metin varsa (nadiren olur)
    if (lastMatchEnd < yorumText.length) {
      final remainingText = yorumText.substring(lastMatchEnd).trim();
      if (remainingText.isNotEmpty) {
        _interpretationPages.add(MapEntry("Detaylar", remainingText)); // TODO: Yerelleştir (loc.details)
      }
    }

    // Hiç bölüm bulunamazsa tüm yorumu tek bölüm yap
    if (_interpretationPages.isEmpty && yorumText.trim().isNotEmpty) {
      _interpretationPages.add(MapEntry("Yorum", yorumText.trim())); // TODO: Yerelleştir (loc.interpretation)
    }
  }

  // Firestore'dan gelen spread map'ini temel TarotCard listesine dönüştürür
  void _convertSpreadMap() {
    _spreadCards = widget.spread.entries.map((entry) {
      final position = entry.key;
      final cardData = entry.value as Map<String, dynamic>? ?? {};
      // Temel bilgileri al, detaylar dialogda yüklenecek
      final card = TarotCard(
        name: cardData['name'] as String? ?? "Bilinmeyen Kart", // TODO: Yerelleştir
        img: cardData['img'] as String? ?? "",
        // Aşağıdaki alanlar dialogda TarotRepository'den alınacak
        arcana: "", suit: "", number: "0", keywords: [],
        meanings:  Meanings(light: [], shadow: []), // Boş liste ile başlat
        fortuneTelling: [],
      );
      return MapEntry(position, card);
    }).toList();
  }

  // Paylaşma fonksiyonu
  void _shareReading(BuildContext context) {
    final loc = S.of(context);
    if (loc == null) {
      debugPrint("Share Reading Error: Localization not loaded.");
      return;
    }

    final String dateStr = DateFormat.yMd(Localizations.localeOf(context).toString())
        .add_jm()
        .format(widget.timestamp);

    final String shareTitle = loc.shareTitle(widget.spreadType.replaceAllMapped(RegExp(r'(?=[A-Z])'), (match) => ' '), dateStr);

    // Yorumu temizle (Markdown başlıklarını değiştir)
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

  // Kart detaylarını gösteren dialog
  void _showCardDetails(BuildContext context, TarotCard basicCard) {
    HapticFeedback.lightImpact();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (dialogContext, anim1, anim2) {
        TarotCard? fullCard;
        String? loadingError;

        try {
          // Kök context'i kullanarak Provider'a eriş (dialog context'i yerine)
          fullCard = Provider.of<TarotRepository>(context, listen: false)
              .getCardByName(basicCard.name);
        } catch (e) {
          if (kDebugMode) { print("Kart detayı alınırken hata: $e"); }
          loadingError = S.of(context)!.errorLoadingCardDetails;
        }

        final TarotCard cardToShow = fullCard ?? basicCard;
        final bool detailsCouldNotBeLoaded = fullCard == null;

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
                  border: Border.all(color: Colors.purpleAccent.withOpacity(0.4), width: 1.5)
              ),
              child: Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _buildCardDetailContent(dialogContext, S.of(dialogContext), cardToShow), // Dialog context'ini kullan
                            if (detailsCouldNotBeLoaded || loadingError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  loadingError ?? S.of(dialogContext)!.errorLoadingCardDetails,
                                  style: GoogleFonts.cabin(color: Colors.orangeAccent),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      )
                  ),
                  // Kapatma Butonu
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: TapAnimatedScale(
                      onTap: () => Navigator.pop(dialogContext),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.purpleAccent.shade100, Colors.purpleAccent.shade400]),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [ BoxShadow( color: Colors.purpleAccent.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4),),],
                        ),
                        child: Text(
                          (S.of(dialogContext)!.close).toUpperCase(),
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

  // Kart detay dialog içeriğini oluşturan metot
  Widget _buildCardDetailContent(BuildContext context, S? loc, TarotCard card) {
    loc ??= S.of(context); // Güvenlik önlemi
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
        _buildDetailSection(loc!.arcana, card.arcana),
        _buildDetailSection(loc.suit, card.suit),
        if (card.elemental != null && card.elemental!.isNotEmpty) _buildDetailSection("Element", card.elemental!),
        _buildDetailSection(loc.keywords, card.keywords.join(", ")),
        _buildDetailSection(loc.fortuneTelling, card.fortuneTelling.join("\n\n")),
        _buildDetailSection(loc.lightMeaning, card.meanings.light.join("\n\n")),
        _buildDetailSection(loc.shadowMeaning, card.meanings.shadow.join("\n\n")),
        if (card.archetype != null && card.archetype!.isNotEmpty) _buildDetailSection("Archetype", card.archetype!),
        if (card.hebrewAlphabet != null && card.hebrewAlphabet!.isNotEmpty) _buildDetailSection("Hebrew Alphabet", card.hebrewAlphabet!),
        if (card.numerology != null && card.numerology!.isNotEmpty) _buildDetailSection("Numerology", card.numerology!),
        if (card.mythicalSpiritual != null && card.mythicalSpiritual!.isNotEmpty) _buildDetailSection("Mythical/Spiritual", card.mythicalSpiritual!),
        if (card.questionsToAsk != null && card.questionsToAsk!.isNotEmpty)
          _buildDetailSection(loc.questionsToAsk, card.questionsToAsk!.join("\n\n")),
        const SizedBox(height: 20),
      ],
    );
  }

  // Detay bölümü widget'ı
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

  // --- Metin Formatlama Metotları (reading_result.dart'tan alındı ve uyarlandı) ---
  List<TextSpan> _formatText(String text) {
    List<TextSpan> spans = [];
    final paragraphs = text.split(RegExp(r'\n{2,}')); // Split by double (or more) newlines
    final starRegex = RegExp('\\*(.*?)\\*'); // Escape asterisks
    final subheadingRegex = RegExp('^\\s*(-?\\s*[\\w\\s\'&]+):\\s*(.*)', dotAll: true);

    for (var paragraph in paragraphs) {
      paragraph = paragraph.trim();
      if (paragraph.isEmpty) continue;

      var match = subheadingRegex.firstMatch(paragraph);

      if (match != null) {
        // Alt başlık paragrafı
        final String subheadingKey = match.group(1)?.trim() ?? '';
        final String subheadingContent = match.group(2)?.trim() ?? '';

        spans.add(TextSpan(
          text: "$subheadingKey:\n",
          style: TextStyle(
            color: _getSubheadingColor(subheadingKey),
            fontWeight: FontWeight.bold,
            fontSize: 17, height: 1.8,
          ),
        ));
        if (subheadingContent.isNotEmpty) {
          spans.addAll(_processStars(subheadingContent, starRegex));
          spans.add(const TextSpan(text: "\n\n"));
        }
      } else {
        // Normal paragraf
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
    List<TextSpan> starSpans = [];
    int lastEnd = 0;
    for (Match match in starRegex.allMatches(text)) {
      if (match.start > lastEnd) {
        starSpans.add(TextSpan(text: text.substring(lastEnd, match.start))); // Normal text style inherited
      }
      if (match.group(1) != null) {
        starSpans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle( color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic,),
        ));
      }
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      starSpans.add(TextSpan(text: text.substring(lastEnd))); // Normal text style inherited
    }
    return starSpans;
  }

  Color _getSubheadingColor(String text) {
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
    return Colors.white.withOpacity(0.9); // Default
  }
  // --- Bitiş: Metin Formatlama Metotları ---

  // Mini kart widget'ı
  Widget _buildMiniCard(TarotCard card, String position) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.28;
    final double cardHeight = cardWidth * 1.5;
    return TapAnimatedScale(
      onTap: () => _showCardDetails(context, card), // Kart detayını aç
      child: SizedBox(
        width: cardWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: cardWidth, height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage('assets/tarot_card_images/${card.img}'),
                  fit: BoxFit.cover,
                  onError: (e, s) => debugPrint("Error loading image: ${card.img} - $e"),
                ),
                boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.5), blurRadius: 8, offset: const Offset(2, 4), ),],
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              // Pozisyon ismini formatla (örn: "PresentSituation" -> "Present Situation")
              position.replaceAll('_', ' ').splitMapJoin(RegExp(r'(?=[A-Z])'), onMatch: (m) => ' ', onNonMatch: (n) => n),
              style: GoogleFonts.cinzel( fontSize: 11, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500,),
              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Sayfa göstergesi widget'ı
  Widget _buildPageIndicator(int pageCount) {
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
      ),
      ),
    );
  }

  // Alt aksiyon butonları
  Widget _buildBottomActionBar(BuildContext context, S loc) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10, top: 10, left: 16, right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient( colors: [ Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.95)], begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: const [0.0, 0.3, 1.0],),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded( child: _buildActionButton( context: context, label: loc.share, icon: Icons.share, onPressed: () => _shareReading(context),),),
          const SizedBox(width: 16),
          Expanded( child: _buildActionButton( context: context, label: loc.returnToHome, icon: Icons.home_outlined, onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),),),
        ],
      ),
    );
  }

  // Tek bir aksiyon butonu widget'ı
  Widget _buildActionButton({ required BuildContext context, required String label, required IconData icon, required VoidCallback onPressed,}) {
    return TapAnimatedScale(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            gradient: LinearGradient( colors: [Colors.deepPurple[600]!, Colors.purple[800]!], begin: Alignment.topLeft, end: Alignment.bottomRight,),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3), ),],
            border: Border.all(color: Colors.purpleAccent.withOpacity(0.3), width: 1)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white.withOpacity(0.9)),
            const SizedBox(width: 8),
            Flexible( child: Text( label, style: GoogleFonts.cinzel( fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600,), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 1,),),
          ],
        ),
      ),
    );
  }

  // Yorum sekmesinin içeriğini oluşturan PageView ve ilgili metotlar
  Widget _buildInterpretationTabView(int totalPages, S loc) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          itemCount: totalPages,
          itemBuilder: (context, index) {
            // Sayfa içeriğini oluşturmak için Builder kullanıyoruz
            return Builder(
                builder: (BuildContext innerContext) { // Scaffold altından gelen context
                  if (index < _interpretationPages.length) {
                    final pageData = _interpretationPages[index];
                    // İçeriği oluştururken innerContext'i kullan
                    return _buildInterpretationPageContent(innerContext, pageData.key, pageData.value);
                  }
                  return Center(child: Text(loc.invalidPage, style: const TextStyle(color: Colors.red))); // TODO: Yerelleştir
                }
            );
          },
        ),
        // Sayfa Göstergesi
        if (totalPages > 1)
          Positioned(
            // Konumunu ayarlayarak alt butonların üzerine gelmesini engelle
            // BottomActionBar yüksekliği + padding + ek boşluk
            bottom: MediaQuery.of(context).padding.bottom + 60,
            left: 0, right: 0,
            child: _buildPageIndicator(totalPages),
          ),
      ],
    );
  }

  // Tek bir yorum sayfası içeriğini oluşturur (BuildContext parametresi alır)
  Widget _buildInterpretationPageContent(BuildContext context, String title, String content) {
    // context artık Builder'dan gelen doğru context olduğu için Scaffold.of çalışır
    final double appBarHeight = Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight;
    final double tabBarHeight = kTextTabBarHeight; // TabBar'ın standart yüksekliği
    final double topPadding = appBarHeight + tabBarHeight + 20; // Ek boşluk

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      // ClipBehavior.none ekleyerek kenarlardaki potansiyel taşmaları engelle
      clipBehavior: Clip.none,
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.05,
        right: MediaQuery.of(context).size.width * 0.05,
        top: topPadding,
        // Alt boşluk bottomNavigationBar tarafından sağlanıyor, ama biraz daha ekleyelim
        bottom: MediaQuery.of(context).padding.bottom + 80, // Page indicator ve alt bar için
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Başlık Konteyneri
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient( colors: [ Colors.purpleAccent.withOpacity(0.2), Colors.deepPurple[900]!.withOpacity(0.5),], begin: Alignment.topLeft, end: Alignment.bottomRight,),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.3), blurRadius: 5, offset: Offset(0, 2) )],
            ),
            child: Text(
              title,
              style: GoogleFonts.cinzelDecorative( color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5,),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          // İçerik Konteyneri
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all( color: Colors.purple[300]!.withOpacity(0.4), width: 1,),
              boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4) )],
            ),
            padding: const EdgeInsets.all(20),
            child: RichText(
              text: TextSpan(
                // Varsayılan stil (kalıtım yoluyla uygulanır)
                style: GoogleFonts.cabin( color: Colors.white.withOpacity(0.9), fontSize: 16, height: 1.6, fontWeight: FontWeight.w400,),
                children: _formatText(content), // Formatlanmış metin parçaları
              ),
              textAlign: TextAlign.justify, // İki yana yaslı metin
            ),
          ),
          // Sayfa sonu için ekstra boşluk gerekmez, SingleChildScrollView padding'i hallediyor
        ],
      ),
    );
  }

  // Kartlar sekmesinin içeriği (BuildContext parametresi alır)
  Widget _buildSpreadCardsView(BuildContext context, S loc) {
    // context artık Builder'dan gelen doğru context olduğu için Scaffold.of çalışır
    final double appBarHeight = Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight;
    final double tabBarHeight = kTextTabBarHeight;
    final double topPadding = appBarHeight + tabBarHeight + 20;

    if (_spreadCards.isEmpty) {
      return Center(
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Text(
              loc.noCardsInSpread,
              style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 16),
            ),
          )
      );
    }
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.04,
        right: MediaQuery.of(context).size.width * 0.04,
        top: topPadding,
        bottom: MediaQuery.of(context).padding.bottom + 70, // Alt bar için boşluk
      ),
      child: Wrap(
        spacing: 15.0, // Yatay boşluk
        runSpacing: 25.0, // Dikey boşluk
        alignment: WrapAlignment.center, // Ortala
        children: _spreadCards.map((entry) {
          return _buildMiniCard(entry.value, entry.key); // Mini kartları göster
        }).toList(),
      ),
    );
  }

  // Ana build metodu
  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final int totalInterpretationPages = _interpretationPages.length;

    return Scaffold(
      extendBodyBehindAppBar: true, // AppBar arkasına içeriği uzat
      backgroundColor: Colors.transparent, // Arka planı Container yönetecek
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Şeffaf AppBar
        elevation: 0, // Gölgeyi kaldır
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          // SpreadType ismini formatla (örn: "CelticCross" -> "CELTIC CROSS")
          widget.spreadType.replaceAllMapped(RegExp(r'(?=[A-Z])'), (match) => ' ').toUpperCase(),
          style: GoogleFonts.cinzelDecorative( color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5 ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController, // Controller'ı ata
          labelStyle: GoogleFonts.cinzel( fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, ),
          unselectedLabelStyle: GoogleFonts.cinzel( fontSize: 15, color: Colors.white70,),
          indicatorColor: Colors.purpleAccent, indicatorWeight: 3.0,
          labelPadding: const EdgeInsets.symmetric(vertical: 10), // Sekme etiketlerine dikey boşluk
          tabs: [
            Tab(text: loc!.interpretation),
            Tab(text: loc.cards),
          ],
        ),
        // AppBar arkasına bulanıklık efekti
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.2)), // Hafif karartma
          ),
        ),
      ),
      // Ana İçerik Alanı
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient( // Ana arka plan gradient'i
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.deepPurple[900]!, Colors.black],
            stops: const [0.0, 0.8],
          ),
        ),
        // Sekme İçerikleri
        child: TabBarView(
          controller: _tabController, // Controller'ı ata
          physics: const BouncingScrollPhysics(), // Sekmeler arası geçişte güzel efekt
          children: [
            // --- 1. Sekme: Yorum Sayfaları ---
            // Builder widget'ı _buildInterpretationTabView içinde kullanılıyor
            _buildInterpretationTabView(totalInterpretationPages, loc),

            // --- 2. Sekme: Kartlar ---
            // Builder widget'ı _buildSpreadCardsView çağrısını sarmalıyor
            Builder(
                builder: (BuildContext innerContext) {
                  return _buildSpreadCardsView(innerContext, loc);
                }
            ),
          ],
        ),
      ),
      // Alt Aksiyon Butonları
      bottomNavigationBar: _buildBottomActionBar(context, loc),
    );
  }
} // State Sınıfı Sonu