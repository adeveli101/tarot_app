import 'dart:async';
import 'dart:math' as math; // Random için

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

// Projenizdeki ilgili dosyaları import edin
import 'package:tarot_fal/generated/l10n.dart'; // Yerelleştirme
import 'package:tarot_fal/screens/reading_result.dart'; // Sonuç ekranı
import '../../data/tarot_bloc.dart'; // BLoC
import '../../data/tarot_event_state.dart'; // BLoC State'leri

// --- Okuma Sonucu Geçiş Ekranı ---

/// Okuma sonucu ekranına geçiş yaparken görsel olarak zenginleştirilmiş
/// ve dönen metinler içeren bir yükleme/animasyon ekranı gösterir.
class ReadingResultScreenWithTransition extends StatefulWidget {
  const ReadingResultScreenWithTransition({super.key});

  @override
  ReadingResultScreenWithTransitionState createState() =>
      ReadingResultScreenWithTransitionState();
}

class ReadingResultScreenWithTransitionState
    extends State<ReadingResultScreenWithTransition>
    with TickerProviderStateMixin {

  // --- Animasyon Kontrolcüleri ---
  late AnimationController _fadeController;       // İçeriğin genel fade-in animasyonu
  late AnimationController _gradientController;   // Arka plan gradient animasyonu
  late AnimationController _textSwapController;   // Metin değiştirme animasyonu (cross-fade)

  // --- Animasyonlar ---
  late Animation<double> _fadeAnimation;
  late Animation<Alignment> _gradientAlignAnimation;
  late Animation<double> _textFadeInAnimation;    // Yeni metnin fade-in'i
  late Animation<double> _textFadeOutAnimation;   // Eski metnin fade-out'u

  // --- Durum Değişkenleri ---
  bool _isNavigating = false;
  bool _isBlocStateReady = false;
  bool _isMinimumTimeElapsed = false;
  Timer? _minimumTimeTimer;
  Timer? _textChangeTimer; // Metinleri değiştirmek için Timer

  // --- Metin Yönetimi ---
  int _currentTextIndex = 0; // Gösterilen metnin indeksi
  List<String> _loadingMessages = []; // Yerelleştirilmiş mesaj listesi
  List<Color> _textColors = []; // Metin renkleri listesi (isteğe bağlı)

  // --- Sabitler ---
  static const Duration _minimumDisplayDuration = Duration(milliseconds: 2500);
  static const Duration _fadeInDuration = Duration(milliseconds: 800);
  static const Duration _gradientShiftDuration = Duration(seconds: 10);
  static const Duration _textSwapDuration = Duration(milliseconds: 600); // Metin geçiş süresi
  static const Duration _textDisplayDuration = Duration(milliseconds: 1400); // Her metnin görünme süresi

  @override
  void initState() {
    super.initState();

    // 1. Fade-in Kontrolcüsü
    _fadeController = AnimationController(duration: _fadeInDuration, vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    // 2. Gradient Kayma Kontrolcüsü
    _gradientController = AnimationController(duration: _gradientShiftDuration, vsync: this)
      ..repeat(reverse: true);
    _gradientAlignAnimation = TweenSequence<Alignment>(
        [
          TweenSequenceItem(tween: AlignmentTween(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
          TweenSequenceItem(tween: AlignmentTween(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
          TweenSequenceItem(tween: AlignmentTween(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
          TweenSequenceItem(tween: AlignmentTween(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
        ]
    ).animate(_gradientController);

    // 3. Metin Değiştirme Kontrolcüsü (Cross-fade için)
    _textSwapController = AnimationController(duration: _textSwapDuration, vsync: this);
    // Yeni metin animasyonun ikinci yarısında belirir
    _textFadeInAnimation = CurvedAnimation(
        parent: _textSwapController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn)
    );
    // Eski metin animasyonun ilk yarısında kaybolur
    _textFadeOutAnimation = CurvedAnimation(
        parent: _textSwapController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut)
    );

    // Başlangıç state'ini ve minimum süreyi ayarla
    _setupInitialStateAndTimers();

    // Animasyonları başlat
    _fadeController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Yerelleştirme nesnesi değiştiğinde metinleri güncelle
    _updateLoadingMessages();
  }

  /// Başlangıç durumunu ve zamanlayıcıları ayarlar.
  void _setupInitialStateAndTimers() {
    // Minimum Bekleme Süresi Timer'ı
    _minimumTimeTimer = Timer(_minimumDisplayDuration, () {
      if (mounted) {
        _isMinimumTimeElapsed = true;
        if (kDebugMode) print("Minimum display time elapsed.");
        _checkAndNavigate();
      }
    });

    // Başlangıç BLoC Durumunu Kontrol Et
    final initialBlocState = context.read<TarotBloc>().state;
    if (initialBlocState is FalYorumuLoaded || initialBlocState is TarotError) {
      if (kDebugMode) print("Initial BLoC state is already ready.");
      _isBlocStateReady = true;
    }

    // Metin Değiştirme Timer'ı
    _startTextChangeTimer();
  }

  /// Yerelleştirilmiş yükleme mesajlarını ve renklerini ayarlar.
  void _updateLoadingMessages() {
    final loc = S.of(context);
    // Yerelleştirme dosyanıza eklemeniz gereken anahtarlar:
    // loadingMessage1, loadingMessage2, loadingMessage3, loadingMessage4
    _loadingMessages = [
      loc?.unveilingMysticalPath ?? "Unveiling the Mystical Path...", // Varsayılan
      loc?.loadingMessage1 ?? "Reading the threads of fate...", // Örnek 1
      loc?.loadingMessage2 ?? "Consulting the cosmic energies...", // Örnek 2
      loc?.loadingMessage3 ?? "Aligning the stars for you...", // Örnek 3
      loc?.loadingMessage4 ?? "Decoding the symbols...", // Örnek 4
    ];
    // İsteğe bağlı: Her mesaj için farklı renkler tanımlayabilirsiniz
    _textColors = [
      Colors.white.withOpacity(0.9),
      Colors.amber[100]!,
      Colors.lightBlue[100]!,
      Colors.purpleAccent[100]!,
      Colors.greenAccent[100]!,
    ];
    // Liste uzunlukları eşit değilse veya renk istenmiyorsa varsayılan renk kullanılır
    if (_textColors.length != _loadingMessages.length) {
      _textColors = List.filled(_loadingMessages.length, Colors.white.withOpacity(0.9));
    }
    // İlk metni rastgele seçelim
    _currentTextIndex = math.Random().nextInt(_loadingMessages.length);
    // Eğer widget zaten build edildiyse state'i güncelle
    if(mounted) setState(() {});
  }


  /// Metin değiştirme zamanlayıcısını başlatır.
  void _startTextChangeTimer() {
    _textChangeTimer?.cancel(); // Önceki timer'ı iptal et
    _textChangeTimer = Timer.periodic(_textDisplayDuration, (_) {
      if (mounted) {
        // Metin değiştirme animasyonunu başlat
        _textSwapController.forward(from: 0.0).whenComplete(() {
          if (mounted) {
            // Animasyon bitince index'i değiştir ve kontrolcüyü sıfırla
            setState(() {
              // Bir sonraki indekse geç, listenin sonuna gelince başa dön
              _currentTextIndex = (_currentTextIndex + 1) % _loadingMessages.length;
            });
            _textSwapController.reset();
          }
        });
      } else {
        _textChangeTimer?.cancel(); // Widget dispose edildiyse timer'ı durdur
      }
    });
  }


  @override
  void dispose() {
    _minimumTimeTimer?.cancel();
    _textChangeTimer?.cancel(); // Metin değiştirme timer'ını da iptal et
    _fadeController.dispose();
    _gradientController.dispose();
    _textSwapController.dispose(); // Metin değiştirme kontrolcüsünü dispose et
    super.dispose();
  }

  /// Geçiş için tüm koşulların sağlanıp sağlanmadığını kontrol eder ve gerekirse geçiş yapar.
  void _checkAndNavigate() {
    if (_isNavigating || !mounted || !_isBlocStateReady || !_isMinimumTimeElapsed) {
      if (kDebugMode) {
        print("Navigation skipped: "
            "isNavigating=$_isNavigating, "
            "mounted=$mounted, "
            "isBlocStateReady=$_isBlocStateReady, "
            "isMinimumTimeElapsed=$_isMinimumTimeElapsed");
      }
      return;
    }
    _isNavigating = true;
    if (kDebugMode) print("Navigating to ReadingResultScreen...");

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ReadingResultScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build içinde loc almak yerine didChangeDependencies'de güncelliyoruz
    // Eğer _loadingMessages henüz doldurulmadıysa (ilk build anı), doldur
    if (_loadingMessages.isEmpty) {
      _updateLoadingMessages();
    }

    return BlocListener<TarotBloc, TarotState>(
      listener: (context, state) {
        final bool isReadyState = state is FalYorumuLoaded || state is TarotError;
        if (isReadyState && mounted && !_isBlocStateReady) {
          if (kDebugMode) print("BLoC state became ready.");
          _isBlocStateReady = true;
          _checkAndNavigate();
        }
      },
      listenWhen: (previous, current) => previous.runtimeType != current.runtimeType,
      child: Scaffold(
        body: AnimatedBuilder( // Arka plan animasyonu
          animation: _gradientAlignAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: _gradientAlignAnimation.value,
                  end: Alignment(-_gradientAlignAnimation.value.x, -_gradientAlignAnimation.value.y),
                  colors: [ Colors.deepPurple[900]!, Colors.indigo[900]!, Colors.black, ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: child,
            );
          },
          child: Center( // İçerik
            child: FadeTransition(
              opacity: _fadeAnimation, // Genel giriş animasyonu
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lottie animasyonu
                  Lottie.asset(
                    'assets/animations/tarot_loading.json',
                    width: 180,
                    height: 180,
                    repeat: true,
                  ),
                  const SizedBox(height: 35),

                  // --- Dönen Metinler Alanı ---
                  AnimatedBuilder(
                      animation: _textSwapController, // Metin değiştirme animasyonunu dinle
                      builder: (context, child) {
                        // Mevcut metin (kaybolan)
                        final Widget oldText = FadeTransition(
                          opacity: ReverseAnimation(_textFadeOutAnimation), // Ters animasyonla solma
                          child: Text(
                            _loadingMessages.isNotEmpty ? _loadingMessages[_currentTextIndex] : "",
                            key: ValueKey<int>(_currentTextIndex), // Key değişimi animasyonu tetikler
                            style: GoogleFonts.cinzel(
                              fontSize: 18, // Biraz daha küçük olabilir
                              color: _textColors.isNotEmpty ? _textColors[_currentTextIndex] : Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
                              shadows: [ Shadow( color: Colors.black.withOpacity(0.5), offset: const Offset(0, 1), blurRadius: 3,), ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );

                        // Bir sonraki metin (beliren)
                        final int nextIndex = (_currentTextIndex + 1) % (_loadingMessages.isNotEmpty ? _loadingMessages.length : 1);
                        final Widget newText = FadeTransition(
                          opacity: _textFadeInAnimation, // Normal animasyonla belirme
                          child: Text(
                            _loadingMessages.isNotEmpty ? _loadingMessages[nextIndex] : "",
                            key: ValueKey<int>(nextIndex),
                            style: GoogleFonts.cinzel(
                              fontSize: 18,
                              color: _textColors.isNotEmpty ? _textColors[nextIndex] : Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
                              shadows: [ Shadow( color: Colors.black.withOpacity(0.5), offset: const Offset(0, 1), blurRadius: 3,), ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );

                        // Animasyonun durumuna göre eski veya yeni metni göster
                        return _textSwapController.value < 0.5 ? oldText : newText;
                      }
                  ),
                  // --- Dönen Metinler Alanı Sonu ---

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- String Extension (İlk Harfleri Büyütmek İçin) ---
// Bu extension'ı ayrı bir dosyaya taşımanız önerilir.
extension StringExtension on String {
  String capitalizeFirstofEach() => replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.isNotEmpty
      ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}'
      : '')
      .join(" ");
}

