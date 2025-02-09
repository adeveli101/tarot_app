// lib/ui/tarot_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/tarot_bloc.dart';

class TarotScreen extends StatelessWidget {
  const TarotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tarot Falı')),
      body: BlocBuilder<TarotBloc, TarotState>(
        builder: (context, state) {
          if (state is TarotLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is TarotError) {
            return Center(child: Text('Hata: ${state.message}'));
          } else if (state is TarotCardsLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        context.read<TarotBloc>().add(DrawPastPresentFuture()),
                    child: Text('Geçmiş-Şimdi-Gelecek Açılımı Yap'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<TarotBloc>().add(DrawProblemSolution()),
                    child: Text('Problem-Çözüm Açılımı Yap'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<TarotBloc>().add(DrawSingleCard()),
                    child: Text('Tek Kart Açılımı Yap'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<TarotBloc>().add(DrawCategoryReading(category: "Aşk", cardCount: 3)),
                    child: Text('Aşk Açılımı Yap'),
                  ),

                  ElevatedButton(
                    onPressed: () =>
                        context.read<TarotBloc>().add(DrawCategoryReading(category: "Kariyer", cardCount: 3)),
                    child: Text('Kariyer Açılımı Yap'),
                  ),

                ],
              ),
            );


          } else if (state is FalYorumuLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(state.yorum),
            );
          }
          return Center(child: Text('Henüz bir seçim yapılmadı'));
        },
      ),
    );
  }
}