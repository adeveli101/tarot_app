// lib/screens/tarot_reading_screen.dart
// ignore_for_file: unused_local_variable

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/screens/profile_page.dart';
import 'package:tarot_fal/screens/purchase_sheet.dart';
import 'package:tarot_fal/screens/card_selection_animation.dart';
import '../data/tarot_event_state.dart';
import '../models/animations/tap_animations_scale.dart';

class TarotReadingScreen extends StatefulWidget {
  final VoidCallback onSettingsTap;

  const TarotReadingScreen({super.key, required this.onSettingsTap});

  @override
  State<TarotReadingScreen> createState() => _TarotReadingScreenState();
}

class _TarotReadingScreenState extends State<TarotReadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _titleController;
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  void _showPurchaseSheet(BuildContext context, double requiredTokens) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<TarotBloc>(context),
        child: PurchaseSheet(requiredTokens: requiredTokens),
      ),
    );
  }

  void _showCouponSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<TarotBloc>(context),
        child: const CouponSheet(),
      ),
    );
  }

  void _navigateToProfilePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          BlocConsumer<TarotBloc, TarotState>(
            listener: (context, state) {
              if (state is SingleCardDrawn || state is SpreadDrawn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardSelectionAnimationScreen(
                      cardCount: state is SingleCardDrawn ? 1 : (state as SpreadDrawn).spread.length,
                    ),
                  ),
                );
              } else if (state is CouponRedeemed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc!.couponRedeemed(state.message))),
                );
              } else if (state is CouponInvalid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc!.couponInvalid(state.message))),
                );
              } else if (state is TarotError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc!.errorMessage(state.message))),
                );
              }
            },
            builder: (context, state) {
              if (state is TarotLoading) return _buildLoadingWidget();
              return _buildMainContent(context, state);
            },
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildUserInfoBar(context),
                      const SizedBox(width: 8),
                      _buildRedeemButton(context),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.person, color: Colors.white),
                        onPressed: () => _navigateToProfilePage(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: widget.onSettingsTap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Lottie.asset(
        'assets/animations/tarot_loading.json',
        width: 200,
        height: 200,
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, TarotState state) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackground(),
        _buildGradientOverlay(),
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTitle(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.45),
              _buildMainCard(context, state),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              _buildBottomInfo(),
            ],
          ),
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
          frameRate: FrameRate(30),
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
      ],
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Colors.transparent,
            Colors.deepPurple[700]!.withOpacity(0.3),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final loc = S.of(context);
    return FadeTransition(
      opacity: _titleController,
      child: ScaleTransition(
        scale: _titleController,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
          child: Column(
            children: [
              Text(
                '⋆ ${loc!.tarotFortune.toUpperCase()} ⋆',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 12,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.purple[300]!.withOpacity(0.8),
                      offset: const Offset(0, 4),
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple[200]!.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '✧ ${loc.mysticJourney} ✧',
                  style: GoogleFonts.cinzel(
                    color: Colors.purple[100]!.withOpacity(0.9),
                    fontSize: 14,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard(BuildContext context, TarotState state) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
        child: _buildStartButton(context, state),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, TarotState state) {
    final loc = S.of(context);
    const maxFreeReadsPerDay = 3;
    const minTokensRequired = 1.0;
    final canStart = state.isPremium || state.dailyFreeFalCount < maxFreeReadsPerDay || state.userTokens >= minTokensRequired;

    return TapAnimatedScale(
      onTap: () {
        HapticFeedback.lightImpact();
        _showCategorySheet(context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: canStart
                ? [
              Colors.deepPurple[700]!.withOpacity(0.8),
              Colors.purple[900]!.withOpacity(0.6),
            ]
                : [
              Colors.grey[700]!.withOpacity(0.8),
              Colors.grey[900]!.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: canStart ? Colors.purple[400]!.withOpacity(0.5) : Colors.grey[400]!.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(canStart ? 0.2 : 0.1)),
        ),
        child: Text(
          loc!.startJourney,
          textAlign: TextAlign.center,
          style: GoogleFonts.cinzel(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: Colors.white.withOpacity(canStart ? 1.0 : 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInfo() {
    final loc = S.of(context);
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.purple[800]!.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.purple[200]!.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Text(
              loc!.differentInterpretation,
              style: GoogleFonts.cinzel(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoBar(BuildContext context) {
    return BlocBuilder<TarotBloc, TarotState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.purple[300]!.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                color: state.isPremium ? Colors.amber : Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                state.isPremium ? "Premium" : "${state.userTokens.toStringAsFixed(1)} Tokens",
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRedeemButton(BuildContext context) {
    final loc = S.of(context);
    return TapAnimatedScale(
      onTap: () {
        HapticFeedback.lightImpact();
        _showCouponSheet(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple[700]!.withOpacity(0.8),
              Colors.deepPurple[900]!.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.card_giftcard, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              loc!.redeem,
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategorySheet(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<TarotBloc>(context),
        child: const CategorySelectionSheet(),
      ),
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 400),
      ),
    ).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context)!.categorySelection)),
        );
      }
    });
  }
}

class CategorySelectionSheet extends StatelessWidget {
  const CategorySelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple[900]!, Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildSheetHeader(context, loc!.categorySelection, loc.chooseTopic),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  _buildCategoryTile(
                    context: context,
                    title: loc.loveRelationships,
                    description: loc.loveDescription,
                    icon: Icons.favorite,
                    categoryKey: 'love',
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryTile(
                    context: context,
                    title: loc.career,
                    description: loc.careerDescription,
                    icon: Icons.work,
                    categoryKey: 'career',
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryTile(
                    context: context,
                    title: loc.money,
                    description: loc.moneyDescription,
                    icon: Icons.attach_money,
                    categoryKey: 'money',
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryTile(
                    context: context,
                    title: loc.general,
                    description: loc.generalDescription,
                    icon: Icons.psychology,
                    categoryKey: 'general',
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryTile(
                    context: context,
                    title: "Spiritual & Mystical",
                    description: "Explore your inner self, dreams, and cosmic connections.",
                    icon: Icons.star_border,
                    categoryKey: 'spiritual',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetHeader(BuildContext context, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required String categoryKey,
  }) {
    return TapAnimatedScale(
      onTap: () {
        HapticFeedback.selectionClick();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => BlocProvider.value(
            value: BlocProvider.of<TarotBloc>(context),
            child: SpreadSelectionSheet(categoryKey: categoryKey),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple[700]!.withOpacity(0.6),
              Colors.deepPurple[900]!.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple[300]!.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.amber[200], size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cinzel(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.cinzel(
                      fontSize: 14,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpreadSelectionSheet extends StatefulWidget {
  final String categoryKey;

  const SpreadSelectionSheet({super.key, required this.categoryKey});

  @override
  SpreadSelectionSheetState createState() => SpreadSelectionSheetState();
}

class SpreadSelectionSheetState extends State<SpreadSelectionSheet> {
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple[900]!, Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildSheetHeader(loc!.spreadSelection, loc.chooseSpread),
            _buildCustomPromptSection(context),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: _buildSpreadOptions(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomPromptSection(BuildContext context) {
    final loc = S.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc!.customPromptTitle,
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple[700]!.withOpacity(0.6),
                  Colors.deepPurple[900]!.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple[300]!.withOpacity(0.5)),
            ),
            child: TextField(
              controller: _promptController,
              maxLines: 3,
              style: GoogleFonts.cinzel(color: Colors.white),
              decoration: InputDecoration(
                hintText: loc.customPromptHint,
                hintStyle: GoogleFonts.cinzel(color: Colors.grey[400]),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSpreadOptions(BuildContext context) {
    final loc = S.of(context);
    final String? customPrompt = _promptController.text.trim().isNotEmpty ? _promptController.text.trim() : null;
    final List<Map<String, dynamic>> spreads = _getSpreadsForCategory(widget.categoryKey);

    return spreads.map((spread) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12), // Replace with bottom: 12
        child: _buildSpreadTile(
          context: context,
          title: spread['title'],
          description: spread['description'],
          cardCount: spread['cardCount'],
          event: spread['event'],
          cost: spread['cost'],
        ),
      );
    }).toList();
  }

  List<Map<String, dynamic>> _getSpreadsForCategory(String categoryKey) {
    switch (categoryKey) {
      case 'love':
        return [
          {
            'title': 'Single Card',
            'description': 'A quick insight into your love life.',
            'cardCount': 1,
            'event': () => DrawSingleCard(customPrompt: null),
            'cost': SpreadType.singleCard.costInCredits,
          },
          {
            'title': 'Relationship Spread',
            'description': 'Explore the dynamics of your relationship.',
            'cardCount': 7,
            'event': () => DrawRelationshipSpread(customPrompt: null),
            'cost': SpreadType.relationshipSpread.costInCredits,
          },
          {
            'title': 'Broken Heart',
            'description': 'Heal and understand emotional pain.',
            'cardCount': 5,
            'event': () => DrawBrokenHeart(customPrompt: null),
            'cost': SpreadType.brokenHeart.costInCredits,
          },
        ];
      case 'career':
        return [
          {
            'title': 'Past Present Future',
            'description': 'Understand your career journey over time.',
            'cardCount': 3,
            'event': () => DrawPastPresentFuture(customPrompt: null),
            'cost': SpreadType.pastPresentFuture.costInCredits,
          },
          {
            'title': 'Five Card Path',
            'description': 'Map out your career progression.',
            'cardCount': 5,
            'event': () => DrawFiveCardPath(customPrompt: null),
            'cost': SpreadType.fiveCardPath.costInCredits,
          },
          {
            'title': 'Career Path Spread',
            'description': 'Detailed guidance for professional growth.',
            'cardCount': 5,
            'event': () => DrawCareerPathSpread(customPrompt: null),
            'cost': SpreadType.careerPathSpread.costInCredits,
          },
        ];
      case 'money':
        return [
          {
            'title': 'Problem Solution',
            'description': 'Address financial challenges and solutions.',
            'cardCount': 3,
            'event': () => DrawProblemSolution(customPrompt: null),
            'cost': SpreadType.problemSolution.costInCredits,
          },
          {
            'title': 'Horseshoe Spread',
            'description': 'A broad view of your financial outlook.',
            'cardCount': 7,
            'event': () => DrawHorseshoeSpread(customPrompt: null),
            'cost': SpreadType.horseshoeSpread.costInCredits,
          },
        ];
      case 'general':
        return [
          {
            'title': 'Celtic Cross',
            'description': 'A comprehensive life overview.',
            'cardCount': 10,
            'event': () => DrawCelticCross(customPrompt: null),
            'cost': SpreadType.celticCross.costInCredits,
          },
          {
            'title': 'Yearly Spread',
            'description': 'Insights for the year ahead.',
            'cardCount': 12,
            'event': () => DrawYearlySpread(customPrompt: null),
            'cost': SpreadType.yearlySpread.costInCredits,
          },
          {
            'title': 'Astrological Cross',
            'description': 'Align your path with the stars.',
            'cardCount': 5,
            'event': () => DrawAstroLogicalCross(customPrompt: null),
            'cost': SpreadType.astroLogicalCross.costInCredits,
          },
        ];
      case 'spiritual':
        return [
          {
            'title': 'Mind Body Spirit',
            'description': 'Harmonize your inner self.',
            'cardCount': 3,
            'event': () => DrawMindBodySpirit(customPrompt: null),
            'cost': SpreadType.mindBodySpirit.costInCredits,
          },
          {
            'title': 'Dream Interpretation',
            'description': 'Decode the messages in your dreams.',
            'cardCount': 3,
            'event': () => DrawDreamInterpretation(customPrompt: null),
            'cost': SpreadType.dreamInterpretation.costInCredits,
          },
          {
            'title': 'Full Moon Spread',
            'description': 'Harness lunar energy for clarity.',
            'cardCount': 5,
            'event': () => DrawFullMoonSpread(customPrompt: null),
            'cost': SpreadType.fullMoonSpread.costInCredits,
          },
        ];
      default:
        return [];
    }
  }

  Widget _buildSpreadTile({
    required BuildContext context,
    required String title,
    required String description,
    required int cardCount,
    required Function event,
    required double cost,
  }) {
    final loc = S.of(context);
    return TapAnimatedScale(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.pop(context); // Close SpreadSelectionSheet
        context.read<TarotBloc>().add(event() as TarotEvent);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardSelectionAnimationScreen(cardCount: cardCount),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple[700]!.withOpacity(0.6),
              Colors.deepPurple[900]!.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple[300]!.withOpacity(0.5)),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        loc!.cardCount(cardCount),
                        style: GoogleFonts.cinzel(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.cinzel(fontSize: 14, color: Colors.grey[300]),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${cost.toStringAsFixed(1)} Tokens",
                  style: GoogleFonts.cinzel(
                    color: Colors.yellowAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}