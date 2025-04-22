//---------- CategorySelectionSheet Başlangıcı ----------

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
import 'package:tarot_fal/screens/spread_selection_screen.dart';
import 'package:tarot_fal/screens/tarot_fortune_reading_screen.dart';

import 'card_selection_animation.dart'; // ReadingResultScreen importu


class CategorySelectionSheet extends StatelessWidget {
  const CategorySelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.85, minChildSize: 0.4, maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
            gradient: LinearGradient( colors: [Colors.deepPurple[900]!, Colors.black87], begin: Alignment.topLeft, end: Alignment.bottomRight,),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)), border: Border.all(color: Colors.purpleAccent.withOpacity(0.2))),
        child: Stack( children: [
          Column( children: [
            _buildSheetHeader(context, loc!.categorySelection, loc.chooseTopic),
            Expanded( child: ListView( controller: scrollController, padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 10),
              children: [
                _buildCategoryTile( context: context, title: loc.loveRelationships, description: loc.loveDescription, icon: Icons.favorite_border, categoryKey: 'love',), const SizedBox(height: 14),
                _buildCategoryTile( context: context, title: loc.career, description: loc.careerDescription, icon: Icons.business_center_outlined, categoryKey: 'career',), const SizedBox(height: 14),
                _buildCategoryTile( context: context, title: loc.money, description: loc.moneyDescription, icon: Icons.monetization_on_outlined, categoryKey: 'money',), const SizedBox(height: 14),
                _buildCategoryTile( context: context, title: loc.general, description: loc.generalDescription, icon: Icons.lightbulb_outline, categoryKey: 'general',), const SizedBox(height: 14),
                _buildCategoryTile( context: context, title: loc.spiritualMystical, description: loc.spiritualMysticalDescription, icon: Icons.auto_awesome_outlined, categoryKey: 'spiritual',), const SizedBox(height: 30),
              ],),),],),
          Positioned( top: 12, right: 12, child: _buildCloseButton(context),),
        ],),),);
  }

  Widget _buildSheetHeader(BuildContext context, String title, String subtitle) {
    return Container( padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
      child: Column( mainAxisSize: MainAxisSize.min,
        children: [
          Container( width: 50, height: 5, decoration: BoxDecoration( color: Colors.white.withOpacity(0.4), borderRadius: BorderRadius.circular(2.5),),), const SizedBox(height: 20),
          Text( title, style: GoogleFonts.cinzelDecorative( fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5,),), const SizedBox(height: 8),
          Text( subtitle, textAlign: TextAlign.center, style: GoogleFonts.cinzel( fontSize: 15, color: Colors.white.withOpacity(0.7),),),
          Divider(color: Colors.purpleAccent.withOpacity(0.2), height: 30, thickness: 1),
        ],),);
  }

  Widget _buildCategoryTile({ required BuildContext context, required String title, required String description, required IconData icon, required String categoryKey,}) {
    return TapAnimatedScale(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push( context, MaterialPageRoute( builder: (_) => BlocProvider.value( value: context.read<TarotBloc>(), child: SpreadSelectionSheet(categoryKey: categoryKey),)),);
      },
      child: Container( padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration( gradient: LinearGradient( colors: [ Colors.purple[800]!.withOpacity(0.5), Colors.indigo[900]!.withOpacity(0.6),], begin: Alignment.centerLeft, end: Alignment.centerRight,),
            borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.purpleAccent.withOpacity(0.3), width: 1), boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, offset: Offset(0, 2)) ]),
        child: Row( children: [
          Container( padding: const EdgeInsets.all(10), decoration: BoxDecoration( color: Colors.purpleAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.amber[300], size: 26),), const SizedBox(width: 16),
          Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text( title, style: GoogleFonts.cinzel( fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white,),), const SizedBox(height: 6),
              Text( description, style: GoogleFonts.lato( fontSize: 13, color: Colors.white.withOpacity(0.7), height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis,),
            ],),), const SizedBox(width: 10),
          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.5), size: 18)
        ],),),);
  }

  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector( onTap: () => Navigator.pop(context),
      child: Container( padding: const EdgeInsets.all(8),
        decoration: BoxDecoration( shape: BoxShape.circle, color: Colors.black.withOpacity(0.5), boxShadow: [ BoxShadow( color: Colors.purple[300]!.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2), ), ],),
        child: const Icon(Icons.close, color: Colors.white70, size: 22),),);
  }
}

//---------- CategorySelectionSheet Sonu ----------

