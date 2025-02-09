import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/data/tarot_repository.dart';
import 'package:tarot_fal/tarot_fortune_reading_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tarot_fal/tarot_screen_gemini.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env dosyasını yükle
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TarotBloc(
        repository: TarotRepository(),
      ),
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
        home: const TarotReadingScreen(),
      ),
    );
  }
}
