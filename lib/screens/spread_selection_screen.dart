//---------- SpreadSelectionSheet Başlangıcı ----------
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart'; // CardSelection için eklendi
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart'; // CardSelection için eklendi

// Projenizin doğru import yolları ile değiştirin
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/screens/profile_page.dart'; // ProfilePage importu
import 'package:tarot_fal/data/payment_manager.dart'; // PaymentManager importu
import 'package:tarot_fal/data/tarot_event_state.dart';
import 'package:tarot_fal/models/animations/tap_animations_scale.dart';
import 'package:tarot_fal/models/tarot_card.dart'; // CardSelection için eklendi
import 'package:tarot_fal/data/tarot_repository.dart'; // CardSelection için eklendi
import 'package:tarot_fal/screens/reading_result.dart';

import 'card_selection_animation.dart';
import 'category_selection_sheet.dart'; // ReadingResultScreen importu


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
    final spreads = _getSpreadsForCategory(widget.categoryKey, context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9, width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient( colors: [Colors.deepPurple[900]!, Colors.black.withOpacity(0.95)], begin: Alignment.topCenter, end: Alignment.bottomCenter,),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),),
      child: Stack( children: [
        CustomScrollView( slivers: [
          SliverPadding( padding: const EdgeInsets.only(top: 20), sliver: SliverToBoxAdapter( child: _buildSheetHeader(loc!.spreadSelection, loc.chooseSpread),),),
          SliverPadding( padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            sliver: SliverList( delegate: SliverChildBuilderDelegate( (context, index) {
              if (index >= spreads.length) return null; final spreadData = spreads[index];
              return Padding( padding: const EdgeInsets.only(bottom: 14),
                child: _buildSpreadTile( context: context, title: spreadData['title'], description: spreadData['description'], spreadType: spreadData['spreadType'], categoryKey: widget.categoryKey,),);},
              childCount: spreads.length,),),),
          const SliverToBoxAdapter( child: SizedBox(height: 60),),],),
        Positioned( top: 60, right: 12, child: _buildCloseButton(context),),
      ],),);
  }

  Widget _buildSheetHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.cinzelDecorative(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
              decoration: TextDecoration.none, // <-- EKLENDİ
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontSize: 15,
              color: Colors.white.withOpacity(0.7),
              decoration: TextDecoration.none, // <-- ZATEN VARDI/EKLENDİ
            ),
          ),
          Divider(color: Colors.purpleAccent.withOpacity(0.2), height: 30, thickness: 1),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getSpreadsForCategory(String categoryKey, BuildContext context) {
    final loc = S.of(context);
    switch (categoryKey) {
      case 'love': return [ {'title': loc!.singleCard, 'description': loc.singleCardDescription,
        'spreadType': SpreadType.singleCard}, {'title': loc.relationshipSpread,
        'description': loc.relationshipSpreadDescription, 'spreadType': SpreadType.relationshipSpread},
        {'title': loc.brokenHeart, 'description': loc.brokenHeartDescription,
          'spreadType': SpreadType.brokenHeart}, {'title': loc.pastPresentFuture,
          'description': loc.pastPresentFutureDescriptionLove, 'spreadType': SpreadType.pastPresentFuture},
        {'title': loc.mindBodySpirit, 'description': loc.mindBodySpiritDescriptionLove,
          'spreadType': SpreadType.mindBodySpirit}, {'title': loc.fullMoonSpread, 'description': loc.fullMoonSpreadDescriptionLove, 'spreadType': SpreadType.fullMoonSpread},];
      case 'career': return [ {'title': loc!.singleCard, 'description': loc.singleCardDescription, 'spreadType': SpreadType.singleCard}, {'title': loc.pastPresentFuture, 'description': loc.pastPresentFutureDescription, 'spreadType': SpreadType.pastPresentFuture}, {'title': loc.fiveCardPath, 'description': loc.fiveCardPathDescription, 'spreadType': SpreadType.fiveCardPath}, {'title': loc.careerPathSpread, 'description': loc.careerPathSpreadDescription, 'spreadType': SpreadType.careerPathSpread}, {'title': loc.problemSolution, 'description': loc.problemSolutionDescriptionCareer, 'spreadType': SpreadType.problemSolution}, {'title': loc.horseshoeSpread, 'description': loc.horseshoeSpreadDescriptionCareer, 'spreadType': SpreadType.horseshoeSpread},];
      case 'money': return [ {'title': loc!.singleCard, 'description': loc.singleCardDescription, 'spreadType': SpreadType.singleCard}, {'title': loc.problemSolution, 'description': loc.problemSolutionDescriptionMoney, 'spreadType': SpreadType.problemSolution}, {'title': loc.horseshoeSpread, 'description': loc.horseshoeSpreadDescriptionMoney, 'spreadType': SpreadType.horseshoeSpread}, {'title': loc.pastPresentFuture, 'description': loc.pastPresentFutureDescriptionMoney, 'spreadType': SpreadType.pastPresentFuture}, {'title': loc.careerPathSpread, 'description': loc.careerPathSpreadDescriptionMoney, 'spreadType': SpreadType.careerPathSpread},];
      case 'general': return [ {'title': loc!.singleCard, 'description': loc.singleCardDescription, 'spreadType': SpreadType.singleCard}, {'title': loc.celticCrossReading, 'description': loc.celticCrossDescription, 'spreadType': SpreadType.celticCross}, {'title': loc.yearlySpreadReading, 'description': loc.yearlySpreadDescription, 'spreadType': SpreadType.yearlySpread}, {'title': loc.astroLogicalCross, 'description': loc.astroLogicalCrossDescriptionGeneral, 'spreadType': SpreadType.astroLogicalCross}, {'title': loc.horseshoeSpread, 'description': loc.horseshoeSpreadDescriptionGeneral, 'spreadType': SpreadType.horseshoeSpread}, {'title': loc.pastPresentFuture, 'description': loc.pastPresentFutureDescriptionGeneral, 'spreadType': SpreadType.pastPresentFuture},];
      case 'spiritual': return [ {'title': loc!.singleCard, 'description': loc.singleCardDescription, 'spreadType': SpreadType.singleCard}, {'title': loc.mindBodySpirit, 'description': loc.mindBodySpiritDescriptionSpiritual, 'spreadType': SpreadType.mindBodySpirit}, {'title': loc.dreamInterpretation, 'description': loc.dreamInterpretationDescriptionSpiritual, 'spreadType': SpreadType.dreamInterpretation}, {'title': loc.fullMoonSpread, 'description': loc.fullMoonSpreadDescriptionSpiritual, 'spreadType': SpreadType.fullMoonSpread}, {'title': loc.astroLogicalCross, 'description': loc.astroLogicalCrossDescriptionSpiritual, 'spreadType': SpreadType.astroLogicalCross}, {'title': loc.celticCrossReading, 'description': loc.celticCrossDescriptionSpiritual, 'spreadType': SpreadType.celticCross},];
      default: return [];
    }
  }

  Widget _buildSpreadTile({
    required BuildContext context,
    required String title,
    required String description,
    required SpreadType spreadType,
    required String categoryKey,
  }) {
    final loc = S.of(context);
    final int cardCount = spreadType.cardCount;
    final double cost = spreadType.costInCredits;

    return TapAnimatedScale(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<TarotBloc>(),
              child: CardSelectionAnimationScreen(
                spreadType: spreadType,
                categoryKey: categoryKey,
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple[800]!.withOpacity(0.5),
              Colors.indigo[900]!.withOpacity(0.6),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.purpleAccent.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.cinzel(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      decoration: TextDecoration.none, // <-- EKLENDİ
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    loc!.cardCount(cardCount),
                    style: GoogleFonts.cinzel(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none, // <-- EKLENDİ
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.cabin(
                fontSize: 13,
                color: Colors.white.withOpacity(0.7),
                height: 1.3,
                decoration: TextDecoration.none, // <-- EKLENDİ
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.yellowAccent.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars_rounded, color: Colors.yellowAccent[100], size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${cost.toStringAsFixed(1)} ${loc.mysticalTokens}',
                      style: GoogleFonts.cabin(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none, // <-- EKLENDİ
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector( onTap: () => Navigator.pop(context),
      child: Container( padding: const EdgeInsets.all(8),
        decoration: BoxDecoration( shape: BoxShape.circle, color: Colors.black.withOpacity(0.5), boxShadow: [ BoxShadow( color: Colors.purple[300]!.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2), ), ],),
        child: const Icon(Icons.close, color: Colors.white70, size: 22),),);
  }
}