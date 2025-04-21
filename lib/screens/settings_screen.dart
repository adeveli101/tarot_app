// lib/screens/settings_screen.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart'; // Lottie importu eklendi (arka plan için)
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/generated/l10n.dart'; // Yerelleştirme
import 'package:tarot_fal/data/payment_manager.dart'; // PaymentManager importu
import 'package:tarot_fal/data/tarot_event_state.dart'; // TarotState için
import 'package:tarot_fal/models/animations/tap_animations_scale.dart'; // TapAnimatedScale için

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
  // Arka plan widget'ı (diğer ekranlarla tutarlı)
  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Arka plan resmi
        Image.asset(
          'assets/image_fx_c.jpg', // Arka plan resminizin yolu
          fit: BoxFit.cover,
          gaplessPlayback: true, // Resim yüklenirken boşluk olmasın
        ),
        // Lottie animasyonu (isteğe bağlı, performansa dikkat)
        Lottie.asset(
          'assets/animations/tarot_shuffle.json', // Animasyon dosyanızın yolu
          fit: BoxFit.cover,
          frameRate: FrameRate(24), // Daha düşük frame rate performans artırabilir
          repeat: true,
        ),
        // Gradient katmanı (görünürlüğü artırmak için)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple[900]!.withOpacity(0.6), // Daha az opaklık
                Colors.black.withOpacity(0.85), // Daha fazla opaklık
              ],
              stops: const [0.0, 0.8], // Gradient durakları
            ),
          ),
        ),
      ],
    );
  }

  // Özel AppBar widget'ı
  Widget _buildAppBar(BuildContext context, S loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Geri Butonu (isteğe bağlı, genellikle Navigator.pop kullanılır)
          // IconButton(
          //   icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          //   onPressed: () => Navigator.pop(context),
          // ),
          // Başlık
          Padding(
            padding: const EdgeInsets.only(left: 16.0), // Sol boşluk
            child: Text(
              loc.settings, // Yerelleştirilmiş başlık
              style: GoogleFonts.cinzelDecorative( // Özel font
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [ // Gölge efekti
                  Shadow(
                    color: Colors.purpleAccent.withOpacity(0.5),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          // Kapatma Butonu
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70, size: 24),
            tooltip: loc.close, // Yerelleştirilmiş tooltip
            onPressed: () => Navigator.pop(context), // Geri git
          ),
        ],
      ),
    );
  }

  // Kullanıcı Kredi Bilgisi Bölümü
  Widget _buildUserInfoSection(BuildContext context, S loc) {
    return BlocBuilder<TarotBloc, TarotState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 10.0), // Üst ve alt boşluk
          decoration: BoxDecoration(
            gradient: LinearGradient( // Arka plan gradient'i
              colors: [
                Colors.purple[800]!.withOpacity(0.7),
                Colors.indigo[900]!.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15), // Yuvarlak kenarlar
            border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)), // Çerçeve
            boxShadow: [ // Gölge
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // İki yana yasla
            children: [
              Row( // İkon ve metin grubu
                children: [
                  Icon(Icons.stars_rounded, color: Colors.yellowAccent[100], size: 24), // İkon
                  const SizedBox(width: 12),
                  Text(
                    loc.mysticalTokens, // Yerelleştirilmiş metin
                    style: GoogleFonts.cinzel( // Font
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // Kredi miktarı
              Text(
                state.userTokens.toStringAsFixed(1), // Ondalıklı gösterim
                style: GoogleFonts.orbitron( // Özel font
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [ // Hafif parlama efekti
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

  // Dil Seçimi Bölümü
  Widget _buildLanguageSection(BuildContext context, S loc) {
    return _buildSectionContainer( // Ortak container yapısı
      title: loc.language, // Bölüm başlığı
      icon: Icons.language, // Bölüm ikonu
      children: [
        // İngilizce Dil Kartı
        LanguageCard(
          language: loc.english, // Dil adı
          locale: const Locale('en'), // Dil kodu
          isSelected: widget.currentLocale.languageCode == 'en', // Seçili mi?
          onTap: () { // Tıklama olayı
            widget.onLocaleChange(const Locale('en'), context);
            // Kullanıcıya geri bildirim (isteğe bağlı)
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(content: Text(loc.languageChangedToEnglish)),
            // );
          },
        ),
        const SizedBox(height: 12), // Kartlar arası boşluk
        // Türkçe Dil Kartı
        LanguageCard(
          language: loc.turkish,
          locale: const Locale('tr'),
          isSelected: widget.currentLocale.languageCode == 'tr',
          onTap: () {
            widget.onLocaleChange(const Locale('tr'), context);
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(content: Text(loc.languageChangedToTurkish)),
            // );
          },
        ),
      ],
    );
  }

  // Kredi Satın Alma Bölümü
  Widget _buildPurchaseSection(BuildContext context, S loc) {
    return _buildSectionContainer( // Ortak container yapısı
      title: loc.purchaseCredits, // Bölüm başlığı
      icon: Icons.add_shopping_cart, // Bölüm ikonu
      children: [
        // Kredi Satın Alma Kartları (Örnekler - Kendi ürün ID'lerinize göre ayarlayın)
        _buildPurchaseCard(
          context: context,
          title: loc.tenTokens, // TODO: Yerelleştirme anahtarı ekleyin (örn: 25 Kredi)
          icon: Icons.star_outline, // İkon
          onTap: () => PaymentManager.showPaymentDialog(context), // Ödeme dialogunu aç
        ),
        const SizedBox(height: 12),
        _buildPurchaseCard(
          context: context,
          title: loc.fiftyTokens, // TODO: Yerelleştirme anahtarı ekleyin (örn: 50 Kredi)
          icon: Icons.star_half_outlined,
          onTap: () => PaymentManager.showPaymentDialog(context),
        ),
        const SizedBox(height: 12),
        _buildPurchaseCard(
          context: context,
          title: loc.hundredTokens, // TODO: Yerelleştirme anahtarı ekleyin (örn: 150 Kredi)
          icon: Icons.star,
          onTap: () => PaymentManager.showPaymentDialog(context),
        ),
        // --- PREMIUM KARTI KALDIRILDI ---
        // const SizedBox(height: 12),
        // _buildPurchaseCard(
        //   context: context,
        //   title: loc.premiumSubscription, // KALDIRILDI
        //   icon: Icons.workspace_premium_outlined,
        //   onTap: () => PaymentManager.showPaymentDialog(context),
        // ),
      ],
    );
  }

  // Ortak Bölüm Container Widget'ı (Başlık ve Çocuklar için)
  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25.0), // Bölümler arası boşluk
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2), // Hafif transparan arka plan
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.purpleAccent.withOpacity(0.2))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bölüm Başlığı
          Row(
            children: [
              Icon(icon, color: Colors.purpleAccent[100], size: 22), // Başlık ikonu
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.cinzel( // Font
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          Divider(color: Colors.purpleAccent.withOpacity(0.2), height: 25, thickness: 1), // Ayırıcı
          // Bölüm İçeriği (Kartlar vb.)
          ...children,
        ],
      ),
    );
  }

  // Tek bir satın alma seçeneği kartını oluşturan yardımcı widget
  Widget _buildPurchaseCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TapAnimatedScale( // Tıklama animasyonu
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration( // Stil
          gradient: LinearGradient( // Gradient arka plan
            colors: [
              Colors.deepPurple[900]!.withOpacity(0.7),
              Colors.purple[800]!.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12), // Yuvarlak kenarlar
          border: Border.all(color: Colors.purple.shade400.withOpacity(0.4)), // Çerçeve
          boxShadow: [ // Gölge
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row( // İkon, Metin, Ok
          children: [
            Icon(icon, color: Colors.yellowAccent.shade100, size: 20), // İkon
            const SizedBox(width: 12),
            Expanded( // Metnin taşmasını engelle
              child: Text(
                title,
                style: GoogleFonts.lato( // Font
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16), // İleri oku
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context); // Yerelleştirme nesnesi

    return Scaffold(
      // Scaffold arka planını şeffaf yapıp Stack içindeki arka planı kullan
      backgroundColor: Colors.black, // Veya transparan yapabilirsiniz
      extendBodyBehindAppBar: true, // AppBar arkasına içeriği uzat
      appBar: AppBar( // Basit, transparan AppBar
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Otomatik geri butonunu kaldır
        flexibleSpace: ClipRect( // Arka plan blur efekti için
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),
        ),
        title: _buildAppBar(context, loc!), // Özel AppBar içeriği
        toolbarHeight: 70, // AppBar yüksekliği
      ),
      body: Stack( // Arka plan ve içerik için Stack
        children: [
          _buildBackground(), // Arka planı çiz
          SafeArea( // İçeriği güvenli alana yerleştir
            child: SingleChildScrollView( // Kaydırılabilir içerik
              physics: const BouncingScrollPhysics(), // Güzel kaydırma efekti
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0), // İç boşluklar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Çocukları yatayda genişlet
                  children: [
                    _buildUserInfoSection(context, loc), // Kullanıcı bilgisi bölümü
                    _buildLanguageSection(context, loc), // Dil seçimi bölümü
                    _buildPurchaseSection(context, loc), // Satın alma bölümü
                    // TODO: İsteğe bağlı olarak buraya başka ayar bölümleri eklenebilir
                    // (örn: Gizlilik Politikası, Hakkında, Uygulamayı Değerlendir)
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
// (Dil seçimi için kullanılan kart widget'ı - önceki koddan alındı, stil iyileştirilebilir)
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
    return TapAnimatedScale( // Tıklama animasyonu
      onTap: onTap,
      child: AnimatedContainer( // Seçim durumuna göre animasyonlu geçiş
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient( // Arka plan gradient'i
            colors: isSelected // Seçiliyse farklı renkler
                ? [Colors.green.shade700.withOpacity(0.8), Colors.green.shade900.withOpacity(0.9)]
                : [Colors.deepPurple[900]!.withOpacity(0.7), Colors.purple[800]!.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12), // Yuvarlak kenarlar
          border: Border.all( // Çerçeve (seçiliyse daha belirgin)
            color: isSelected ? Colors.lightGreenAccent.shade100 : Colors.purple.shade400.withOpacity(0.4),
            width: isSelected ? 2.5 : 1.5, // Seçiliyse daha kalın çerçeve
          ),
          boxShadow: [ // Gölge
            BoxShadow(
              color: isSelected ? Colors.green.withOpacity(0.3) : Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // İki yana yasla
          children: [
            // Dil Adı
            Row(
              children: [
                // Bayrak ikonu (isteğe bağlı)
                // Image.asset('assets/flags/${locale.languageCode}.png', width: 24, height: 24),
                // const SizedBox(width: 12),
                Text(
                  language,
                  style: GoogleFonts.lato( // Font
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 16, // Biraz daha büyük font
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Seçili ise onay ikonu
            if (isSelected)
              Icon(
                Icons.check_circle, // Onay ikonu
                color: Colors.lightGreenAccent.shade100, // İkon rengi
                size: 24, // İkon boyutu
                shadows: [ // İkona hafif parlama
                  Shadow(color: Colors.white.withOpacity(0.5), blurRadius: 4)
                ],
              )
            else // Seçili değilse boş ikon (yer tutucu)
              const Icon(Icons.circle_outlined, color: Colors.white30, size: 24),
          ],
        ),
      ),
    );
  }
}