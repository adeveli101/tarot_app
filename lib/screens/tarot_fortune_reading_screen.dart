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
    super.dispose();
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
    final loc = S.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Ana İçerik Alanı
          BlocConsumer<TarotBloc, TarotState>(
            listener: (context, state) {
              if (state is CouponRedeemed) {
                ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(loc.couponRedeemed(state.message)), backgroundColor: Colors.green[700]),);
              } else if (state is CouponInvalid) {
                ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(loc.couponInvalid(state.message)), backgroundColor: Colors.orange[800]),);
              } else if (state is TarotError) {
                ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(loc.errorMessage(state.message)), backgroundColor: Colors.redAccent),);
              }
            },
            builder: (context, state) {
              // Yükleme durumunda arka plan müziğini duraklat (isteğe bağlı)
              // if (state is TarotLoading && _backgroundMusicPlayer.state == PlayerState.playing) {
              //   _backgroundMusicPlayer.pause();
              // } else if (state is! TarotLoading && _backgroundMusicPlayer.state == PlayerState.paused) {
              //   _backgroundMusicPlayer.resume();
              // }

              if (state is TarotLoading && state is! TarotInitial) {
                return _buildLoadingWidget();
              }
              return _buildMainContent(context, state);
            },
          ),
          // Üst Bar
          _buildTopBar(context),
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
                    // <<< Tooltipler Geri Eklendi >>>
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
  Widget _buildLeftTopBar(BuildContext context) {
    final loc = S.of(context)!;
    return BlocBuilder<TarotBloc, TarotState>(
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
              // --- Token Göstergesi (Tıklanabilir) ---
              Tooltip( // <<< Tooltip Eklendi >>>
                message: loc.creditInfoTooltip,
                child: GestureDetector( // <<< Tıklama Eklendi >>>
                  onTap: () {
                    _playSound(_clickSoundPath);
                    PaymentManager.showPaymentDialog(context, onSuccess: () {
                      // Başarılı satın alma sonrası BLoC'u güncellemek için event gönderilebilir
                      // context.read<TarotBloc>().add(FetchUserDataEvent()); // Örnek event
                      if (kDebugMode) print("Ödeme başarılı, UI güncellenebilir.");
                    });
                  },
                  child: _buildTokenDisplay(context, state.userTokens),
                ),
              ),
              // --- Kupon Kullan Butonu ---
              Tooltip( // <<< Tooltip Eklendi >>>
                message: loc.redeemCouponTooltip,
                child: _buildCompactRedeemButton(context),
              ),
              // --- Günlük Ödül/Sayaç ---
              if (state.isDailyTokenAvailable)
                Tooltip( // <<< Tooltip Eklendi >>>
                  message: loc.claimDailyRewardTooltip,
                  child: _buildCompactClaimButton(context),
                )
              else if (state.nextDailyTokenTime != null && state.nextDailyTokenTime!.isAfter(DateTime.now()))
              // <<< Sayaç da Tıklanabilir ve Tooltip Eklendi >>>
                GestureDetector(
                  onTap: () {
                    _playSound(_clickSoundPath);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.dailyRewardInfo), // Yerelleştirilmiş bilgi
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  child: DailyTokenCountdownTimerCompact(
                    key: ValueKey(state.nextDailyTokenTime), // Key önemli
                    targetTime: state.nextDailyTokenTime!,
                    localization: loc, // Yerelleştirme objesi geçildi
                  ),
                )
              else
                const SizedBox.shrink(), // Hiçbir şey gösterme
            ],
          ),
        );
      },
    );
  }


  /// Token ikonunu ve miktarını gösterir (Yatay taşma düzeltmeli).
  Widget _buildTokenDisplay(BuildContext context, double userTokens) {
    // Tokena tıklandığında satın alma ekranını açmak için GestureDetector ile sarıldı
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
        _playSound(_clickSoundPath); // <<< Tıklama sesi eklendi
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

  /// Kompakt günlük ödül alma butonu (ikon). Tooltip kaldırıldı.
  /// Kompakt günlük ödül alma butonu (YAZI).
  Widget _buildCompactClaimButton(BuildContext context) {
    final loc = S.of(context)!; // Yerelleştirme için

    return TapAnimatedScale(
      onTap: () {
        // _playSound(_clickSoundPath); // İstersen sesi tekrar aktif edebilirsin
        HapticFeedback.lightImpact();
        context.read<TarotBloc>().add(ClaimDailyToken());
      },
      child: Container(
        // Padding'i ayarlayarak yazıya uygun hale getir
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Daha geniş yatay padding
        decoration: BoxDecoration(
          // shape: BoxShape.circle, // Daire şeklini kaldır
            borderRadius: BorderRadius.circular(15), // Yuvarlak köşeler ekle
            gradient: LinearGradient( colors: [Colors.amber[500]!, Colors.orange[700]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
            boxShadow: [ BoxShadow( color: Colors.yellow.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)],
            border: Border.all(color: Colors.white.withOpacity(0.7), width: 0.8)
        ),
        // Icon yerine Text kullan
        child: Text(
          loc.claim,
          style: GoogleFonts.cinzel( // Stili ayarla
            color: Colors.white,
            fontSize: 11, // Boyutu ayarla
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
  /// Üst bar butonları (Tooltip Geri Eklendi).
  Widget _buildAppBarButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip, // <<< Tooltip parametresi geri eklendi
    required VoidCallback onPressed,})
  {
    return Tooltip( // <<< Tooltip widget'ı eklendi
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: Colors.white.withOpacity(0.85), size: 24),
        onPressed: onPressed, // Ses efekti onPressed içinde çağrılacak
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

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "00:00:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_remainingTime <= Duration.zero) {
      return const SizedBox.shrink();
    }
    final formattedTime = _formatDuration(_remainingTime);

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
//---------- Bitti: Günlük Token Geri Sayım Sayacı Widget'ı ----------