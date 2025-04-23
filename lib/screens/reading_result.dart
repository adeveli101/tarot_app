import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/models/tarot_card.dart';
import 'package:tarot_fal/screens/settings_screen.dart';
import 'package:tarot_fal/screens/tarot_fortune_reading_screen.dart'; // Assuming this is the home/main screen
import '../data/tarot_bloc.dart';
import '../data/tarot_event_state.dart';
import '../main.dart'; // For MyAppState access if needed for locale
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

  // Store the spread and interpretation sections to build pages
  Map<String, TarotCard>? _currentSpread;
  List<String> _interpretationSections = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      final page = _pageController.page;
      if (page != null && page == page.roundToDouble()) {
        if (_currentPage != page.round()) {
          if (mounted) { // Add mounted check here too
            setState(() {
              _currentPage = page.round();
            });
          }
          HapticFeedback.lightImpact();
        }
      }
    });

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Initialize controller FIRST
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize animation object immediately AFTER controller initialization
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

    // Schedule the state check and animation start AFTER the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // Ensure widget is still mounted
      final currentState = context.read<TarotBloc>().state;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _glowController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // Helper to update page data based on state
  void _updatePages(FalYorumuLoaded state) {
    _currentSpread = state.spread; // Assumes FalYorumuLoaded includes spread
    _interpretationSections = state.yorum
        .split(RegExp(r'\n\n### ')) // Split interpretation into sections
        .where((s) => s.trim().isNotEmpty) // Remove empty sections
        .toList();
    if (_currentPage >= _getTotalPageCount()) {
      _currentPage = 0; // Reset page if necessary
    }
    setState(() {}); // Trigger rebuild with new page data
  }

  int _getTotalPageCount() {
    int count = 0;
    if (_currentSpread != null && _currentSpread!.isNotEmpty) {
      count++; // Add 1 for the drawn cards summary page
    }
    count += _interpretationSections.length; // Add pages for interpretation sections
    return count.clamp(1, 100); // Ensure at least 1 page
  }

  void _shareReading(String content) {
    Share.share(content);
    HapticFeedback.mediumImpact();
  }

  // Navigate back to the main Tarot Reading Screen
  void _navigateToHome(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => TarotReadingScreen( // Navigate back to your main screen
          onSettingsTap: () {
            // Keep the navigation logic for settings if needed
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
          (route) => false, // Remove all previous routes
    );
  }

  void _showCardDetails(TarotCard card) {
    HapticFeedback.lightImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.92, // Slightly wider
              height: MediaQuery.of(context).size.height * 0.88, // Slightly taller
              padding: const EdgeInsets.only(top: 25, left: 20, right: 20, bottom: 15),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    // Consistent gradient with other parts of the app
                    colors: [Colors.indigo[900]!, Colors.purple[800]!, Colors.black87],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(25), // Smoother radius
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purpleAccent.withOpacity(0.5), // Enhanced shadow
                      blurRadius: 25,
                      spreadRadius: 3,
                    ),
                  ],
                  // Subtle border
                  border: Border.all(color: Colors.purpleAccent.withOpacity(0.4), width: 1.5)
              ),
              child: Column( // Use Column for layout
                children: [
                  Expanded( // Make content scrollable
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // --- Card Name ---
                          Text(
                            card.name.toUpperCase(), // Uppercase for emphasis
                            style: GoogleFonts.cinzelDecorative( // Use decorative for title
                              fontSize: 26, // Slightly smaller for balance
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  color: Colors.purpleAccent.withOpacity(0.6),
                                  offset: const Offset(1, 1), // Subtle shadow
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),

                          // --- Card Image ---
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [ // Add inner glow/shadow to image
                                  BoxShadow(
                                      color: Colors.white.withOpacity(0.15),
                                      blurRadius: 15,
                                      spreadRadius: 2
                                  )
                                ]
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/tarot_card_images/${card.img}',
                                height: MediaQuery.of(context).size.height * 0.4, // Responsive height
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                  size: 100,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- Details Sections ---
                          // Using cabin for better readability of longer texts
                          _buildDetailSection(S.of(context)!.arcana, card.arcana),
                          _buildDetailSection(S.of(context)!.suit, card.suit),
                          if (card.elemental != null && card.elemental!.isNotEmpty) _buildDetailSection("Element", card.elemental!),
                          _buildDetailSection("Keywords", card.keywords.join(", ")),
                          _buildDetailSection("Fortune Telling", card.fortuneTelling.join("\n\n")),
                          _buildDetailSection("Light Meanings", card.meanings.light.join("\n\n")),
                          _buildDetailSection("Shadow Meanings", card.meanings.shadow.join("\n\n")),
                          if (card.archetype != null && card.archetype!.isNotEmpty) _buildDetailSection("Archetype", card.archetype!),
                          if (card.hebrewAlphabet != null && card.hebrewAlphabet!.isNotEmpty) _buildDetailSection("Hebrew Alphabet", card.hebrewAlphabet!),
                          if (card.numerology != null && card.numerology!.isNotEmpty) _buildDetailSection("Numerology", card.numerology!),
                          if (card.mythicalSpiritual != null && card.mythicalSpiritual!.isNotEmpty) _buildDetailSection("Mythical/Spiritual", card.mythicalSpiritual!),
                          if (card.questionsToAsk != null && card.questionsToAsk!.isNotEmpty)
                            _buildDetailSection("Questions to Ask", card.questionsToAsk!.join("\n\n")),

                          const SizedBox(height: 20), // Space before close button
                        ],
                      ),
                    ),
                  ),
                  // --- Close Button --- (Positioned outside scroll)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0), // Space from scroll content
                    child: TapAnimatedScale(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient( // Brighter gradient for button
                              colors: [Colors.purpleAccent.shade100, Colors.purpleAccent.shade400]
                          ),
                          borderRadius: BorderRadius.circular(25), // Pill shape
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purpleAccent.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          S.of(context)!.close.toUpperCase(), // Uppercase action text
                          style: GoogleFonts.cinzel(
                            fontSize: 16, // Clear font size
                            color: Colors.black87, // Contrast color
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
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
        // Enhanced transition
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut), // Elastic effect
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 600), // Slightly longer duration
    );
  }

  // Helper for the close button in the dialog
  // ignore: unused_element
  Widget _buildCloseButtonDialog(BuildContext context) {
    return Positioned(
      top: 8, // Closer to the edge
      right: 8,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(6), // Smaller padding
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.5), // Semi-transparent background
            boxShadow: [ // Subtle shadow for depth
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 3,
              ),
            ],
          ),
          child: const Icon(Icons.close, color: Colors.white70, size: 20), // Slightly smaller icon
        ),
      ),
    );
  }

  // Refined detail section widget
  Widget _buildDetailSection(String title, String? content) {
    if (content == null || content.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12), // Increased vertical padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.cinzel( // Title font
              fontSize: 16, // Slightly smaller title
              fontWeight: FontWeight.bold,
              color: Colors.purpleAccent[100], // Consistent accent color
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10), // Increased space
          Text(
            content,
            style: GoogleFonts.cabin( // Content font (more readable)
              fontSize: 15, // Standard content size
              color: Colors.white.withOpacity(0.85), // High visibility
              height: 1.5, // Good line spacing
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.left, // Align text naturally
          ),
          // Divider for separation
          Divider(color: Colors.purpleAccent.withOpacity(0.2), thickness: 1, height: 30),
        ],
      ),
    );
  }


  // --- Page Builder Widgets ---

  // Page 0: Summary of Drawn Cards
  Widget _buildDrawnCardsSummaryPage(Map<String, TarotCard> spread) {
    final loc = S.of(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: 20, // Add vertical padding
      ).copyWith(top: kToolbarHeight + 20), // Ensure content is below AppBar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Page Title
          Text(
            loc!.drawCards.toUpperCase(),
            style: GoogleFonts.cinzelDecorative(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
              shadows: [
                Shadow(color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 5)
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            loc.tapCardForDetails, // Instruction text
            style: GoogleFonts.cabin(fontSize: 14, color: Colors.white70),
          ),
          Divider(color: Colors.purpleAccent.withOpacity(0.2), height: 30, thickness: 1),
          const SizedBox(height: 10),

          // Cards Grid/Wrap
          Wrap(
            spacing: 15.0, // Horizontal space between cards
            runSpacing: 25.0, // Vertical space between rows
            alignment: WrapAlignment.center, // Center cards
            children: spread.entries.map((entry) {
              String position = entry.key;
              TarotCard card = entry.value;
              return _buildMiniCard(card, position);
            }).toList(),
          ),
          const SizedBox(height: 80), // Space at the bottom before potential buttons
        ],
      ),
    );
  }

  // Widget for displaying a single card in the summary
  Widget _buildMiniCard(TarotCard card, String position) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.28; // Responsive width
    final double cardHeight = cardWidth * 1.5; // Maintain aspect ratio

    return TapAnimatedScale(
      onTap: () => _showCardDetails(card),
      child: SizedBox( // Constrain the size of the tappable area
        width: cardWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Take minimum space
          children: [
            Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), // Smaller radius for mini card
                image: DecorationImage(
                  image: AssetImage('assets/tarot_card_images/${card.img}'),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    // Sadece debug modunda konsola yazdırır
                    debugPrint("Error loading image: ${card.img} - $exception");
                  },
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                  // Optional: Add a subtle glow on hover/tap (needs state management)
                ],
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            // Display position name below the card
            Text(
              position.replaceAll('_', ' ').splitMapJoin(RegExp(r'(?=[A-Z])'), onMatch: (m) => ' ', onNonMatch: (n) => n), // Format position name
              style: GoogleFonts.cinzel(
                fontSize: 11,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Optionally display card name too (can make it crowded)
            /*
             Text(
               card.name,
               style: GoogleFonts.cabin(
                 fontSize: 9,
                 color: Colors.white70,
               ),
               textAlign: TextAlign.center,
               maxLines: 1,
               overflow: TextOverflow.ellipsis,
             ),
             */
          ],
        ),
      ),
    );
  }

  // Page for displaying one section of the Gemini interpretation
  Widget _buildFortuneTellingSectionPage(String sectionText) {
    final loc = S.of(context);
    final List<String> lines = sectionText.split('\n\n');
    // Ensure title is correctly extracted, even if it's the only line
    String title = lines.firstWhere((line) => line.trim().isNotEmpty, orElse: () => loc!.interpretation);
    String content = lines.skipWhile((line) => line == title || line.trim().isEmpty).join('\n\n').trim();

    // If content is empty after removing title, use the title as content
    if (content.isEmpty && lines.length == 1) {
      content = title;
      title = loc!.interpretation; // Use generic title
    } else if (title.startsWith("### ")) {
      // Clean up title if it still has markdown
      title = title.substring(4).trim();
    } else if (title.trim().isEmpty) {
      title = loc!.interpretationSection; // Fallback title
    }


    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: 20,
          ).copyWith(top: kToolbarHeight + 20), // Ensure content is below AppBar
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - (kToolbarHeight + 40)), // Adjust min height
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch content horizontally
              mainAxisAlignment: MainAxisAlignment.start, // Align content to top
              children: [
                // Section Title with Glow
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    final Color titleColor = _getTitleColor(title);
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            titleColor.withOpacity(0.7), // Use dynamic color
                            Colors.deepPurple[900]!.withOpacity(0.9),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: titleColor.withOpacity(0.3 + _glowController.value * 0.3),
                            blurRadius: 10 + _glowController.value * 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Text(
                        title, // Display cleaned title
                        style: GoogleFonts.cinzelDecorative( // Use decorative font for titles
                          color: Colors.white,
                          fontSize: 22, // Slightly smaller title
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20), // Increased space

                // Interpretation Content Box
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient( // Consistent gradient for content
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.deepPurple[900]!.withOpacity(0.8), // Slightly adjusted opacity
                        Colors.indigo[900]!.withOpacity(0.85),
                        Colors.black.withOpacity(0.75),
                      ],
                      stops: const [0.1, 0.5, 0.9],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [ // Consistent shadow
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3), // Softer shadow
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all( // Consistent border
                      color: Colors.purple[300]!.withOpacity(0.3),
                      width: 1, // Thinner border
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: RichText(
                    text: TextSpan(
                      // Use cabin for better readability of interpretation text
                      style: GoogleFonts.cabin(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16, // Readable text size
                        height: 1.6, // Good line spacing for reading
                        fontWeight: FontWeight.w400,
                      ),
                      children: _formatText(content), // Apply formatting
                    ),
                    textAlign: TextAlign.justify, // Justify text for block look
                  ),
                ),
                const SizedBox(height: 80), // Space for page indicator and buttons
              ],
            ),
          ),
        );
      },
    );
  }


  // Helper to determine title color based on keywords
  Color _getTitleColor(String title) {
    // Use case-insensitive matching
    title = title.toLowerCase();
    if (RegExp(r'(dizilim|layout|symphony|elements|dynamics)').hasMatch(title)) {
      return Colors.amber[400]!; // Brighter amber for layout
    } else if (RegExp(r'(analiz|analysis|yorum|reflections|diagnosis|insight|evaluation|commentary)').hasMatch(title)) {
      return Colors.purpleAccent[100]!; // Lighter purple for analysis
    } else if (RegExp(r'(rehberlik|guidance|öneri|recommendations|whispers|suggestions|advice|tips)').hasMatch(title)) {
      return Colors.tealAccent[100]!; // Lighter teal for guidance
    } else if (RegExp(r'(sonuç|conclusion|summary|outcome|thoughts)').hasMatch(title)) {
      return Colors.orangeAccent[100]!; // Lighter orange for conclusion
    } else {
      return Colors.white; // Default
    }
  }

  // Text formatting logic (Using standard strings for Regex - CORRECTED)
  List<TextSpan> _formatText(String text) {
    List<TextSpan> spans = [];
    final paragraphs = text.split(RegExp(r'\n{2,}')); // Split by double (or more) newlines

    // Define Regex using standard strings with escaping
    // Escape backslashes: \w -> \\w, \s -> \\s
    final subheadingRegex = RegExp('^\\s*(-?\\s*[\\w\\s\'&]+):\\s*(.*)', dotAll: true);
    final starRegex = RegExp('\\*(.*?)\\*'); // Escape asterisks

    for (var paragraph in paragraphs) {
      paragraph = paragraph.trim();
      if (paragraph.isEmpty) continue;

      var match = subheadingRegex.firstMatch(paragraph);

      if (match != null) {
        // --- Handle Subheading Paragraph ---
        final String subheadingKey = match.group(1)?.trim() ?? '';
        final String subheadingContent = match.group(2)?.trim() ?? '';

        spans.add(TextSpan(
          text: "$subheadingKey:\n", // Subheading text + newline
          style: TextStyle(
            color: _getSubheadingColor(subheadingKey), // Dynamic color based on subheading
            fontWeight: FontWeight.bold,
            fontSize: 17, // Slightly larger font for subheading
            height: 1.8, // Add space after the subheading line
          ),
        ));

        // Add the content after the subheading, processing it for stars
        if (subheadingContent.isNotEmpty) {
          // Pass the already defined starRegex to the helper
          spans.addAll(_processStars(subheadingContent, starRegex));
          spans.add(const TextSpan(text: "\n\n")); // Add space after subheading content
        }

      } else {
        // --- Handle Regular Paragraph (No subheading detected) ---
        // Process the whole paragraph for stars using the defined starRegex
        spans.addAll(_processStars(paragraph, starRegex));
        spans.add(const TextSpan(text: "\n\n")); // Space between paragraphs
      }
    }

    // Remove trailing newlines if any resulted from processing
    if (spans.isNotEmpty && spans.last.text == "\n\n") {
      spans.removeLast();
    }
    return spans;
  }

  // Helper to process text with stars for emphasis (accepts starRegex)
  // CORRECTED: Accepts RegExp as argument
  List<TextSpan> _processStars(String text, RegExp starRegex) {
    List<TextSpan> starSpans = [];
    int lastEnd = 0;
    for (Match match in starRegex.allMatches(text)) {
      // Add normal text before the match
      if (match.start > lastEnd) {
        starSpans.add(_formatRegularTextSpan(text.substring(lastEnd, match.start)));
      }
      // Add the emphasized text (group 1 is the content between stars)
      if (match.group(1) != null) {
        starSpans.add(TextSpan(
          text: match.group(1), // Use group 1 content
          style: const TextStyle(
            color: Colors.yellowAccent, // Brighter emphasis color
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ));
      }
      lastEnd = match.end;
    }
    // Add any remaining normal text after the last match
    if (lastEnd < text.length) {
      starSpans.add(_formatRegularTextSpan(text.substring(lastEnd)));
    }
    return starSpans;
  }

  // Helper for consistent regular text styling (Remains the same)
  TextSpan _formatRegularTextSpan(String text) {
    // Inherits default style from RichText parent
    return TextSpan(text: text);
  }

  // Subheading color logic (Remains the same)
  Color _getSubheadingColor(String text) {
    text = text.toLowerCase().replaceAll('-', '').trim(); // Normalize text
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
    // Fallback for keywords often used as subheadings
    if (text.contains('keywords') || text.contains('anahtar kelimeler')) return Colors.lightBlue[200]!;
    if (text.contains('fortune telling') || text.contains('kehanet')) return Colors.lightGreen[300]!;
    return Colors.white.withOpacity(0.9); // Default
  }




  // --- Bottom Action Buttons and Page Indicator ---

  Widget _buildBottomBar(BuildContext context, String? shareContent) {
    final loc = S.of(context);
    final totalPages = _getTotalPageCount();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(bottom: 15, top: 10, left: 16, right: 16),
        decoration: BoxDecoration( // Add background gradient for better visibility
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.0),
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Page Indicator
            if (totalPages > 1) ...[
              _buildPageIndicator(totalPages),
              const SizedBox(height: 15), // Space between indicator and buttons
            ],
            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    label: loc!.share,
                    icon: Icons.share,
                    onPressed: () => _shareReading(shareContent ?? loc.myTarotReading),
                  ),
                ),
                const SizedBox(width: 16), // Space between buttons
                Expanded(
                  child: _buildActionButton(
                    context: context,
                    label: loc.returnToHome,
                    icon: Icons.home_outlined, // Use outlined icon
                    onPressed: () => _navigateToHome(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Refined Page Indicator
  Widget _buildPageIndicator(int pageCount) {
    if (pageCount <= 1) return const SizedBox.shrink(); // Hide if only one page

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300), // Smooth transition
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 5), // Adjust spacing
          width: _currentPage == index ? 12 : 8, // Active dot is larger
          height: _currentPage == index ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Colors.purpleAccent // Brighter active color
                : Colors.white.withOpacity(0.4), // Dim inactive color
            boxShadow: [ // Add shadow to active dot
              if (_currentPage == index)
                BoxShadow(
                  color: Colors.purpleAccent.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Refined Action Button
  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return TapAnimatedScale( // Use TapAnimatedScale for feedback
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Adjusted padding
        decoration: BoxDecoration(
            gradient: LinearGradient( // Consistent gradient
              colors: [Colors.deepPurple[600]!, Colors.purple[800]!], // Slightly lighter gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20), // Rounded corners
            boxShadow: [
              BoxShadow( // Subtle shadow
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.purpleAccent.withOpacity(0.3), width: 1) // Subtle border
        ),
        child: Row( // Use Row for icon and text
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Prevent excessive width
          children: [
            Icon(icon, size: 18, color: Colors.white.withOpacity(0.9)), // Slightly smaller icon
            const SizedBox(width: 8), // Space between icon and text
            Flexible( // Allow text to wrap if needed
              child: Text(
                label,
                style: GoogleFonts.cabin(
                  fontSize: 13, // Consistent font size
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600, // Bold action text
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis, // Handle overflow
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }


  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Scaffold(
      // Extend body behind AppBar for seamless gradient
      extendBodyBehindAppBar: true,
      appBar: AppBar(

        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => _navigateToHome(context), // Go home on back press
        ),
        actions: [
          // Optional: Add share button directly to AppBar if preferred
          /*
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.white70),
              tooltip: loc.share,
              onPressed: () {
                final state = context.read<TarotBloc>().state;
                if (state is FalYorumuLoaded) {
                  _shareReading(state.yorum);
                }
              },
            ),
            */
        ],
      ),
      body: Container(
        // Main background gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple[900]!, Colors.black], // Consistent background
            stops: const [0.0, 0.8],
          ),
        ),
        child: BlocConsumer<TarotBloc, TarotState>(
          listener: (context, state) {
            if (state is TarotError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc!.errorMessage(state.message)),
                  backgroundColor: Colors.redAccent,
                  action: SnackBarAction(
                    label: loc.tryAgain,
                    onPressed: () => _navigateToHome(context), // Go home on error action
                  ),
                ),
              );
              _fadeController.forward(); // Ensure fade-in completes on error
            } else if (state is FalYorumuLoaded) {
              // Update page data when state changes
              _updatePages(state);
              _fadeController.forward(); // Start fade-in animation
            } else if (state is! TarotLoading) {
              // If it's not Loading or FalYorumuLoaded, still fade in
              _fadeController.forward();
            }
          },
          builder: (context, state) {
            Widget content;

            if (state is TarotLoading) {
              content = Center(
                child: Lottie.asset(
                  'assets/animations/tarot_loading.json',
                  width: 180, // Slightly smaller loading animation
                  height: 180,
                  frameRate: FrameRate(60),
                ),
              );
            } else if (state is FalYorumuLoaded) {
              final totalPages = _getTotalPageCount();
              if (totalPages == 0) {
                // Handle case where interpretation/spread might be empty
                content = Center(
                  child: Text(
                    loc!.noReadingData,
                    style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                content = Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(), // Nice scroll physics
                      itemCount: totalPages,
                      itemBuilder: (context, index) {
                        // Page 0: Drawn Cards Summary
                        if (_currentSpread != null && _currentSpread!.isNotEmpty && index == 0) {
                          return _buildDrawnCardsSummaryPage(_currentSpread!);
                        }
                        // Subsequent Pages: Interpretation Sections
                        else {
                          int interpretationIndex = index;
                          // Adjust index if summary page exists
                          if (_currentSpread != null && _currentSpread!.isNotEmpty) {
                            interpretationIndex = index - 1;
                          }
                          // Check bounds
                          if (interpretationIndex >= 0 && interpretationIndex < _interpretationSections.length) {
                            String section = _interpretationSections[interpretationIndex];
                            // Prepend the markdown if it's not the first section originally
                            if (index > 0 || (_currentSpread == null || _currentSpread!.isEmpty)) {
                              if(!section.trim().startsWith("###")) {
                                section = "### ${section.trim()}";
                              }
                            }
                            return _buildFortuneTellingSectionPage(section);
                          } else {
                            // Should not happen with correct itemCount, but fallback
                            return Center(child: Text("Invalid Page Index", style: TextStyle(color: Colors.red)));
                          }
                        }
                      },
                    ),
                    // Bottom Bar with Buttons and Indicator
                    _buildBottomBar(context, state.yorum),
                  ],
                );
              }
            } else if (state is TarotError) {
              content = Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    loc!.errorMessage(state.message),
                    style: GoogleFonts.cinzel(color: Colors.red[300], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else {
              // Handle other potential states (e.g., TarotInitial)
              content = Center(
                child: Text(
                  loc!.pleaseWait, // Or a more specific message
                  style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 16),
                ),
              );
            }

            // Apply fade-in animation to the content
            return FadeTransition(
              opacity: _fadeAnimation,
              child: content,
            );
          },
        ),
      ),
    );
  }
}