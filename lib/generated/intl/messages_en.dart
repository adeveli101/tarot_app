// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(error) =>
      "An error occurred while loading the cards: ${error}";

  static String m1(error) =>
      "An error occurred while performing a category-based spread: ${error}";

  static String m2(error) =>
      "An error occurred while performing a Celtic Cross spread: ${error}";

  static String m3(message) => "Error: ${message}";

  static String m4(error) =>
      "An error occurred while performing a five-card path spread: ${error}";

  static String m5(category, spreadType) =>
      "This reading provides deep insight into ${category} using the ${spreadType} spread. As we journey into the depths of your soul, let us interpret the mysterious messages of the cards together.";

  static String m6(error) =>
      "An error occurred while performing a past-present-future spread: ${error}";

  static String m7(error) =>
      "An error occurred while performing a problem-solution spread: ${error}";

  static String m8(error) =>
      "An error occurred while performing a relationship spread: ${error}";

  static String m9(error) =>
      "An error occurred while performing a single card reading: ${error}";

  static String m10(category) =>
      "The combination of these cards marks a significant turning point in your ${category} journey. The unified energy of the cards reveals messages from the depths of your soul.";

  static String m11(error) =>
      "An error occurred while performing a yearly spread: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "cardLoadingError": m0,
    "cardsCombinedAssessment": MessageLookupByLibrary.simpleMessage(
      "Combined Assessment of the Cards",
    ),
    "cardsEnergiesInteract": MessageLookupByLibrary.simpleMessage(
      "The energies of the cards are interacting with each other.",
    ),
    "careerReading": MessageLookupByLibrary.simpleMessage(
      "Perform Career Reading",
    ),
    "categorySpreadReadingError": m1,
    "celticCrossReadingError": m2,
    "divineDance": MessageLookupByLibrary.simpleMessage(
      "The Divine Dance of the Cards",
    ),
    "errorMessage": m3,
    "fiveCardPathReadingError": m4,
    "fortuneInsight": m5,
    "futureSuggestions": MessageLookupByLibrary.simpleMessage(
      "For your near future, consider these suggestions: [NEAR_FUTURE_SUGGESTIONS]",
    ),
    "generalDetailedComment": MessageLookupByLibrary.simpleMessage(
      "General Commentary (Detailed)",
    ),
    "guidingWhispers": MessageLookupByLibrary.simpleMessage("Guiding Whispers"),
    "lifeDynamicsHighlighted": MessageLookupByLibrary.simpleMessage(
      "These cards highlight important dynamics in your life.",
    ),
    "loveReading": MessageLookupByLibrary.simpleMessage("Perform Love Reading"),
    "meaning": MessageLookupByLibrary.simpleMessage("Meaning"),
    "mysticMeaning": MessageLookupByLibrary.simpleMessage(
      "Mystical Interpretation",
    ),
    "noSelectionYet": MessageLookupByLibrary.simpleMessage(
      "No selection has been made yet",
    ),
    "pastPresentFuture": MessageLookupByLibrary.simpleMessage(
      "Perform Past-Present-Future Spread",
    ),
    "pastPresentFutureReadingError": m6,
    "position": MessageLookupByLibrary.simpleMessage("Position"),
    "potentialPitfalls": MessageLookupByLibrary.simpleMessage(
      "Potential pitfalls to watch out for: [POTENTIAL_PITFALLS]",
    ),
    "problemSolution": MessageLookupByLibrary.simpleMessage(
      "Perform Problem-Solution Spread",
    ),
    "problemSolutionReadingError": m7,
    "relationshipSpreadReadingError": m8,
    "singleCard": MessageLookupByLibrary.simpleMessage(
      "Perform Single Card Reading",
    ),
    "singleCardReadingError": m9,
    "tarotFortune": MessageLookupByLibrary.simpleMessage("Tarot Reading"),
    "tarotFortuneGuide": MessageLookupByLibrary.simpleMessage(
      "Tarot Reading - Guide to Mystical Paths",
    ),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Try Again"),
    "unifiedDestinyMessage": m10,
    "unifiedDestinyReflection": MessageLookupByLibrary.simpleMessage(
      "Unified Reflection of Destiny",
    ),
    "yearlySpreadReadingError": m11,
  };
}
