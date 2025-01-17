// reading_result.dart

import '../models/tarot_card.dart';

class ReadingResult {
  final String readingType;
  final DateTime readingDate;
  final List<TarotCard> cards;
  final Map<String, TarotCard> positions;
  final String question;
  final String interpretation;

  ReadingResult({
    required this.readingType,
    required this.readingDate,
    required this.cards,
    required this.positions,
    this.question = '',
    this.interpretation = '',
  });

  factory ReadingResult.fromJson(Map<String, dynamic> json) {
    return ReadingResult(
      readingType: json['reading_type'] ?? '',
      readingDate: DateTime.parse(json['reading_date'] ?? DateTime.now().toIso8601String()),
      cards: (json['cards'] as List?)?.map((card) => TarotCard.fromJson(card)).toList() ?? [],
      positions: Map.from(
        (json['positions'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), TarotCard.fromJson(value)),
        ) ?? {},
      ),
      question: json['question'] ?? '',
      interpretation: json['interpretation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reading_type': readingType,
      'reading_date': readingDate.toIso8601String(),
      'cards': cards.map((card) => card.toJson()).toList(),
      'positions': positions.map((key, value) => MapEntry(key, value.toJson())),
      'question': question,
      'interpretation': interpretation,
    };
  }

  ReadingResult copyWith({
    String? readingType,
    DateTime? readingDate,
    List<TarotCard>? cards,
    Map<String, TarotCard>? positions,
    String? question,
    String? interpretation,
  }) {
    return ReadingResult(
      readingType: readingType ?? this.readingType,
      readingDate: readingDate ?? this.readingDate,
      cards: cards ?? this.cards,
      positions: positions ?? this.positions,
      question: question ?? this.question,
      interpretation: interpretation ?? this.interpretation,
    );
  }

  @override
  String toString() {
    return 'ReadingResult{readingType: $readingType, date: $readingDate, cards: ${cards.length}, question: $question}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ReadingResult &&
              readingType == other.readingType &&
              readingDate == other.readingDate &&
              cards == other.cards;

  @override
  int get hashCode =>
      readingType.hashCode ^
      readingDate.hashCode ^
      cards.hashCode;
}
