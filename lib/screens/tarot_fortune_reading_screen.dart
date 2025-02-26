// ignore_for_file: unused_local_variable

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lottie/lottie.dart';
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/data/tarot_repository.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/screens/profile_page.dart';
import 'package:tarot_fal/screens/reading_result.dart';
import '../gemini_service.dart';
import 'card_selection_animation.dart';

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

  // Kullanıcının fal açma koşullarını kontrol eden yardımcı metod
  bool _canStartReading(TarotBloc bloc) {
    final isPremium = bloc.isPremium;
    final userCredits = bloc.userCredits;
    final dailyFreeFalCount = bloc.dailyFreeFalCount;
    const maxFreeFalsPerDay = 5;
    const minCreditsRequired = 1.0;

    if (isPremium) {
      return true;
    } else if (dailyFreeFalCount < maxFreeFalsPerDay) {
      return true;
    } else if (userCredits >= minCreditsRequired) {
      return true;
    }
    return false;
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

  void _showPurchaseSheet(BuildContext context, double requiredCredits) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<TarotBloc>(context),
        child: PurchaseSheet(requiredCredits: requiredCredits),
      ),
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
              debugPrint("BlocListener durumu: $state");
              if (state is SingleCardDrawn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardSelectionAnimationScreen(cardCount: 1),
                  ),
                );
              } else if (state is SpreadDrawn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardSelectionAnimationScreen(cardCount: state.spread.length),
                  ),
                );
              } else if (state is FalYorumuLoaded) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const ReadingResultScreen()),
                      (route) => false,
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
              } else if (state is InsufficientResources) {
                _showPurchaseSheet(context, state.requiredCredits);
              }
            },
            builder: (context, state) {
              debugPrint("Builder durumu: $state");
              if (state is TarotLoading) {
                return _buildLoadingWidget();
              }
              return _buildMainContent(context);
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

  Widget _buildMainContent(BuildContext context) {
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
              _buildMainCard(context),
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
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.withOpacity(0.2),
              Colors.brown,
              Colors.indigo[300]!.withOpacity(0.2),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
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

  Widget _buildMainCard(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
        child: _buildStartButton(context),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    final loc = S.of(context);
    final bloc = context.read<TarotBloc>();
    final canStart = _canStartReading(bloc);

    return TapAnimatedScale(
      onTap: canStart
          ? () {
        HapticFeedback.lightImpact();
        _showCategorySheet(context);
      }
          : () {
        HapticFeedback.heavyImpact();
        _showPurchaseSheet(context, 1.0); // Minimum 1 kredi gerekiyor
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
              color: canStart
                  ? Colors.purple[400]!.withOpacity(0.5)
                  : Colors.grey[400]!.withOpacity(0.3),
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
        margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.15),
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
        final bloc = context.read<TarotBloc>();
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
                color: bloc.isPremium ? Colors.amber : Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                bloc.isPremium
                    ? "Premium"
                    : "${bloc.userCredits.toStringAsFixed(1)} Credits",
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

class CouponSheet extends StatefulWidget {
  const CouponSheet({super.key});

  @override
  CouponSheetState createState() => CouponSheetState();
}

class CouponSheetState extends State<CouponSheet> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple[900]!,
              Colors.black87,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc!.redeem,
              style: GoogleFonts.cinzel(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _couponController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: loc.couponHint,
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple[300]!.withOpacity(0.5)),
                ),
                filled: true,
                fillColor: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            TapAnimatedScale(
              onTap: () {
                if (_couponController.text.trim().isNotEmpty) {
                  context.read<TarotBloc>().add(RedeemCoupon(_couponController.text));
                  _couponController.clear();
                  Navigator.pop(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple[700]!.withOpacity(0.8),
                      Colors.deepPurple[900]!.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  loc.redeem,
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Test: PREMIUM_TEST for premium, CREDITS_50 for 50 credits",
              style: GoogleFonts.cinzel(
                color: Colors.white70,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
            colors: [
              Colors.deepPurple[900]!,
              Colors.black87,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TapAnimatedScale(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  TapAnimatedScale(
                    onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: const Icon(Icons.home, color: Colors.white),
                  ),
                ],
              ),
            ),
            MysticGradientWidget(
              child: _buildSheetHeader(
                loc!.categorySelection,
                loc.chooseTopic,
              ),
            ),
            _buildInfoBanner(loc),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  _buildCategoryTile(context, loc.loveRelationships, loc.loveDescription, Icons.favorite, 'aşk'),
                  const SizedBox(height: 12),
                  _buildCategoryTile(context, loc.career, loc.careerDescription, Icons.work, 'kariyer'),
                  const SizedBox(height: 12),
                  _buildCategoryTile(context, loc.money, loc.moneyDescription, Icons.attach_money, 'para'),
                  const SizedBox(height: 12),
                  _buildCategoryTile(context, loc.general, loc.generalDescription, Icons.psychology, 'genel'),
                ],
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

  Widget _buildInfoBanner(S loc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.black45.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_sharp, color: Colors.red[200]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              loc.categoryInfoBanner,
              style: TextStyle(color: Colors.red[200]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(
      BuildContext context,
      String title,
      String description,
      IconData icon,
      String category,
      ) {
    return TapAnimatedScale(
      onTap: () {
        HapticFeedback.selectionClick();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => BlocProvider.value(
            value: BlocProvider.of<TarotBloc>(context),
            child: SpreadSelectionSheet(category: category),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.amber[200], size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.cinzel(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
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
    );
  }
}

class SpreadSelectionSheet extends StatefulWidget {
  final String category;

  const SpreadSelectionSheet({super.key, required this.category});

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
            colors: [
              Colors.deepPurple[900]!,
              Colors.black87,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TapAnimatedScale(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  TapAnimatedScale(
                    onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: const Icon(Icons.home, color: Colors.white),
                  ),
                ],
              ),
            ),
            HeaderScaleAnimation(
              title: loc!.spreadSelection,
              subtitle: loc.chooseSpread,
            ),
            _buildInfoBanner(loc),
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

  Widget _buildInfoBanner(S loc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.black45.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_sharp, color: Colors.red[200]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              loc.spreadInfoBanner,
              style: TextStyle(color: Colors.red[200], fontSize: 14),
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
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: loc.customPromptHint,
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                if (kDebugMode) {
                  debugPrint("Prompt changed to: $value");
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            loc.swipeForMore,
            style: GoogleFonts.cinzel(
              color: Colors.white70,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSpreadOptions(BuildContext context) {
    final loc = S.of(context);
    final String? customPrompt = _promptController.text.trim().isNotEmpty ? _promptController.text.trim() : null;

    final List<Widget> options = [];

    if (widget.category == 'aşk') {
      options.addAll([
        _buildSpreadTile(context, loc!.singleCard, loc.singleCardDescription, 1, DrawSingleCard(customPrompt: customPrompt)),
        const SizedBox(height: 12),
        _buildSpreadTile(context, loc.relationshipSpread, loc.relationshipSpreadDescription, 7, DrawRelationshipSpread(customPrompt: customPrompt)),
      ]);
    } else if (widget.category == 'kariyer') {
      options.addAll([
        _buildSpreadTile(context, loc!.pastPresentFuture, loc.pastPresentFutureDescription, 3, DrawPastPresentFuture(customPrompt: customPrompt)),
        const SizedBox(height: 12),
        _buildSpreadTile(context, loc.fiveCardPath, loc.fiveCardPathDescription, 5, DrawFiveCardPath(customPrompt: customPrompt)),
      ]);
    } else {
      options.addAll([
        _buildSpreadTile(context, loc!.celticCrossReading, loc.celticCrossDescription, 10, DrawCelticCross(customPrompt: customPrompt)),
        const SizedBox(height: 12),
        _buildSpreadTile(context, loc.yearlySpreadReading, loc.yearlySpreadDescription, 12, DrawYearlySpread(customPrompt: customPrompt)),
      ]);
    }

    return options;
  }

  Widget _buildSpreadTile(
      BuildContext context,
      String title,
      String description,
      int cardCount,
      TarotEvent event) {
    final loc = S.of(context);
    return TapAnimatedScale(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.pop(context);
        context.read<TarotBloc>().add(event);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardSelectionAnimationScreen(cardCount: cardCount),
          ),
        ).then((_) {
          if (mounted) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReadingResultScreen()),
                );
              }
            });
          }
        });
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
        child: Column(
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
      ),
    );
  }
}

class PurchaseSheet extends StatelessWidget {
  final double requiredCredits;

  const PurchaseSheet({super.key, required this.requiredCredits});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.6,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple[900]!,
              Colors.black87,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc!.purchaseCredits,
              style: GoogleFonts.cinzel(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              loc.insufficientCreditsMessage(requiredCredits),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildPurchaseOption(context, "10 Credits", 0.99, '10_credits'),
            const SizedBox(height: 12),
            _buildPurchaseOption(context, "50 Credits", 4.99, '50_credits'),
            const SizedBox(height: 12),
            _buildPurchaseOption(context, "100 Credits", 9.99, '100_credits'),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                loc.cancel,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseOption(BuildContext context, String title, double price, String productId) {
    return TapAnimatedScale(
      onTap: () async {
        final purchaseParam = PurchaseParam(
          productDetails: ProductDetails(
            id: productId,
            title: title,
            description: 'Purchase $title',
            price: '$price USD',
            rawPrice: price,
            currencyCode: 'USD',
          ),
        );
        await InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
        Navigator.pop(context); // Satın alma başlatıldığında sheet'i kapat
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple[700]!.withOpacity(0.8),
              Colors.deepPurple[900]!.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.cinzel(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '\$$price',
              style: GoogleFonts.cinzel(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tap Animated Scale (Değişmedi)
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

// Mystic Gradient Widget (Optimize edildi)
class MysticGradientWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const MysticGradientWidget({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 3),
  });

  @override
  MysticGradientWidgetState createState() => MysticGradientWidgetState();
}

class MysticGradientWidgetState extends State<MysticGradientWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  final List<List<Color>> _gradients = [
    [Colors.deepPurple[900]!, Colors.purpleAccent],
    [Colors.purpleAccent, Colors.deepPurple[700]!],
    [Colors.deepPurple[800]!, Colors.black87],
    [Colors.black87, Colors.deepPurpleAccent],
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)..repeat(reverse: true);
    _color1 = TweenSequence<Color?>(
      _gradients.map((gradient) => TweenSequenceItem(tween: ColorTween(begin: gradient[0], end: gradient[1]), weight: 1)).toList(),
    ).animate(_controller);
    _color2 = TweenSequence<Color?>(
      _gradients.map((gradient) => TweenSequenceItem(tween: ColorTween(begin: gradient[1], end: gradient[0]), weight: 1)).toList(),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_color1.value ?? Colors.deepPurple[900]!, _color2.value ?? Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

// Header Scale Animation (Değişmedi)
class HeaderScaleAnimation extends StatelessWidget {
  final String title;
  final String subtitle;

  const HeaderScaleAnimation({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: _buildHeaderContent(),
        );
      },
    );
  }

  Widget _buildHeaderContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo[900]!.withOpacity(0.8),
            Colors.deepPurple[800]!.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 6,
            margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              color: Colors.purpleAccent.withOpacity(0.7),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}