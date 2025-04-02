import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tarot_fal/generated/l10n.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _titleController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeInOut),
    );

    _requestNotificationPermission(); // Hata 3 çözümü
    _titleController.forward().then((_) {
      if (mounted) {
        widget.onFinish();
      }
    });
  }

  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
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
          frameRate: FrameRate(30),
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

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildGradientOverlay(),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                  _buildTitle()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildTitle() {
    final loc = S.of(context);

    return Column(
      children: [
        AnimatedBuilder(
          animation: _titleController,
          builder: (context, child) {
            final shimmerValue = sin(_titleController.value * pi * 2) * 0.5 + 0.5;

            return ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.white,
                  Color(0xFFE6E6FA),
                  Colors.purpleAccent.shade100,
                  Colors.white,
                ],
                stops: [0.0, shimmerValue * 0.5, shimmerValue, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                ' ASTRAL TAROT ',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                  color: Colors.white,
                  decoration: TextDecoration.none, // Alt çizgi kaldırıldı
                  shadows: [
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
        SizedBox(height: MediaQuery.of(context).size.height * 0.001),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.purple[200]!.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            loc!.unveilTheStars,
            style: GoogleFonts.cinzel(
              color: Colors.purple[100]!.withOpacity(0.7),
              fontSize: 16,
              letterSpacing: 4,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none, // Alt çizgi kaldırıldı
            ),
          ),
        ),
      ],
    );
  }

}
