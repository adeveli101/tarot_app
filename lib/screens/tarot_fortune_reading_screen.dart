// ignore_for_file: dead_code

import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart'; // CardSelection için eklendi
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart'; // CardSelection için eklendi

// Projenizin doğru import yolları ile değiştirin
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/screens/profile_page.dart'; // ProfilePage importu
import 'package:tarot_fal/data/payment_manager.dart'; // PaymentManager importu
import 'package:tarot_fal/data/tarot_event_state.dart';
import 'package:tarot_fal/models/animations/tap_animations_scale.dart';
import 'package:tarot_fal/models/tarot_card.dart'; // CardSelection için eklendi
import 'package:tarot_fal/data/tarot_repository.dart'; // CardSelection için eklendi
import 'package:tarot_fal/screens/reading_result.dart';

import 'card_selection_animation.dart'; // ReadingResultScreen importu

//---------- TarotReadingScreen Başlangıcı ----------

class TarotReadingScreen extends StatefulWidget {
  final VoidCallback? onSettingsTap; // Nullable callback

  const TarotReadingScreen({super.key, this.onSettingsTap}); // required kaldırıldı

  @override
  State<TarotReadingScreen> createState() => _TarotReadingScreenState();
}

class _TarotReadingScreenState extends State<TarotReadingScreen> with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _glowController;

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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  // Yerelleştirme fallback'li ödeme dialogu
  // ignore: unused_element
  void _showPaymentDialog(BuildContext context, double requiredTokens) {
    final loc = S.of(context);
    PaymentManager.showPaymentDialog(
      context,
      requiredTokens: requiredTokens,
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(loc!.paymentSuccessful), // Fallback eklendi
              backgroundColor: Colors.green),
        );
      },
    );
  }

  // Kupon Sheet gösterme
  void _showCouponSheet(BuildContext context) {
    final paymentManager = PaymentManager();
    paymentManager.initialize();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, animation1, animation2) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              // BlocProvider.value burada gerekli olabilir, CouponSheet'in Bloc'a ihtiyacı varsa
              child: BlocProvider.value(
                value: context.read<TarotBloc>(), // Mevcut Bloc'u sağla
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

  // Profil sayfasına gitme
  void _navigateToProfilePage(BuildContext context) {
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

  // Kategori seçim sheet'ini gösterme
  void _showCategorySheet(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => BlocProvider.value( // Bloc'u aktar
          value: BlocProvider.of<TarotBloc>(context),
          child: const CategorySelectionSheet(), // Bu dosyadaki CategorySelectionSheet'i çağır
        ));
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          BlocConsumer<TarotBloc, TarotState>(
            listener: (context, state) {
              // !!! DÜZELTME: CardSelectionAnimationScreen'e yönlendiren listener kaldırıldı !!!
              /*
              if (state is SingleCardDrawn || state is SpreadDrawn) {
                // ... eski yönlendirme kodu ...
              } else */
              if (state is InsufficientResources) {
                if (kDebugMode) {
                  print("Listener (TarotReadingScreen): InsufficientResources detected.");
                }
                // Ana ekranda ödeme dialogunu göstermek yerine,
                // ilgili işlem (örn: spread seçimi) sırasında kontrol etmek daha mantıklı olabilir.
                // _showPaymentDialog(context, state.requiredTokens);
              } else if (state is CouponRedeemed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(loc!.couponRedeemed(state.message)),
                      backgroundColor: Colors.green[700]),
                );
              } else if (state is CouponInvalid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(loc!.couponInvalid(state.message)),
                      backgroundColor: Colors.orange[800]),
                );
              } else if (state is TarotError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(loc!.errorMessage(state.message)),
                      backgroundColor: Colors.redAccent),
                );
              }
            },
            builder: (context, state) {
              // TarotInitial hariç loading durumları
              if (state is TarotLoading && state is! TarotInitial) {
                return _buildLoadingWidget();
              }
              return _buildMainContent(context, state);
            },
          ),
          // Üst Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(child: _buildUserInfoBar(context)),
                        const SizedBox(width: 8),
                        Flexible(child: _buildRedeemButton(context)),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAppBarButton(
                        context: context,
                        icon: Icons.person_outline,
                        tooltip: loc!.profile,
                        onPressed: () => _navigateToProfilePage(context),
                      ),
                      const SizedBox(width: 4),
                      _buildAppBarButton(
                        context: context,
                        icon: Icons.settings_outlined,
                        tooltip: loc.settings,
                        onPressed: widget.onSettingsTap ?? () {}, // Null kontrolü eklendi
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TarotReadingScreen Helper Widget'ları ---

  Widget _buildLoadingWidget() {
    return Center(
      child: Lottie.asset(
        'assets/animations/tarot_loading.json',
        width: 200,
        height: 200,
        frameRate: FrameRate(60),
      ),
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
          frameRate: FrameRate(60),
          repeat: true,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple[800]!.withOpacity(0.45),
                Colors.black.withOpacity(0.7),
              ],
              stops: const [0.3, 1.1],
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildTitle(BuildContext context) {
    final loc = S.of(context);
    return Column(
      children: [
        AnimatedBuilder(
          animation: _titleController,
          builder: (context, child) {
            final shimmerValue = (sin(_titleController.value * 2 * pi) + 1) / 2;
            return ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [ Colors.white, Colors.purpleAccent.shade100.withOpacity(0.8), Colors.white, Colors.purpleAccent.shade100.withOpacity(0.8), Colors.white,],
                stops: [ 0.0, (shimmerValue * 0.4).clamp(0.0, 1.0), (shimmerValue * 0.8).clamp(0.0, 1.0), (shimmerValue * 1.2).clamp(0.0, 1.0), 1.0,],
                tileMode: TileMode.mirror, transform: GradientRotation(pi / 4),
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              blendMode: BlendMode.srcIn,
              child: Text(
                ' ASTRAL TAROT ',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzelDecorative(
                  fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: 5, color: Colors.white,
                  shadows: [ Shadow(color: Colors.purple[700]!.withOpacity(0.7), offset: const Offset(2, 3), blurRadius: 10),],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Text(
          loc!.unveilTheStars,
          style: GoogleFonts.cinzel( color: Colors.purple[100]!.withOpacity(0.8), fontSize: 15, letterSpacing: 3, fontWeight: FontWeight.w500,),
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

  // Başlat Butonu Widget'ı (Geliştirilmiş ve Hata Düzeltilmiş)
  Widget _buildStartButton(BuildContext context, TarotState state) {
    final loc = S.of(context);
    // Başlatma koşulu (her zaman başlatılabilir yapıldı, kontrolü kaldırdık)
    final bool canStart = true; // Veya eski kontrol: state.dailyFreeFalCount < maxFreeReadsPerDay || state.userTokens >= minTokensRequired;

    return TapAnimatedScale(
      // !!! DÜZELTME: onTap için boş fonksiyon atandı !!!
      onTap: canStart
          ? () { // canStart true ise asıl fonksiyon
        HapticFeedback.lightImpact();
        _showCategorySheet(context); // Kategori seçimini aç
      }
          : () {}, // canStart false ise boş fonksiyon (tip uyumu için)
      child: AnimatedBuilder( // Parlama animasyonu için
        animation: _glowController,
        builder: (context, child) {
          // Parlama yoğunluğu (sadece canStart ise)
          final double glow = canStart ? (sin(_glowController.value * pi) * 0.4 + 0.3) : 0.0;
          return Container(
            width: MediaQuery.of(context).size.width * 0.65, // Biraz daha geniş
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18), // İç boşluklar
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: canStart
                    ? [Colors.purple[800]!, Colors.indigo[900]!] // Aktif renkler
                    : [Colors.grey[800]!, Colors.grey[900]!], // Pasif renkler
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(35), // Daha yuvarlak kenarlar
              boxShadow: [ // Gölge efekti
                BoxShadow(
                  color: canStart
                      ? Colors.purpleAccent.withOpacity(glow) // Aktif parlama
                      : Colors.black.withOpacity(0.4), // Pasif gölge
                  blurRadius: 18, // Daha yumuşak gölge
                  spreadRadius: 2,
                ),
              ],
              border: Border.all( // Çerçeve
                color: canStart
                    ? Colors.purpleAccent.withOpacity(0.5) // Aktif çerçeve
                    : Colors.grey[700]!, // Pasif çerçeve
                width: 1.5,
              ),
            ),
            child: Row( // İkon ve Metin
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome, // Yıldız ikonu
                  color: Colors.white.withOpacity(canStart ? 1.0 : 0.5),
                  size: 20,
                  shadows: canStart ? [Shadow(color: Colors.white.withOpacity(0.5), blurRadius: 5)] : null,
                ),
                const SizedBox(width: 12),
                Text(
                  loc!.startJourney, // Buton metni (Fallback eklendi)
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    fontSize: 16, // Biraz daha küçük font
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2, // Harf aralığı
                    color: Colors.white.withOpacity(canStart ? 1.0 : 0.6), // Pasifse soluklaştır
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text( infoText, style: GoogleFonts.cinzel( color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w400,), textAlign: TextAlign.center,),
    );
  }

  Widget _buildUserInfoBar(BuildContext context) {
    final loc = S.of(context);
    return BlocBuilder<TarotBloc, TarotState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[700]!.withOpacity(0.8), Colors.deepPurple[800]!.withOpacity(0.9)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 3, offset: const Offset(0, 1)) ],
          ),
          // Ana Row'un taşmasını önlemek için Flexible veya Expanded eklemeye gerek yok,
          // çünkü bu widget zaten dışarıda bir Flexible içinde.
          // Ancak iç Row'un içeriğini yönetmemiz gerekiyor.
          child: Row(
            mainAxisSize: MainAxisSize.min, // Row'un sadece içeriği kadar yer kaplamasını sağlar
            children: [
              Icon( Icons.stars, color: Colors.yellowAccent[100], size: 14), // Boyutu biraz küçülttük
              const SizedBox(width: 4),
              // Token Miktarı - Çok uzayabilir diye Flexible içine alalım
              Flexible(
                child: Text(
                  state.userTokens.toStringAsFixed(1),
                  style: GoogleFonts.orbitron( color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), // Font boyutunu biraz küçülttük
                  overflow: TextOverflow.clip, // Taşarsa ... göster
                  maxLines: 1, // Tek satırda kalmasını sağla
                ),
              ),
              const SizedBox(width: 4),
              // "Mystical Tokens" Yazısı - Bu da uzayabilir, Flexible içine alalım
              Flexible(
                child: Text(
                  loc!.mysticalTokens, // Fallback eklendi
                  style: GoogleFonts.cinzel( color: Colors.white.withOpacity(0.8), fontSize: 9), // Font boyutunu biraz küçülttük
                  overflow: TextOverflow.ellipsis, // Taşarsa ... göster
                  maxLines: 1, // Tek satırda kalmasını sağla
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildRedeemButton(BuildContext context) {
    final loc = S.of(context);
    return TapAnimatedScale(
      onTap: () { HapticFeedback.lightImpact(); _showCouponSheet(context); },
      child: Container( padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration( color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.purpleAccent.withOpacity(0.4), width: 1),),
        child: Row( mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.card_giftcard, color: Colors.amber[300], size: 12),
            const SizedBox(width: 6),
            Text( loc!.redeem, style: GoogleFonts.cinzel( color: Colors.white.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.w500),),
          ],),),);
  }

  Widget _buildAppBarButton({ required BuildContext context, required IconData icon, required String tooltip, required VoidCallback onPressed}) {
    return IconButton( icon: Icon(icon, color: Colors.white.withOpacity(0.8), size: 24), tooltip: tooltip, onPressed: onPressed, splashRadius: 20, splashColor: Colors.purpleAccent.withOpacity(0.3), highlightColor: Colors.purpleAccent.withOpacity(0.2),);
  }
}

//---------- TarotReadingScreen Sonu ----------

//---------- CategorySelectionSheet Başlangıcı ----------

class CategorySelectionSheet extends StatelessWidget {
  const CategorySelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.85, minChildSize: 0.4, maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
            gradient: LinearGradient( colors: [Colors.deepPurple[900]!, Colors.black87], begin: Alignment.topLeft, end: Alignment.bottomRight,),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)), border: Border.all(color: Colors.purpleAccent.withOpacity(0.2))),
        child: Stack( children: [
          Column( children: [
            _buildSheetHeader(context, loc!.categorySelection, loc.chooseTopic),
            Expanded( child: ListView( controller: scrollController, padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 10),
              children: [
                _buildCategoryTile( context: context, title: loc.loveRelationships, description: loc.loveDescription, icon: Icons.favorite_border, categoryKey: 'love',), const SizedBox(height: 14),
                _buildCategoryTile( context: context, title: loc.career, description: loc.careerDescription, icon: Icons.business_center_outlined, categoryKey: 'career',), const SizedBox(height: 14),
                _buildCategoryTile( context: context, title: loc.money, description: loc.moneyDescription, icon: Icons.monetization_on_outlined, categoryKey: 'money',), const SizedBox(height: 14),
                _buildCategoryTile( context: context, title: loc.general, description: loc.generalDescription, icon: Icons.lightbulb_outline, categoryKey: 'general',), const SizedBox(height: 14),
                _buildCategoryTile( context: context, title: loc.spiritualMystical, description: loc.spiritualMysticalDescription, icon: Icons.auto_awesome_outlined, categoryKey: 'spiritual',), const SizedBox(height: 30),
              ],),),],),
          Positioned( top: 12, right: 12, child: _buildCloseButton(context),),
        ],),),);
  }

  Widget _buildSheetHeader(BuildContext context, String title, String subtitle) {
    return Container( padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
      child: Column( mainAxisSize: MainAxisSize.min,
        children: [
          Container( width: 50, height: 5, decoration: BoxDecoration( color: Colors.white.withOpacity(0.4), borderRadius: BorderRadius.circular(2.5),),), const SizedBox(height: 20),
          Text( title, style: GoogleFonts.cinzelDecorative( fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5,),), const SizedBox(height: 8),
          Text( subtitle, textAlign: TextAlign.center, style: GoogleFonts.cinzel( fontSize: 15, color: Colors.white.withOpacity(0.7),),),
          Divider(color: Colors.purpleAccent.withOpacity(0.2), height: 30, thickness: 1),
        ],),);
  }

  Widget _buildCategoryTile({ required BuildContext context, required String title, required String description, required IconData icon, required String categoryKey,}) {
    return TapAnimatedScale(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push( context, MaterialPageRoute( builder: (_) => BlocProvider.value( value: context.read<TarotBloc>(), child: SpreadSelectionSheet(categoryKey: categoryKey),)),);
      },
      child: Container( padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration( gradient: LinearGradient( colors: [ Colors.purple[800]!.withOpacity(0.5), Colors.indigo[900]!.withOpacity(0.6),], begin: Alignment.centerLeft, end: Alignment.centerRight,),
            borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.purpleAccent.withOpacity(0.3), width: 1), boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, offset: Offset(0, 2)) ]),
        child: Row( children: [
          Container( padding: const EdgeInsets.all(10), decoration: BoxDecoration( color: Colors.purpleAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.amber[300], size: 26),), const SizedBox(width: 16),
          Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text( title, style: GoogleFonts.cinzel( fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white,),), const SizedBox(height: 6),
              Text( description, style: GoogleFonts.lato( fontSize: 13, color: Colors.white.withOpacity(0.7), height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis,),
            ],),), const SizedBox(width: 10),
          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.5), size: 18)
        ],),),);
  }

  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector( onTap: () => Navigator.pop(context),
      child: Container( padding: const EdgeInsets.all(8),
        decoration: BoxDecoration( shape: BoxShape.circle, color: Colors.black.withOpacity(0.5), boxShadow: [ BoxShadow( color: Colors.purple[300]!.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2), ), ],),
        child: const Icon(Icons.close, color: Colors.white70, size: 22),),);
  }
}

//---------- CategorySelectionSheet Sonu ----------


//---------- SpreadSelectionSheet Başlangıcı ----------

class SpreadSelectionSheet extends StatefulWidget {
  final String categoryKey;

  const SpreadSelectionSheet({super.key, required this.categoryKey});

  @override
  SpreadSelectionSheetState createState() => SpreadSelectionSheetState();
}

class SpreadSelectionSheetState extends State<SpreadSelectionSheet> {
  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final spreads = _getSpreadsForCategory(widget.categoryKey, context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9, width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient( colors: [Colors.deepPurple[900]!, Colors.black.withOpacity(0.95)], begin: Alignment.topCenter, end: Alignment.bottomCenter,),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),),
      child: Stack( children: [
        CustomScrollView( slivers: [
          SliverPadding( padding: const EdgeInsets.only(top: 20), sliver: SliverToBoxAdapter( child: _buildSheetHeader(loc!.spreadSelection, loc.chooseSpread),),),
          SliverPadding( padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            sliver: SliverList( delegate: SliverChildBuilderDelegate( (context, index) {
              if (index >= spreads.length) return null; final spreadData = spreads[index];
              return Padding( padding: const EdgeInsets.only(bottom: 14),
                child: _buildSpreadTile( context: context, title: spreadData['title'], description: spreadData['description'], spreadType: spreadData['spreadType'], categoryKey: widget.categoryKey,),);},
              childCount: spreads.length,),),),
          const SliverToBoxAdapter( child: SizedBox(height: 60),),],),
        Positioned( top: 60, right: 12, child: _buildCloseButton(context),),
      ],),);
  }

  Widget _buildSheetHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.cinzelDecorative(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
              decoration: TextDecoration.none, // <-- EKLENDİ
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontSize: 15,
              color: Colors.white.withOpacity(0.7),
              decoration: TextDecoration.none, // <-- ZATEN VARDI/EKLENDİ
            ),
          ),
          Divider(color: Colors.purpleAccent.withOpacity(0.2), height: 30, thickness: 1),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getSpreadsForCategory(String categoryKey, BuildContext context) {
    final loc = S.of(context);
    switch (categoryKey) {
      case 'love': return [ {'title': loc!.singleCard, 'description': loc.singleCardDescription,
        'spreadType': SpreadType.singleCard}, {'title': loc.relationshipSpread,
        'description': loc.relationshipSpreadDescription, 'spreadType': SpreadType.relationshipSpread},
        {'title': loc.brokenHeart, 'description': loc.brokenHeartDescription,
          'spreadType': SpreadType.brokenHeart}, {'title': loc.pastPresentFuture,
          'description': loc.pastPresentFutureDescriptionLove, 'spreadType': SpreadType.pastPresentFuture},
        {'title': loc.mindBodySpirit, 'description': loc.mindBodySpiritDescriptionLove,
          'spreadType': SpreadType.mindBodySpirit}, {'title': loc.fullMoonSpread, 'description': loc.fullMoonSpreadDescriptionLove, 'spreadType': SpreadType.fullMoonSpread},];
      case 'career': return [ {'title': loc!.singleCard, 'description': loc.singleCardDescription, 'spreadType': SpreadType.singleCard}, {'title': loc.pastPresentFuture, 'description': loc.pastPresentFutureDescription, 'spreadType': SpreadType.pastPresentFuture}, {'title': loc.fiveCardPath, 'description': loc.fiveCardPathDescription, 'spreadType': SpreadType.fiveCardPath}, {'title': loc.careerPathSpread, 'description': loc.careerPathSpreadDescription, 'spreadType': SpreadType.careerPathSpread}, {'title': loc.problemSolution, 'description': loc.problemSolutionDescriptionCareer, 'spreadType': SpreadType.problemSolution}, {'title': loc.horseshoeSpread, 'description': loc.horseshoeSpreadDescriptionCareer, 'spreadType': SpreadType.horseshoeSpread},];
      case 'money': return [ {'title': loc!.singleCard, 'description': loc.singleCardDescription, 'spreadType': SpreadType.singleCard}, {'title': loc.problemSolution, 'description': loc.problemSolutionDescriptionMoney, 'spreadType': SpreadType.problemSolution}, {'title': loc.horseshoeSpread, 'description': loc.horseshoeSpreadDescriptionMoney, 'spreadType': SpreadType.horseshoeSpread}, {'title': loc.pastPresentFuture, 'description': loc.pastPresentFutureDescriptionMoney, 'spreadType': SpreadType.pastPresentFuture}, {'title': loc.careerPathSpread, 'description': loc.careerPathSpreadDescriptionMoney, 'spreadType': SpreadType.careerPathSpread},];
      case 'general': return [ {'title': loc!.singleCard, 'description': loc.singleCardDescription, 'spreadType': SpreadType.singleCard}, {'title': loc.celticCrossReading, 'description': loc.celticCrossDescription, 'spreadType': SpreadType.celticCross}, {'title': loc.yearlySpreadReading, 'description': loc.yearlySpreadDescription, 'spreadType': SpreadType.yearlySpread}, {'title': loc.astroLogicalCross, 'description': loc.astroLogicalCrossDescriptionGeneral, 'spreadType': SpreadType.astroLogicalCross}, {'title': loc.horseshoeSpread, 'description': loc.horseshoeSpreadDescriptionGeneral, 'spreadType': SpreadType.horseshoeSpread}, {'title': loc.pastPresentFuture, 'description': loc.pastPresentFutureDescriptionGeneral, 'spreadType': SpreadType.pastPresentFuture},];
      case 'spiritual': return [ {'title': loc!.singleCard, 'description': loc.singleCardDescription, 'spreadType': SpreadType.singleCard}, {'title': loc.mindBodySpirit, 'description': loc.mindBodySpiritDescriptionSpiritual, 'spreadType': SpreadType.mindBodySpirit}, {'title': loc.dreamInterpretation, 'description': loc.dreamInterpretationDescriptionSpiritual, 'spreadType': SpreadType.dreamInterpretation}, {'title': loc.fullMoonSpread, 'description': loc.fullMoonSpreadDescriptionSpiritual, 'spreadType': SpreadType.fullMoonSpread}, {'title': loc.astroLogicalCross, 'description': loc.astroLogicalCrossDescriptionSpiritual, 'spreadType': SpreadType.astroLogicalCross}, {'title': loc.celticCrossReading, 'description': loc.celticCrossDescriptionSpiritual, 'spreadType': SpreadType.celticCross},];
      default: return [];
    }
  }

  Widget _buildSpreadTile({
    required BuildContext context,
    required String title,
    required String description,
    required SpreadType spreadType,
    required String categoryKey,
  }) {
    final loc = S.of(context);
    final int cardCount = spreadType.cardCount;
    final double cost = spreadType.costInCredits;

    return TapAnimatedScale(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<TarotBloc>(),
              child: CardSelectionAnimationScreen(
                spreadType: spreadType,
                categoryKey: categoryKey,
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple[800]!.withOpacity(0.5),
              Colors.indigo[900]!.withOpacity(0.6),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.purpleAccent.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.cinzel(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      decoration: TextDecoration.none, // <-- EKLENDİ
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    loc!.cardCount(cardCount),
                    style: GoogleFonts.cinzel(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none, // <-- EKLENDİ
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.lato(
                fontSize: 13,
                color: Colors.white.withOpacity(0.7),
                height: 1.3,
                decoration: TextDecoration.none, // <-- EKLENDİ
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.yellowAccent.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars_rounded, color: Colors.yellowAccent[100], size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${cost.toStringAsFixed(1)} ${loc.mysticalTokens}',
                      style: GoogleFonts.orbitron(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none, // <-- EKLENDİ
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector( onTap: () => Navigator.pop(context),
      child: Container( padding: const EdgeInsets.all(8),
        decoration: BoxDecoration( shape: BoxShape.circle, color: Colors.black.withOpacity(0.5), boxShadow: [ BoxShadow( color: Colors.purple[300]!.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2), ), ],),
        child: const Icon(Icons.close, color: Colors.white70, size: 22),),);
  }
}