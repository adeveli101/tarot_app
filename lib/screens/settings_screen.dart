import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/generated/l10n.dart';
import '../data/payment_maganer.dart';
import '../data/tarot_event_state.dart';

class SettingsScreen extends StatefulWidget {
  final Function(Locale, BuildContext) onLocaleChange;
  final Locale currentLocale;

  const SettingsScreen({
    super.key,
    required this.onLocaleChange,
    required this.currentLocale,
  });

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool _isPurchasing = false;

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Lottie.asset(
          'assets/animations/tarot_shuffle.json',
          fit: BoxFit.cover,
          frameRate: FrameRate(24),
          repeat: true,
        ),
        Container(
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
        ),
      ],
    );
  }

  Widget _buildHeader(S loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          loc.settings,
          style: GoogleFonts.cinzel(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.purple[300]!.withOpacity(0.8),
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.white70),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Text(
                  loc.settings,
                  style: GoogleFonts.cinzel(color: Colors.white, fontSize: 20),
                ),
                content: Text(
                  loc.settingsHelp, // "Adjust your language and manage your mystical tokens here." localize
                  style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 14),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      loc.close,
                      style: GoogleFonts.cinzel(color: Colors.purple[300]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(BuildContext context, S loc) {
    return BlocBuilder<TarotBloc, TarotState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple[900]!.withOpacity(0.8),
                Colors.purple[700]!.withOpacity(0.6),
              ],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.profile,
                style: GoogleFonts.cinzel(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.mysticalTokens, // "Mystical Tokens" localize
                    style: GoogleFonts.cinzel(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    state.isPremium ? loc.premium : "${state.userTokens.toStringAsFixed(1)} ${loc.mysticalTokens}", // "Premium" ve "Tokens" localize
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.dailyFreeReadings, // "Daily Free Readings" localize
                    style: GoogleFonts.cinzel(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    state.isPremium ? loc.unlimited : "${state.dailyFreeFalCount}/3",
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageSettings(BuildContext context, S loc) {
    return _buildSection(
      title: loc.language, // "Language / Dil" localize
      children: [
        LanguageCard(
          language: loc.english,
          locale: const Locale('en'),
          isSelected: widget.currentLocale.languageCode == 'en',
          onTap: () {
            widget.onLocaleChange(const Locale('en'), context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc.languageChangedToEnglish)), // "Language changed to English" localize
            );
          },
        ),
        const SizedBox(height: 12),
        LanguageCard(
          language: loc.turkish,
          locale: const Locale('tr'),
          isSelected: widget.currentLocale.languageCode == 'tr',
          onTap: () {
            widget.onLocaleChange(const Locale('tr'), context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc.languageChangedToTurkish)), // "Dil Türkçe olarak değiştirildi" localize
            );
          },
        ),
      ],
    );
  }

  Widget _buildPurchaseOptions(BuildContext context, S loc) {
    return _buildSection(
      title: loc.purchaseCredits,
      children: [
        _buildPurchaseCard(
          context: context,
          title: loc.tenTokens, // "10 Tokens" localize
          onTap: () => _showPaymentDialog(context),
          isDisabled: _isPurchasing,
        ),
        const SizedBox(height: 12),
        _buildPurchaseCard(
          context: context,
          title: loc.fiftyTokens, // "50 Tokens" localize
          onTap: () => _showPaymentDialog(context),
          isDisabled: _isPurchasing,
        ),
        const SizedBox(height: 12),
        _buildPurchaseCard(
          context: context,
          title: loc.hundredTokens, // "100 Tokens" localize
          onTap: () => _showPaymentDialog(context),
          isDisabled: _isPurchasing,
        ),
        const SizedBox(height: 12),
        _buildPurchaseCard(
          context: context,
          title: loc.premiumSubscription, // "Premium Subscription" localize
          onTap: () => _showPaymentDialog(context),
          isDisabled: _isPurchasing,
        ),
      ],
    );
  }

  void _showPaymentDialog(BuildContext context) {
    final loc = S.of(context);

    setState(() => _isPurchasing = true);
    PaymentManager.showPaymentDialog(
      context,
      requiredTokens: 0.0, // Ayarlar ekranında belirli bir gereksinim yok, genel satın alma için 0
      onSuccess: () {
        setState(() => _isPurchasing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc!.couponRedeemed(loc.redeem))), // "Purchase completed successfully" localize
        );
      },
    ).then((_) => setState(() => _isPurchasing = false));
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cinzel(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.purple[300]!.withOpacity(0.5),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                  vertical: MediaQuery.of(context).size.height * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(loc!),
                    const SizedBox(height: 20),
                    _buildUserInfoCard(context, loc),
                    const SizedBox(height: 20),
                    _buildLanguageSettings(context, loc),
                    const SizedBox(height: 20),
                    _buildPurchaseOptions(context, loc),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseCard({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
    required bool isDisabled,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDisabled ? Colors.grey[700]! : Colors.deepPurple[900]!.withOpacity(0.8),
              isDisabled ? Colors.grey[900]! : Colors.purple[700]!.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            Text(
              '', // Fiyat bilgisi PaymentDialog içinde gösterilecek
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
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