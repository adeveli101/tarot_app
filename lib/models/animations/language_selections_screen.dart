import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarot_fal/models/animations/tap_animations_scale.dart'; // Mevcut animasyonlu butonunuz
import '../../screens/tarot_fortune_reading_screen.dart'; // Ana ekrana yönlendirme için

/// Kullanıcının uygulama dilini seçmesini sağlayan ekran.
///
/// Bu ekran, uygulamanın başlangıcında veya ayarlardan erişildiğinde gösterilebilir.
/// Seçilen dil `onLocaleSelected` geri çağrımı ile bildirilir ve ardından
/// ana ekrana (`TarotReadingScreen`) yönlendirme yapılır.
class LanguageSelectionScreen extends StatelessWidget {
  /// Dil seçildiğinde çağrılacak fonksiyon.
  ///
  /// Genellikle uygulamanın locale'ini güncelleyen bir state management
  /// mekanizmasını tetikler.
  final Future<void> Function(Locale, BuildContext) onLocaleSelected;

  const LanguageSelectionScreen({super.key, required this.onLocaleSelected});

  // --- Stil Sabitleri ---
  // Daha iyi okunabilirlik ve yönetilebilirlik için sabitler tanımlandı.
  static const double _buttonPaddingHorizontal = 40.0;
  static const double _buttonPaddingVertical = 18.0; // Dikey padding ayarlandı
  static const double _spacingBetweenButtons = 25.0; // Butonlar arası boşluk artırıldı
  static const double _titleSpacing = 50.0;         // Başlık altı boşluk artırıldı
  static const Duration _navigationTransitionDuration = Duration(milliseconds: 600); // Geçiş süresi
  static const double _maxButtonWidth = 320.0; // Butonlar için maksimum genişlik

  /// Kullanıcıyı ana ekrana yönlendirir.
  ///
  /// `pushReplacement` kullanarak mevcut ekranı yığından kaldırır ve
  /// kayma (slide) animasyonu ile `TarotReadingScreen`'i açar.
  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => TarotReadingScreen(
          // onSettingsTap için geçici veya kalıcı bir çözüm gerekebilir.
          // Şimdilik boş bir fonksiyon atıyoruz. İdealde bu, ana widget ağacından
          // veya bir state yönetim çözümüyle sağlanmalıdır.
          onSettingsTap: () {
            debugPrint("Settings tapped from LanguageSelectionScreen's navigation context.");
            // Ayarlar ekranına gitme mantığı buraya eklenebilir veya
            // TarotReadingScreen bu callback'i kendisi yönetebilir.
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Aşağıdan yukarı kayma animasyonu
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final curve = Curves.easeOutQuart; // Daha yumuşak bir curve
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var slideAnimation = animation.drive(tween);

          // Ek olarak Fade animasyonu
          var fadeAnimation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
        transitionDuration: _navigationTransitionDuration,
      ),
    );
  }

  /// Dil seçimi işlemini yönetir.
  ///
  /// `onLocaleSelected` callback'ini çağırır ve başarılı olursa ana ekrana yönlendirir.
  /// Olası hataları yakalar ve kullanıcıya geri bildirimde bulunur.
  Future<void> _selectLanguage(BuildContext context, Locale locale) async {
    try {
      // Ana widget'tan gelen locale ayarlama fonksiyonunu bekle
      await onLocaleSelected(locale, context);
      // Başarılı olursa ana ekrana git
      if (context.mounted) { // Context'in hala geçerli olup olmadığını kontrol et
        _navigateToHome(context);
      }
    } catch (e) {
      // Hata durumunda loglama yap ve kullanıcıya bilgi ver
      debugPrint("Dil ayarlanırken hata oluştu: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          // TODO: Bu metni de yerelleştir
          const SnackBar(content: Text('Dil ayarlanamadı. Lütfen tekrar deneyin.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tema verilerine erişim (renkler, yazı tipleri vb. için)
    final theme = Theme.of(context);
    // Uygulama genelinde tutarlılık için tema renklerini kullan
    final primaryColor = theme.colorScheme.primary; // Veya belirgin bir renk
    final secondaryColor = theme.colorScheme.secondary; // Veya başka bir renk
    final backgroundColorStart = Colors.deepPurple[900] ?? theme.colorScheme.surface;
    final backgroundColorEnd = Colors.black;

    // Buton ve başlık için metin stilleri (Google Fonts ile)
    final buttonTextStyle = GoogleFonts.cinzel(
      fontSize: 18,
      color: Colors.white, // Buton üzerindeki metin rengi
      fontWeight: FontWeight.w600,
    );

    final titleTextStyle = GoogleFonts.cinzelDecorative( // Başlık için farklı bir font
      color: Colors.white.withOpacity(0.9), // Başlık metin rengi
      fontSize: 26,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
      shadows: [ // Hafif gölge efekti
        Shadow(
          color: Colors.black.withOpacity(0.5),
          offset: const Offset(1, 1),
          blurRadius: 3,
        ),
      ],
    );

    return Scaffold(
      // Arka plan gradyanı (uygulamanın genel temasıyla uyumlu)
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColorStart, backgroundColorEnd],
            stops: const [0.0, 0.8], // Gradyan geçiş noktaları
          ),
        ),
        child: Center(
          // İçeriğin küçük ekranlarda kaydırılabilmesini sağla
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Başlık metni (İki dilde)
                Text(
                  'Select your language /\nDilinizi seçin', // Daha iyi okunabilirlik için satır ayrımı
                  textAlign: TextAlign.center,
                  style: titleTextStyle,
                ),
                const SizedBox(height: _titleSpacing),

                // İngilizce Dil Butonu
                _buildLanguageButton(
                  context: context,
                  text: 'English',
                  locale: const Locale('en'),
                  textStyle: buttonTextStyle,
                  icon: Icons.translate, // İkon eklendi
                  gradientColors: [primaryColor.withOpacity(0.8), secondaryColor.withOpacity(0.9)], // Tema renkleri
                  onPressed: () => _selectLanguage(context, const Locale('en')),
                ),
                const SizedBox(height: _spacingBetweenButtons),

                // Türkçe Dil Butonu
                _buildLanguageButton(
                  context: context,
                  text: 'Türkçe',
                  locale: const Locale('tr'),
                  textStyle: buttonTextStyle,
                  icon: Icons.translate, // İkon eklendi
                  gradientColors: [primaryColor.withOpacity(0.8), secondaryColor.withOpacity(0.9)], // Tema renkleri
                  onPressed: () => _selectLanguage(context, const Locale('tr')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Tekrarlanan buton yapısını oluşturan yardımcı metot.
  ///
  /// Bu metot, butonun metnini, locale'ini, stilini, ikonunu ve
  /// tıklama olayını parametre olarak alır, böylece kod tekrarı azalır.
  Widget _buildLanguageButton({
    required BuildContext context,
    required String text,
    required Locale locale,
    required TextStyle textStyle,
    required VoidCallback onPressed,
    IconData? icon, // Opsiyonel ikon
    List<Color>? gradientColors, // Opsiyonel gradyan renkleri
  }) {
    // Sağlanan renkler yoksa varsayılan gradyanı kullan
    final List<Color> colors = gradientColors ?? [Colors.purple[700]!, Colors.indigo[800]!];

    return TapAnimatedScale( // Dokunma animasyonu
      onTap: onPressed,
      child: Container(
        width: double.infinity, // Merkezi sütunda mevcut genişliği doldur
        constraints: const BoxConstraints(maxWidth: _maxButtonWidth), // Maksimum genişlik
        padding: const EdgeInsets.symmetric(
          horizontal: _buttonPaddingHorizontal,
          vertical: _buttonPaddingVertical,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30), // Daha yuvarlak kenarlar
          boxShadow: [ // Daha belirgin gölge
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all( // Hafif çerçeve
            color: Colors.white.withOpacity(0.2),
            width: 0.8,
          ),
        ),
        child: Row( // İkon ve metni yan yana göstermek için Row
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) // İkon varsa göster
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
            if (icon != null)
              const SizedBox(width: 12), // İkon ve metin arası boşluk
            Text(
              text,
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }
}