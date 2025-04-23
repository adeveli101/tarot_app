// lib/models/animations/splash_screen.dart

import 'dart:async'; // Timer için eklendi
import 'dart:math'; // Orijinal kodda vardı (sin için)
import 'package:flutter/foundation.dart'; // kDebugMode için eklendi
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Orijinal kodda vardı
import 'package:lottie/lottie.dart'; // Orijinal kodda vardı
// import 'package:permission_handler/permission_handler.dart'; // <<< BU SATIRI SİL (Artık burada kullanılmayacak)
import 'package:tarot_fal/generated/l10n.dart';

import 'notification_service.dart'; // Orijinal kodda vardı

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _titleController;
  late Animation<double> _fadeAnimation;
  Timer? _finishTimer; // Minimum süreyi yönetmek için
  // Minimum splash süresi (izin isteme dahil beklenmesi için)
  static const _minSplashDuration = Duration(seconds: 3); // Orijinaldeki gibi 3 sn

  @override
  void initState() {
    super.initState();
    _titleController = AnimationController(
      // Orijinal süreyi kullanalım veya isteğe bağlı ayarlayalım
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeIn), // Yumuşak giriş
    );

    // Başlatma ve izin isteme işlemlerini başlat
    _initializeAppAndPermissions();
  }

  Future<void> _initializeAppAndPermissions() async {
    // Başlık animasyonunu başlat
    _titleController.forward();

    // Güvenli: İlk frame çizildikten sonra izinleri iste
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(mounted) {
        if (kDebugMode) print("SplashScreen: İzin kontrolü başlatılıyor (NotificationService üzerinden)...");
        // NotificationService üzerinden izinleri kontrol et ve iste
        await NotificationService().checkAndRequestPermissionsIfNeeded(requestExactAlarm: true);
        if (kDebugMode) print("SplashScreen: İzin kontrolü tamamlandı.");

        // İzin isteme işlemi bittikten sonra minimum süreyi başlat/kontrol et
        _startFinishTimer();
      }
    });
  }

  // Minimum splash süresi için zamanlayıcıyı başlatır
  void _startFinishTimer() {
    _finishTimer?.cancel();
    _finishTimer = Timer(_minSplashDuration, () {
      // Süre dolduğunda ve widget hala bağlıysa onFinish callback'ini çağır
      if (mounted) {
        if (kDebugMode) print("SplashScreen: Minimum süre doldu, onFinish çağrılıyor.");
        widget.onFinish();
      }
    });
  }

  // --- Eski izin isteme metodunu SİL ---
  /*
  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }
  */

  // --- Orijinal SplashScreen'den _buildBackground ---
  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/image_fx_c.jpg',
          fit: BoxFit.cover,
        ),
        Lottie.asset(
          'assets/animations/tarot_shuffle.json',
          fit: BoxFit.contain,
          frameRate: FrameRate(30), // Orijinalindeki gibi
          repeat: true,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple[800]!.withOpacity(0.25),
                Colors.black.withOpacity(0.9),
              ],
              stops: const [0.3, 0.8],
            ),
          ),
        ),
      ],
    );
  }

  // --- Orijinal SplashScreen'den _buildGradientOverlay ---
  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Colors.transparent,
            Colors.deepPurple[700]!.withOpacity(0.3),
          ],
        ),
      ),
    );
  }

  // --- Orijinal SplashScreen'den _buildTitle ---
  Widget _buildTitle() {
    // Build metodu içinde S.of(context) kullanıldığı için burada tekrar almaya gerek yok.
    // Eğer build metodu dışında kullanılacaksa S nesnesini parametre olarak almak gerekir.
    // Şimdilik doğrudan metinleri kullanalım.
    const String appTitle = " ASTRAL TAROT "; // Orijinal metin
    const String taglineKey = "unveilTheStars"; // l10n anahtarı (build içinde alınacak)

    return Column(
      children: [
        AnimatedBuilder( // Shimmer efekti için (orijinalde vardı)
          animation: _titleController,
          builder: (context, child) {
            final shimmerValue = sin(_titleController.value * pi * 2) * 0.5 + 0.5;
            return ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.white,
                  const Color(0xFFE6E6FA), // Orijinal renkler
                  Colors.purpleAccent.shade100,
                  Colors.white,
                ],
                stops: [0.0, shimmerValue * 0.5, shimmerValue, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                appTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel( // Orijinal font
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                  color: Colors.white, // ShaderMask ile kaplanacak
                  decoration: TextDecoration.none,
                  shadows: [ // Orijinal gölgeler
                    Shadow(
                      color: Colors.purple[300]!.withOpacity(0.8),
                      offset: const Offset(0, 4),
                      blurRadius: 15,
                    ),
                    Shadow(
                      color: Colors.purpleAccent.withOpacity(0.3 + shimmerValue * 0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.001), // Orijinal boşluk
        // Tagline Container (Orijinal yapı)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.purple[200]!.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            S.of(context)?.unveilTheStars ?? "Unveil The Stars Within Your Soul", // l10n kullan veya varsayılan
            style: GoogleFonts.cinzel( // Orijinal stil
              color: Colors.purple[100]!.withOpacity(0.7),
              fontSize: 16,
              letterSpacing: 4,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _finishTimer?.cancel(); // Timer'ı iptal et
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    // final loc = S.of(context); // _buildTitle içinde zaten context üzerinden alınıyor.

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),       // Orijinal arka plan
          _buildGradientOverlay(),  // Orijinal overlay
          Center(
            child: FadeTransition( // Başlığın yumuşak girişi için
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Dikeyde ortala
                children: [
                  const SizedBox(height: 120), // Başlık ile gösterge arası boşluk

                  _buildTitle(), // Orijinal başlık widget'ı
                  const SizedBox(height: 60), // Başlık ile gösterge arası boşluk
                  // Yükleme/Bekleme göstergesi
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                    strokeWidth: 2.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }}