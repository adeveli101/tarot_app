import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @tarotFortune.
  ///
  /// In en, this message translates to:
  /// **'Tarot Reading'**
  String get tarotFortune;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorMessage(Object message);

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @pastPresentFuture.
  ///
  /// In en, this message translates to:
  /// **'Perform Past-Present-Future Spread'**
  String get pastPresentFuture;

  /// No description provided for @problemSolution.
  ///
  /// In en, this message translates to:
  /// **'Perform Problem-Solution Spread'**
  String get problemSolution;

  /// No description provided for @singleCard.
  ///
  /// In en, this message translates to:
  /// **'Perform Single Card Reading'**
  String get singleCard;

  /// No description provided for @loveReading.
  ///
  /// In en, this message translates to:
  /// **'Perform Love Reading'**
  String get loveReading;

  /// No description provided for @careerReading.
  ///
  /// In en, this message translates to:
  /// **'Perform Career Reading'**
  String get careerReading;

  /// No description provided for @noSelectionYet.
  ///
  /// In en, this message translates to:
  /// **'No selection has been made yet'**
  String get noSelectionYet;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @meaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get meaning;

  /// No description provided for @mysticMeaning.
  ///
  /// In en, this message translates to:
  /// **'Mystical Interpretation'**
  String get mysticMeaning;

  /// No description provided for @tarotFortuneGuide.
  ///
  /// In en, this message translates to:
  /// **'Tarot Reading - Guide to Mystical Paths'**
  String get tarotFortuneGuide;

  /// No description provided for @fortuneInsight.
  ///
  /// In en, this message translates to:
  /// **'This reading provides deep insight into {category} using the {spreadType} spread. As we journey into the depths of your soul, let us interpret the mysterious messages of the cards together.'**
  String fortuneInsight(Object category, Object spreadType);

  /// No description provided for @divineDance.
  ///
  /// In en, this message translates to:
  /// **'The Divine Dance of the Cards'**
  String get divineDance;

  /// No description provided for @unifiedDestinyReflection.
  ///
  /// In en, this message translates to:
  /// **'Unified Reflection of Destiny'**
  String get unifiedDestinyReflection;

  /// No description provided for @unifiedDestinyMessage.
  ///
  /// In en, this message translates to:
  /// **'The combination of these cards marks a significant turning point in your {category} journey. The unified energy of the cards reveals messages from the depths of your soul.'**
  String unifiedDestinyMessage(Object category);

  /// No description provided for @cardsCombinedAssessment.
  ///
  /// In en, this message translates to:
  /// **'Combined Assessment of the Cards'**
  String get cardsCombinedAssessment;

  /// No description provided for @cardsEnergiesInteract.
  ///
  /// In en, this message translates to:
  /// **'The energies of the cards are interacting with each other.'**
  String get cardsEnergiesInteract;

  /// No description provided for @generalDetailedComment.
  ///
  /// In en, this message translates to:
  /// **'General Commentary (Detailed)'**
  String get generalDetailedComment;

  /// No description provided for @lifeDynamicsHighlighted.
  ///
  /// In en, this message translates to:
  /// **'These cards highlight important dynamics in your life.'**
  String get lifeDynamicsHighlighted;

  /// No description provided for @guidingWhispers.
  ///
  /// In en, this message translates to:
  /// **'Guiding Whispers'**
  String get guidingWhispers;

  /// No description provided for @futureSuggestions.
  ///
  /// In en, this message translates to:
  /// **'For your near future, consider these suggestions: [NEAR_FUTURE_SUGGESTIONS]'**
  String get futureSuggestions;

  /// No description provided for @potentialPitfalls.
  ///
  /// In en, this message translates to:
  /// **'Potential pitfalls to watch out for: [POTENTIAL_PITFALLS]'**
  String get potentialPitfalls;

  /// No description provided for @cardLoadingError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading the cards: {error}'**
  String cardLoadingError(Object error);

  /// No description provided for @singleCardReadingError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while performing a single card reading: {error}'**
  String singleCardReadingError(Object error);

  /// No description provided for @pastPresentFutureReadingError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while performing a past-present-future spread: {error}'**
  String pastPresentFutureReadingError(Object error);

  /// No description provided for @problemSolutionReadingError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while performing a problem-solution spread: {error}'**
  String problemSolutionReadingError(Object error);

  /// No description provided for @fiveCardPathReadingError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while performing a five-card path spread: {error}'**
  String fiveCardPathReadingError(Object error);

  /// No description provided for @relationshipSpreadReadingError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while performing a relationship spread: {error}'**
  String relationshipSpreadReadingError(Object error);

  /// No description provided for @celticCrossReadingError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while performing a Celtic Cross spread: {error}'**
  String celticCrossReadingError(Object error);

  /// No description provided for @yearlySpreadReadingError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while performing a yearly spread: {error}'**
  String yearlySpreadReadingError(Object error);

  /// No description provided for @categorySpreadReadingError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while performing a category-based spread: {error}'**
  String categorySpreadReadingError(Object error);

  /// No description provided for @cardDeckEmpty.
  ///
  /// In en, this message translates to:
  /// **'Card deck is empty'**
  String get cardDeckEmpty;

  /// No description provided for @tooManyCardsRequested.
  ///
  /// In en, this message translates to:
  /// **'The requested number of cards exceeds the deck size'**
  String get tooManyCardsRequested;

  /// No description provided for @cardsLoadingErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading cards: {error}'**
  String cardsLoadingErrorGeneric(Object error);

  /// No description provided for @tarotFortuneTitle.
  ///
  /// In en, this message translates to:
  /// **'Tarot Reading - Guide to Mystical Paths'**
  String get tarotFortuneTitle;

  /// No description provided for @tarotFortuneDescription.
  ///
  /// In en, this message translates to:
  /// **'This reading provides personal and deep insights into {category} using the {spreadType} spread. Prepare to dive into the depths of your soul and uncover the unique messages of the cards!'**
  String tarotFortuneDescription(Object category, Object spreadType);

  /// No description provided for @divineSymphony.
  ///
  /// In en, this message translates to:
  /// **'The Divine Symphony of the Cards'**
  String get divineSymphony;

  /// No description provided for @unifiedDestinyReflectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reflections of Unified Destiny'**
  String get unifiedDestinyReflectionTitle;

  /// No description provided for @generalAnalysis.
  ///
  /// In en, this message translates to:
  /// **'General Analysis'**
  String get generalAnalysis;

  /// No description provided for @cardsCombinedEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Combined Evaluation of the Cards'**
  String get cardsCombinedEvaluation;

  /// No description provided for @specialNote.
  ///
  /// In en, this message translates to:
  /// **'Special Note'**
  String get specialNote;

  /// No description provided for @detailedGeneralCommentary.
  ///
  /// In en, this message translates to:
  /// **'In-Depth General Commentary'**
  String get detailedGeneralCommentary;

  /// No description provided for @guidingWhispersAndSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Guiding Whispers & Suggestions'**
  String get guidingWhispersAndSuggestions;

  /// No description provided for @timelineAndSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Timeline & Suggestions'**
  String get timelineAndSuggestions;

  /// No description provided for @pointsToWatch.
  ///
  /// In en, this message translates to:
  /// **'Points to Watch Out For'**
  String get pointsToWatch;

  /// No description provided for @categorySpecificTips.
  ///
  /// In en, this message translates to:
  /// **'Category-Specific Tips'**
  String get categorySpecificTips;

  /// No description provided for @deck_empty.
  ///
  /// In en, this message translates to:
  /// **'Card deck is empty'**
  String get deck_empty;

  /// No description provided for @too_many_cards.
  ///
  /// In en, this message translates to:
  /// **'The requested number of cards exceeds the deck size'**
  String get too_many_cards;

  /// No description provided for @cards_loading_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading cards: {error}'**
  String cards_loading_error(Object error);

  /// No description provided for @keywords.
  ///
  /// In en, this message translates to:
  /// **'Keywords:'**
  String get keywords;

  /// No description provided for @lightMeaning.
  ///
  /// In en, this message translates to:
  /// **'Light:'**
  String get lightMeaning;

  /// No description provided for @shadowMeaning.
  ///
  /// In en, this message translates to:
  /// **'Shadow:'**
  String get shadowMeaning;

  /// No description provided for @swipeForMore.
  ///
  /// In en, this message translates to:
  /// **'Swipe for more'**
  String get swipeForMore;

  /// No description provided for @swipeToSeePages.
  ///
  /// In en, this message translates to:
  /// **'Swipe to see pages'**
  String get swipeToSeePages;

  /// No description provided for @fortuneTelling.
  ///
  /// In en, this message translates to:
  /// **'Fortune Telling:'**
  String get fortuneTelling;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @mysticJourney.
  ///
  /// In en, this message translates to:
  /// **'Mystic Journey'**
  String get mysticJourney;

  /// No description provided for @startJourney.
  ///
  /// In en, this message translates to:
  /// **'Start Journey'**
  String get startJourney;

  /// No description provided for @differentInterpretation.
  ///
  /// In en, this message translates to:
  /// **'A different interpretation awaits each choice'**
  String get differentInterpretation;

  /// No description provided for @categorySelection.
  ///
  /// In en, this message translates to:
  /// **'Category Selection'**
  String get categorySelection;

  /// No description provided for @chooseTopic.
  ///
  /// In en, this message translates to:
  /// **'Choose the topic you want to explore'**
  String get chooseTopic;

  /// No description provided for @loveRelationships.
  ///
  /// In en, this message translates to:
  /// **'Love & Relationships'**
  String get loveRelationships;

  /// No description provided for @loveDescription.
  ///
  /// In en, this message translates to:
  /// **'Gain deep insights into your relationships'**
  String get loveDescription;

  /// No description provided for @career.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get career;

  /// No description provided for @careerDescription.
  ///
  /// In en, this message translates to:
  /// **'Get guidance on your career path'**
  String get careerDescription;

  /// No description provided for @money.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get money;

  /// No description provided for @moneyDescription.
  ///
  /// In en, this message translates to:
  /// **'Gain insights into financial matters'**
  String get moneyDescription;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @generalDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive general life guidance'**
  String get generalDescription;

  /// No description provided for @categoryInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'Special spreads will be offered based on your chosen category'**
  String get categoryInfoBanner;

  /// No description provided for @spreadSelection.
  ///
  /// In en, this message translates to:
  /// **'Spread Selection'**
  String get spreadSelection;

  /// No description provided for @chooseSpread.
  ///
  /// In en, this message translates to:
  /// **'Choose how the cards will be drawn'**
  String get chooseSpread;

  /// No description provided for @spreadInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'Each spread offers a different number of cards and interpretations'**
  String get spreadInfoBanner;

  /// No description provided for @singleCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Ideal for quick answers'**
  String get singleCardDescription;

  /// No description provided for @relationshipSpread.
  ///
  /// In en, this message translates to:
  /// **'Relationship Spread'**
  String get relationshipSpread;

  /// No description provided for @relationshipSpreadDescription.
  ///
  /// In en, this message translates to:
  /// **'Detailed analysis of your relationship'**
  String get relationshipSpreadDescription;

  /// No description provided for @pastPresentFutureDescription.
  ///
  /// In en, this message translates to:
  /// **'Guidance for your career path'**
  String get pastPresentFutureDescription;

  /// No description provided for @fiveCardPath.
  ///
  /// In en, this message translates to:
  /// **'Five Card Path'**
  String get fiveCardPath;

  /// No description provided for @fiveCardPathDescription.
  ///
  /// In en, this message translates to:
  /// **'Detailed analysis for career choices'**
  String get fiveCardPathDescription;

  /// No description provided for @celticCrossDescription.
  ///
  /// In en, this message translates to:
  /// **'Detailed and comprehensive analysis'**
  String get celticCrossDescription;

  /// No description provided for @yearlySpreadDescription.
  ///
  /// In en, this message translates to:
  /// **'Guidance for the next 12 months'**
  String get yearlySpreadDescription;

  /// No description provided for @cardCount.
  ///
  /// In en, this message translates to:
  /// **'{count} cards'**
  String cardCount(Object count);

  /// No description provided for @celticCrossReading.
  ///
  /// In en, this message translates to:
  /// **'Celtic Cross'**
  String get celticCrossReading;

  /// No description provided for @yearlySpreadReading.
  ///
  /// In en, this message translates to:
  /// **'Yearly Spread'**
  String get yearlySpreadReading;

  /// No description provided for @cardSelection.
  ///
  /// In en, this message translates to:
  /// **'Card Selection'**
  String get cardSelection;

  /// No description provided for @cardSelectionInstructions.
  ///
  /// In en, this message translates to:
  /// **'The number of cards will be displayed face down. Please tap to reveal them one by one, long press to see a brief description, or use the \'Flip All Cards\' option.'**
  String get cardSelectionInstructions;

  /// No description provided for @flipAllCards.
  ///
  /// In en, this message translates to:
  /// **'Flip All Cards'**
  String get flipAllCards;

  /// No description provided for @reshuffleCards.
  ///
  /// In en, this message translates to:
  /// **'Reshuffle Cards'**
  String get reshuffleCards;

  /// No description provided for @viewResults.
  ///
  /// In en, this message translates to:
  /// **'View Results'**
  String get viewResults;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return SEn();
    case 'tr': return STr();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
