// lib/screens/settings_screen.dart

import 'dart:ui'; // BackdropFilter için

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart'; // Lottie
// ProductDetails importu artık burada gerekmeyebilir
// import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/generated/l10n.dart'; // Yerelleştirme
import 'package:tarot_fal/data/payment_manager.dart'; // PaymentManager importu
import 'package:tarot_fal/data/tarot_event_state.dart'; // TarotState için
import 'package:tarot_fal/models/animations/tap_animations_scale.dart'; // TapAnimatedScale için
// Intl importu artık burada gerekmeyebilir
// import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  final Function(Locale, BuildContext) onLocaleChange; // Dil değiştirme callback'i
  final Locale currentLocale; // Mevcut seçili dil

  const SettingsScreen({
    super.key,
    required this.onLocaleChange,
    required this.currentLocale,
  });

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  // --- PaymentManager instance'ı BURADAN KALDIRILDI ---
  // late PaymentManager _paymentManager; // Kaldırıldı

  @override
  void initState() {
    super.initState();
    // --- PaymentManager başlatma BURADAN KALDIRILDI ---
    // _paymentManager = PaymentManager(); // Kaldırıldı
    // _paymentManager.initialize(); // Kaldırıldı
  }

  @override
  void dispose() {
    // --- PaymentManager dispose BURADAN KALDIRILDI ---
    // _paymentManager.dispose(); // Kaldırıldı
    super.dispose();
  }

  // Arka plan widget'ı (diğer ekranlarla tutarlı)
  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Arka plan gradient ve Lottie animasyonu... (Aynı kalır)
        Image.asset( 'assets/image_fx_c.jpg', fit: BoxFit.cover, gaplessPlayback: true,),
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
                Colors.deepPurple[900]!.withOpacity(0.6),
                Colors.black.withOpacity(0.85),
              ],
              stops: const [0.0, 0.8],
            ),
          ),
        ),
      ],
    );
  }

  // Özel AppBar widget'ı (Aynı kalır)
  PreferredSizeWidget _buildAppBar(BuildContext context, S loc) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text(
        loc.settings,
        style: GoogleFonts.cinzelDecorative(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white70, size: 24),
          tooltip: loc.close,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: Colors.black.withOpacity(0.1)),
        ),
      ),
    );
  }

  // Kullanıcı Kredi Bilgisi Bölümü (Aynı kalır)
  Widget _buildUserInfoSection(BuildContext context, S loc) {
    return BlocBuilder<TarotBloc, TarotState>(
      builder: (context, state) {
        final String tokenText = state.userTokens.truncateToDouble() == state.userTokens
            ? state.userTokens.toInt().toString()
            : state.userTokens.toStringAsFixed(1);

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          margin: const EdgeInsets.only(bottom: 25.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple[800]!.withOpacity(0.7),
                Colors.indigo[900]!.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.stars_rounded, color: Colors.yellowAccent[100], size: 24),
                  const SizedBox(width: 12),
                  Text(
                    loc.mysticalTokens,
                    style: GoogleFonts.cinzel(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                tokenText,
                style: GoogleFonts.orbitron(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(color: Colors.yellowAccent.withOpacity(0.5), blurRadius: 5)
                    ]
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Dil Seçimi Bölümü (Aynı kalır)
  Widget _buildLanguageSection(BuildContext context, S loc) {
    return _buildSectionContainer(
      title: loc.language,
      icon: Icons.language,
      children: [
        LanguageCard(
          language: loc.english,
          locale: const Locale('en'),
          isSelected: widget.currentLocale.languageCode == 'en',
          onTap: () => widget.onLocaleChange(const Locale('en'), context),
        ),
        const SizedBox(height: 12),
        LanguageCard(
          language: loc.turkish,
          locale: const Locale('tr'),
          isSelected: widget.currentLocale.languageCode == 'tr',
          onTap: () => widget.onLocaleChange(const Locale('tr'), context),
        ),
      ],
    );
  }

  // --- DEĞİŞTİRİLDİ: Kredi Satın Alma Bölümü ---
  Widget _buildPurchaseSection(BuildContext context, S loc) {
    return _buildSectionContainer(
      title: loc.mysticalTokens,
      icon: Icons.add_shopping_cart,
      children: [
        // Ürün listesi yerine tek bir buton/kart göster
        TapAnimatedScale(
          onTap: () {
            // PaymentManager'daki static metodu çağırarak dialogu aç
            PaymentManager.showPaymentDialog(
              context,
              // Gerekirse onSuccess callback'i eklenebilir:
              // onSuccess: () {
              //   // Satın alma başarılı olduktan sonra yapılacaklar
              //   // (Örneğin Bloc state'ini yenilemek)
              //   BlocProvider.of<TarotBloc>(context).add(FetchUserData()); // Örnek event
              // }
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple[900]!.withOpacity(0.7),
                  Colors.purple[800]!.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade400.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // İkon ve Metin
                Row(
                  children: [
                    Icon(Icons.stars_rounded, color: Colors.yellowAccent.shade100, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      loc.purchaseCredits, // "Kredi Paketlerini Görüntüle" gibi bir metin
                      style: GoogleFonts.cabin(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
                // Ok ikonu
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
  // --- Kredi Satın Alma Bölümü Değişikliği Sonu ---

  // Ortak Bölüm Container Widget'ı (Aynı kalır)
  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.purpleAccent.withOpacity(0.2))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.purpleAccent[100], size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          Divider(color: Colors.purpleAccent.withOpacity(0.2), height: 25, thickness: 1),
          ...children,
        ],
      ),
    );
  }

  // --- _buildPurchaseCard METODU BURADAN KALDIRILDI ---
  // Bu metoda artık settings_screen içinde ihtiyaç yok.

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context); // Null check kaldırıldı, initState sonrası context garantili

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, loc!), // Null check kaldırıldı
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0)
                    .copyWith(top: 20.0, bottom: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildUserInfoSection(context, loc), // Null check kaldırıldı
                    _buildLanguageSection(context, loc), // Null check kaldırıldı
                    _buildPurchaseSection(context, loc), // Güncellenmiş bölüm
                    // İsteğe bağlı: Diğer ayarlar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- LanguageCard Widget ----
// (Aynı kalır)
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
    return TapAnimatedScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [Colors.green.shade700.withOpacity(0.8), Colors.green.shade900.withOpacity(0.9)]
                : [Colors.deepPurple[900]!.withOpacity(0.7), Colors.purple[800]!.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.lightGreenAccent.shade100 : Colors.purple.shade400.withOpacity(0.4),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? Colors.green.withOpacity(0.3) : Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language,
              style: GoogleFonts.cabin(
                color: Colors.white.withOpacity(0.95),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.lightGreenAccent.shade100,
                size: 24,
                shadows: [
                  Shadow(color: Colors.white.withOpacity(0.5), blurRadius: 4)
                ],
              )
            else
              const Icon(Icons.circle_outlined, color: Colors.white30, size: 24),
          ],
        ),
      ),
    );
  }
}