// lib/screens/reading_result_screen.dart
// ignore_for_file: unused_local_variable

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

class _ReadingResultScreenState extends State<ReadingResultScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _closeButtonController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
    _closeButtonController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _closeButtonController.dispose();
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
          (route) => false, // Clear navigation stack
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple[900]!.withOpacity(0.7),
              Colors.black.withOpacity(0.9),
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
            } else if (state is FalYorumuLoaded) {
              // Auto-save is handled in TarotBloc, no manual action needed here
            }
          },
          builder: (context, state) {
            if (state is TarotLoading) {
              return Center(
                child: Lottie.asset(
                  'assets/animations/tarot_loading.json',
                  width: 200,
                  height: 200,
                  frameRate: FrameRate(30),
                ),
              );
            } else if (state is TarotInitial) {
              return Center(
                child: Text(
                  loc!.pleaseWait,
                  style: GoogleFonts.cinzel(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              );
            } else if (state is SingleCardDrawn) {
              return Stack(
                children: [
                  _buildCardPage(loc!.singleCard, state.card, null),
                  _buildCloseButton(context),
                  _buildActionButtons(context, state.card.name, null),
                ],
              );
            } else if (state is SpreadDrawn) {
              return Stack(
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
                  _buildCloseButton(context),
                  _buildActionButtons(context, state.spread.values.elementAt(_currentPage).name, state),
                ],
              );
            } else if (state is FalYorumuLoaded) {
              return Stack(
                children: [
                  _buildFortuneTellingPage(state.yorum),
                  _buildCloseButton(context),
                  _buildActionButtons(context, 'Fortune Telling', null, yorum: state.yorum),
                ],
              );
            } else if (state is TarotError) {
              return Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        loc!.errorMessage(state.message),
                        style: GoogleFonts.cinzel(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  _buildCloseButton(context),
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
                      style: GoogleFonts.cinzel(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                _buildCloseButton(context),
              ],
            );
          },
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
          _navigateToHome(context);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.purple[300]!.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: null, // Handled by TapAnimatedScale
          ),
        ),
      ),
    );
  }

  Widget _buildCardPage(String position, TarotCard card, SpreadDrawn? state) {
    final loc = S.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Text(
            position,
            style: GoogleFonts.cinzel(
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
          Stack(
            alignment: Alignment.center,
            children: [
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
              if (state != null) ...[
                Positioned(
                  left: 16,
                  child: _currentPage > 0
                      ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.purple),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  )
                      : const SizedBox.shrink(),
                ),
                Positioned(
                  right: 16,
                  child: _currentPage < (state.spread.length - 1)
                      ? IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Colors.purple),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          if (state != null) _buildPageIndicator(state.spread.length),
          const SizedBox(height: 20),
          Text(
            card.name,
            style: GoogleFonts.cinzel(
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
          _buildKeywords(card.keywords),
          const SizedBox(height: 16),
          _buildFortuneTelling(card.fortuneTelling),
          const SizedBox(height: 16),
          _buildMeanings(card),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int pageCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.deepOrangeAccent : Colors.white54,
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
    );
  }

  Widget _buildKeywords(List<String> keywords) {
    final loc = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          loc!.keywords,
          style: GoogleFonts.cinzel(
            fontSize: 18,
            color: Colors.yellowAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: keywords
              .map(
                (keyword) => Chip(
              label: Text(keyword, style: GoogleFonts.cinzel(color: Colors.white)),
              backgroundColor: Colors.orange[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMeanings(TarotCard card) {
    final loc = S.of(context);
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
            loc!.meaning,
            style: GoogleFonts.cinzel(
              fontSize: 20,
              color: Colors.yellowAccent,
              fontWeight: FontWeight.bold,
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
                        style: GoogleFonts.cinzel(
                          color: Colors.green[400],
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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
                        style: GoogleFonts.cinzel(
                          color: Colors.white70,
                          fontSize: 16,
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
                        style: GoogleFonts.cinzel(
                          color: Colors.red[400],
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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
                        style: GoogleFonts.cinzel(
                          color: Colors.white70,
                          fontSize: 16,
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

  Widget _buildFortuneTelling(List<String> fortuneTelling) {
    final loc = S.of(context);
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
            loc!.fortuneTelling,
            style: GoogleFonts.cinzel(
              fontSize: 20,
              color: Colors.yellowAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...fortuneTelling.map(
                (fortune) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '• $fortune',
                style: GoogleFonts.cinzel(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneTellingPage(String yorum) {
    final loc = S.of(context);
    final sections = yorum.split(RegExp(r'\n### '));
    final PageController fortunePageController = PageController();

    return Stack(
      children: [
        PageView.builder(
          controller: fortunePageController,
          physics: const BouncingScrollPhysics(),
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
                              style: GoogleFonts.cinzel(
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
                            style: GoogleFonts.cinzel(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (index == 0 && content.length < 150)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              loc!.swipeForMore,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cinzel(
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
                  color: _currentPage == index ? Colors.deepOrangeAccent : Colors.white54,
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
  }

  Widget _buildActionButtons(BuildContext context, String title, SpreadDrawn? state, {String? yorum}) {
    return Positioned(
      bottom: 16,
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

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return TapAnimatedScale(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cinzel(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}