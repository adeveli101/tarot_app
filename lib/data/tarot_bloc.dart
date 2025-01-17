import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tarot_fal/data/tarot_repository.dart';

import '../models/tarot_card.dart';

// Events
abstract class TarotEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTarotCards extends TarotEvent {}
class ShuffleDeck extends TarotEvent {}
class DrawSingleCard extends TarotEvent {}
class DrawPastPresentFuture extends TarotEvent {}
class DrawProblemSolution extends TarotEvent {}
class DrawFiveCardPath extends TarotEvent {}
class DrawRelationshipSpread extends TarotEvent {}
class DrawCelticCross extends TarotEvent {}
class DrawYearlySpread extends TarotEvent {}
class DrawCategoryReading extends TarotEvent {
  final String category;
  final int cardCount;

  DrawCategoryReading({required this.category, required this.cardCount});

  @override
  List<Object?> get props => [category, cardCount];
}

// States
abstract class TarotState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TarotInitial extends TarotState {}
class TarotLoading extends TarotState {}
class TarotError extends TarotState {
  final String message;
  TarotError(this.message);

  @override
  List<Object?> get props => [message];
}

class TarotCardsLoaded extends TarotState {
  final List<TarotCard> cards;
  TarotCardsLoaded(this.cards);

  @override
  List<Object?> get props => [cards];
}

class SingleCardDrawn extends TarotState {
  final TarotCard card;
  SingleCardDrawn(this.card);

  @override
  List<Object?> get props => [card];
}

class SpreadDrawn extends TarotState {
  final Map<String, TarotCard> spread;
  SpreadDrawn(this.spread);

  @override
  List<Object?> get props => [spread];
}

// Bloc
class TarotBloc extends Bloc<TarotEvent, TarotState> {
  final TarotRepository repository;

  TarotBloc({required this.repository}) : super(TarotInitial()) {
    on<LoadTarotCards>(_onLoadTarotCards);
    on<ShuffleDeck>(_onShuffleDeck);
    on<DrawSingleCard>(_onDrawSingleCard);
    on<DrawPastPresentFuture>(_onDrawPastPresentFuture);
    on<DrawProblemSolution>(_onDrawProblemSolution);
    on<DrawFiveCardPath>(_onDrawFiveCardPath);
    on<DrawRelationshipSpread>(_onDrawRelationshipSpread);
    on<DrawCelticCross>(_onDrawCelticCross);
    on<DrawYearlySpread>(_onDrawYearlySpread);
    on<DrawCategoryReading>(_onDrawCategoryReading);
  }

  Future<void> _onLoadTarotCards(LoadTarotCards event, Emitter<TarotState> emit) async {
    emit(TarotLoading());
    try {
      await repository.loadCardsFromAsset();
      emit(TarotCardsLoaded(repository.getAllCards()));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  void _onShuffleDeck(ShuffleDeck event, Emitter<TarotState> emit) {
    repository.shuffleDeck();
    emit(TarotCardsLoaded(repository.getAllCards()));
  }

  void _onDrawSingleCard(DrawSingleCard event, Emitter<TarotState> emit) {
    try {
      final card = repository.singleCardReading();
      emit(SingleCardDrawn(card));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  void _onDrawPastPresentFuture(DrawPastPresentFuture event, Emitter<TarotState> emit) {
    try {
      final spread = repository.pastPresentFutureReading();
      emit(SpreadDrawn(spread));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  void _onDrawProblemSolution(DrawProblemSolution event, Emitter<TarotState> emit) {
    try {
      final spread = repository.problemSolutionReading();
      emit(SpreadDrawn(spread));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  void _onDrawFiveCardPath(DrawFiveCardPath event, Emitter<TarotState> emit) {
    try {
      final spread = repository.fiveCardPathReading();
      emit(SpreadDrawn(spread));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  void _onDrawRelationshipSpread(DrawRelationshipSpread event, Emitter<TarotState> emit) {
    try {
      final spread = repository.relationshipReading();
      emit(SpreadDrawn(spread));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  void _onDrawCelticCross(DrawCelticCross event, Emitter<TarotState> emit) {
    try {
      final spread = repository.celticCrossReading();
      emit(SpreadDrawn(spread));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  void _onDrawYearlySpread(DrawYearlySpread event, Emitter<TarotState> emit) {
    try {
      final spread = repository.yearlyReading();
      emit(SpreadDrawn(spread));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }

  void _onDrawCategoryReading(DrawCategoryReading event, Emitter<TarotState> emit) {
    try {
      final spread = repository.categoryReading(event.category, event.cardCount);
      emit(SpreadDrawn(spread));
    } catch (e) {
      emit(TarotError(e.toString()));
    }
  }
}
