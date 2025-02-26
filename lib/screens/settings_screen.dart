import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/generated/l10n.dart';

class SettingsScreen extends StatelessWidget {
  final Function(Locale, BuildContext) onLocaleChange;
  final Locale currentLocale;

  const SettingsScreen({
    super.key,
    required this.onLocaleChange,
    required this.currentLocale,
  });

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Lottie.asset(
          'assets/animations/tarot_shuffle.json',
          fit: BoxFit.contain,
          frameRate: FrameRate(24),
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
              Colors.purple[200]!.withOpacity(0.2),
              Colors.transparent,
              Colors.indigo[300]!.withOpacity(0.2),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05)),
          ),
        ),
      ],
    );
  }

  Widget _buildCreditInfo(BuildContext context) {
    final bloc = context.watch<TarotBloc>();
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple[900]!.withOpacity(0.6),
              Colors.purple[700]!.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple[300]!.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Credits",
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              bloc.isPremium ? "Premium" : "${bloc.userCredits.toStringAsFixed(1)} Credits",
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc!.tarotFortune, style: GoogleFonts.cinzel(color: Colors.white, fontSize: 24)),
        backgroundColor: Colors.deepPurple[900],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.black87,
                  title: Text(loc.tarotFortune, style: const TextStyle(color: Colors.white)),
                  content: Text("Adjust settings like language and credits here.", style: const TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(loc.close, style: const TextStyle(color: Colors.deepPurple)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCreditInfo(context),
                  const SizedBox(height: 20),
                  Text(
                    'Language / Dil',
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LanguageCard(
                    language: 'English',
                    locale: const Locale('en'),
                    isSelected: currentLocale.languageCode == 'en',
                    onTap: () {
                      onLocaleChange(const Locale('en'), context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Language changed to English")),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  LanguageCard(
                    language: 'Türkçe',
                    locale: const Locale('tr'),
                    isSelected: currentLocale.languageCode == 'tr',
                    onTap: () {
                      onLocaleChange(const Locale('tr'), context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Dil Türkçe olarak değiştirildi")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageCard extends StatelessWidget {
  final String language;
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageCard({
    super.key,
    required this.language,
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple[900]!.withOpacity(0.6),
              Colors.purple[700]!.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.purple[300]!.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language,
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}