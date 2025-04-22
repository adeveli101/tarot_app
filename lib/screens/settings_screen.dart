// lib/screens/settings_screen.dart

import 'dart:ui'; // BackdropFilter için

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart'; // Lottie eklendi
import 'package:in_app_purchase/in_app_purchase.dart'; // ProductDetails için eklendi

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
  // PaymentManager'ı state içinde yönet
  late PaymentManager _paymentManager;

  @override
  void initState() {
    super.initState();
    _paymentManager = PaymentManager();
    _paymentManager.initialize(); // Satın alma akışını dinlemeye başla
  }

  @override
  void dispose() {
    _paymentManager.dispose(); // Kaynakları serbest bırak
    super.dispose();
  }

  // Arka plan widget'ı (diğer ekranlarla tutarlı)
  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
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

  // Özel AppBar widget'ı
  PreferredSizeWidget _buildAppBar(BuildContext context, S loc) {
    return AppBar(
      backgroundColor: Colors.transparent, // Şeffaf arka plan
      elevation: 0, // Gölge yok
      automaticallyImplyLeading: false, // Otomatik geri butonunu kaldır
      centerTitle: true, // Başlığı ortala
      title: Text(
        loc.settings,
        style: GoogleFonts.cinzelDecorative(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
      actions: [ // Kapatma butonu sağda
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white70, size: 24),
          tooltip: loc.close,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8), // Sağ kenar boşluğu
      ],
      flexibleSpace: ClipRect( // AppBar arkasına blur efekti
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: Colors.black.withOpacity(0.1)),
        ),
      ),
    );
  }

  // Kullanıcı Kredi Bilgisi Bölümü
  Widget _buildUserInfoSection(BuildContext context, S loc) {
    return BlocBuilder<TarotBloc, TarotState>(
      builder: (context, state) {
        // Ondalık kısmı sadece 0'dan farklıysa göster
        final String tokenText = state.userTokens.truncateToDouble() == state.userTokens
            ? state.userTokens.toInt().toString()
            : state.userTokens.toStringAsFixed(1);

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          margin: const EdgeInsets.only(bottom: 25.0), // Bölümler arası boşluk
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

  // Dil Seçimi Bölümü
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

  // --- Geliştirilmiş Kredi Satın Alma Bölümü ---
  Widget _buildPurchaseSection(BuildContext context, S loc) {
    return _buildSectionContainer(
      title: loc.purchaseCredits,
      icon: Icons.add_shopping_cart,
      children: [
        // Ürünleri dinamik olarak yükle ve göster
        FutureBuilder<List<ProductDetails>>(
          // PaymentManager'dan ürünleri yükle
          future: _paymentManager.loadProducts(),
          builder: (context, snapshot) {
            // Yükleniyor durumu
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: CircularProgressIndicator(color: Colors.purpleAccent),
                ),
              );
            }
            // Hata durumu
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
                  child: Text(
                    loc.failedToLoadProducts, // Yerelleştirilmiş hata mesajı
                    style: GoogleFonts.lato(color: Colors.redAccent[100], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            // Ürün yok durumu
            final products = snapshot.data!;
            if (products.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
                  child: Text(
                    loc.noProductsAvailable, // Yerelleştirilmiş mesaj
                    style: GoogleFonts.lato(color: Colors.white60, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // Ürünleri listele
            return ListView.separated(
              shrinkWrap: true, // Column içinde boyutunu ayarla
              physics: const NeverScrollableScrollPhysics(), // Column kendi kaydırıyor
              itemCount: products.length,
              itemBuilder: (context, index) {
                // Her ürün için bir kart oluştur
                return _buildPurchaseCard(
                  context: context,
                  product: products[index], // ProductDetails nesnesini geçir
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12), // Kartlar arası boşluk
            );
          },
        ),
      ],
    );
  }
  // --- Bitti: Geliştirilmiş Kredi Satın Alma Bölümü ---


  // Ortak Bölüm Container Widget'ı (Başlık ve Çocuklar için)
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
          ...children, // Kartlar vb. bu bölüme eklenir
        ],
      ),
    );
  }

  // --- Geliştirilmiş Satın Alma Kartı Widget'ı ---
  Widget _buildPurchaseCard({
    required BuildContext context,
    required ProductDetails product, // Artık ProductDetails alıyor
  }) {
    return TapAnimatedScale(
      onTap: () async {
        // Satın alma işlemini doğrudan PaymentManager üzerinden başlat
        // Dialog göstermeye gerek yok, ConfirmationDialog zaten buyProduct içinde var
        await _paymentManager.buyProduct(product, context);
        // Satın alma sonucu PaymentManager içindeki stream listener tarafından işlenecek
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
          children: [
            // İkon (Belki ürün ID'sine göre farklı ikonlar?)
            Icon(Icons.star_rounded, color: Colors.yellowAccent.shade100, size: 20),
            const SizedBox(width: 12),
            // Ürün Adı ve Açıklaması (varsa)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title, // Ürün başlığı
                    style: GoogleFonts.lato(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  if (product.description.isNotEmpty) // Açıklama varsa göster
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        product.description,
                        style: GoogleFonts.lato(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Fiyat
            Text(
              product.price, // Ürün fiyatı
              style: GoogleFonts.orbitron(
                fontSize: 14,
                color: Colors.yellowAccent.shade200,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 5), // Fiyat ile ok arası boşluk
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }
  // --- Bitti: Geliştirilmiş Satın Alma Kartı Widget'ı ---


  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      // Özel AppBar'ı kullan
      appBar: _buildAppBar(context, loc!),
      body: Stack(
        children: [
          _buildBackground(), // Arka planı çiz
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0)
                    .copyWith(top: 20.0, bottom: 40.0), // Üst ve Alt boşluk
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildUserInfoSection(context, loc),
                    _buildLanguageSection(context, loc),
                    _buildPurchaseSection(context, loc), // Dinamik satın alma bölümü
                    // İsteğe bağlı: Diğer ayarlar eklenebilir
                    // _buildOtherSettingsSection(context, loc),
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
// (Dil seçimi için kullanılan kart widget'ı - Stil biraz iyileştirildi)
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
            width: isSelected ? 2.0 : 1.0, // Seçiliyse çerçeve daha belirgin
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
              style: GoogleFonts.lato(
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