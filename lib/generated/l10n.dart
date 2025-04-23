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
  /// **'Astral Tarot'**
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
  /// **' Past-Present-Future Spread'**
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
  /// **'Guide to Mystical Paths'**
  String get tarotFortuneGuide;

  /// No description provided for @fortuneInsight.
  ///
  /// In en, this message translates to:
  /// **'This Tarot Reading - reading provides deep insight into {category} using the {spreadType} spread. As we journey into the depths of your soul, let us interpret the mysterious messages of the cards together.'**
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

  /// Text for the close button in dialogs.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @lightMeaning.
  ///
  /// In en, this message translates to:
  /// **'Light (Positive):'**
  String get lightMeaning;

  /// No description provided for @shadowMeaning.
  ///
  /// In en, this message translates to:
  /// **'Shadow (Negative):'**
  String get shadowMeaning;

  /// Title for the custom prompt input dialog.
  ///
  /// In en, this message translates to:
  /// **'Custom Prompt'**
  String get customPromptTitle;

  /// Hint for the custom prompt field.
  ///
  /// In en, this message translates to:
  /// **'Type your custom prompt here...'**
  String get customPromptHint;

  /// Error message when the prompt input is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a prompt.'**
  String get promptEmptyError;

  /// Text for the button used to send the prompt.
  ///
  /// In en, this message translates to:
  /// **'Send Prompt'**
  String get sendPrompt;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @dailyLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Daily free reading limit reached. Please purchase credits or upgrade to premium.'**
  String get dailyLimitExceeded;

  /// No description provided for @tokenLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Token limit exceeded for this spread. Upgrade to premium for more detailed readings.'**
  String get tokenLimitExceeded;

  /// No description provided for @mindBodySpiritError.
  ///
  /// In en, this message translates to:
  /// **'Mind-Body-Spirit reading error: \${error}'**
  String mindBodySpiritError(Object error);

  /// No description provided for @astroLogicalCrossError.
  ///
  /// In en, this message translates to:
  /// **'AstroLogical Cross reading error: \${error}'**
  String astroLogicalCrossError(Object error);

  /// No description provided for @brokenHeartError.
  ///
  /// In en, this message translates to:
  /// **'Broken Heart reading error: \${error}'**
  String brokenHeartError(Object error);

  /// No description provided for @dreamInterpretationError.
  ///
  /// In en, this message translates to:
  /// **'Dream Interpretation reading error: \${error}'**
  String dreamInterpretationError(Object error);

  /// No description provided for @horseshoeSpreadError.
  ///
  /// In en, this message translates to:
  /// **'Horseshoe Spread reading error: \${error}'**
  String horseshoeSpreadError(Object error);

  /// No description provided for @careerPathSpreadError.
  ///
  /// In en, this message translates to:
  /// **'Career Path Spread reading error: \${error}'**
  String careerPathSpreadError(Object error);

  /// No description provided for @fullMoonSpreadError.
  ///
  /// In en, this message translates to:
  /// **'Full Moon Spread reading error: \${error}'**
  String fullMoonSpreadError(Object error);

  /// No description provided for @readingSaved.
  ///
  /// In en, this message translates to:
  /// **'Reading saved successfully'**
  String get readingSaved;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @insufficientCredits.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have enough credits to proceed.'**
  String get insufficientCredits;

  /// No description provided for @dailyLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You have reached your daily free reading limit.'**
  String get dailyLimitReached;

  /// No description provided for @insufficientCreditsAndLimit.
  ///
  /// In en, this message translates to:
  /// **'You have reached your daily free reading limit and don\'t have enough credits.'**
  String get insufficientCreditsAndLimit;

  /// No description provided for @couponHint.
  ///
  /// In en, this message translates to:
  /// **'Enter coupon code'**
  String get couponHint;

  /// No description provided for @redeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get redeem;

  /// Coupon is successfully redeemed
  ///
  /// In en, this message translates to:
  /// **'{message}'**
  String couponRedeemed(Object message);

  /// Coupon is invalid
  ///
  /// In en, this message translates to:
  /// **'{message}'**
  String couponInvalid(Object message);

  /// No description provided for @returnToHome.
  ///
  /// In en, this message translates to:
  /// **'Return to Home'**
  String get returnToHome;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait.'**
  String get pleaseWait;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @noReadings.
  ///
  /// In en, this message translates to:
  /// **'No readings found'**
  String get noReadings;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get dateLabel;

  /// No description provided for @purchaseCredits.
  ///
  /// In en, this message translates to:
  /// **'Purchase Credits'**
  String get purchaseCredits;

  /// Message shown when user has insufficient credits
  ///
  /// In en, this message translates to:
  /// **'You need {required} credits to continue. Purchase more credits below.'**
  String insufficientCreditsMessage(Object required);

  /// Informs the user about the time until their next free reading
  ///
  /// In en, this message translates to:
  /// **'Your next free reading will be available in {hours} hours.'**
  String nextFreeReadingInfo(Object hours);

  /// No description provided for @userInfo.
  ///
  /// In en, this message translates to:
  /// **'User Info'**
  String get userInfo;

  /// No description provided for @dailyFreeReadings.
  ///
  /// In en, this message translates to:
  /// **'Daily Free Readings'**
  String get dailyFreeReadings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Adjust your language and manage your mystical tokens here.'**
  String get settingsHelp;

  /// No description provided for @celticCrossCurrentSituation.
  ///
  /// In en, this message translates to:
  /// **'Current Situation'**
  String get celticCrossCurrentSituation;

  /// No description provided for @celticCrossChallenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get celticCrossChallenge;

  /// No description provided for @celticCrossSubconscious.
  ///
  /// In en, this message translates to:
  /// **'Subconscious'**
  String get celticCrossSubconscious;

  /// No description provided for @celticCrossPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get celticCrossPast;

  /// No description provided for @celticCrossFuture.
  ///
  /// In en, this message translates to:
  /// **'Possible Future'**
  String get celticCrossFuture;

  /// No description provided for @celticCrossNearFuture.
  ///
  /// In en, this message translates to:
  /// **'Near Future'**
  String get celticCrossNearFuture;

  /// No description provided for @celticCrossPersonalStance.
  ///
  /// In en, this message translates to:
  /// **'Personal Stance'**
  String get celticCrossPersonalStance;

  /// No description provided for @celticCrossExternalInfluences.
  ///
  /// In en, this message translates to:
  /// **'External Influences'**
  String get celticCrossExternalInfluences;

  /// No description provided for @celticCrossHopesFears.
  ///
  /// In en, this message translates to:
  /// **'Hopes & Fears'**
  String get celticCrossHopesFears;

  /// No description provided for @celticCrossFinalOutcome.
  ///
  /// In en, this message translates to:
  /// **'Final Outcome'**
  String get celticCrossFinalOutcome;

  /// No description provided for @brokenHeart.
  ///
  /// In en, this message translates to:
  /// **'Broken Heart'**
  String get brokenHeart;

  /// No description provided for @brokenHeartDescription.
  ///
  /// In en, this message translates to:
  /// **'Heal and understand emotional pain.'**
  String get brokenHeartDescription;

  /// No description provided for @careerPathSpread.
  ///
  /// In en, this message translates to:
  /// **'Career Path Spread'**
  String get careerPathSpread;

  /// No description provided for @careerPathSpreadDescription.
  ///
  /// In en, this message translates to:
  /// **'Detailed guidance for professional growth.'**
  String get careerPathSpreadDescription;

  /// No description provided for @spiritualMystical.
  ///
  /// In en, this message translates to:
  /// **'Spiritual & Mystical'**
  String get spiritualMystical;

  /// No description provided for @spiritualMysticalDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore your inner self, dreams, and cosmic connections.'**
  String get spiritualMysticalDescription;

  /// No description provided for @pastPresentFutureDescriptionLove.
  ///
  /// In en, this message translates to:
  /// **'Understand the influences of past, present, and future in your love life.'**
  String get pastPresentFutureDescriptionLove;

  /// No description provided for @mindBodySpiritDescriptionLove.
  ///
  /// In en, this message translates to:
  /// **'Harmonize your mind, body, and spirit in the context of love.'**
  String get mindBodySpiritDescriptionLove;

  /// No description provided for @fullMoonSpreadDescriptionLove.
  ///
  /// In en, this message translates to:
  /// **'Uncover hidden messages in your love life with lunar energy.'**
  String get fullMoonSpreadDescriptionLove;

  /// No description provided for @problemSolutionDescriptionCareer.
  ///
  /// In en, this message translates to:
  /// **'Get guidance to address challenges in your career.'**
  String get problemSolutionDescriptionCareer;

  /// No description provided for @horseshoeSpreadDescriptionCareer.
  ///
  /// In en, this message translates to:
  /// **'Gain a broad perspective on your career.'**
  String get horseshoeSpreadDescriptionCareer;

  /// No description provided for @problemSolutionDescriptionMoney.
  ///
  /// In en, this message translates to:
  /// **'Get guidance to address financial challenges.'**
  String get problemSolutionDescriptionMoney;

  /// No description provided for @horseshoeSpreadDescriptionMoney.
  ///
  /// In en, this message translates to:
  /// **'Gain a broad perspective on your finances.'**
  String get horseshoeSpreadDescriptionMoney;

  /// No description provided for @pastPresentFutureDescriptionMoney.
  ///
  /// In en, this message translates to:
  /// **'Explore your financial past, present, and future.'**
  String get pastPresentFutureDescriptionMoney;

  /// No description provided for @careerPathSpreadDescriptionMoney.
  ///
  /// In en, this message translates to:
  /// **'Detailed guidance for financial growth.'**
  String get careerPathSpreadDescriptionMoney;

  /// No description provided for @astroLogicalCrossDescriptionGeneral.
  ///
  /// In en, this message translates to:
  /// **'Align your path with the stars.'**
  String get astroLogicalCrossDescriptionGeneral;

  /// No description provided for @horseshoeSpreadDescriptionGeneral.
  ///
  /// In en, this message translates to:
  /// **'Gain a broad perspective on your life.'**
  String get horseshoeSpreadDescriptionGeneral;

  /// No description provided for @pastPresentFutureDescriptionGeneral.
  ///
  /// In en, this message translates to:
  /// **'Understand the influences of past, present, and future in your life.'**
  String get pastPresentFutureDescriptionGeneral;

  /// No description provided for @mindBodySpiritDescriptionSpiritual.
  ///
  /// In en, this message translates to:
  /// **'Harmonize your inner self with mind, body, and spirit.'**
  String get mindBodySpiritDescriptionSpiritual;

  /// No description provided for @dreamInterpretationDescriptionSpiritual.
  ///
  /// In en, this message translates to:
  /// **'Decode the messages in your dreams with a spiritual perspective.'**
  String get dreamInterpretationDescriptionSpiritual;

  /// No description provided for @fullMoonSpreadDescriptionSpiritual.
  ///
  /// In en, this message translates to:
  /// **'Gain spiritual clarity with lunar energy.'**
  String get fullMoonSpreadDescriptionSpiritual;

  /// No description provided for @astroLogicalCrossDescriptionSpiritual.
  ///
  /// In en, this message translates to:
  /// **'Align your spiritual path with the stars.'**
  String get astroLogicalCrossDescriptionSpiritual;

  /// No description provided for @celticCrossDescriptionSpiritual.
  ///
  /// In en, this message translates to:
  /// **'Receive a comprehensive analysis for your spiritual life.'**
  String get celticCrossDescriptionSpiritual;

  /// No description provided for @spiritualDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore your inner self, dreams, and cosmic connections.'**
  String get spiritualDescription;

  /// No description provided for @mindBodySpirit.
  ///
  /// In en, this message translates to:
  /// **'Mind Body Spirit'**
  String get mindBodySpirit;

  /// No description provided for @mindBodySpiritDescription.
  ///
  /// In en, this message translates to:
  /// **'Harmonize your inner self.'**
  String get mindBodySpiritDescription;

  /// No description provided for @astroLogicalCross.
  ///
  /// In en, this message translates to:
  /// **'Astrological Cross'**
  String get astroLogicalCross;

  /// No description provided for @astroLogicalCrossDescription.
  ///
  /// In en, this message translates to:
  /// **'Align your path with the stars.'**
  String get astroLogicalCrossDescription;

  /// No description provided for @dreamInterpretation.
  ///
  /// In en, this message translates to:
  /// **'Dream Interpretation'**
  String get dreamInterpretation;

  /// No description provided for @dreamInterpretationDescription.
  ///
  /// In en, this message translates to:
  /// **'Decode the messages in your dreams.'**
  String get dreamInterpretationDescription;

  /// No description provided for @horseshoeSpread.
  ///
  /// In en, this message translates to:
  /// **'Horseshoe Spread'**
  String get horseshoeSpread;

  /// No description provided for @horseshoeSpreadDescription.
  ///
  /// In en, this message translates to:
  /// **'A broad view of your situation.'**
  String get horseshoeSpreadDescription;

  /// No description provided for @fullMoonSpread.
  ///
  /// In en, this message translates to:
  /// **'Full Moon Spread'**
  String get fullMoonSpread;

  /// No description provided for @fullMoonSpreadDescription.
  ///
  /// In en, this message translates to:
  /// **'Harness lunar energy for clarity.'**
  String get fullMoonSpreadDescription;

  /// No description provided for @unveilTheStars.
  ///
  /// In en, this message translates to:
  /// **'Unveil the Stars'**
  String get unveilTheStars;

  /// No description provided for @unveilingMysticalPath.
  ///
  /// In en, this message translates to:
  /// **'Unveiling the Mystical Path...'**
  String get unveilingMysticalPath;

  /// No description provided for @instructionsFlipAll.
  ///
  /// In en, this message translates to:
  /// **'Flip all cards with a single tap.'**
  String get instructionsFlipAll;

  /// No description provided for @instructionsReshuffle.
  ///
  /// In en, this message translates to:
  /// **'Reshuffle the cards for a new draw.'**
  String get instructionsReshuffle;

  /// No description provided for @instructionsViewResults.
  ///
  /// In en, this message translates to:
  /// **'View the results once all cards are revealed.'**
  String get instructionsViewResults;

  /// No description provided for @problem.
  ///
  /// In en, this message translates to:
  /// **'Problem'**
  String get problem;

  /// No description provided for @solution.
  ///
  /// In en, this message translates to:
  /// **'Solution'**
  String get solution;

  /// No description provided for @dreamPast.
  ///
  /// In en, this message translates to:
  /// **'Dream Past'**
  String get dreamPast;

  /// No description provided for @dreamPresent.
  ///
  /// In en, this message translates to:
  /// **'Dream Present'**
  String get dreamPresent;

  /// No description provided for @dreamFuture.
  ///
  /// In en, this message translates to:
  /// **'Dream Future'**
  String get dreamFuture;

  /// No description provided for @fiveCardPathPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get fiveCardPathPast;

  /// No description provided for @fiveCardPathPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get fiveCardPathPresent;

  /// No description provided for @fiveCardPathChallenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get fiveCardPathChallenge;

  /// No description provided for @fiveCardPathFuture.
  ///
  /// In en, this message translates to:
  /// **'Future'**
  String get fiveCardPathFuture;

  /// No description provided for @fiveCardPathOutcome.
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get fiveCardPathOutcome;

  /// No description provided for @relationshipSelf.
  ///
  /// In en, this message translates to:
  /// **'Self'**
  String get relationshipSelf;

  /// No description provided for @relationshipPartner.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get relationshipPartner;

  /// No description provided for @relationshipPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get relationshipPast;

  /// No description provided for @relationshipPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get relationshipPresent;

  /// No description provided for @relationshipFuture.
  ///
  /// In en, this message translates to:
  /// **'Future'**
  String get relationshipFuture;

  /// No description provided for @relationshipStrengths.
  ///
  /// In en, this message translates to:
  /// **'Strengths'**
  String get relationshipStrengths;

  /// No description provided for @relationshipChallenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get relationshipChallenges;

  /// No description provided for @mindBody.
  ///
  /// In en, this message translates to:
  /// **'Mind-Body'**
  String get mindBody;

  /// No description provided for @mindSpirit.
  ///
  /// In en, this message translates to:
  /// **'Mind-Spirit'**
  String get mindSpirit;

  /// No description provided for @bodySpirit.
  ///
  /// In en, this message translates to:
  /// **'Body-Spirit'**
  String get bodySpirit;

  /// No description provided for @astroPast.
  ///
  /// In en, this message translates to:
  /// **'Astro Past'**
  String get astroPast;

  /// No description provided for @astroPresent.
  ///
  /// In en, this message translates to:
  /// **'Astro Present'**
  String get astroPresent;

  /// No description provided for @astroFuture.
  ///
  /// In en, this message translates to:
  /// **'Astro Future'**
  String get astroFuture;

  /// No description provided for @astroChallenge.
  ///
  /// In en, this message translates to:
  /// **'Astro Challenge'**
  String get astroChallenge;

  /// No description provided for @astroOutcome.
  ///
  /// In en, this message translates to:
  /// **'Astro Outcome'**
  String get astroOutcome;

  /// No description provided for @brokenHeartCause.
  ///
  /// In en, this message translates to:
  /// **'Cause'**
  String get brokenHeartCause;

  /// No description provided for @brokenHeartEmotion.
  ///
  /// In en, this message translates to:
  /// **'Emotion'**
  String get brokenHeartEmotion;

  /// No description provided for @brokenHeartLesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get brokenHeartLesson;

  /// No description provided for @brokenHeartHope.
  ///
  /// In en, this message translates to:
  /// **'Hope'**
  String get brokenHeartHope;

  /// No description provided for @brokenHeartHealing.
  ///
  /// In en, this message translates to:
  /// **'Healing'**
  String get brokenHeartHealing;

  /// No description provided for @horseshoePast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get horseshoePast;

  /// No description provided for @horseshoePresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get horseshoePresent;

  /// No description provided for @horseshoeFuture.
  ///
  /// In en, this message translates to:
  /// **'Future'**
  String get horseshoeFuture;

  /// No description provided for @horseshoeStrengths.
  ///
  /// In en, this message translates to:
  /// **'Strengths'**
  String get horseshoeStrengths;

  /// No description provided for @horseshoeObstacles.
  ///
  /// In en, this message translates to:
  /// **'Obstacles'**
  String get horseshoeObstacles;

  /// No description provided for @horseshoeAdvice.
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get horseshoeAdvice;

  /// No description provided for @horseshoeOutcome.
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get horseshoeOutcome;

  /// No description provided for @careerPast.
  ///
  /// In en, this message translates to:
  /// **'Career Past'**
  String get careerPast;

  /// No description provided for @careerPresent.
  ///
  /// In en, this message translates to:
  /// **'Career Present'**
  String get careerPresent;

  /// No description provided for @careerChallenge.
  ///
  /// In en, this message translates to:
  /// **'Career Challenge'**
  String get careerChallenge;

  /// No description provided for @careerPotential.
  ///
  /// In en, this message translates to:
  /// **'Career Potential'**
  String get careerPotential;

  /// No description provided for @careerOutcome.
  ///
  /// In en, this message translates to:
  /// **'Career Outcome'**
  String get careerOutcome;

  /// No description provided for @fullMoonPast.
  ///
  /// In en, this message translates to:
  /// **'Full Moon Past'**
  String get fullMoonPast;

  /// No description provided for @fullMoonPresent.
  ///
  /// In en, this message translates to:
  /// **'Full Moon Present'**
  String get fullMoonPresent;

  /// No description provided for @fullMoonChallenge.
  ///
  /// In en, this message translates to:
  /// **'Full Moon Challenge'**
  String get fullMoonChallenge;

  /// No description provided for @fullMoonHope.
  ///
  /// In en, this message translates to:
  /// **'Full Moon Hope'**
  String get fullMoonHope;

  /// No description provided for @fullMoonOutcome.
  ///
  /// In en, this message translates to:
  /// **'Full Moon Outcome'**
  String get fullMoonOutcome;

  /// Currency used in the app for readings
  ///
  /// In en, this message translates to:
  /// **'Mystical Tokens'**
  String get mysticalTokens;

  /// No description provided for @errorLoadingReadings.
  ///
  /// In en, this message translates to:
  /// **'Error loading readings'**
  String get errorLoadingReadings;

  /// No description provided for @unknownSpread.
  ///
  /// In en, this message translates to:
  /// **'Unknown spread'**
  String get unknownSpread;

  /// No description provided for @noInterpretation.
  ///
  /// In en, this message translates to:
  /// **'No interpretation available'**
  String get noInterpretation;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @languageChangedToEnglish.
  ///
  /// In en, this message translates to:
  /// **'Language changed to English'**
  String get languageChangedToEnglish;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @languageChangedToTurkish.
  ///
  /// In en, this message translates to:
  /// **'Language changed to Turkish'**
  String get languageChangedToTurkish;

  /// No description provided for @tenTokens.
  ///
  /// In en, this message translates to:
  /// **'10 Tokens'**
  String get tenTokens;

  /// No description provided for @fiftyTokens.
  ///
  /// In en, this message translates to:
  /// **'50 Tokens'**
  String get fiftyTokens;

  /// No description provided for @hundredTokens.
  ///
  /// In en, this message translates to:
  /// **'100 Tokens'**
  String get hundredTokens;

  /// No description provided for @premiumSubscription.
  ///
  /// In en, this message translates to:
  /// **'Premium Subscription'**
  String get premiumSubscription;

  /// No description provided for @drawCards.
  ///
  /// In en, this message translates to:
  /// **'Draw Cards'**
  String get drawCards;

  /// No description provided for @instructionsDrawCards.
  ///
  /// In en, this message translates to:
  /// **'Use this button to manually draw the cards.'**
  String get instructionsDrawCards;

  /// No description provided for @selectToDraw.
  ///
  /// In en, this message translates to:
  /// **'Swipe to reveal your destiny'**
  String get selectToDraw;

  /// No description provided for @premiumDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlimited readings and exclusive content'**
  String get premiumDescription;

  /// No description provided for @bundleDescription.
  ///
  /// In en, this message translates to:
  /// **'50 credits + Premium subscription'**
  String get bundleDescription;

  /// No description provided for @creditDescription.
  ///
  /// In en, this message translates to:
  /// **'{credits} credits for more readings'**
  String creditDescription(Object credits);

  /// No description provided for @premiumReadings.
  ///
  /// In en, this message translates to:
  /// **'Premium Readings'**
  String get premiumReadings;

  /// No description provided for @confirmPurchase.
  ///
  /// In en, this message translates to:
  /// **'Confirm Purchase'**
  String get confirmPurchase;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to purchase'**
  String get areYouSure;

  /// No description provided for @forText.
  ///
  /// In en, this message translates to:
  /// **'for'**
  String get forText;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @couponAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'This coupon has already been used.'**
  String get couponAlreadyUsed;

  /// Snackbar message shown after a successful purchase.
  ///
  /// In en, this message translates to:
  /// **'Ödeme Başarılı'**
  String get paymentSuccessful;

  /// No description provided for @arcana.
  ///
  /// In en, this message translates to:
  /// **'Sır'**
  String get arcana;

  /// No description provided for @suit.
  ///
  /// In en, this message translates to:
  /// **'Takım'**
  String get suit;

  /// No description provided for @celticCrossConscious.
  ///
  /// In en, this message translates to:
  /// **'Kelt Haçı Bilinçli'**
  String get celticCrossConscious;

  /// No description provided for @longPressHint.
  ///
  /// In en, this message translates to:
  /// **'Uzun Basma İpucu'**
  String get longPressHint;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Talimatlar'**
  String get instructions;

  /// No description provided for @slideToDrawCards.
  ///
  /// In en, this message translates to:
  /// **'Kart Çekmek İçin Kaydırın'**
  String get slideToDrawCards;

  /// Instruction text on the drawn cards summary page
  ///
  /// In en, this message translates to:
  /// **'Tap card for details'**
  String get tapCardForDetails;

  /// Generic title for an interpretation section when specific title isn't found
  ///
  /// In en, this message translates to:
  /// **'Interpretation'**
  String get interpretation;

  /// Fallback title for a section of the interpretation
  ///
  /// In en, this message translates to:
  /// **'Interpretation Section'**
  String get interpretationSection;

  /// Default text for sharing the reading
  ///
  /// In en, this message translates to:
  /// **'My Tarot Reading'**
  String get myTarotReading;

  /// AppBar title for the reading result screen
  ///
  /// In en, this message translates to:
  /// **'Reading Result'**
  String get readingResult;

  /// Message shown when the reading result state doesn't contain expected data
  ///
  /// In en, this message translates to:
  /// **'No reading data available.'**
  String get noReadingData;

  /// No description provided for @checkingResources.
  ///
  /// In en, this message translates to:
  /// **'Checking resources...'**
  String get checkingResources;

  /// No description provided for @obstacleAdvice.
  ///
  /// In en, this message translates to:
  /// **'Obstacle / Advice'**
  String get obstacleAdvice;

  /// Confirmation message before buying a product
  ///
  /// In en, this message translates to:
  /// **'Do you want to buy {title} for {price}?'**
  String purchaseConfirmation(String title, String price);

  /// Message shown after successfully adding credits
  ///
  /// In en, this message translates to:
  /// **'{count} credits added successfully!'**
  String creditsAdded(String count);

  /// Message shown when premium subscription is activated
  ///
  /// In en, this message translates to:
  /// **'Premium subscription activated!'**
  String get premiumActivated;

  /// Message shown when a purchase fails
  ///
  /// In en, this message translates to:
  /// **'Purchase failed: {error}'**
  String purchaseFailed(String error);

  /// Message shown while a purchase is pending
  ///
  /// In en, this message translates to:
  /// **'Purchase pending...'**
  String get purchasePending;

  /// Error message when products cannot be loaded from the store
  ///
  /// In en, this message translates to:
  /// **'Failed to load products.'**
  String get failedToLoadProducts;

  /// Message shown when no products are returned from the store
  ///
  /// In en, this message translates to:
  /// **'No products available at the moment.'**
  String get noProductsAvailable;

  /// Error message when the user tries to redeem an empty coupon code
  ///
  /// In en, this message translates to:
  /// **'Coupon code cannot be empty.'**
  String get couponCannotBeEmpty;

  /// Error message when full card details cannot be fetched
  ///
  /// In en, this message translates to:
  /// **'Error loading card details.'**
  String get errorLoadingCardDetails;

  /// Tab title for the spread cards view
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// Message shown in the cards tab if spread data is empty
  ///
  /// In en, this message translates to:
  /// **'No cards found in this spread.'**
  String get noCardsInSpread;

  /// Title for the 'Questions to Ask' section in card details
  ///
  /// In en, this message translates to:
  /// **'Questions to Ask'**
  String get questionsToAsk;

  /// Default title for the first section of interpretation if no markdown title exists
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Default title for remaining interpretation text if no markdown title exists
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// Title for sharing a reading, includes spread type and date
  ///
  /// In en, this message translates to:
  /// **'{spreadType} Reading - {dateStr}'**
  String shareTitle(String spreadType, String dateStr);

  /// No description provided for @invalidPage.
  ///
  /// In en, this message translates to:
  /// **'Invalid Page'**
  String get invalidPage;

  /// No description provided for @yearlySpreadSummary.
  ///
  /// In en, this message translates to:
  /// **'Yearly Summary'**
  String get yearlySpreadSummary;

  /// Label for a card in a generic spread, showing its number
  ///
  /// In en, this message translates to:
  /// **'Card {index}'**
  String cardLabel(int index);

  /// No description provided for @mindBodySpiritMind.
  ///
  /// In en, this message translates to:
  /// **'Mind'**
  String get mindBodySpiritMind;

  /// No description provided for @mindBodySpiritBody.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get mindBodySpiritBody;

  /// No description provided for @mindBodySpiritSpirit.
  ///
  /// In en, this message translates to:
  /// **'Spirit'**
  String get mindBodySpiritSpirit;

  /// No description provided for @astroLogicalCrossIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity / Self'**
  String get astroLogicalCrossIdentity;

  /// No description provided for @astroLogicalCrossEmotional.
  ///
  /// In en, this message translates to:
  /// **'Emotional State'**
  String get astroLogicalCrossEmotional;

  /// No description provided for @astroLogicalCrossExternal.
  ///
  /// In en, this message translates to:
  /// **'External Influences'**
  String get astroLogicalCrossExternal;

  /// No description provided for @astroLogicalCrossChallenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge / Lesson'**
  String get astroLogicalCrossChallenge;

  /// No description provided for @astroLogicalCrossDestiny.
  ///
  /// In en, this message translates to:
  /// **'Destiny / Outcome'**
  String get astroLogicalCrossDestiny;

  /// No description provided for @dreamInterpretationPast.
  ///
  /// In en, this message translates to:
  /// **'Dream - Past Link'**
  String get dreamInterpretationPast;

  /// No description provided for @dreamInterpretationPresent.
  ///
  /// In en, this message translates to:
  /// **'Dream - Present Emotion'**
  String get dreamInterpretationPresent;

  /// No description provided for @dreamInterpretationFuture.
  ///
  /// In en, this message translates to:
  /// **'Dream - Future Guidance'**
  String get dreamInterpretationFuture;

  /// No description provided for @horseshoeUserAttitude.
  ///
  /// In en, this message translates to:
  /// **'Your Attitude'**
  String get horseshoeUserAttitude;

  /// No description provided for @horseshoeExternalInfluence.
  ///
  /// In en, this message translates to:
  /// **'External Influence'**
  String get horseshoeExternalInfluence;

  /// No description provided for @careerPathCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current Situation'**
  String get careerPathCurrent;

  /// No description provided for @careerPathObstacles.
  ///
  /// In en, this message translates to:
  /// **'Obstacles'**
  String get careerPathObstacles;

  /// No description provided for @careerPathOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Opportunities'**
  String get careerPathOpportunities;

  /// No description provided for @careerPathStrengths.
  ///
  /// In en, this message translates to:
  /// **'Strengths'**
  String get careerPathStrengths;

  /// No description provided for @careerPathOutcome.
  ///
  /// In en, this message translates to:
  /// **'Potential Outcome'**
  String get careerPathOutcome;

  /// No description provided for @fullMoonCulmination.
  ///
  /// In en, this message translates to:
  /// **'Culmination'**
  String get fullMoonCulmination;

  /// No description provided for @fullMoonRevealed.
  ///
  /// In en, this message translates to:
  /// **'What is Revealed'**
  String get fullMoonRevealed;

  /// No description provided for @fullMoonRelease.
  ///
  /// In en, this message translates to:
  /// **'What to Release'**
  String get fullMoonRelease;

  /// No description provided for @fullMoonObstacles.
  ///
  /// In en, this message translates to:
  /// **'Obstacles to Release'**
  String get fullMoonObstacles;

  /// No description provided for @fullMoonAction.
  ///
  /// In en, this message translates to:
  /// **'Action / Integration'**
  String get fullMoonAction;

  /// No description provided for @fullMoonResultingEnergy.
  ///
  /// In en, this message translates to:
  /// **'Resulting Energy'**
  String get fullMoonResultingEnergy;

  /// No description provided for @claim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get claim;

  /// Message shown after claiming the daily reward
  ///
  /// In en, this message translates to:
  /// **'Daily reward claimed! Next reward in {time}'**
  String dailyRewardClaimedMessage(String time);

  /// No description provided for @dailyRewardNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Reward Ready!'**
  String get dailyRewardNotificationTitle;

  /// No description provided for @dailyRewardNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Your mystical tokens await. Come back to claim them!'**
  String get dailyRewardNotificationBody;

  /// Tooltip text shown when hovering over the daily claim button/icon
  ///
  /// In en, this message translates to:
  /// **'Claim your daily credits!'**
  String get claimDailyRewardTooltip;

  /// Prefix text shown before the countdown timer for the next daily reward
  ///
  /// In en, this message translates to:
  /// **'Next:'**
  String get nextReward;

  /// Tooltip text shown when hovering over the countdown timer for the next daily reward
  ///
  /// In en, this message translates to:
  /// **'Next daily reward available in {time}'**
  String nextRewardTooltip(String time);

  /// Text for the main claim button (now compact icon, text not directly visible but key is used)
  ///
  /// In en, this message translates to:
  /// **'Claim Your Daily {count} Credits!'**
  String claimYourDailyTokens(int count);

  /// Information text displayed in a dialog when the user taps on the daily reward countdown timer.
  ///
  /// In en, this message translates to:
  /// **'This timer shows when your next free daily credits will be available.'**
  String get dailyRewardInfo;

  /// Tooltip shown when hovering over the credit display area in the top bar.
  ///
  /// In en, this message translates to:
  /// **'Tap to buy credits'**
  String get creditInfoTooltip;

  /// Tooltip shown for the redeem coupon button/icon.
  ///
  /// In en, this message translates to:
  /// **'Redeem Coupon'**
  String get redeemCouponTooltip;
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
