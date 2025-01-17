// Temel Anlamlar için model
class Meanings {
  final List<String> light;
  final List<String> shadow;

  Meanings({
    required this.light,
    required this.shadow,
  });

  factory Meanings.fromJson(Map<String, dynamic> json) {
    return Meanings(
      light: List<String>.from(json['light'] ?? []),
      shadow: List<String>.from(json['shadow'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'light': light,
      'shadow': shadow,
    };
  }

  Meanings copyWith({
    List<String>? light,
    List<String>? shadow,
  }) {
    return Meanings(
      light: light ?? this.light,
      shadow: shadow ?? this.shadow,
    );
  }
}

// Ana Tarot Kart Sınıfı
class TarotCard {
  final String name;
  final String number;
  final String arcana;
  final String suit;
  final String img;
  final List<String> fortuneTelling;
  final List<String> keywords;
  final Meanings meanings;
  final String? archetype;
  final String? hebrewAlphabet;
  final String? numerology;
  final String? elemental;
  final String? mythicalSpiritual;
  final List<String>? questionsToAsk;

  TarotCard({
    required this.name,
    required this.number,
    required this.arcana,
    required this.suit,
    required this.img,
    required this.fortuneTelling,
    required this.keywords,
    required this.meanings,
    this.archetype,
    this.hebrewAlphabet,
    this.numerology,
    this.elemental,
    this.mythicalSpiritual,
    this.questionsToAsk,
  });

  // JSON'dan nesne oluşturma
  factory TarotCard.fromJson(Map<String, dynamic> json) {
    return TarotCard(
      name: json['name'] ?? '',
      number: json['number']?.toString() ?? '',
      arcana: json['arcana'] ?? '',
      suit: json['suit'] ?? '',
      img: json['img'] ?? '',
      fortuneTelling: List<String>.from(json['fortune_telling'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),
      meanings: Meanings.fromJson(json['meanings'] ?? {}),
      archetype: json['Archetype'],
      hebrewAlphabet: json['Hebrew Alphabet'],
      numerology: json['Numerology'],
      elemental: json['Elemental'],
      mythicalSpiritual: json['Mythical/Spiritual'],
      questionsToAsk: json['Questions to Ask'] != null
          ? List<String>.from(json['Questions to Ask'])
          : null,
    );
  }

  // Nesneyi JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': number,
      'arcana': arcana,
      'suit': suit,
      'img': img,
      'fortune_telling': fortuneTelling,
      'keywords': keywords,
      'meanings': meanings.toJson(),
      'Archetype': archetype,
      'Hebrew Alphabet': hebrewAlphabet,
      'Numerology': numerology,
      'Elemental': elemental,
      'Mythical/Spiritual': mythicalSpiritual,
      'Questions to Ask': questionsToAsk,
    };
  }

  // Nesne kopyalama ve güncelleme
  TarotCard copyWith({
    String? name,
    String? number,
    String? arcana,
    String? suit,
    String? img,
    List<String>? fortuneTelling,
    List<String>? keywords,
    Meanings? meanings,
    String? archetype,
    String? hebrewAlphabet,
    String? numerology,
    String? elemental,
    String? mythicalSpiritual,
    List<String>? questionsToAsk,
  }) {
    return TarotCard(
      name: name ?? this.name,
      number: number ?? this.number,
      arcana: arcana ?? this.arcana,
      suit: suit ?? this.suit,
      img: img ?? this.img,
      fortuneTelling: fortuneTelling ?? this.fortuneTelling,
      keywords: keywords ?? this.keywords,
      meanings: meanings ?? this.meanings,
      archetype: archetype ?? this.archetype,
      hebrewAlphabet: hebrewAlphabet ?? this.hebrewAlphabet,
      numerology: numerology ?? this.numerology,
      elemental: elemental ?? this.elemental,
      mythicalSpiritual: mythicalSpiritual ?? this.mythicalSpiritual,
      questionsToAsk: questionsToAsk ?? this.questionsToAsk,
    );
  }

  // Eşitlik kontrolü için override
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TarotCard &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              number == other.number;

  @override
  int get hashCode => name.hashCode ^ number.hashCode;

  // String temsili
  @override
  String toString() {
    return 'TarotCard{name: $name, number: $number, arcana: $arcana}';
  }
}

// Kart türü enum
enum CardType {
  major,
  minor,
  court;

  static CardType fromString(String arcana) {
    if (arcana == 'Major Arcana') return CardType.major;
    return CardType.minor;
  }
}

// Kart takımı enum
enum Suit {
  wands,
  cups,
  swords,
  pentacles,
  trump;

  static Suit fromString(String suit) {
    switch (suit.toLowerCase()) {
      case 'wands':
        return Suit.wands;
      case 'cups':
        return Suit.cups;
      case 'swords':
        return Suit.swords;
      case 'pentacles':
        return Suit.pentacles;
      default:
        return Suit.trump;
    }
  }
}
