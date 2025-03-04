import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/screens/profile_page.dart';
import 'package:tarot_fal/screens/card_selection_animation.dart';
import '../data/payment_maganer.dart';
import '../data/tarot_event_state.dart';
import '../models/animations/tap_animations_scale.dart';

class TarotReadingScreen extends StatefulWidget {
  final VoidCallback onSettingsTap;

  const TarotReadingScreen({super.key, required this.onSettingsTap});

  @override
  State<TarotReadingScreen> createState() => _TarotReadingScreenState();
}

class _TarotReadingScreenState extends State<TarotReadingScreen> with TickerProviderStateMixin {
  late AnimationController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }



  void _showPaymentDialog(BuildContext context, double requiredTokens) {
    PaymentManager.showPaymentDialog(
      context,
      requiredTokens: requiredTokens,
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context)!.couponRedeemed("Mystical Tokens added successfully"))),
        );
      },
    );
  }

  void _showCouponSheet(BuildContext context) {
    final paymentManager = PaymentManager();
    paymentManager.initialize();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, animation1, animation2) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: BlocProvider.value(
                value: BlocProvider.of<TarotBloc>(context),
                child: CouponSheet(manager: paymentManager),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1), // Aşağıdan yukarı doğru animasyon
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuad,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    ).whenComplete(() => paymentManager.dispose());
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
      resizeToAvoidBottomInset: false, // Prevent screen from resizing with keyboard
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
              } else if (state is InsufficientResources) {
                _showPaymentDialog(context, state.requiredTokens);
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
                        icon: const Icon(
                          Icons.visibility_outlined,
                          color: Color(0xB9D8BFD8),
                          size: 24,
                        ),
                        tooltip: loc!.profile,
                        onPressed: () => _navigateToProfilePage(context),
                        splashRadius: 24,
                        splashColor: Colors.grey.withOpacity(0.3),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Color(0xB9D8BFD8),
                          size: 24,
                        ),
                        tooltip: loc.settings,
                        onPressed: widget.onSettingsTap,
                        splashRadius: 24,
                        splashColor: Colors.grey.withOpacity(0.9),
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
    return Column(
      children: [
        AnimatedBuilder(
          animation: _titleController,
          builder: (context, child) {
            final shimmerValue = sin(_titleController.value * pi * 2) * 0.5 + 0.5;

            return ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.white,
                  Color(0xFFE6E6FA), // Lavanta rengi
                  Colors.purpleAccent.shade100,
                  Colors.white,
                ],
                stops: [0.0, shimmerValue * 0.5, shimmerValue, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                ' ASTRAL TAROT ', // Yıldız sembolünü değiştirdim
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4, // Tek satıra sığması için azaltılmış letter spacing
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.purple[300]!.withOpacity(0.8),
                      offset: const Offset(0, 4),
                      blurRadius: 15,
                    ),
                    Shadow(
                      color: Colors.purpleAccent.withOpacity(0.3 + shimmerValue * 0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.001),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.purple[200]!.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '✧ UNVEIL THE STARS ✧',
            style: GoogleFonts.cinzel(
              color: Colors.purple[100]!.withOpacity(0.9),
              fontSize: 14,
              letterSpacing: 4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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
              Color(0xFF2D0A4E), // Koyu mor
              Color(0xFF4B0082), // İndigo
            ]
                : [
              Colors.grey[900]!.withOpacity(0.3),
              Color(0xFF2D0A40), // Koyu mor
              Color(0xFF2D0A40), // Koyu mor
              Color(0xFF4B0082), // İndigo
              Colors.grey[900]!.withOpacity(0.3),


            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: canStart ? Color(0xFFDA70D6).withOpacity(0.6) : Colors.grey[400]!.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: canStart ? Colors.purpleAccent.withOpacity(0.3) : Colors.white.withOpacity(0.1),
            width: 1.6,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (canStart) ...[
              Positioned(
                left: 10,
                child: Icon(Icons.auto_awesome, color: Colors.white.withOpacity(0.2), size: 16),
              ),
              Positioned(
                right: 10,
                child: Icon(Icons.star, color: Colors.white.withOpacity(0.2), size: 16),
              ),
            ],
            // Ana metin
            Text(
              loc!.startJourney,
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: Colors.white.withOpacity(canStart ? 1.0 : 0.7),
                shadows: canStart
                    ? [
                  Shadow(
                    color: Colors.purpleAccent.withOpacity(0.8),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : null,
              ),
            ),
          ],
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
                fontSize: 12,
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
                state.isPremium ? "Premium" : "${state.userTokens.toStringAsFixed(1)} ${S.of(context)!.mysticalTokens}",
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
    );
  }



  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
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
        child: Stack(
          children: [
            Column(
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
                        title: loc.spiritualMystical,
                        description: loc.spiritualMysticalDescription,
                        icon: Icons.star_border,
                        categoryKey: 'spiritual',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 16,
              right: 16,
              child: _buildCloseButton(context),
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
        child: const Icon(Icons.close, color: Colors.white, size: 24),
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
  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple[900]!, Colors.black87],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildSheetHeader(loc!.spreadSelection, loc.chooseSpread),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final spreads = _getSpreadsForCategory(widget.categoryKey);
                    if (index >= spreads.length) return null;
                    final spread = spreads[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      child: _buildSpreadTile(
                        context: context,
                        title: spread['title'],
                        description: spread['description'],
                        cardCount: spread['cardCount'],
                        event: spread['event'],
                        cost: spread['cost'],
                      ),
                    );
                  },
                  childCount: _getSpreadsForCategory(widget.categoryKey).length,
                ),
              ),
            ],
          ),
          Positioned(
            top: 20,
            right: 12,
            bottom: 730,
            child: _buildCloseButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 16), // Başlığı aşağı kaydırmak için üst padding artırıldı
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

  List<Map<String, dynamic>> _getSpreadsForCategory(String categoryKey) {
    final loc = S.of(context);
    switch (categoryKey) {
      case 'love':
        return [
          {
            'title': loc!.singleCard,
            'description': loc.singleCardDescription,
            'cardCount': 1,
            'event': () => DrawSingleCard(),
            'cost': SpreadType.singleCard.costInCredits,
          },
          {
            'title': loc.relationshipSpread,
            'description': loc.relationshipSpreadDescription,
            'cardCount': 7,
            'event': () => DrawRelationshipSpread(),
            'cost': SpreadType.relationshipSpread.costInCredits,
          },
          {
            'title': loc.brokenHeart,
            'description': loc.brokenHeartDescription,
            'cardCount': 5,
            'event': () => DrawBrokenHeart(),
            'cost': SpreadType.brokenHeart.costInCredits,
          },
          {
            'title': loc.pastPresentFuture,
            'description': loc.pastPresentFutureDescriptionLove,
            'cardCount': 3,
            'event': () => DrawPastPresentFuture(),
            'cost': SpreadType.pastPresentFuture.costInCredits,
          },
          {
            'title': loc.mindBodySpirit,
            'description': loc.mindBodySpiritDescriptionLove,
            'cardCount': 3,
            'event': () => DrawMindBodySpirit(),
            'cost': SpreadType.mindBodySpirit.costInCredits,
          },
          {
            'title': loc.fullMoonSpread,
            'description': loc.fullMoonSpreadDescriptionLove,
            'cardCount': 5,
            'event': () => DrawFullMoonSpread(),
            'cost': SpreadType.fullMoonSpread.costInCredits,
          },
        ];
      case 'career':
        return [
          {
            'title': loc!.singleCard,
            'description': loc.singleCardDescription,
            'cardCount': 1,
            'event': () => DrawSingleCard(),
            'cost': SpreadType.singleCard.costInCredits,
          },
          {
            'title': loc.pastPresentFuture,
            'description': loc.pastPresentFutureDescription,
            'cardCount': 3,
            'event': () => DrawPastPresentFuture(),
            'cost': SpreadType.pastPresentFuture.costInCredits,
          },
          {
            'title': loc.fiveCardPath,
            'description': loc.fiveCardPathDescription,
            'cardCount': 5,
            'event': () => DrawFiveCardPath(),
            'cost': SpreadType.fiveCardPath.costInCredits,
          },
          {
            'title': loc.careerPathSpread,
            'description': loc.careerPathSpreadDescription,
            'cardCount': 5,
            'event': () => DrawCareerPathSpread(),
            'cost': SpreadType.careerPathSpread.costInCredits,
          },
          {
            'title': loc.problemSolution,
            'description': loc.problemSolutionDescriptionCareer,
            'cardCount': 3,
            'event': () => DrawProblemSolution(),
            'cost': SpreadType.problemSolution.costInCredits,
          },
          {
            'title': loc.horseshoeSpread,
            'description': loc.horseshoeSpreadDescriptionCareer,
            'cardCount': 7,
            'event': () => DrawHorseshoeSpread(),
            'cost': SpreadType.horseshoeSpread.costInCredits,
          },
        ];
      case 'money':
        return [
          {
            'title': loc!.singleCard,
            'description': loc.singleCardDescription,
            'cardCount': 1,
            'event': () => DrawSingleCard(),
            'cost': SpreadType.singleCard.costInCredits,
          },
          {
            'title': loc.problemSolution,
            'description': loc.problemSolutionDescriptionMoney,
            'cardCount': 3,
            'event': () => DrawProblemSolution(),
            'cost': SpreadType.problemSolution.costInCredits,
          },
          {
            'title': loc.horseshoeSpread,
            'description': loc.horseshoeSpreadDescriptionMoney,
            'cardCount': 7,
            'event': () => DrawHorseshoeSpread(),
            'cost': SpreadType.horseshoeSpread.costInCredits,
          },
          {
            'title': loc.pastPresentFuture,
            'description': loc.pastPresentFutureDescriptionMoney,
            'cardCount': 3,
            'event': () => DrawPastPresentFuture(),
            'cost': SpreadType.pastPresentFuture.costInCredits,
          },
          {
            'title': loc.careerPathSpread,
            'description': loc.careerPathSpreadDescriptionMoney,
            'cardCount': 5,
            'event': () => DrawCareerPathSpread(),
            'cost': SpreadType.careerPathSpread.costInCredits,
          },
        ];
      case 'general':
        return [
          {
            'title': loc!.singleCard,
            'description': loc.singleCardDescription,
            'cardCount': 1,
            'event': () => DrawSingleCard(),
            'cost': SpreadType.singleCard.costInCredits,
          },
          {
            'title': loc.celticCrossReading,
            'description': loc.celticCrossDescription,
            'cardCount': 10,
            'event': () => DrawCelticCross(),
            'cost': SpreadType.celticCross.costInCredits,
          },
          {
            'title': loc.yearlySpreadReading,
            'description': loc.yearlySpreadDescription,
            'cardCount': 12,
            'event': () => DrawYearlySpread(),
            'cost': SpreadType.yearlySpread.costInCredits,
          },
          {
            'title': loc.astroLogicalCross,
            'description': loc.astroLogicalCrossDescriptionGeneral,
            'cardCount': 5,
            'event': () => DrawAstroLogicalCross(),
            'cost': SpreadType.astroLogicalCross.costInCredits,
          },
          {
            'title': loc.horseshoeSpread,
            'description': loc.horseshoeSpreadDescriptionGeneral,
            'cardCount': 7,
            'event': () => DrawHorseshoeSpread(),
            'cost': SpreadType.horseshoeSpread.costInCredits,
          },
          {
            'title': loc.pastPresentFuture,
            'description': loc.pastPresentFutureDescriptionGeneral,
            'cardCount': 3,
            'event': () => DrawPastPresentFuture(),
            'cost': SpreadType.pastPresentFuture.costInCredits,
          },
        ];
      case 'spiritual':
        return [
          {
            'title': loc!.singleCard,
            'description': loc.singleCardDescription,
            'cardCount': 1,
            'event': () => DrawSingleCard(),
            'cost': SpreadType.singleCard.costInCredits,
          },
          {
            'title': loc.mindBodySpirit,
            'description': loc.mindBodySpiritDescriptionSpiritual,
            'cardCount': 3,
            'event': () => DrawMindBodySpirit(),
            'cost': SpreadType.mindBodySpirit.costInCredits,
          },
          {
            'title': loc.dreamInterpretation,
            'description': loc.dreamInterpretationDescriptionSpiritual,
            'cardCount': 3,
            'event': () => DrawDreamInterpretation(),
            'cost': SpreadType.dreamInterpretation.costInCredits,
          },
          {
            'title': loc.fullMoonSpread,
            'description': loc.fullMoonSpreadDescriptionSpiritual,
            'cardCount': 5,
            'event': () => DrawFullMoonSpread(),
            'cost': SpreadType.fullMoonSpread.costInCredits,
          },
          {
            'title': loc.astroLogicalCross,
            'description': loc.astroLogicalCrossDescriptionSpiritual,
            'cardCount': 5,
            'event': () => DrawAstroLogicalCross(),
            'cost': SpreadType.astroLogicalCross.costInCredits,
          },
          {
            'title': loc.celticCrossReading,
            'description': loc.celticCrossDescriptionSpiritual,
            'cardCount': 10,
            'event': () => DrawCelticCross(),
            'cost': SpreadType.celticCross.costInCredits,
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
        Navigator.pop(context); // Kapat SpreadSelectionSheet
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
        constraints: BoxConstraints(
          minHeight: 130, // Hafif artırıldı
          maxWidth: MediaQuery.of(context).size.width * 0.85, // Ekranın %85'i ile dengeli
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple[700]!.withOpacity(0.7),
              Colors.deepPurple[900]!.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.purple[300]!.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.cinzel(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.purple[600],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    loc!.cardCount(cardCount),
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                description,
                style: GoogleFonts.cinzel(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple[800]!.withOpacity(0.9), // Daha farklı bir mor tonu
                  borderRadius: BorderRadius.circular(20), // Oval bir badge
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${cost.toStringAsFixed(1)} ${loc.mysticalTokens}',
                  style: GoogleFonts.cinzel(
                    color: Colors.white70, // Daha yumuşak bir renk
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
      child: const Icon(Icons.close, color: Colors.white, size: 24),
    ),
  );
}
