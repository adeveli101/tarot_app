import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarot_fal/data/tarot_repository.dart';

import 'package:tarot_fal/tarot_fortune_reading_screen.dart';

import 'data/tarot_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TarotBloc(
        repository: TarotRepository(),
      )..add(LoadTarotCards()),
      child: MaterialApp(
        title: 'Tarot Falı',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.purple[700],
          scaffoldBackgroundColor: Colors.grey[900],
          cardColor: Colors.grey[850],
          colorScheme: ColorScheme.dark(
            primary: Colors.purple[700]!,
            secondary: Colors.amber,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[900],
            elevation: 0,
          ),
          bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: Colors.transparent,
            modalBackgroundColor: Colors.transparent,
          ),
        ),
        builder: (context, child) {
          return BlocProvider.value(
            value: BlocProvider.of<TarotBloc>(context),
            child: child!,
          );
        },
        home: const TarotReadingScreen(),
      ),
    );
  }
}
