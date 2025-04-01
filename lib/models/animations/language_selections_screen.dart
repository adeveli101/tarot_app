import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarot_fal/models/animations/tap_animations_scale.dart';

import '../../screens/tarot_fortune_reading_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final Future<void> Function(Locale, BuildContext) onLocaleSelected;

  const LanguageSelectionScreen({super.key, required this.onLocaleSelected});

  @override
  Widget build(BuildContext context) {
    // Sabit değerler için değişkenler
    const double buttonPaddingHorizontal = 40.0;
    const double buttonPaddingVertical = 20.0;
    const double spacingBetweenButtons = 20.0;
    const double titleSpacing = 40.0;

    void navigateToHome(Locale locale) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => TarotReadingScreen(
            onSettingsTap: () {}, // Boş bir fonksiyon ile hata önlendi
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Select your language / Dilinizi seçin',
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: titleSpacing),
            TapAnimatedScale(
              onTap: () async {
                await onLocaleSelected(const Locale('en'), context);
                navigateToHome(const Locale('en'));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: buttonPaddingHorizontal,
                  vertical: buttonPaddingVertical,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple[700]!, Colors.deepPurple[900]!],
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
                child: Text(
                  'English',
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: spacingBetweenButtons),
            TapAnimatedScale(
              onTap: () async {
                await onLocaleSelected(const Locale('tr'), context);
                navigateToHome(const Locale('tr'));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: buttonPaddingHorizontal,
                  vertical: buttonPaddingVertical,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple[700]!, Colors.deepPurple[900]!],
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
                child: Text(
                  'Türkçe',
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    color: Colors.white,
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