// lib/screens/settings_screen.dart

import 'dart:ui'; // BackdropFilter için
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart'; // Lottie
import 'package:permission_handler/permission_handler.dart'; // <<< İzin yönetimi için eklendi
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/generated/l10n.dart'; // Yerelleştirme
import 'package:tarot_fal/data/payment_manager.dart';
import 'package:tarot_fal/data/tarot_event_state.dart'; // TarotState için
import 'package:tarot_fal/models/animations/tap_animations_scale.dart';
// NotificationService importu (doğru yolu kullanın)
import '../services/notification_service.dart'; // <<< Bildirim servisi için eklendi

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

// <<< WidgetsBindingObserver eklendi (Ayarlardan dönünce izin kontrolü için) >>>
class SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  // <<< Bildirim izin durumu için state değişkeni >>>
  PermissionStatus _notificationStatus = PermissionStatus.denied; // Başlangıç değeri

  @override
  void initState() {
    super.initState();
    // <<< Observer kaydı >>>
    WidgetsBinding.instance.addObserver(this);
    // <<< Başlangıçta izin durumunu kontrol et >>>
    _checkNotificationPermission();
  }

  @override
  void dispose() {
    // <<< Observer kaydını kaldır >>>
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // <<< Uygulama yaşam döngüsü değişikliğini dinle >>>
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Kullanıcı ayarlardan uygulamaya geri döndüğünde izin durumunu tekrar kontrol et
    if (state == AppLifecycleState.resumed) {
      _checkNotificationPermission();
    }
  }

  /// Mevcut bildirim izin durumunu kontrol eder ve state'i günceller.
  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    if (mounted) {
      setState(() {
        _notificationStatus = status;
      });
    }
  }

  /// Bildirim switch'i değiştirildiğinde çağrılır.
  Future<void> _handleNotificationToggle(bool newValue) async {
    final loc = S.of(context); // Yerelleştirme için context gerekli

    if (newValue) {
      // --- Switch AÇILIYOR ---
      // İzin iste
      final status = await Permission.notification.request();
      if (mounted) {
        setState(() {
          _notificationStatus = status;
        });
        if (status.isPermanentlyDenied) {
          // Kalıcı olarak reddedildiyse ayarlara yönlendir
          _showOpenSettingsDialog(
            loc!.notificationPermissionDeniedTitle, // Yerelleştirilmiş başlık
            loc.notificationPermissionDeniedText, // Yerelleştirilmiş içerik
          );
        } else if (status.isDenied) {
          // Sadece reddedildiyse (henüz kalıcı değil) bilgi verilebilir
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc!.notificationPermissionDeniedTextShort)), // Kısa mesaj için yeni anahtar
          );
        }
      }
    } else {
      // --- Switch KAPATILIYOR ---
      // Kullanıcıyı uygulama ayarlarına yönlendir, çünkü izni kodla geri alamayız.
      _showOpenSettingsDialog(
        loc!.disableNotificationsTitle, // Yeni anahtar
        loc.disableNotificationsDesc, // Yeni anahtar
      );
    }
  }

  /// Kullanıcıyı uygulama ayarlarına yönlendirmek için diyalog gösterir.
  Future<void> _showOpenSettingsDialog(String title, String content) async {
    final loc = S.of(context);
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900]?.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(content, style: GoogleFonts.cabin(color: Colors.white70, fontSize: 15)),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc!.cancel, style: GoogleFonts.cinzel(fontWeight: FontWeight.w600)), // İptal
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent[100], foregroundColor: Colors.black87, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              Navigator.pop(dialogContext);
              openAppSettings(); // Uygulama ayarlarını aç
            },
            child: Text(loc.settings, style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)), // Ayarlar
          ),
        ],
      ),
    );
  }


  // Arka plan widget'ı (Aynı kalır)
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

  Widget _buildPurchaseSection(BuildContext context, S loc) {
    // Artık _buildSectionContainer kullanmıyoruz.
    // Doğrudan tıklanabilir butonu döndürüyoruz.
    // Bölümler arası boşluğu korumak için Margin ekliyoruz.
    return Container(
      margin: const EdgeInsets.only(bottom: 25.0), // Diğer bölümlerle aynı alt boşluk
      child: TapAnimatedScale(
        onTap: () {
          // Ödeme dialogunu göster
          PaymentManager.showPaymentDialog(context);
        },
        child: Container(
          // Butonun görünümü (gradient, border, shadow vb.) aynı kalır
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
          // Butonun içeriği (ikon, metin, ok) aynı kalır
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.add_shopping_cart, color: Colors.yellowAccent.shade100, size: 22), // İkonu değiştirdik
                  const SizedBox(width: 12),
                  Text(
                    loc.purchaseCredits, // "Kredi Satın Al" metni
                    style: GoogleFonts.cabin(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 18),
            ],
          ),
        ),
      ),
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

  // <<< YENİ: Bildirim Ayarları Bölümü >>>
  Widget _buildNotificationSection(BuildContext context, S loc) {
    // Switch'in değeri mevcut izin durumuna göre belirlenir
    bool isNotificationEnabled = _notificationStatus.isGranted;

    return _buildSectionContainer(
      // Yerelleştirme dosyanıza 'notifications' anahtarını ekleyin
      title: loc.notifications,
      icon: Icons.notifications_active_outlined,
      children: [
        SwitchListTile(
          title: Text(
            // Yerelleştirme dosyanıza 'allowNotifications' anahtarını ekleyin
            loc.allowNotifications,
            style: GoogleFonts.cabin(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            // Yerelleştirme dosyanıza 'notificationStatusDesc' anahtarını ekleyin
            // Duruma göre farklı açıklama gösterilebilir (opsiyonel)
            isNotificationEnabled
                ? (loc.notificationsEnabledDesc)
                : (loc.notificationsDisabledDesc),
            style: GoogleFonts.cabin(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          value: isNotificationEnabled,
          onChanged: _handleNotificationToggle, // Switch değiştiğinde handle fonksiyonunu çağır
          activeColor: Colors.greenAccent.shade100, // Açık durum rengi
          inactiveThumbColor: Colors.grey.shade400,
          inactiveTrackColor: Colors.grey.shade800.withOpacity(0.5),
          secondary: Icon(
            isNotificationEnabled ? Icons.notifications_active : Icons.notifications_off_outlined,
            color: isNotificationEnabled ? Colors.greenAccent.shade100 : Colors.grey.shade400,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8), // İç padding
        ),
      ],
    );
  }


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


  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, loc!),
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
                    _buildUserInfoSection(context, loc),
                    _buildPurchaseSection(context, loc),
                    _buildLanguageSection(context, loc),
                    _buildNotificationSection(context, loc), // <<< Yeni bölüm eklendi
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
