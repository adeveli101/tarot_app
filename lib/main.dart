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
import 'data/payment_maganer.dart';
import 'data/tarot_event_state.dart';
import 'firebase_options.dart';
import 'gemini_service.dart';
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
    locale: savedLanguage ?? 'tr', // Varsayılan dil Türkçe
  );

  // PaymentManager'ı başlatıyoruz
  final paymentManager = PaymentManager();
  paymentManager.initialize();

  runApp(MyApp(
    initialLocale: savedLanguage != null ? Locale(savedLanguage) : null,
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale ?? const Locale('tr'); // Varsayılan dil Türkçe
    _tarotBloc = widget.tarotBloc;
    _tarotBloc.add(LoadTarotCards()); // Kartları yükle
  }

  Future<void> changeLocale(Locale newLocale, BuildContext context) async {
    setState(() => _isLoading = true);

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
        _isLoading = false;
      });
    }
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
        navigatorKey: navigatorKey, // Global navigator key eklendi
        title: 'Tarot Falı',
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
        home: Builder(
          builder: (context) => Stack(
            children: [
              FutureBuilder<bool>(
                future: _checkLanguageSelection(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                  }
                  if (snapshot.data == true) {
                    return TarotReadingScreen(
                      onSettingsTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(
                              onLocaleChange: changeLocale,
                              currentLocale: _locale,
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return LanguageSelectionScreen(
                    onLocaleSelected: changeLocale,
                  );
                },
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.8),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.deepPurple),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _checkLanguageSelection() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') != null;
  }
}

class LanguageSelectionScreen extends StatelessWidget {
  final Future<void> Function(Locale, BuildContext) onLocaleSelected;

  const LanguageSelectionScreen({super.key, required this.onLocaleSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Select your language / Dilinizi seçin',
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            TapAnimatedScale(
              onTap: () => onLocaleSelected(const Locale('en'), context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple[700]!, Colors.deepPurple[900]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'English',
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TapAnimatedScale(
              onTap: () => onLocaleSelected(const Locale('tr'), context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple[700]!, Colors.deepPurple[900]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Türkçe',
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}