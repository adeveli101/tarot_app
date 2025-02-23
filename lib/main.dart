import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/data/tarot_repository.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/screens/settings_screen.dart';
import 'package:tarot_fal/screens/tarot_fortune_reading_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'gemini_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final prefs = await SharedPreferences.getInstance();
  final String? savedLanguage = prefs.getString('language');
  runApp(MyApp(initialLocale: savedLanguage != null ? Locale(savedLanguage) : null));
}

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
    _locale = widget.initialLocale ?? const Locale('tr');
    _tarotBloc = TarotBloc(
      repository: TarotRepository(),
      geminiService: GeminiService(),
      locale: _locale.languageCode,
    )..add(LoadTarotCards());
  }

  Future<void> _changeLocale(Locale newLocale, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLocale.languageCode);

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _locale = newLocale;
      _tarotBloc.close();
      _tarotBloc = TarotBloc(
        repository: TarotRepository(),
        geminiService: GeminiService(),
        locale: newLocale.languageCode,
      )..add(LoadTarotCards());
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tarotBloc.close();
    super.dispose();
  }

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
        supportedLocales: S.supportedLocales,
        locale: _locale,
        home: Stack(
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
                          onLocaleChange: (locale, ctx) => _changeLocale(locale, ctx),
                          currentLocale: _locale,
                        ),
                      ),
                    );
                  });
                }
                return LanguageSelectionScreen(
                  onLocaleSelected: (locale, ctx) => _changeLocale(locale, ctx),
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