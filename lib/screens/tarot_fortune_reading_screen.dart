// lib/screens/tarot_fortune_reading_screen.dart

// ignore_for_file: dead_code, unused_element

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart'; // <-- Ses için eklendi

// Projenizin doğru import yolları
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/screens/profile_page.dart';
import 'package:tarot_fal/data/payment_manager.dart';
import 'package:tarot_fal/data/tarot_event_state.dart';
import 'package:tarot_fal/models/animations/tap_animations_scale.dart';
import 'package:tarot_fal/screens/card_selection_animation.dart';
import 'package:tarot_fal/screens/category_selection_sheet.dart';

//---------- TarotReadingScreen Başlangıcı ----------

class TarotReadingScreen extends StatefulWidget {
  final VoidCallback? onSettingsTap;

  const TarotReadingScreen({super.key, this.onSettingsTap});

  @override
  State<TarotReadingScreen> createState() => _TarotReadingScreenState();
}

class _TarotReadingScreenState extends State<TarotReadingScreen> with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _glowController;

  // --- Ses Çalarlar ---
  late AudioPlayer _backgroundMusicPlayer;
  late AudioPlayer _soundEffectPlayer;
  bool _isMusicInitialized = false; // Müziğin başlatılıp başlatılmadığını kontrol et

  final String _backgroundMusicPath = 'audios/ritualistic3.mp3'; // Örnek yol
  final String _clickSoundPath = 'sounds/click.mp3';           // Örnek yol
  final String _startButtonSoundPath = 'sounds/start_button.mp3'; // Örnek yol


  late AnimationController _dailyRewardGlowController; // <-- YENİ: Günlük ödül butonu için animasyon kontrolcüsü
// <-- YENİ: Ödül hazır sesi (varsa)

  @override
  void initState() {
    super.initState();
    _titleController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Ses çalarları başlat
    _backgroundMusicPlayer = AudioPlayer();
    _soundEffectPlayer = AudioPlayer();
    // Arka plan müziği için ID belirleyerek aynı anda çalmasını engelle
    //_backgroundMusicPlayer.setPlayerId('background_music');
    // Efektler için ID belirleyerek aynı anda çalmasını engelleme (isteğe bağlı)
    // _soundEffectPlayer.setPlayerId('sound_effects');

    _dailyRewardGlowController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    // Bloc state'i dinleyerek animasyonu başlat/durdur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateRewardGlowAnimation(context.read<TarotBloc>().state.isDailyTokenAvailable);
    });



    // Ses efektleri için durdurma modunu ayarla (tekrar çalmadan önce bitmesini sağla)
    _soundEffectPlayer.setReleaseMode(ReleaseMode.loop);

    // Arka plan müziğini başlat
    // initState içinde async işlem yapmamak için WidgetsBinding kullan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAndPlayBackgroundMusic();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _glowController.dispose();
    // Ses çalarları durdur ve kaynakları serbest bırak
    _backgroundMusicPlayer.stop();
    _backgroundMusicPlayer.dispose();
    _soundEffectPlayer.stop(); // Efektler anlık olduğu için stop yeterli olabilir
    _soundEffectPlayer.dispose();

    _dailyRewardGlowController.dispose();

    super.dispose();
  }


  void _updateRewardGlowAnimation(bool isAvailable) {
    if (!mounted) return; // Widget ağaçtan kaldırıldıysa işlem yapma
    if (isAvailable) {
      if (!_dailyRewardGlowController.isAnimating) {
        _dailyRewardGlowController.repeat(reverse: true);
        // _playSound(_rewardReadySoundPath); // Ödül hazır olduğunda ses çal (opsiyonel)
      }
    } else {
      if (_dailyRewardGlowController.isAnimating) {
        _dailyRewardGlowController.stop();
        _dailyRewardGlowController.value = 0; // Animasyonu başa sar
      }
    }
  }


  void _showClaimTokenPopup(BuildContext context) {
    final loc = S.of(context)!;
    // _playSound(_clickSoundPath); // Popup açma sesi (opsiyonel)

    showDialog(
      context: context,
      barrierDismissible: true, // Dışarı tıklayarak kapatılabilir
      builder: (BuildContext dialogContext) {
        // Dialog içinde Bloc erişimi gerekiyorsa BlocProvider.value kullanılabilir
        // Ancak burada sadece event göndereceğimiz için BuildContext yeterli.
        return AlertDialog(
          backgroundColor: Colors.deepPurple[900]?.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(color: Colors.purpleAccent.withOpacity(0.5)),
          ),
          title: Row(
            children: [
              Icon(Icons.card_giftcard_rounded, color: Colors.amber[300], size: 28),
              const SizedBox(width: 10),
              Text(
                loc.dailyRewardNotificationTitle, // l10n: "Günlük Ödül" (eklenmeli)
                style: GoogleFonts.cinzel(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            // l10n: "Günlük {tokenAmount} kredinizi almak için butona tıklayın!" (eklenmeli)
            // Sabit değeri veya BLoC'tan gelen değeri kullanabilirsiniz.
            loc.rewardNotificationBody(TarotBloc.dailyLoginTokens.toStringAsFixed(0)),
            style: GoogleFonts.cinzel(color: Colors.white.withOpacity(0.9), fontSize: 14),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                loc.cancel, // l10n: "İptal"
                style: GoogleFonts.cinzel(color: Colors.white70),
              ),
              onPressed: () {
                // _playSound(_clickSoundPath); // İptal sesi (opsiyonel)
                Navigator.of(dialogContext).pop(); // Dialog'u kapat
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                loc.claim, // l10n: "Ödülü Al" (eklenmeli)
                style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                // _playSound(_claimRewardSoundPath); // Ödül alma sesi (opsiyonel)
                HapticFeedback.lightImpact();
                // Dialog'u kapatmadan ÖNCE event'i gönderiyoruz
                context.read<TarotBloc>().add(ClaimDailyToken());
                Navigator.of(dialogContext).pop(); // Dialog'u kapat
              },
            ),
          ],
        );
      },
    );
  }

  // --- Arka Plan Müziği Başlatma ---
  Future<void> _initAndPlayBackgroundMusic() async {
    if (_isMusicInitialized) return; // Zaten başlatıldıysa tekrar başlatma
    try {
      await _backgroundMusicPlayer.setSource(AssetSource(_backgroundMusicPath));
      await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop); // Döngüye al
      await _backgroundMusicPlayer.resume(); // Müziği başlat/devam ettir
      _isMusicInitialized = true; // Başlatıldı olarak işaretle
      if (kDebugMode) {
        print("Arka plan müziği başlatıldı: $_backgroundMusicPath");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Arka plan müziği yüklenirken/çalınırken hata: $e");
      }
      // Hata durumunda kullanıcıya bilgi verilebilir (isteğe bağlı)
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Müzik yüklenemedi.")));
    }
  }


  // --- Ses Efekti Yardımcı Metodu ---
  Future<void> _playSound(String soundPath) async {
    try {
      // Efekt sesi kaynağını ayarla ve çal
      await _soundEffectPlayer.play(AssetSource(soundPath));
      if (kDebugMode) {
        print("Ses efekti çalındı: $soundPath");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Ses efekti çalınırken hata ($soundPath): $e");
      }
    }
  }

  /// Kupon giriş sheet'ini gösterir.
  void _showCouponSheet(BuildContext context) {
    _playSound(_clickSoundPath); // <<< Tıklama sesi eklendi
    final loc = S.of(context)!;
    final paymentManager = PaymentManager();
    paymentManager.initialize();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, animation1, animation2) {
        return BlocProvider.value(
          value: context.read<TarotBloc>(),
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: CouponSheet(manager: paymentManager),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.7, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutExpo),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    ).whenComplete(() => paymentManager.dispose());
  }

  /// Profil sayfasına yönlendirme yapar.
  void _navigateToProfilePage(BuildContext context) {
    _playSound(_clickSoundPath); // <<< Tıklama sesi eklendi
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ProfilePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOutQuart));
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  /// Kategori seçim sheet'ini gösterir.
  void _showCategorySheet(BuildContext context) {
    // _playSound(_startButtonSoundPath); // Başlat butonu kendi sesini çalıyor
    HapticFeedback.selectionClick();
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => BlocProvider.value(
          value: BlocProvider.of<TarotBloc>(context),
          child: const CategorySelectionSheet(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context)!; // Yerelleştirme için build başında al
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black, // Arka plan rengi
      body: Stack( // Ana layout Stack
        children: [
          // Ana İçerik Alanı (BlocConsumer ile yönetilir)
          BlocConsumer<TarotBloc, TarotState>(
            // BlocConsumer state değişikliklerini dinler ve UI'ı günceller
            listener: (context, state) {

              // ------------ YENİ EKLEMELER BAŞLANGIÇ ------------
              // Günlük ödül butonu animasyonunu state değişikliğine göre güncelle
              _updateRewardGlowAnimation(state.isDailyTokenAvailable);
              // ------------ YENİ EKLEMELER SON ------------

              // --- Ödül Alındı Popup Gösterimi ---
              if (state is DailyTokenClaimSuccess) {
                // SnackBar gösterimi mevcut haliyle kalıyor, iyi çalışıyor.
                if (state.nextDailyTokenTime != null) {
                  final remainingDuration = state.nextDailyTokenTime!.difference(DateTime.now());
                  final displayDuration = remainingDuration.isNegative ? Duration.zero : remainingDuration;
                  final formattedTime = formatTimeDuration(displayDuration);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.dailyRewardClaimedMessage(formattedTime)),
                      duration: const Duration(seconds: 4), // Biraz daha uzun gösterilebilir
                      backgroundColor: Colors.green[700],
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      action: SnackBarAction(
                        label: loc.close, // l10n: "Kapat" (veya Tamam)
                        textColor: Colors.white,
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                      ),
                    ),
                  );
                }
              }
              // --- Diğer State'ler için Listener'lar (Kupon, Hata vb.) ---
              else if (state is CouponRedeemed) {
                ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(loc.couponRedeemed(state.message)), backgroundColor: Colors.green[700]),);
              } else if (state is CouponInvalid) {
                ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(loc.couponInvalid(state.message)), backgroundColor: Colors.orange[800]),);
              } else if (state is TarotError) {
                if (kDebugMode) {
                  print("TarotError Listener: ${state.message}");
                } // Konsola yazdır
                // ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(loc.errorMessage(state.message)), backgroundColor: Colors.redAccent),);
              }
              // --- InsufficientResources için Listener ---
              else if (state is InsufficientResources) {
                // Ödeme dialogunu göster (Mevcut PaymentManager kullanımı)
                PaymentManager.showPaymentDialog(context, onSuccess: () {
                  // Başarılı olursa belki kullanıcı verilerini yeniden çekmek gerekebilir
                  context.read<TarotBloc>().add(LoadTarotCards()); // Veya özel bir event
                  if (kDebugMode) print("Ödeme başarılı, UI güncellenebilir.");
                });
              }
            },
            builder: (context, state) {
              // State'e göre ana içeriği veya yükleme göstergesini oluştur
              if (state is TarotLoading && state is! TarotInitial && state is! DailyTokenClaimSuccess && state is! CouponRedeemed && state is! CouponInvalid) {
                // Sadece belirli durumlarda yükleme göster
                return _buildLoadingWidget();
              }
              // Diğer durumlarda ana içeriği göster
              return _buildMainContent(context, state);
            },
          ),

          // Üst Bar (Her zaman görünür, Stack'in üzerinde)
          _buildTopBar(context),


          // if (kDebugMode) // Sadece debug modunda göster
          //   Positioned(
          //     bottom: 10, // Konumunu ayarlayabilirsiniz
          //     right: 10,
          //     child: FloatingActionButton(
          //       mini: true, // Küçük buton
          //       tooltip: 'Reset Daily Reward (DEBUG)',
          //       backgroundColor: Colors.redAccent.withOpacity(0.7),
          //       onPressed: () {
          //         // Sıfırlama event'ini gönder
          //         context.read<TarotBloc>().add(ResetDailyRewardForTesting());
          //         // Kullanıcıya geri bildirim ver (opsiyonel)
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           const SnackBar(
          //             content: Text("DEBUG: Günlük Ödül Sıfırlandı!"),
          //             duration: Duration(seconds: 1),
          //           ),
          //         );
          //       },
          //       child: const Icon(Icons.refresh, size: 20),
          //     ),
          //   ),
          // --- YENİ TEST BUTONU SON ---



         ],
      ),
     );


  }
  // ===========================================================================
  // --- Yardımcı Widget'lar ---
  // ===========================================================================

  Widget _buildLoadingWidget() {
    return Center(
      child: Lottie.asset('assets/animations/tarot_loading.json', width: 200, height: 200, frameRate: FrameRate(60),),
    );
  }

  Widget _buildMainContent(BuildContext context, TarotState state) {
    final loc = S.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackground(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 25),

                _buildTitle(context),
                const Spacer(flex: 2),
                _buildMainCard(context, state),
                const Spacer(flex: 1),
                _buildBottomInfo(loc!.differentInterpretation),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard(BuildContext context, TarotState state) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
        child: _buildStartButton(context, state),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack( fit: StackFit.expand, children: [ Image.asset( 'assets/image_fx_c.jpg', fit: BoxFit.cover,), Lottie.asset( 'assets/animations/tarot_shuffle.json', fit: BoxFit.contain, frameRate: FrameRate(60), repeat: true,), Container( decoration: BoxDecoration( gradient: LinearGradient( begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ Colors.deepPurple[800]!.withOpacity(0.45), Colors.black.withOpacity(0.7),], stops: const [0.3, 1.0], ), ), ), ], );
  }

  Widget _buildTitle(BuildContext context) {
    final loc = S.of(context)!;
    return Column( mainAxisSize: MainAxisSize.min, children: [ AnimatedBuilder( animation: _titleController, builder: (context, child) { final shimmerValue = (sin(_titleController.value * 2 * pi) + 1) / 2; return ShaderMask( shaderCallback: (bounds) => LinearGradient( colors: [ Colors.white, Colors.purpleAccent.shade100.withOpacity(0.8), Colors.white, Colors.purpleAccent.shade100.withOpacity(0.8), Colors.white,], stops: [ 0.0, (shimmerValue * 0.4).clamp(0.0, 1.0), (shimmerValue * 0.8).clamp(0.0, 1.0), (shimmerValue * 1.2).clamp(0.0, 1.0), 1.0,], tileMode: TileMode.mirror, transform: const GradientRotation(pi / 4), ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)), blendMode: BlendMode.srcIn, child: Text( loc.tarotFortune, textAlign: TextAlign.center, style: GoogleFonts.cinzelDecorative( fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 5, color: Colors.white, shadows: [ Shadow(color: Colors.purple[700]!.withOpacity(0.7), offset: const Offset(2, 3), blurRadius: 10),], ), ), ); }, ), const SizedBox(height: 10), Text( loc.unveilTheStars, style: GoogleFonts.cinzel( color: Colors.purple[100]!.withOpacity(0.8), fontSize: 15, letterSpacing: 3, fontWeight: FontWeight.w500,), ), ], );
  }

  Widget _buildStartButton(BuildContext context, TarotState state) {
    final loc = S.of(context)!;
    const bool canStart = true; // Başlatma butonu her zaman aktif varsayıyoruz
    return TapAnimatedScale(
      onTap: canStart
          ? () {
        // <<< Başlatma butonu için özel ses eklendi >>>
        _playSound(_startButtonSoundPath);
        HapticFeedback.lightImpact();
        _showCategorySheet(context);
      }
          : () {}, // Aktif değilse bir şey yapma
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          final double glow = canStart ? (sin(_glowController.value * pi) * 0.4 + 0.3) : 0.0;
          return Container(
            width: MediaQuery.of(context).size.width * 0.65,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: canStart ? [Colors.purple[800]!, Colors.indigo[900]!] : [Colors.grey[800]!, Colors.grey[900]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: canStart ? Colors.purpleAccent.withOpacity(glow) : Colors.black.withOpacity(0.4),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: canStart ? Colors.purpleAccent.withOpacity(0.5) : Colors.grey[700]!,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.white.withOpacity(canStart ? 1.0 : 0.5),
                  size: 20,
                  shadows: canStart ? [Shadow(color: Colors.white.withOpacity(0.5), blurRadius: 5)] : null,
                ),
                const SizedBox(width: 12),
                Text(
                  loc.startJourney,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: Colors.white.withOpacity(canStart ? 1.0 : 0.6),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _buildBottomInfo(String infoText) {
    return Padding( padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text( infoText, style: GoogleFonts.cinzel( color: Colors.white.withOpacity(0.6),
        fontSize: 12, fontWeight: FontWeight.w900,), textAlign: TextAlign.center,), );
  }

  /// Yeniden tasarlanmış üst bar.
  Widget _buildTopBar(BuildContext context) {
    final loc = S.of(context)!; // Tooltipler için loc eklendi
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Sol Taraf
            Flexible(
              flex: 3,
              child: _buildLeftTopBar(context),
            ),
            // Sağ Taraf (FittedBox ile sarıldı)
            Flexible(
              flex: 1,
              child: FittedBox( // <-- Yatay taşmayı önlemek için eklendi
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAppBarButton( context: context, icon: Icons.person_outline_rounded, tooltip: loc.profile, onPressed: () { _navigateToProfilePage(context); },),
                    _buildAppBarButton( context: context, icon: Icons.settings_outlined, tooltip: loc.settings, onPressed: () { _playSound(_clickSoundPath); widget.onSettingsTap?.call(); },),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  /// Üst barın sol tarafını oluşturur (Token, Kupon, Ödül).
  /// Üst barın sol tarafını oluşturur (Token, Kupon, Ödül).
  Widget _buildLeftTopBar(BuildContext context) {
    final loc = S.of(context)!;
    return BlocBuilder<TarotBloc, TarotState>(
      // buildWhen state'i aynı kalabilir, gösterilecek widget'ı etkileyen state'leri dinler
      buildWhen: (prev, curr) =>
      prev.userTokens != curr.userTokens ||
          prev.isDailyTokenAvailable != curr.isDailyTokenAvailable ||
          prev.nextDailyTokenTime != curr.nextDailyTokenTime,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Wrap( // Farklı ekran boyutlarına uyum için Wrap
            spacing: 8.0,
            runSpacing: 4.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // --- Token Göstergesi ---
              Tooltip(
                message: loc.creditInfoTooltip,
                child: GestureDetector(
                  onTap: () {          PaymentManager.showPaymentDialog(context);
                  },
                  child: _buildTokenDisplay(context, state.userTokens),
                ),
              ),
              // --- Kupon Kullan Butonu ---
              Tooltip(
                message: loc.redeemCouponTooltip,
                child: _buildCompactRedeemButton(context),
              ),

              // --- GÜNCELLENMİŞ GÜNLÜK ÖDÜL GÖSTERİM MANTIĞI ---
              if (state.isDailyTokenAvailable)
              // 1. Durum: Ödül alınabilir -> Aktif Buton
                Tooltip(
                  message: loc.claimDailyRewardTooltip,
                  child: _buildCompactClaimButton(context), // Aktif, animasyonlu buton
                )
              else if (state.nextDailyTokenTime != null &&
                  state.nextDailyTokenTime!.isAfter(DateTime.now()))
              // 2. Durum: Ödül alınamaz & Sonraki zaman gelecek bir tarih -> Sayaç
                GestureDetector(
                  onTap: () { Tooltip(
                    message: loc.claimDailyRewardTooltip,
                    child: _buildCompactClaimButton(context), // Aktif, animasyonlu buton
                  ); },



                  child: DailyTokenCountdownTimerCompact(
                    key: ValueKey(state.nextDailyTokenTime),
                    targetTime: state.nextDailyTokenTime!,
                    localization: loc,
                  ),
                )
              else
              // 3. Durum: Ödül alınamaz & Sonraki zaman gelecek bir tarih DEĞİL -> İnaktif Buton
              // Bu durum genellikle ödülün o gün içinde alındığı anlamına gelir.
                _buildInactiveClaimedButton(context), // Yeni inaktif butonumuz
              // --- GÜNCELLENMİŞ GÜNLÜK ÖDÜL GÖSTERİM MANTIĞI SONU ---

            ],
          ),
        );
      },
    );
  }
  /// Token ikonunu ve miktarını gösterir (Yatay taşma düzeltmeli).
  Widget _buildTokenDisplay(BuildContext context, double userTokens) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.deepPurple[900]?.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars_rounded, color: Colors.yellowAccent[100], size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              userTokens.toStringAsFixed(userTokens.truncateToDouble() == userTokens ? 0 : 1),
              style: GoogleFonts.orbitron( color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis, maxLines: 1, softWrap: false,
            ),
          ),
        ],
      ),
    );
  }

  /// Kompakt kupon butonu (ikon). Tooltip kaldırıldı.
  Widget _buildCompactRedeemButton(BuildContext context) {
    return TapAnimatedScale(
      onTap: () {
        _playSound(_clickSoundPath);
        _showCouponSheet(context);
      },
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.purpleAccent.withOpacity(0.5), width: 0.8),
        ),
        child: Icon(Icons.card_giftcard_rounded, color: Colors.amber[300], size: 16),
      ),
    );
  }

  Widget _buildCompactClaimButton(BuildContext context) {
    final loc = S.of(context)!; // Yerelleştirme için

    // Orijinal buton içeriği burada kalacak (Text widget'ı)
    final buttonContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient( colors: [Colors.amber[500]!, Colors.orange[700]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [ BoxShadow( color: Colors.yellow.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)], // Statik parlama
          border: Border.all(color: Colors.white.withOpacity(0.7), width: 0.8)
      ),
      child: Text(
        loc.claim,
        style: GoogleFonts.cinzel(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );

    return TapAnimatedScale(
      onTap: () {
        // Tıklanınca popup'ı göster
        _showClaimTokenPopup(context);
        // Haptic feedback popup içinde verildiği için burada gerek yok
        // HapticFeedback.lightImpact();
      },
      child: AnimatedBuilder( // Animasyonlu parlama ve ölçek için
        animation: _dailyRewardGlowController,
        builder: (context, child) {
          // Animasyon değerine göre bir parlama efekti (örneğin shadow rengi)
          final glowValue = sin(_dailyRewardGlowController.value * pi); // 0-1 arası sinüs dalgası
          final glowColor = Colors.yellowAccent.withOpacity(0.3 + glowValue * 0.5); // 0.3 ile 0.8 arası opaklık
          final scaleValue = 1.0 + glowValue * 0.05; // Hafif boyut animasyonu

          return Transform.scale( // Boyut animasyonu
            scale: scaleValue,
            child: Container(
              // AnimatedBuilder'ın shadow'u Container üzerine uygulaması için
              // iç içe Container kullanıyoruz. Dış Container sadece shadow içindir.
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), // Gölgenin de köşeleri yuvarlak olsun
                boxShadow: [
                  BoxShadow( color: glowColor, blurRadius: 10 + glowValue * 6, spreadRadius: 1 + glowValue * 2),
                ],
              ),
              child: child, // Orijinal buton içeriği (buttonContent)
            ),
          );
        },
        child: buttonContent, // AnimatedBuilder'a orijinal içeriği veriyoruz
      ),
    );
  }

  // --- YENİ WIDGET BAŞLANGIÇ ---
  /// Günlük ödül alındığında gösterilecek inaktif buton.
// --- DÜZELTİLMİŞ WIDGET ---
  /// Günlük ödül alındığında gösterilecek inaktif buton.
  Widget _buildInactiveClaimedButton(BuildContext context) {
    final loc = S.of(context)!; // Yerelleştirme için

    return Tooltip(
      // Hata 1 Düzeltildi: Doğru anahtar kullanıldı ve parametre kaldırıldı.
      message: loc.dailyRewardInfo, // l10n: "Günlük ödül zaten alındı"
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [Colors.grey[700]!, Colors.grey[800]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1))
            ],
            border: Border.all(color: Colors.grey[600]!, width: 0.8)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 12, color: Colors.grey[400]),
            const SizedBox(width: 5),
            Text(
              // Hata 2 Düzeltildi: Doğru anahtar kullanıldı ve parametre kaldırıldı.
              loc.claim, // l10n: "Alındı"
              style: GoogleFonts.cinzel(
                color: Colors.grey[400],
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  // --- DÜZELTİLMİŞ WIDGET SONU ---  // --- YENİ WIDGET SON ---

  /// Üst bar butonları (Tooltip Geri Eklendi).
  Widget _buildAppBarButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,})
  {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: Colors.white.withOpacity(0.85), size: 24),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        splashRadius: 18,
        splashColor: Colors.purpleAccent.withOpacity(0.3),
        highlightColor: Colors.purpleAccent.withOpacity(0.2),
      ),
    );
  }
}
//---------- TarotReadingScreen Sonu ----------


// ===========================================================================
// --- Günlük Token Geri Sayım Sayacı Widget'ı (Tooltip ve Tıklama Eklendi) ---
// ===========================================================================
class DailyTokenCountdownTimerCompact extends StatefulWidget {
  final DateTime targetTime;
  final S localization; // Yerelleştirme objesi

  const DailyTokenCountdownTimerCompact({
    super.key,
    required this.targetTime,
    required this.localization,
  });

  @override
  State<DailyTokenCountdownTimerCompact> createState() => _DailyTokenCountdownTimerCompactState();
}

class _DailyTokenCountdownTimerCompactState extends State<DailyTokenCountdownTimerCompact> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  bool _timerActive = false;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime(calculateOnly: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_remainingTime > Duration.zero && mounted) {
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  void _startTimer() {
    if (_timerActive || !mounted) return;
    _timerActive = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _timer?.cancel();
        _timerActive = false;
        return;
      }
      _updateRemainingTime();
    });
  }

  void _updateRemainingTime({bool calculateOnly = false}) {
    if (!calculateOnly && !mounted) return;
    final now = DateTime.now();
    final remaining = widget.targetTime.difference(now);
    final newRemainingTime = remaining > Duration.zero ? remaining : Duration.zero;
    if (!calculateOnly) {
      if (_remainingTime != newRemainingTime) {
        setState(() {
          _remainingTime = newRemainingTime;
        });
      }
    } else {
      _remainingTime = newRemainingTime;
    }
    if (newRemainingTime <= Duration.zero && _timerActive) {
      _timer?.cancel();
      _timer = null;
      _timerActive = false;
      if (!calculateOnly && mounted && _remainingTime != Duration.zero) {
        setState(() { _remainingTime = Duration.zero; });
      }
      // Süre dolduğunda Bloc'u haberdar et (Opsiyonel, BLoC kendi kontrol edebilir)
      // BlocProvider.of<TarotBloc>(context).add(CheckDailyTokenAvailability());
    }
  }



  @override
  Widget build(BuildContext context) {
    if (_remainingTime <= Duration.zero) {
      return const SizedBox.shrink();
    }
    final formattedTime = formatTimeDuration(_remainingTime); // Bununla değiştir.

    // <<< Tooltip Eklendi >>>
    return Tooltip(
      message: widget.localization.nextRewardTooltip(formattedTime), // Yerelleştirilmiş tooltip
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.cyanAccent.withOpacity(0.4), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, color: Colors.cyanAccent[100], size: 14),
            const SizedBox(width: 4),
            Text(
              formattedTime,
              style: GoogleFonts.orbitron(
                color: Colors.cyanAccent[100],
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
String formatTimeDuration(Duration duration) {
  if (duration.isNegative) return "00:00:00";
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$hours:$minutes:$seconds";
}