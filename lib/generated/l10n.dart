// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Tarot Reading`
  String get tarotFortune {
    return Intl.message(
      'Tarot Reading',
      name: 'tarotFortune',
      desc: '',
      args: [],
    );
  }

  /// `Error: {message}`
  String errorMessage(Object message) {
    return Intl.message(
      'Error: $message',
      name: 'errorMessage',
      desc: '',
      args: [message],
    );
  }

  /// `Try Again`
  String get tryAgain {
    return Intl.message('Try Again', name: 'tryAgain', desc: '', args: []);
  }

  /// `Perform Past-Present-Future Spread`
  String get pastPresentFuture {
    return Intl.message(
      'Perform Past-Present-Future Spread',
      name: 'pastPresentFuture',
      desc: '',
      args: [],
    );
  }

  /// `Perform Problem-Solution Spread`
  String get problemSolution {
    return Intl.message(
      'Perform Problem-Solution Spread',
      name: 'problemSolution',
      desc: '',
      args: [],
    );
  }

  /// `Perform Single Card Reading`
  String get singleCard {
    return Intl.message(
      'Perform Single Card Reading',
      name: 'singleCard',
      desc: '',
      args: [],
    );
  }

  /// `Perform Love Reading`
  String get loveReading {
    return Intl.message(
      'Perform Love Reading',
      name: 'loveReading',
      desc: '',
      args: [],
    );
  }

  /// `Perform Career Reading`
  String get careerReading {
    return Intl.message(
      'Perform Career Reading',
      name: 'careerReading',
      desc: '',
      args: [],
    );
  }

  /// `No selection has been made yet`
  String get noSelectionYet {
    return Intl.message(
      'No selection has been made yet',
      name: 'noSelectionYet',
      desc: '',
      args: [],
    );
  }

  /// `Position`
  String get position {
    return Intl.message('Position', name: 'position', desc: '', args: []);
  }

  /// `Meaning`
  String get meaning {
    return Intl.message('Meaning', name: 'meaning', desc: '', args: []);
  }

  /// `Mystical Interpretation`
  String get mysticMeaning {
    return Intl.message(
      'Mystical Interpretation',
      name: 'mysticMeaning',
      desc: '',
      args: [],
    );
  }

  /// `Tarot Reading - Guide to Mystical Paths`
  String get tarotFortuneGuide {
    return Intl.message(
      'Tarot Reading - Guide to Mystical Paths',
      name: 'tarotFortuneGuide',
      desc: '',
      args: [],
    );
  }

  /// `This reading provides deep insight into {category} using the {spreadType} spread. As we journey into the depths of your soul, let us interpret the mysterious messages of the cards together.`
  String fortuneInsight(Object category, Object spreadType) {
    return Intl.message(
      'This reading provides deep insight into $category using the $spreadType spread. As we journey into the depths of your soul, let us interpret the mysterious messages of the cards together.',
      name: 'fortuneInsight',
      desc: '',
      args: [category, spreadType],
    );
  }

  /// `The Divine Dance of the Cards`
  String get divineDance {
    return Intl.message(
      'The Divine Dance of the Cards',
      name: 'divineDance',
      desc: '',
      args: [],
    );
  }

  /// `Unified Reflection of Destiny`
  String get unifiedDestinyReflection {
    return Intl.message(
      'Unified Reflection of Destiny',
      name: 'unifiedDestinyReflection',
      desc: '',
      args: [],
    );
  }

  /// `The combination of these cards marks a significant turning point in your {category} journey. The unified energy of the cards reveals messages from the depths of your soul.`
  String unifiedDestinyMessage(Object category) {
    return Intl.message(
      'The combination of these cards marks a significant turning point in your $category journey. The unified energy of the cards reveals messages from the depths of your soul.',
      name: 'unifiedDestinyMessage',
      desc: '',
      args: [category],
    );
  }

  /// `Combined Assessment of the Cards`
  String get cardsCombinedAssessment {
    return Intl.message(
      'Combined Assessment of the Cards',
      name: 'cardsCombinedAssessment',
      desc: '',
      args: [],
    );
  }

  /// `The energies of the cards are interacting with each other.`
  String get cardsEnergiesInteract {
    return Intl.message(
      'The energies of the cards are interacting with each other.',
      name: 'cardsEnergiesInteract',
      desc: '',
      args: [],
    );
  }

  /// `General Commentary (Detailed)`
  String get generalDetailedComment {
    return Intl.message(
      'General Commentary (Detailed)',
      name: 'generalDetailedComment',
      desc: '',
      args: [],
    );
  }

  /// `These cards highlight important dynamics in your life.`
  String get lifeDynamicsHighlighted {
    return Intl.message(
      'These cards highlight important dynamics in your life.',
      name: 'lifeDynamicsHighlighted',
      desc: '',
      args: [],
    );
  }

  /// `Guiding Whispers`
  String get guidingWhispers {
    return Intl.message(
      'Guiding Whispers',
      name: 'guidingWhispers',
      desc: '',
      args: [],
    );
  }

  /// `For your near future, consider these suggestions: [NEAR_FUTURE_SUGGESTIONS]`
  String get futureSuggestions {
    return Intl.message(
      'For your near future, consider these suggestions: [NEAR_FUTURE_SUGGESTIONS]',
      name: 'futureSuggestions',
      desc: '',
      args: [],
    );
  }

  /// `Potential pitfalls to watch out for: [POTENTIAL_PITFALLS]`
  String get potentialPitfalls {
    return Intl.message(
      'Potential pitfalls to watch out for: [POTENTIAL_PITFALLS]',
      name: 'potentialPitfalls',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred while loading the cards: {error}`
  String cardLoadingError(Object error) {
    return Intl.message(
      'An error occurred while loading the cards: $error',
      name: 'cardLoadingError',
      desc: '',
      args: [error],
    );
  }

  /// `An error occurred while performing a single card reading: {error}`
  String singleCardReadingError(Object error) {
    return Intl.message(
      'An error occurred while performing a single card reading: $error',
      name: 'singleCardReadingError',
      desc: '',
      args: [error],
    );
  }

  /// `An error occurred while performing a past-present-future spread: {error}`
  String pastPresentFutureReadingError(Object error) {
    return Intl.message(
      'An error occurred while performing a past-present-future spread: $error',
      name: 'pastPresentFutureReadingError',
      desc: '',
      args: [error],
    );
  }

  /// `An error occurred while performing a problem-solution spread: {error}`
  String problemSolutionReadingError(Object error) {
    return Intl.message(
      'An error occurred while performing a problem-solution spread: $error',
      name: 'problemSolutionReadingError',
      desc: '',
      args: [error],
    );
  }

  /// `An error occurred while performing a five-card path spread: {error}`
  String fiveCardPathReadingError(Object error) {
    return Intl.message(
      'An error occurred while performing a five-card path spread: $error',
      name: 'fiveCardPathReadingError',
      desc: '',
      args: [error],
    );
  }

  /// `An error occurred while performing a relationship spread: {error}`
  String relationshipSpreadReadingError(Object error) {
    return Intl.message(
      'An error occurred while performing a relationship spread: $error',
      name: 'relationshipSpreadReadingError',
      desc: '',
      args: [error],
    );
  }

  /// `An error occurred while performing a Celtic Cross spread: {error}`
  String celticCrossReadingError(Object error) {
    return Intl.message(
      'An error occurred while performing a Celtic Cross spread: $error',
      name: 'celticCrossReadingError',
      desc: '',
      args: [error],
    );
  }

  /// `An error occurred while performing a yearly spread: {error}`
  String yearlySpreadReadingError(Object error) {
    return Intl.message(
      'An error occurred while performing a yearly spread: $error',
      name: 'yearlySpreadReadingError',
      desc: '',
      args: [error],
    );
  }

  /// `An error occurred while performing a category-based spread: {error}`
  String categorySpreadReadingError(Object error) {
    return Intl.message(
      'An error occurred while performing a category-based spread: $error',
      name: 'categorySpreadReadingError',
      desc: '',
      args: [error],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'tr', countryCode: 'TR'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
