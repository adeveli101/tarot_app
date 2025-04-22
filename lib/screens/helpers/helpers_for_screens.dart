import 'dart:async';
import 'dart:math'; // 'pi' için
import 'dart:math' as math; // 'max' ve 'min' için (math ön ekiyle)
import 'dart:ui';
// lerpDouble için

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/data/tarot_event_state.dart';
import 'package:tarot_fal/data/tarot_repository.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/models/tarot_card.dart';
import 'package:tarot_fal/screens/reading_result.dart';
import '../../data/payment_manager.dart'; // Import PaymentManager
import '../../models/animations/tap_animations_scale.dart';
import 'package:intl/intl.dart';


class ReadingResultScreenWithTransition extends StatefulWidget {
  const ReadingResultScreenWithTransition({super.key});

  @override
  ReadingResultScreenWithTransitionState createState() => ReadingResultScreenWithTransitionState();
}

class ReadingResultScreenWithTransitionState extends
State<ReadingResultScreenWithTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _transitioning = false; // Tekrar tekrar geçişi engellemek için

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      // Animasyon süresini biraz uzatarak daha yumuşak bir his verelim
      duration: const Duration(seconds: 1, milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut, // Yumuşak çıkış efekti
    );

    // Widget ağaca eklendikten sonra animasyonu ve geçişi başlat
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTransition());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Animasyonu başlatır ve tamamlandığında sonuç ekranına yönlendirir.
  void _startTransition() async {
    // Eğer zaten geçiş yapılıyorsa veya widget dispose edildiyse tekrar başlatma
    if (_transitioning || !mounted) return;
    _transitioning = true;

    try {
      // Animasyonu ileri doğru oynat (görünür hale getir)
      await _animationController.forward().orCancel;

      // Widget hala bağlıysa (ekrandan kaldırılmadıysa)
      if (mounted) {
        // Asıl sonuç ekranına değiştirerek git (geri dönülemeyecek şekilde)
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const ReadingResultScreen(), // Sonuç ekranı
            transitionsBuilder: (_, animation, __, child) {
              // Yeni ekranın solma efektiyle gelmesini sağla
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600), // Geçiş süresi
          ),
        );
      }
    } on TickerCanceled {
      // Animasyon iptal edilirse logla (nadiren olur)
      if (kDebugMode) print("ReadingResultScreenWithTransition animation cancelled.");
      if(mounted) _transitioning = false;
    } catch (e) {
      // Geçiş sırasında bir hata olursa logla ve belki geri dön
      if (kDebugMode) {
        print("ReadingResultScreenWithTransition hatası: $e");
      }
      if (mounted) {
        _transitioning = false;
        // Hata durumunda kullanıcıyı bilgilendirip geri göndermek iyi olabilir
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bir hata oluştu.")));
        // Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context); // Yerelleştirme

    return Scaffold(
      body: Container(
        // Arka plan gradient'i (diğer ekranlarla tutarlı)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple[900]!, Colors.black],
            stops: const [0.0, 0.8], // Gradient durak noktaları
          ),
        ),
        child: Center(
          // İçeriği solma efektiyle göster
          child: FadeTransition(
            opacity: _fadeAnimation, // Fade animasyonunu uygula
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie animasyonu
                Lottie.asset(
                  'assets/animations/tarot_loading.json', // Yükleme animasyonunuz
                  width: 180,
                  height: 180,
                  repeat: true,
                ),
                const SizedBox(height: 35), // Boşluk
                // Yükleme metni
                Text(
                  loc?.unveilingMysticalPath ?? 'Mistik Yol Açılıyor...', // Yerelleştirilmiş metin
                  style: GoogleFonts.cinzel( // Temaya uygun font
                    fontSize: 19, // Biraz daha büyük
                    color: Colors.white.withOpacity(0.85), // Daha belirgin renk
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5, // Harf aralığı
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




/// Kullanıcının kartları çekmek için yatay olarak kaydırması gereken buton.
class SlideToDrawButton extends StatefulWidget {
  final VoidCallback onDrawComplete; // Kaydırma tamamlandığında tetiklenir

  const SlideToDrawButton({
    super.key,
    required this.onDrawComplete,
  });

  @override
  SlideToDrawButtonState createState() => SlideToDrawButtonState();
}

class SlideToDrawButtonState extends State<SlideToDrawButton> with TickerProviderStateMixin {
  // --- State ve Animasyon Değişkenleri ---
  double _dragValue = 0.0; // 0.0 (başlangıç) ile 1.0 (bitiş) arası kaydırma değeri
  bool _isDragging = false; // Kullanıcı şu anda butonu kaydırıyor mu?

  // Animasyon kontrolcüleri
  late AnimationController _pulseController; // Bekleme durumundaki hafif parlama efekti için
  late AnimationController _resetController; // Başarısız kaydırma sonrası geri dönüş animasyonu için
  late AnimationController _successController; // Başarılı kaydırma sonrası efekt için

  // Animasyonlar
  late Animation<double> _pulseAnimation;
  late Animation<double> _resetAnimation;
  late Animation<double> _successScaleAnimation; // Başarıda hafif büyüme
  late Animation<double> _successGlowAnimation; // Başarıda parlama

  // Buton boyutları ve animasyon süreleri
  final double _buttonWidth = 280.0; // Buton genişliği
  final double _handleSize = 60.0; // Kaydırılan dairenin boyutu
  final Duration _resetDuration = const Duration(milliseconds: 350); // Geri dönüş süresi
  final Duration _successDuration = const Duration(milliseconds: 500); // Başarı animasyon süresi

  @override
  void initState() {
    super.initState();

    // Pulse Animasyonu (bekleme durumu)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500), // Daha yavaş bir pulse
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);

    // Reset Animasyonu (başarısız kaydırma)
    _resetController = AnimationController(duration: _resetDuration, vsync: this);
    // _resetAnimation, _onDragEnd içinde dinamik olarak oluşturulur (başlangıç değeri için)
    _resetAnimation = CurvedAnimation(parent: _resetController, curve: Curves.easeOutCirc)
      ..addListener(() {
        if (mounted) {
          // Geri dönüş animasyonu sırasında _dragValue'yu güncelle
          setState(() => _dragValue = lerpDouble(_resetAnimation.value, 0.0, _resetController.value)!);
        }
      })
      ..addStatusListener((status) {
        // Reset bittiğinde ve sürüklenmiyorsa pulse animasyonunu tekrar başlat
        if (status == AnimationStatus.completed) {
          if (mounted && !_isDragging) _pulseController.repeat(reverse: true);
        }
      });

    // Success Animasyonu (başarılı kaydırma)
    _successController = AnimationController(duration: _successDuration, vsync: this);
    _successScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate( // Biraz daha belirgin büyüme
        CurvedAnimation(parent: _successController, curve: Curves.elasticOut) // Elastik efekt
    );
    _successGlowAnimation = TweenSequence<double>([ // Parlama efekti (hızlı artıp yavaş sönme)
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.8), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 0.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _successController, curve: Curves.easeOut));

    // Başarı animasyonu bittiğinde onDrawComplete callback'ini çağır ve resetle
    _successController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDrawComplete();
        // Kısa bir bekleme sonrası reset animasyonunu başlat
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _resetAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
                CurvedAnimation(parent: _resetController, curve: Curves.easeOutCirc)
            );
            _resetController.forward(from: 0.0);
            // Başarı animasyonunu sıfırla
            _successController.reset();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _resetController.dispose();
    _successController.dispose();
    super.dispose();
  }

  // --- Sürükleme Olay Yöneticileri ---

  void _onDragStart(DragStartDetails details) {
    // Eğer zaten sürükleniyorsa veya animasyonlar aktifse yeni sürüklemeyi başlatma
    if (_isDragging || _resetController.isAnimating || _successController.isAnimating) return;
    if (mounted) {
      setState(() {
        _isDragging = true;
        _resetController.stop(); // Reset animasyonunu durdur
        _pulseController.stop(); // Pulse animasyonunu durdur
      });
    }
    HapticFeedback.lightImpact(); // Hafif titreşim
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging || !mounted) return;
    setState(() {
      // Sürükleme mesafesini hesapla ve _dragValue'yu güncelle (0.0 - 1.0 arasında)
      final currentDragPixels = _dragValue * (_buttonWidth - _handleSize);
      final newDragPixels = (currentDragPixels + details.delta.dx).clamp(0.0, _buttonWidth - _handleSize);
      _dragValue = newDragPixels / (_buttonWidth - _handleSize);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging || !mounted) return;

    // Başarı eşiğini kontrol et (%85'ten fazla kaydırıldıysa başarılı say)
    final bool success = _dragValue > 0.85;

    if (success) {
      HapticFeedback.heavyImpact(); // Başarıda güçlü titreşim
      setState(() { _dragValue = 1.0; }); // Tamamla
      _successController.forward(from: 0.0); // Başarı animasyonunu başlat
    } else {
      // Başarısızsa, mevcut pozisyondan başa dönme animasyonunu başlat
      HapticFeedback.lightImpact();
      // Reset animasyonunu mevcut _dragValue'dan başlatacak şekilde ayarla
      _resetAnimation = Tween<double>(begin: _dragValue, end: 0.0).animate(
          CurvedAnimation(parent: _resetController, curve: Curves.easeOutCirc)
      );
      _resetController.forward(from: 0.0);
    }
    setState(() => _isDragging = false); // Sürükleme bitti
  }

  // --- Build Metodu ---

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context); // Yerelleştirme
    // Kaydırılan dairenin anlık yatay pozisyonu
    final handlePosition = _dragValue * (_buttonWidth - _handleSize);

    // Başlangıçtaki "Kaydır..." metninin opaklığı ve pozisyonu (kaydırdıkça kaybolur)
    final initialTextOpacity = math.max(0.0, 1.0 - _dragValue * 3.5); // Daha hızlı kaybolsun
    final initialTextOffset = lerpDouble(0, -50, _dragValue)!; // Biraz daha fazla kaysın
    final initialTextLeftPadding = _handleSize + 15.0; // Daireden sonraki boşluk

    // Ortaya çıkan "Mistik..." metninin opaklığı (belirli bir noktadan sonra görünür olur)
    final mysticTextOpacity = math.max(0.0, (_dragValue - 0.3) * 2.0).clamp(0.0, 1.0); // Daha belirgin geçiş

    // Ana Buton Widget'ı
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _successController, // Başarı animasyonunu dinle
        builder: (context, child) {
          final successScale = _successScaleAnimation.value; // Başarıdaki ölçek değeri
          final successGlow = _successGlowAnimation.value; // Başarıdaki parlama değeri

          // Başarı animasyonu için Transform.scale
          return Transform.scale(
            scale: successScale,
            child: Container(
              width: _buttonWidth,
              height: _handleSize,
              // Kenarlardan taşan efektleri gizle (özellikle gradient geçişi için)
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                // Arka plan gradient'i (kaydırmaya göre renk değiştirir)
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade800.withOpacity(0.8),
                      // Renk geçişi (mordan pembeye)
                      Color.lerp(Colors.deepPurple.shade800, Colors.pinkAccent.shade400, _dragValue)!
                    ],
                    stops: [0.0, _dragValue + 0.1], // Gradient'in nerede biteceğini ayarla
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(_handleSize / 2), // Yuvarlak kenarlar
                  boxShadow: [ // Gölge (kaydırmaya ve başarıya göre değişir)
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
                  // Kenarlık (başarıda daha belirgin)
                  border: Border.all(color: Colors.purpleAccent.withOpacity(0.3 + successGlow * 0.5), width: 1.5)
              ),
              // İçerik Katmanları (Stack ile)
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // 1. Katman: Başlangıç metni ("Kaydır...")
                  Positioned(
                    left: initialTextLeftPadding,
                    right: _handleSize * 0.05, // Sağdan hafif boşluk
                    top: 0, bottom: 0, // Dikeyde ortala
                    child: Center(
                      child: Opacity(
                        opacity: initialTextOpacity, // Kaydırdıkça kaybolur
                        child: Transform.translate(
                          offset: Offset(initialTextOffset, 0), // Sola doğru kayar
                          child: Text(
                            loc?.slideToDrawCards ?? 'Kart Çekmek İçin Kaydır', // Yerelleştirme
                            style: GoogleFonts.cinzel(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                                decoration: TextDecoration.none // Önemli: Stack içinde alt çizgi olmasın
                            ),
                            overflow: TextOverflow.clip, // Taşmayı engelle
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. Katman: Kaydırma alanının dolgu efekti ve ortaya çıkan metin
                  Positioned.fill(
                    child: ClipRect(
                      // Sadece kaydırılan alan kadarını göster
                      clipper: _SlideAreaClipper(
                          clipAmount: handlePosition + (_handleSize * 0.6), // Dairenin biraz ötesine kadar
                          handleSize: _handleSize
                      ),
                      child: Container(
                        // Dolgu efekti gradient'i
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
                        // Ortaya çıkan metin ("Mistik...")
                        child: Padding(
                          padding: EdgeInsets.only(right: _handleSize * 0.4), // Dairenin üzerine gelmesin
                          child: Opacity(
                            opacity: mysticTextOpacity, // Belirli bir noktadan sonra görünür olur
                            child: Text(
                              // loc.unveilTheStars gibi bir anahtar kullanın
                              loc?.unveilTheStars ?? 'Yıldızları Açığa Çıkar',
                              style: GoogleFonts.cinzelDecorative(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  decoration: TextDecoration.none
                              ),
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. Katman: Kaydırılan Daire (Handle) ve Pulse Efekti
                  AnimatedBuilder(
                    animation: _pulseAnimation, // Pulse animasyonunu dinle
                    builder: (context, child) {
                      // Sadece bekleme durumunda pulse efekti uygula
                      final bool canPulse = !_isDragging && !_resetController.isAnimating && !_successController.isAnimating;
                      final double pulseScale = canPulse ? (1.0 + (_pulseAnimation.value * 0.08)) : 1.0; // Biraz daha belirgin pulse scale
                      final double pulseGlow = canPulse ? (_pulseAnimation.value * 0.25) : 0.0; // Biraz daha belirgin pulse glow

                      // Dairenin anlık pozisyonu
                      return Positioned(
                        left: handlePosition,
                        child: Transform.scale(
                          scale: pulseScale, // Pulse ölçeklemesi
                          child: Container(
                            width: _handleSize,
                            height: _handleSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // Daire gradient'i
                              gradient: RadialGradient(
                                colors: [
                                  Colors.pinkAccent.shade100, // İç renk
                                  Colors.purpleAccent.shade400, // Dış renk
                                ],
                                stops: const [0.2, 1.0],
                                radius: 0.7,
                              ),
                              // Gölge (kaydırma ve pulse'a göre değişir)
                              boxShadow: [
                                BoxShadow(
                                    color: Color.lerp(Colors.purpleAccent, Colors.pinkAccent, _dragValue)!.withOpacity(
                                        lerpDouble(0.5, 0.8, _dragValue)! + pulseGlow // Parlama ekle
                                    ),
                                    blurRadius: lerpDouble(10, 16, _dragValue)! + (pulseGlow * 12),
                                    spreadRadius: lerpDouble(2, 4, _dragValue)! + (pulseGlow * 3)
                                )
                              ],
                            ),
                            // Daire içindeki ikon
                            child: Center(
                              child: Icon(
                                Icons.auto_awesome, // Yıldız ikonu
                                // İkon rengi ve boyutu kaydırmaya göre değişir
                                color: Color.lerp(Colors.deepPurple.shade900, Colors.white, _dragValue * 1.8)!.withOpacity(0.9),
                                size: lerpDouble(28, 34, _dragValue)!,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- Custom Clipper (Alan Kırpıcı - Slide Butonu İçin Gerekli) ---
class _SlideAreaClipper extends CustomClipper<Rect> {
  final double clipAmount; // Ne kadar alanın gösterileceği (piksel)
  final double handleSize; // Dairenin boyutu (kırpma buna göre ayarlanır)

  _SlideAreaClipper({required this.clipAmount, required this.handleSize});

  @override
  Rect getClip(Size size) {
    // Soldan başlayarak 'clipAmount' genişliğinde bir dikdörtgen alanı görünür kıl
    return Rect.fromLTWH(0, 0, clipAmount.clamp(0.0, size.width), size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    // Sadece clipAmount değiştiğinde tekrar kırpma yap
    return oldClipper is! _SlideAreaClipper || oldClipper.clipAmount != clipAmount;
  }
}

// --- String Extension (İlk Harfleri Büyütmek İçin) ---
// Bu extension, başka yerlerde de kullanılabilir. Ayrı bir dosyaya (örn: lib/utils/string_extensions.dart) taşımak daha iyi olabilir.
extension StringExtension on String {
  /// Her kelimenin ilk harfini büyük yapar. Örn: "hello world" -> "Hello World"
  String capitalizeFirstofEach() => replaceAll(RegExp(' +'), ' ') // Birden fazla boşluğu tek boşluğa indirge
      .split(" ") // Boşluklardan ayır
      .map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}' : '') // İlk harfi büyüt, kalanı küçült
      .join(" "); // Tekrar birleştir
}

