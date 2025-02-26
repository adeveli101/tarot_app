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

  static String m0(error) => "AstroLogical Cross reading error: \$${error}";

  static String m1(error) => "Broken Heart reading error: \$${error}";

  static String m2(count) => "${count} cards";

  static String m3(error) =>
      "An error occurred while loading the cards: ${error}";

  static String m4(error) => "An error occurred while loading cards: ${error}";

  static String m5(error) => "An error occurred while loading cards: ${error}";

  static String m6(error) => "Career Path Spread reading error: \$${error}";

  static String m7(error) =>
      "An error occurred while performing a category-based spread: ${error}";

  static String m8(error) =>
      "An error occurred while performing a Celtic Cross spread: ${error}";

  static String m9(message) => "${message}";

  static String m10(message) => "${message}";

  static String m11(error) => "Dream Interpretation reading error: \$${error}";

  static String m12(message) => "Error: ${message}";

  static String m13(error) =>
      "An error occurred while performing a five-card path spread: ${error}";

  static String m14(category, spreadType) =>
      "This Tarot Reading - reading provides deep insight into ${category} using the ${spreadType} spread. As we journey into the depths of your soul, let us interpret the mysterious messages of the cards together.";

  static String m15(error) => "Full Moon Spread reading error: \$${error}";

  static String m16(error) => "Horseshoe Spread reading error: \$${error}";

  static String m17(required) =>
      "You need ${required} credits to continue. Purchase more credits below.";

  static String m18(error) => "Mind-Body-Spirit reading error: \$${error}";

  static String m19(hours) =>
      "Your next free reading will be available in ${hours} hours.";

  static String m20(error) =>
      "An error occurred while performing a past-present-future spread: ${error}";

  static String m21(error) =>
      "An error occurred while performing a problem-solution spread: ${error}";

  static String m22(error) =>
      "An error occurred while performing a relationship spread: ${error}";

  static String m23(error) =>
      "An error occurred while performing a single card reading: ${error}";

  static String m24(category, spreadType) =>
      "This reading provides personal and deep insights into ${category} using the ${spreadType} spread. Prepare to dive into the depths of your soul and uncover the unique messages of the cards!";

  static String m25(category) =>
      "The combination of these cards marks a significant turning point in your ${category} journey. The unified energy of the cards reveals messages from the depths of your soul.";

  static String m26(error) =>
      "An error occurred while performing a yearly spread: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "astroLogicalCrossError": m0,
    "brokenHeartError": m1,
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cardCount": m2,
    "cardDeckEmpty": MessageLookupByLibrary.simpleMessage("Card deck is empty"),
    "cardLoadingError": m3,
    "cardSelection": MessageLookupByLibrary.simpleMessage("Card Selection"),
    "cardSelectionInstructions": MessageLookupByLibrary.simpleMessage(
      "The number of cards will be displayed face down. Please tap to reveal them one by one, long press to see a brief description, or use the \'Flip All Cards\' option.",
    ),
    "cardsCombinedAssessment": MessageLookupByLibrary.simpleMessage(
      "Combined Assessment of the Cards",
    ),
    "cardsCombinedEvaluation": MessageLookupByLibrary.simpleMessage(
      "Combined Evaluation of the Cards",
    ),
    "cardsEnergiesInteract": MessageLookupByLibrary.simpleMessage(
      "The energies of the cards are interacting with each other.",
    ),
    "cardsLoadingErrorGeneric": m4,
    "cards_loading_error": m5,
    "career": MessageLookupByLibrary.simpleMessage("Career"),
    "careerDescription": MessageLookupByLibrary.simpleMessage(
      "Get guidance on your career path",
    ),
    "careerPathSpreadError": m6,
    "careerReading": MessageLookupByLibrary.simpleMessage(
      "Perform Career Reading",
    ),
    "categoryInfoBanner": MessageLookupByLibrary.simpleMessage(
      "Special spreads will be offered based on your chosen category",
    ),
    "categorySelection": MessageLookupByLibrary.simpleMessage(
      "Category Selection",
    ),
    "categorySpecificTips": MessageLookupByLibrary.simpleMessage(
      "Category-Specific Tips",
    ),
    "categorySpreadReadingError": m7,
    "celticCrossDescription": MessageLookupByLibrary.simpleMessage(
      "Detailed and comprehensive analysis",
    ),
    "celticCrossReading": MessageLookupByLibrary.simpleMessage("Celtic Cross"),
    "celticCrossReadingError": m8,
    "chooseSpread": MessageLookupByLibrary.simpleMessage(
      "Choose how the cards will be drawn",
    ),
    "chooseTopic": MessageLookupByLibrary.simpleMessage(
      "Choose the topic you want to explore",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "couponHint": MessageLookupByLibrary.simpleMessage("Enter coupon code"),
    "couponInvalid": m9,
    "couponRedeemed": m10,
    "customPromptHint": MessageLookupByLibrary.simpleMessage(
      "Type your custom prompt here...",
    ),
    "customPromptTitle": MessageLookupByLibrary.simpleMessage("Custom Prompt"),
    "dailyLimitExceeded": MessageLookupByLibrary.simpleMessage(
      "Daily free reading limit reached. Please purchase credits or upgrade to premium.",
    ),
    "dailyLimitReached": MessageLookupByLibrary.simpleMessage(
      "You have reached your daily free reading limit.",
    ),
    "dateLabel": MessageLookupByLibrary.simpleMessage("Date:"),
    "deck_empty": MessageLookupByLibrary.simpleMessage("Card deck is empty"),
    "detailedGeneralCommentary": MessageLookupByLibrary.simpleMessage(
      "In-Depth General Commentary",
    ),
    "differentInterpretation": MessageLookupByLibrary.simpleMessage(
      "A different interpretation awaits each choice",
    ),
    "divineDance": MessageLookupByLibrary.simpleMessage(
      "The Divine Dance of the Cards",
    ),
    "divineSymphony": MessageLookupByLibrary.simpleMessage(
      "The Divine Symphony of the Cards",
    ),
    "dreamInterpretationError": m11,
    "errorMessage": m12,
    "fiveCardPath": MessageLookupByLibrary.simpleMessage("Five Card Path"),
    "fiveCardPathDescription": MessageLookupByLibrary.simpleMessage(
      "Detailed analysis for career choices",
    ),
    "fiveCardPathReadingError": m13,
    "flipAllCards": MessageLookupByLibrary.simpleMessage("Flip All Cards"),
    "fortuneInsight": m14,
    "fortuneTelling": MessageLookupByLibrary.simpleMessage("Fortune Telling:"),
    "fullMoonSpreadError": m15,
    "futureSuggestions": MessageLookupByLibrary.simpleMessage(
      "For your near future, consider these suggestions: [NEAR_FUTURE_SUGGESTIONS]",
    ),
    "general": MessageLookupByLibrary.simpleMessage("General"),
    "generalAnalysis": MessageLookupByLibrary.simpleMessage("General Analysis"),
    "generalDescription": MessageLookupByLibrary.simpleMessage(
      "Receive general life guidance",
    ),
    "generalDetailedComment": MessageLookupByLibrary.simpleMessage(
      "General Commentary (Detailed)",
    ),
    "guidingWhispers": MessageLookupByLibrary.simpleMessage("Guiding Whispers"),
    "guidingWhispersAndSuggestions": MessageLookupByLibrary.simpleMessage(
      "Guiding Whispers & Suggestions",
    ),
    "horseshoeSpreadError": m16,
    "insufficientCredits": MessageLookupByLibrary.simpleMessage(
      "You don\'t have enough credits to proceed.",
    ),
    "insufficientCreditsAndLimit": MessageLookupByLibrary.simpleMessage(
      "You have reached your daily free reading limit and don\'t have enough credits.",
    ),
    "insufficientCreditsMessage": m17,
    "keywords": MessageLookupByLibrary.simpleMessage("Keywords:"),
    "lifeDynamicsHighlighted": MessageLookupByLibrary.simpleMessage(
      "These cards highlight important dynamics in your life.",
    ),
    "lightMeaning": MessageLookupByLibrary.simpleMessage("Light:"),
    "loveDescription": MessageLookupByLibrary.simpleMessage(
      "Gain deep insights into your relationships",
    ),
    "loveReading": MessageLookupByLibrary.simpleMessage("Perform Love Reading"),
    "loveRelationships": MessageLookupByLibrary.simpleMessage(
      "Love & Relationships",
    ),
    "meaning": MessageLookupByLibrary.simpleMessage("Meaning"),
    "mindBodySpiritError": m18,
    "money": MessageLookupByLibrary.simpleMessage("Money"),
    "moneyDescription": MessageLookupByLibrary.simpleMessage(
      "Gain insights into financial matters",
    ),
    "mysticJourney": MessageLookupByLibrary.simpleMessage("Mystic Journey"),
    "mysticMeaning": MessageLookupByLibrary.simpleMessage(
      "Mystical Interpretation",
    ),
    "nextFreeReadingInfo": m19,
    "noReadings": MessageLookupByLibrary.simpleMessage("No readings found"),
    "noSelectionYet": MessageLookupByLibrary.simpleMessage(
      "No selection has been made yet",
    ),
    "pastPresentFuture": MessageLookupByLibrary.simpleMessage(
      " Past-Present-Future Spread",
    ),
    "pastPresentFutureDescription": MessageLookupByLibrary.simpleMessage(
      "Guidance for your career path",
    ),
    "pastPresentFutureReadingError": m20,
    "pleaseWait": MessageLookupByLibrary.simpleMessage("Please wait."),
    "pointsToWatch": MessageLookupByLibrary.simpleMessage(
      "Points to Watch Out For",
    ),
    "position": MessageLookupByLibrary.simpleMessage("Position"),
    "potentialPitfalls": MessageLookupByLibrary.simpleMessage(
      "Potential pitfalls to watch out for: [POTENTIAL_PITFALLS]",
    ),
    "problemSolution": MessageLookupByLibrary.simpleMessage(
      "Perform Problem-Solution Spread",
    ),
    "problemSolutionReadingError": m21,
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "promptEmptyError": MessageLookupByLibrary.simpleMessage(
      "Please enter a prompt.",
    ),
    "purchaseCredits": MessageLookupByLibrary.simpleMessage("Purchase Credits"),
    "readingSaved": MessageLookupByLibrary.simpleMessage(
      "Reading saved successfully",
    ),
    "redeem": MessageLookupByLibrary.simpleMessage("Redeem"),
    "relationshipSpread": MessageLookupByLibrary.simpleMessage(
      "Relationship Spread",
    ),
    "relationshipSpreadDescription": MessageLookupByLibrary.simpleMessage(
      "Detailed analysis of your relationship",
    ),
    "relationshipSpreadReadingError": m22,
    "reshuffleCards": MessageLookupByLibrary.simpleMessage("Reshuffle Cards"),
    "returnToHome": MessageLookupByLibrary.simpleMessage("Return to Home"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "sendPrompt": MessageLookupByLibrary.simpleMessage("Send Prompt"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "shadowMeaning": MessageLookupByLibrary.simpleMessage("Shadow:"),
    "share": MessageLookupByLibrary.simpleMessage("Share"),
    "singleCard": MessageLookupByLibrary.simpleMessage(
      "Perform Single Card Reading",
    ),
    "singleCardDescription": MessageLookupByLibrary.simpleMessage(
      "Ideal for quick answers",
    ),
    "singleCardReadingError": m23,
    "specialNote": MessageLookupByLibrary.simpleMessage("Special Note"),
    "spreadInfoBanner": MessageLookupByLibrary.simpleMessage(
      "Each spread offers a different number of cards and interpretations",
    ),
    "spreadSelection": MessageLookupByLibrary.simpleMessage("Spread Selection"),
    "startJourney": MessageLookupByLibrary.simpleMessage("Start Journey"),
    "swipeForMore": MessageLookupByLibrary.simpleMessage("Swipe for more"),
    "swipeToSeePages": MessageLookupByLibrary.simpleMessage(
      "Swipe to see pages",
    ),
    "tarotFortune": MessageLookupByLibrary.simpleMessage("Tarot"),
    "tarotFortuneDescription": m24,
    "tarotFortuneGuide": MessageLookupByLibrary.simpleMessage(
      "Guide to Mystical Paths",
    ),
    "tarotFortuneTitle": MessageLookupByLibrary.simpleMessage(
      "Tarot Reading - Guide to Mystical Paths",
    ),
    "timelineAndSuggestions": MessageLookupByLibrary.simpleMessage(
      "Timeline & Suggestions",
    ),
    "tokenLimitExceeded": MessageLookupByLibrary.simpleMessage(
      "Token limit exceeded for this spread. Upgrade to premium for more detailed readings.",
    ),
    "tooManyCardsRequested": MessageLookupByLibrary.simpleMessage(
      "The requested number of cards exceeds the deck size",
    ),
    "too_many_cards": MessageLookupByLibrary.simpleMessage(
      "The requested number of cards exceeds the deck size",
    ),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Try Again"),
    "unifiedDestinyMessage": m25,
    "unifiedDestinyReflection": MessageLookupByLibrary.simpleMessage(
      "Unified Reflection of Destiny",
    ),
    "unifiedDestinyReflectionTitle": MessageLookupByLibrary.simpleMessage(
      "Reflections of Unified Destiny",
    ),
    "viewResults": MessageLookupByLibrary.simpleMessage("View Results"),
    "warning": MessageLookupByLibrary.simpleMessage("Warning"),
    "yearlySpreadDescription": MessageLookupByLibrary.simpleMessage(
      "Guidance for the next 12 months",
    ),
    "yearlySpreadReading": MessageLookupByLibrary.simpleMessage(
      "Yearly Spread",
    ),
    "yearlySpreadReadingError": m26,
  };
}
