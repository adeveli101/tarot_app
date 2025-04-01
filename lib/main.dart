import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/data/tarot_repository.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/screens/settings_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tarot_fal/screens/tarot_fortune_reading_screen.dart';
import 'data/payment_manager.dart';
import 'data/tarot_event_state.dart';
import 'firebase_options.dart';
import 'gemini_service.dart';
import 'models/animations/language_selections_screen.dart';
import 'models/animations/splash_screen.dart';
import 'models/animations/tap_animations_scale.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();
  final String? savedLanguage = prefs.getString('language');

  final tarotBloc = TarotBloc(
    repository: TarotRepository(),
    geminiService: GeminiService(),
    locale: savedLanguage ?? 'tr',
  );

  final paymentManager = PaymentManager();
  paymentManager.initialize();

  runApp(MyApp(
    initialLocale: savedLanguage != null ? Locale(savedLanguage) : const Locale('tr'),
    tarotBloc: tarotBloc,
    paymentManager: paymentManager,
  ));
}

class MyApp extends StatefulWidget {
  final Locale? initialLocale;
  final TarotBloc tarotBloc;
  final PaymentManager paymentManager;

  const MyApp({
    super.key,
    this.initialLocale,
    required this.tarotBloc,
    required this.paymentManager,
  });

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late Locale _locale;
  late TarotBloc _tarotBloc;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale ?? const Locale('tr');
    _tarotBloc = widget.tarotBloc;
    _tarotBloc.add(LoadTarotCards());
  }

  Future<void> changeLocale(Locale newLocale, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLocale.languageCode);

    await _tarotBloc.close();
    _tarotBloc = TarotBloc(
      repository: TarotRepository(),
      geminiService: GeminiService(),
      locale: newLocale.languageCode,
    )..add(LoadTarotCards());

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _locale = newLocale;
      });
      _navigateToHome(context);
    }
  }

  Future<bool> _checkLanguageSelection() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 3)); // Splash ekranı en az 3 saniye görünecek
    return prefs.getString('language') != null;
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SettingsScreen(
          onLocaleChange: changeLocale,
          currentLocale: _locale,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => TarotReadingScreen(
          onSettingsTap: () => _navigateToSettings(context),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOutExpo));
          return FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 1000), // Daha yavaş geçiş
      ),
    );
  }

  @override
  void dispose() {
    _tarotBloc.close();
    widget.paymentManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _tarotBloc,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Astral Tarot',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: Colors.grey[900],
          fontFamily: GoogleFonts.cinzel().fontFamily,
        ),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('tr'),
        ],
        locale: _locale,
        home: FutureBuilder<bool>(
          future: _checkLanguageSelection(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SplashScreen(
                onFinish: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (snapshot.connectionState == ConnectionState.done && mounted) {
                      Future.delayed(const Duration(milliseconds: 500), () { // Gecikme 500 ms
                        if (snapshot.hasData && snapshot.data!) {
                          _navigateToHome(context); // Fade ile geçiş
                        } else {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => LanguageSelectionScreen(
                                onLocaleSelected: changeLocale,
                              ),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOutExpo));
                                return FadeTransition(
                                  opacity: animation.drive(fadeTween),
                                  child: child,
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 1000), // Daha yavaş geçiş
                            ),
                          );
                        }
                      });
                    }
                  });
                },
              );
            }
            return snapshot.data == true
                ? TarotReadingScreen(
              onSettingsTap: () => _navigateToSettings(context),
            )
                : LanguageSelectionScreen(
              onLocaleSelected: changeLocale,
            );
          },
        ),
      ),
    );
  }
}