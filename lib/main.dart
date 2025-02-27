import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/data/tarot_repository.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/screens/settings_screen.dart';
import 'package:tarot_fal/screens/tarot_fortune_reading_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/tarot_event_state.dart';
import 'firebase_options.dart';
import 'gemini_service.dart';

// ============================================================================
// Sayfa 1: Giriş ve Başlangıç
// Amaç: Uygulamanın temel bağımlılıklarını ve başlangıç noktasını tanımlar.
// ============================================================================

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");

  // Satın alma işlemlerini başlat
  final InAppPurchase inAppPurchase = InAppPurchase.instance;
  final bool available = await inAppPurchase.isAvailable();

  if (available) {
    // Ürün detaylarını yükle
    final productIds = SpreadType.allProductIds;
    final ProductDetailsResponse response = await inAppPurchase.queryProductDetails(productIds.toSet());

    // Hata varsa logla
    if (response.error != null) {
      print('Ürün detayları yüklenirken hata: ${response.error}');
    }
  }

  final prefs = await SharedPreferences.getInstance();
  final String? savedLanguage = prefs.getString('language');

  runApp(MyApp(initialLocale: savedLanguage != null ? Locale(savedLanguage) : null));
}


// ============================================================================
// Sayfa 2: MyApp Sınıfı ve Durum Yönetimi
// Amaç: Uygulamanın ana widget'ını ve durum yönetimini içerir.
// ============================================================================

class MyApp extends StatefulWidget {
  final Locale? initialLocale;

  const MyApp({super.key, this.initialLocale});

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
    _tarotBloc = TarotBloc(
      repository: TarotRepository(),
      geminiService: GeminiService(),
      locale: _locale.languageCode,
    )..add(LoadTarotCards());
  }

  Future<void> changeLocale(Locale newLocale, BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLocale.languageCode);

    // Bloc’u kapatıp yeniden başlat
    _tarotBloc.close();
    _tarotBloc = TarotBloc(
      repository: TarotRepository(),
      geminiService: GeminiService(),
      locale: newLocale.languageCode,
    )..add(LoadTarotCards());

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _locale = newLocale;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tarotBloc.close();
    super.dispose();
  }

// ============================================================================
// Sayfa 3: Uygulama Arayüzü
// Amaç: MaterialApp widget'ını ve temel arayüz yapısını oluşturur.
// Sabit "Ana Sayfaya Dön" butonu kaldırıldı.
// ============================================================================

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _tarotBloc,
      child: MaterialApp(
        title: 'Tarot Falı',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: Colors.grey[900],
          fontFamily: 'Arial',
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
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data == true) {
                    return TarotReadingScreen(onSettingsTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(
                            onLocaleChange: changeLocale,
                            currentLocale: _locale,
                          ),
                        ),
                      );
                    });
                  }
                  return LanguageSelectionScreen(
                    onLocaleSelected: changeLocale,
                  );
                },
              ),
              // Yükleme ekranı
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

// ============================================================================
// Sayfa 4: Dil Seçim Ekranı
// Amaç: Kullanıcıya dil seçimi sunar ve seçimi ana uygulamaya iletir.
// ============================================================================

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
            const Text(
              'Select your language / Dilinizi seçin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => onLocaleSelected(const Locale('en'), context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: const Text('English', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => onLocaleSelected(const Locale('tr'), context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: const Text('Türkçe', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}