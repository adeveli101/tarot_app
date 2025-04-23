import 'dart:async';
import 'dart:math' as math; // 'pi', 'max', 'min' için
import 'dart:ui' show lerpDouble; // lerpDouble için

import 'package:audioplayers/audioplayers.dart'; // Ses çalma için eklendi
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HapticFeedback için
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:tarot_fal/generated/l10n.dart'; // Yerelleştirme için
import 'package:tarot_fal/screens/reading_result.dart'; // ReadingResultScreen için

// --- Okuma Sonucu Geçiş Ekranı ---

/// Okuma sonucu ekranına geçiş yaparken bir yükleme/animasyon ekranı gösterir.
class ReadingResultScreenWithTransition extends StatefulWidget {
  const ReadingResultScreenWithTransition({super.key});

  @override
  ReadingResultScreenWithTransitionState createState() =>
      ReadingResultScreenWithTransitionState();
}

class ReadingResultScreenWithTransitionState
    extends State<ReadingResultScreenWithTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isTransitioning = false; // Tekrar tekrar geçişi engellemek için

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1, milliseconds: 800), // Yumuşak geçiş süresi
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut, // Yumuşak çıkış efekti
    );

    // Widget ağaca eklendikten sonra animasyonu ve geçişi başlat
    // (setState çağrılmadığı için güvenli)
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTransition());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Animasyonu başlatır ve tamamlandığında asıl sonuç ekranına yönlendirir.
  Future<void> _startTransition() async {
    // Widget dispose edildiyse veya zaten geçiş yapılıyorsa tekrar başlatma
    if (!mounted || _isTransitioning) return;
    _isTransitioning = true;

    try {
      // Animasyonu ileri doğru oynat (görünür hale getir)
      await _animationController.forward().orCancel;

      // Widget hala ekranda ise (kullanıcı geri gitmediyse vb.)
      if (mounted) {
        // Asıl sonuç ekranına değiştirerek git (geri dönülemeyecek şekilde)
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const ReadingResultScreen(),
            transitionsBuilder: (_, animation, __, child) {
              // Yeni ekranın solma efektiyle gelmesini sağla
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600), // Geçiş süresi
          ),
        );
      }
    } on TickerCanceled {
      // Animasyon iptal edilirse (nadiren olur, örn. dispose edilirken)
      if (kDebugMode) {
        print("ReadingResultScreenWithTransition animation cancelled.");
      }
      // Geçiş durumunu sıfırla ki tekrar denenebilsin (eğer gerekirse)
      if(mounted) _isTransitioning = false;
    } catch (e, stackTrace) {
      // Geçiş sırasında bir hata olursa logla
      if (kDebugMode) {
        print("ReadingResultScreenWithTransition error: $e\n$stackTrace");
      }
      if (mounted) {
        _isTransitioning = false;
        // Hata durumunda kullanıcıyı bilgilendirip bir önceki ekrana dönmek daha iyi olabilir
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(S.of(context)?.genericError ?? "Bir hata oluştu.")),
        // );
        // if (Navigator.canPop(context)) Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Scaffold(
      body: Container(
        // Arka plan gradient'i
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple[900]!, Colors.black],
            stops: const [0.0, 0.8],
          ),
        ),
        child: Center(
          // İçeriği solma efektiyle göster
          child: FadeTransition(
            opacity: _fadeAnimation,
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
                // Yükleme metni
                Text(
                  // Yerelleştirilmiş metin (null kontrolü eklendi)
                  loc!.unveilingMysticalPath ,
                  style: GoogleFonts.cinzel(
                    fontSize: 19,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    shadows: [ // Hafif parlama efekti
                      Shadow(
                        color: Colors.purpleAccent.withOpacity(0.5),
                        offset: const Offset(0, 1),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// --- Kart Çekmek İçin Kaydırma Butonu ---

/// Kullanıcının kartları çekmek için yatay olarak kaydırması gereken buton.
/// Kaydırma sırasında ses çalar ve görsel geri bildirimler sunar.
class SlideToDrawButton extends StatefulWidget {
  final VoidCallback onDrawComplete; // Kaydırma başarıyla tamamlandığında tetiklenir

  const SlideToDrawButton({
    super.key,
    required this.onDrawComplete,
  });

  @override
  SlideToDrawButtonState createState() => SlideToDrawButtonState();
}

class SlideToDrawButtonState extends State<SlideToDrawButton> with TickerProviderStateMixin {
  // --- State ve Animasyon Değişkenleri ---
  double _dragValue = 0.0; // 0.0 (başlangıç) ile 1.0 (bitiş) arası kaydırma konumu
  bool _isDragging = false; // Kullanıcı şu anda butonu kaydırıyor mu?

  // Animasyon Kontrolcüleri
  late AnimationController _pulseController; // Bekleme durumundaki parlama efekti
  late AnimationController _resetController; // Başarısız kaydırma sonrası geri dönüş
  late AnimationController _successController; // Başarılı kaydırma sonrası efekt

  // Animasyonlar
  late Animation<double> _pulseAnimation; // Pulse animasyon değeri
  late Animation<double> _resetAnimation; // Reset animasyon değeri (dinamik ayarlanır)
  late Animation<double> _successScaleAnimation; // Başarıda büyüme
  late Animation<double> _successGlowAnimation; // Başarıda parlama

  // Ses Çalar
  // Başlatma (lazy initialization) ile sadece gerektiğinde oluşturulur.
  late final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioPlayerInitialized = false; // Ses çaların durumu
  bool _isSoundPlaying = false; // Ses çalıyor mu?
  final String _slideSoundPath = 'audios/transitional-swipe.mp3'; // Kaydırma sesi dosya yolu (PROJENİZE EKLEYİN!)

  // Buton Boyutları ve Süreler (Daha okunabilir hale getirildi)
  static const double _buttonWidth = 280.0;
  static const double _handleSize = 60.0;
  static const Duration _resetDuration = Duration(milliseconds: 350);
  static const Duration _successDuration = Duration(milliseconds: 500);
  static const Duration _pulseDuration = Duration(milliseconds: 1500);

  // Kaydırılabilir alan (Handle'ın hareket edebileceği maksimum mesafe)
  final double _draggableWidth = _buttonWidth - _handleSize;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeAudioPlayer(); // Ses çaları başlat
  }

  /// Animasyonları ve kontrolcüleri başlatır.
  void _initializeAnimations() {
    // Pulse Animasyonu (bekleme durumu)
    _pulseController = AnimationController(duration: _pulseDuration, vsync: this)
      ..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);

    // Reset Animasyonu (başarısız kaydırma)
    _resetController = AnimationController(duration: _resetDuration, vsync: this);
    // _resetAnimation, _onDragEnd içinde dinamik olarak oluşturulur.
    _resetAnimation = CurvedAnimation(parent: _resetController, curve: Curves.easeOutCirc)
      ..addListener(_handleResetAnimation)
      ..addStatusListener(_handleResetStatus);

    // Success Animasyonu (başarılı kaydırma)
    _successController = AnimationController(duration: _successDuration, vsync: this);
    _successScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _successController, curve: Curves.elasticOut)
    );
    _successGlowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.8), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 0.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _successController, curve: Curves.easeOut))
      ..addStatusListener(_handleSuccessStatus); // Listener eklendi
  }

  /// Ses çaları ve kaynaklarını başlatır.
  Future<void> _initializeAudioPlayer() async {
    try {
      // Kaydırma sesini önbelleğe al (opsiyonel ama performansı artırabilir)
      // Projenizde audioplayers_linux vb. platform eklentileri varsa bu çalışır.
      // await _audioPlayer.setSource(AssetSource(_slideSoundPath));
      // Önbelleğe alma yerine doğrudan play içinde de source verilebilir.
      _isAudioPlayerInitialized = true;
      if (kDebugMode) print("AudioPlayer initialized for SlideToDrawButton.");
    } catch (e) {
      if (kDebugMode) print("Error initializing AudioPlayer: $e");
      _isAudioPlayerInitialized = false; // Başlatılamadı olarak işaretle
    }
  }

  /// Reset animasyonu sırasında _dragValue'yu günceller.
  void _handleResetAnimation() {
    if (mounted) {
      // _resetAnimation.value: Başlangıç _dragValue değeri
      // _resetController.value: Animasyonun ilerlemesi (0.0 -> 1.0)
      // lerpDouble ile başlangıçtan 0.0'a doğru interpolasyon yapılır.
      setState(() => _dragValue = lerpDouble(_resetAnimation.value, 0.0, _resetController.value) ?? 0.0);
    }
  }

  /// Reset animasyonu bittiğinde pulse'ı tekrar başlatır.
  void _handleResetStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // Reset bittiğinde ve kullanıcı sürüklemiyorsa pulse animasyonunu tekrar başlat
      if (mounted && !_isDragging) {
        _tryRepeatPulse();
      }
    }
  }

  /// Success animasyonu bittiğinde callback'i çağırır ve resetler.
  void _handleSuccessStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onDrawComplete();
      // Kısa bir bekleme sonrası reset animasyonunu başlat (1.0'dan 0.0'a)
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _startResetAnimation(fromValue: 1.0);
          _successController.reset(); // Başarı animasyonunu sıfırla
        }
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _resetController.dispose();
    _successController.dispose();
    // Ses çaları güvenli bir şekilde durdur ve dispose et
    _stopSlideSound();
    _audioPlayer.dispose();
    if (kDebugMode) print("SlideToDrawButton disposed.");
    super.dispose();
  }

  // --- Sürükleme Olay Yöneticileri ---

  void _onDragStart(DragStartDetails details) {
    // Eğer zaten sürükleniyorsa veya animasyonlar aktifse yeni sürüklemeyi başlatma
    if (_isDragging || _resetController.isAnimating || _successController.isAnimating) return;

    if (mounted) {
      setState(() {
        _isDragging = true;
        _resetController.stop(); // Devam eden reset varsa durdur
        _pulseController.stop(); // Pulse animasyonunu durdur (görsel olarak)
      });
      HapticFeedback.lightImpact(); // Hafif titreşim
      _startSlideSound(); // Kaydırma sesini başlat
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging || !mounted) return;

    setState(() {
      // Sürükleme mesafesini delta kullanarak güncelle
      // _dragValue'yu 0.0 ile 1.0 arasında sınırla
      final currentDragPixels = _dragValue * _draggableWidth;
      final newDragPixels = (currentDragPixels + details.delta.dx).clamp(0.0, _draggableWidth);
      _dragValue = newDragPixels / _draggableWidth;

      // İsteğe bağlı: Sesin perdesini veya yüksekliğini _dragValue'ya göre ayarla
      // _audioPlayer.setPlaybackRate(...);
      // _audioPlayer.setVolume(...);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging || !mounted) return;

    // Başarı eşiğini kontrol et (%85'ten fazla kaydırıldıysa başarılı say)
    final bool isSuccess = _dragValue > 0.85;
    _stopSlideSound(); // Kaydırma sesini durdur

    if (isSuccess) {
      HapticFeedback.heavyImpact(); // Başarıda güçlü titreşim
      setState(() { _dragValue = 1.0; }); // Pozisyonu 1.0'a kilitle
      _successController.forward(from: 0.0); // Başarı animasyonunu başlat
    } else {
      // Başarısızsa, mevcut pozisyondan başa dönme animasyonunu başlat
      HapticFeedback.lightImpact();
      _startResetAnimation(fromValue: _dragValue); // Mevcut değerden resetle
    }
    setState(() => _isDragging = false); // Sürükleme bitti
  }

  /// Reset animasyonunu belirtilen değerden başlatır.
  void _startResetAnimation({required double fromValue}) {
    if (!mounted) return;
    // Reset animasyonunu mevcut _dragValue'dan başlatacak şekilde ayarla
    // Tween'i burada tanımlamak yerine _handleResetAnimation içinde kullanıyoruz.
    // Ancak animasyonun başlangıç değerini bilmesi için tween'in `begin` değerini ayarlıyoruz.
    _resetAnimation = Tween<double>(begin: fromValue, end: 0.0).animate(
        CurvedAnimation(parent: _resetController, curve: Curves.easeOutCirc)
    )..addListener(_handleResetAnimation); // Listener'ı tekrar ekle
    _resetController.forward(from: 0.0);
  }

  /// Güvenli bir şekilde pulse animasyonunu tekrarlamayı dener.
  void _tryRepeatPulse() {
    if (mounted && !_pulseController.isAnimating && !_isDragging && !_resetController.isAnimating && !_successController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  // --- Ses Kontrol Metotları ---

  /// Kaydırma sesini başlatır (eğer başlatılmadıysa ve ses dosyası varsa).
  Future<void> _startSlideSound() async {
    if (!_isAudioPlayerInitialized || _isSoundPlaying) return;
    try {
      // PlayerState kontrolü: Durdurulmuş veya tamamlanmışsa tekrar oynatılabilir.
      if (_audioPlayer.state == PlayerState.stopped ||
          _audioPlayer.state == PlayerState.completed ||
          _audioPlayer.state == PlayerState.disposed // disposed ise tekrar başlatılamaz
      ) {
        // Loop modunda sesi çal
        await _audioPlayer.play(AssetSource(_slideSoundPath), volume: 0.6, mode: PlayerMode.lowLatency); // Loop için `play` yerine `resume` gerekebilir veya farklı bir yaklaşım. Audioplayers'ın son sürümüne göre loop doğrudan play içinde olmayabilir. Alternatif: `onPlayerComplete` ile tekrar `play` çağırmak. Şimdilik basit play ile bırakalım.
        // await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Bu şekilde de loop ayarlanabilir.
        setState(() => _isSoundPlaying = true);
        if (kDebugMode) print("Slide sound started.");
      } else if (_audioPlayer.state == PlayerState.paused) {
        await _audioPlayer.resume(); // Duraklatılmışsa devam et
        setState(() => _isSoundPlaying = true);
        if (kDebugMode) print("Slide sound resumed.");
      }

    } catch (e) {
      if (kDebugMode) print("Error starting slide sound: $e");
      setState(() => _isSoundPlaying = false);
    }
  }

  /// Kaydırma sesini durdurur.
  Future<void> _stopSlideSound() async {
    if (!_isAudioPlayerInitialized || !_isSoundPlaying) return;
    try {
      // Sesi durdur (başa sarmaz) veya pause() ile duraklat.
      await _audioPlayer.stop();
      // await _audioPlayer.pause(); // Pause kullanırsak resume ile devam edilebilir.
      setState(() => _isSoundPlaying = false);
      if (kDebugMode) print("Slide sound stopped.");
    } catch (e) {
      if (kDebugMode) print("Error stopping slide sound: $e");
    }
  }


  // --- Build Metotları (Okunabilirlik için ayrıldı) ---

  @override
  Widget build(BuildContext context) {
    // Başarı animasyonunu dinle
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: Listenable.merge([_successController, _resetController, _pulseController]), // Tüm relevant controller'ları dinle
        builder: (context, child) {
          final successScale = _successScaleAnimation.value;
          final successGlow = _successGlowAnimation.value;
          final handlePosition = _dragValue * _draggableWidth; // Handle konumu güncellendi

          // Ana buton container'ı
          return Transform.scale(
            scale: successScale, // Başarı animasyonu için ölçekleme
            child: Container(
              width: _buttonWidth,
              height: _handleSize,
              clipBehavior: Clip.antiAlias, // Taşmaları engelle
              decoration: _buildBackgroundDecoration(successGlow),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Katman 1: Başlangıç ve Bitiş Metinleri
                  _buildTextOverlays(context),
                  // Katman 2: Kaydırılan Daire (Handle) ve Pulse Efekti
                  _buildHandle(handlePosition),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Butonun arka planını ve gölgelerini oluşturur.
  BoxDecoration _buildBackgroundDecoration(double successGlow) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.deepPurple.shade800.withOpacity(0.8),
          Color.lerp(Colors.deepPurple.shade800, Colors.pinkAccent.shade400, _dragValue)!,
        ],
        stops: [0.0, (_dragValue + 0.1).clamp(0.0, 1.0)], // Stop değerini 0-1 arasına sınırla
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(_handleSize / 2),
      boxShadow: [
        BoxShadow(
          color: Color.lerp(Colors.purple, Colors.pinkAccent, _dragValue)!.withOpacity(lerpDouble(0.2, 0.5, _dragValue)!),
          blurRadius: lerpDouble(8, 15, _dragValue)!,
          offset: const Offset(0, 4),
        ),
        // Başarı parlaması
        BoxShadow(
          color: Colors.pinkAccent.withOpacity(successGlow * 0.8),
          blurRadius: 25 * successGlow,
          spreadRadius: 8 * successGlow,
        ),
      ],
      border: Border.all(color: Colors.purpleAccent.withOpacity(0.3 + successGlow * 0.5), width: 1.5),
    );
  }

  /// Başlangıç ("Kaydır...") ve ortaya çıkan ("Mistik...") metin katmanlarını oluşturur.
  Widget _buildTextOverlays(BuildContext context) {
    final loc = S.of(context);
    final handlePosition = _dragValue * _draggableWidth;

    // Başlangıç metninin opaklığı ve pozisyonu
    final initialTextOpacity = math.max(0.0, 1.0 - _dragValue * 3.5);
    final initialTextOffset = lerpDouble(0, -50, _dragValue)!;
    final initialTextLeftPadding = _handleSize + 15.0;

    // Ortaya çıkan metnin opaklığı
    final mysticTextOpacity = math.max(0.0, (_dragValue - 0.3) * 2.0).clamp(0.0, 1.0);

    return Stack(
      children: [
        // Başlangıç metni
        Positioned(
          left: initialTextLeftPadding,
          right: _handleSize * 0.05,
          top: 0, bottom: 0,
          child: Center(
            child: Opacity(
              opacity: initialTextOpacity,
              child: Transform.translate(
                offset: Offset(initialTextOffset, 0),
                child: Text(
                  loc!.slideToDrawCards,
                  style: GoogleFonts.cinzel(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      decoration: TextDecoration.none),
                  overflow: TextOverflow.clip,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
          ),
        ),
        // Dolgu efekti ve ortaya çıkan metin
        Positioned.fill(
          child: ClipRect(
            clipper: _SlideAreaClipper(
                clipAmount: handlePosition + (_handleSize * 0.6), // Dairenin biraz ilerisine kadar kırp
                handleSize: _handleSize
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purpleAccent.withOpacity(0.3),
                    Colors.pinkAccent.withOpacity(0.5),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(_handleSize / 2),
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(right: _handleSize * 0.4), // Handle'ın üzerine gelmesin
                child: Opacity(
                  opacity: mysticTextOpacity,
                  child: Text(
                    loc.unveilTheStars,
                    style: GoogleFonts.cinzelDecorative(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        decoration: TextDecoration.none),
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Kaydırılan daireyi (handle) ve pulse efektini oluşturur.
  Widget _buildHandle(double handlePosition) {
    // Sadece bekleme durumunda pulse efekti uygula
    final bool canPulse = !_isDragging && !_resetController.isAnimating && !_successController.isAnimating;
    final double pulseScale = canPulse ? (1.0 + (_pulseAnimation.value * 0.08)) : 1.0;
    final double pulseGlow = canPulse ? (_pulseAnimation.value * 0.25) : 0.0;

    return Positioned(
      left: handlePosition,
      child: Transform.scale(
        scale: pulseScale, // Pulse ölçeklemesi
        child: Container(
          width: _handleSize,
          height: _handleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.pinkAccent.shade100,
                Colors.purpleAccent.shade400,
              ],
              stops: const [0.2, 1.0],
              radius: 0.7,
            ),
            boxShadow: [
              BoxShadow(
                  color: Color.lerp(Colors.purpleAccent, Colors.pinkAccent, _dragValue)!.withOpacity(
                      lerpDouble(0.5, 0.8, _dragValue)! + pulseGlow // Parlama ekle
                  ),
                  blurRadius: lerpDouble(10, 16, _dragValue)! + (pulseGlow * 12),
                  spreadRadius: lerpDouble(2, 4, _dragValue)! + (pulseGlow * 3))
            ],
          ),
          // Daire içindeki ikon
          child: Center(
            child: Icon(
              Icons.auto_awesome, // Yıldız ikonu
              color: Color.lerp(Colors.deepPurple.shade900, Colors.white, _dragValue * 1.8)!.withOpacity(0.9),
              size: lerpDouble(28, 34, _dragValue)!,
            ),
          ),
        ),
      ),
    );
  }

}


// --- Custom Clipper (Alan Kırpıcı - Slide Butonu İçin Gerekli) ---
// Bu widget, kaydırma sırasında ortaya çıkan metnin ve dolgu efektinin
// sadece kaydırılan alan kadar görünmesini sağlar.
class _SlideAreaClipper extends CustomClipper<Rect> {
  final double clipAmount; // Ne kadar alanın gösterileceği (piksel)
  final double handleSize; // Handle boyutu (kırpma buna göre ayarlanır)

  _SlideAreaClipper({required this.clipAmount, required this.handleSize});

  @override
  Rect getClip(Size size) {
    // Soldan başlayarak 'clipAmount' genişliğinde bir dikdörtgen alanı görünür kıl.
    // clipAmount'ın 0 ile size.width arasında kalmasını sağla.
    return Rect.fromLTWH(0, 0, clipAmount.clamp(0.0, size.width), size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    // Sadece clipAmount değiştiğinde tekrar kırpma yap (performans için)
    return oldClipper is! _SlideAreaClipper ||
        oldClipper.clipAmount != clipAmount ||
        oldClipper.handleSize != handleSize;
  }
}


// --- String Extension (İlk Harfleri Büyütmek İçin) ---
// NOT: Bu extension'ı projenizde genel bir yardımcı (utility) dosyasına
// taşımak (örn: lib/utils/string_extensions.dart) daha iyi bir pratiktir.
extension StringExtension on String {
  /// Her kelimenin ilk harfini büyük yapar. Örn: "hello world" -> "Hello World"
  /// Birden fazla boşluğu tek boşluğa indirger.
  String capitalizeFirstofEach() => replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.isNotEmpty
      ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}'
      : '')
      .join(" ");
}