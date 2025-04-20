import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get tarotFortune => 'Astral Tarot';

  @override
  String errorMessage(Object message) {
    return 'Error: $message';
  }

  @override
  String get tryAgain => 'Try Again';

  @override
  String get pastPresentFuture => ' Past-Present-Future Spread';

  @override
  String get problemSolution => 'Perform Problem-Solution Spread';

  @override
  String get singleCard => 'Perform Single Card Reading';

  @override
  String get loveReading => 'Perform Love Reading';

  @override
  String get careerReading => 'Perform Career Reading';

  @override
  String get noSelectionYet => 'No selection has been made yet';

  @override
  String get position => 'Position';

  @override
  String get meaning => 'Meaning';

  @override
  String get mysticMeaning => 'Mystical Interpretation';

  @override
  String get tarotFortuneGuide => 'Guide to Mystical Paths';

  @override
  String fortuneInsight(Object category, Object spreadType) {
    return 'This Tarot Reading - reading provides deep insight into $category using the $spreadType spread. As we journey into the depths of your soul, let us interpret the mysterious messages of the cards together.';
  }

  @override
  String get divineDance => 'The Divine Dance of the Cards';

  @override
  String get unifiedDestinyReflection => 'Unified Reflection of Destiny';

  @override
  String unifiedDestinyMessage(Object category) {
    return 'The combination of these cards marks a significant turning point in your $category journey. The unified energy of the cards reveals messages from the depths of your soul.';
  }

  @override
  String get cardsCombinedAssessment => 'Combined Assessment of the Cards';

  @override
  String get cardsEnergiesInteract => 'The energies of the cards are interacting with each other.';

  @override
  String get generalDetailedComment => 'General Commentary (Detailed)';

  @override
  String get lifeDynamicsHighlighted => 'These cards highlight important dynamics in your life.';

  @override
  String get guidingWhispers => 'Guiding Whispers';

  @override
  String get futureSuggestions => 'For your near future, consider these suggestions: [NEAR_FUTURE_SUGGESTIONS]';

  @override
  String get potentialPitfalls => 'Potential pitfalls to watch out for: [POTENTIAL_PITFALLS]';

  @override
  String cardLoadingError(Object error) {
    return 'An error occurred while loading the cards: $error';
  }

  @override
  String singleCardReadingError(Object error) {
    return 'An error occurred while performing a single card reading: $error';
  }

  @override
  String pastPresentFutureReadingError(Object error) {
    return 'An error occurred while performing a past-present-future spread: $error';
  }

  @override
  String problemSolutionReadingError(Object error) {
    return 'An error occurred while performing a problem-solution spread: $error';
  }

  @override
  String fiveCardPathReadingError(Object error) {
    return 'An error occurred while performing a five-card path spread: $error';
  }

  @override
  String relationshipSpreadReadingError(Object error) {
    return 'An error occurred while performing a relationship spread: $error';
  }

  @override
  String celticCrossReadingError(Object error) {
    return 'An error occurred while performing a Celtic Cross spread: $error';
  }

  @override
  String yearlySpreadReadingError(Object error) {
    return 'An error occurred while performing a yearly spread: $error';
  }

  @override
  String categorySpreadReadingError(Object error) {
    return 'An error occurred while performing a category-based spread: $error';
  }

  @override
  String get cardDeckEmpty => 'Card deck is empty';

  @override
  String get tooManyCardsRequested => 'The requested number of cards exceeds the deck size';

  @override
  String cardsLoadingErrorGeneric(Object error) {
    return 'An error occurred while loading cards: $error';
  }

  @override
  String get tarotFortuneTitle => 'Tarot Reading - Guide to Mystical Paths';

  @override
  String tarotFortuneDescription(Object category, Object spreadType) {
    return 'This reading provides personal and deep insights into $category using the $spreadType spread. Prepare to dive into the depths of your soul and uncover the unique messages of the cards!';
  }

  @override
  String get divineSymphony => 'The Divine Symphony of the Cards';

  @override
  String get unifiedDestinyReflectionTitle => 'Reflections of Unified Destiny';

  @override
  String get generalAnalysis => 'General Analysis';

  @override
  String get cardsCombinedEvaluation => 'Combined Evaluation of the Cards';

  @override
  String get specialNote => 'Special Note';

  @override
  String get detailedGeneralCommentary => 'In-Depth General Commentary';

  @override
  String get guidingWhispersAndSuggestions => 'Guiding Whispers & Suggestions';

  @override
  String get timelineAndSuggestions => 'Timeline & Suggestions';

  @override
  String get pointsToWatch => 'Points to Watch Out For';

  @override
  String get categorySpecificTips => 'Category-Specific Tips';

  @override
  String get deck_empty => 'Card deck is empty';

  @override
  String get too_many_cards => 'The requested number of cards exceeds the deck size';

  @override
  String cards_loading_error(Object error) {
    return 'An error occurred while loading cards: $error';
  }

  @override
  String get keywords => 'Keywords:';

  @override
  String get swipeForMore => 'Swipe for more';

  @override
  String get swipeToSeePages => 'Swipe to see pages';

  @override
  String get fortuneTelling => 'Fortune Telling:';

  @override
  String get settings => 'Settings';

  @override
  String get mysticJourney => 'Mystic Journey';

  @override
  String get startJourney => 'Start Journey';

  @override
  String get differentInterpretation => 'A different interpretation awaits each choice';

  @override
  String get categorySelection => 'Category Selection';

  @override
  String get chooseTopic => 'Choose the topic you want to explore';

  @override
  String get loveRelationships => 'Love & Relationships';

  @override
  String get loveDescription => 'Gain deep insights into your relationships';

  @override
  String get career => 'Career';

  @override
  String get careerDescription => 'Get guidance on your career path';

  @override
  String get money => 'Money';

  @override
  String get moneyDescription => 'Gain insights into financial matters';

  @override
  String get general => 'General';

  @override
  String get generalDescription => 'Receive general life guidance';

  @override
  String get categoryInfoBanner => 'Special spreads will be offered based on your chosen category';

  @override
  String get spreadSelection => 'Spread Selection';

  @override
  String get chooseSpread => 'Choose how the cards will be drawn';

  @override
  String get spreadInfoBanner => 'Each spread offers a different number of cards and interpretations';

  @override
  String get singleCardDescription => 'Ideal for quick answers';

  @override
  String get relationshipSpread => 'Relationship Spread';

  @override
  String get relationshipSpreadDescription => 'Detailed analysis of your relationship';

  @override
  String get pastPresentFutureDescription => 'Guidance for your career path';

  @override
  String get fiveCardPath => 'Five Card Path';

  @override
  String get fiveCardPathDescription => 'Detailed analysis for career choices';

  @override
  String get celticCrossDescription => 'Detailed and comprehensive analysis';

  @override
  String get yearlySpreadDescription => 'Guidance for the next 12 months';

  @override
  String cardCount(Object count) {
    return '$count cards';
  }

  @override
  String get celticCrossReading => 'Celtic Cross';

  @override
  String get yearlySpreadReading => 'Yearly Spread';

  @override
  String get cardSelection => 'Card Selection';

  @override
  String get cardSelectionInstructions => 'The number of cards will be displayed face down. Please tap to reveal them one by one, long press to see a brief description, or use the \'Flip All Cards\' option.';

  @override
  String get flipAllCards => 'Flip All Cards';

  @override
  String get reshuffleCards => 'Reshuffle Cards';

  @override
  String get viewResults => 'View Results';

  @override
  String get close => 'Close';

  @override
  String get lightMeaning => 'Light (Positive):';

  @override
  String get shadowMeaning => 'Shadow (Negative):';

  @override
  String get customPromptTitle => 'Custom Prompt';

  @override
  String get customPromptHint => 'Type your custom prompt here...';

  @override
  String get promptEmptyError => 'Please enter a prompt.';

  @override
  String get sendPrompt => 'Send Prompt';

  @override
  String get cancel => 'Cancel';

  @override
  String get dailyLimitExceeded => 'Daily free reading limit reached. Please purchase credits or upgrade to premium.';

  @override
  String get tokenLimitExceeded => 'Token limit exceeded for this spread. Upgrade to premium for more detailed readings.';

  @override
  String mindBodySpiritError(Object error) {
    return 'Mind-Body-Spirit reading error: \$$error';
  }

  @override
  String astroLogicalCrossError(Object error) {
    return 'AstroLogical Cross reading error: \$$error';
  }

  @override
  String brokenHeartError(Object error) {
    return 'Broken Heart reading error: \$$error';
  }

  @override
  String dreamInterpretationError(Object error) {
    return 'Dream Interpretation reading error: \$$error';
  }

  @override
  String horseshoeSpreadError(Object error) {
    return 'Horseshoe Spread reading error: \$$error';
  }

  @override
  String careerPathSpreadError(Object error) {
    return 'Career Path Spread reading error: \$$error';
  }

  @override
  String fullMoonSpreadError(Object error) {
    return 'Full Moon Spread reading error: \$$error';
  }

  @override
  String get readingSaved => 'Reading saved successfully';

  @override
  String get save => 'Save';

  @override
  String get share => 'Share';

  @override
  String get warning => 'Warning';

  @override
  String get insufficientCredits => 'You don\'t have enough credits to proceed.';

  @override
  String get dailyLimitReached => 'You have reached your daily free reading limit.';

  @override
  String get insufficientCreditsAndLimit => 'You have reached your daily free reading limit and don\'t have enough credits.';

  @override
  String get couponHint => 'Enter coupon code';

  @override
  String get redeem => 'Redeem';

  @override
  String couponRedeemed(Object message) {
    return '$message';
  }

  @override
  String couponInvalid(Object message) {
    return '$message';
  }

  @override
  String get returnToHome => 'Return to Home';

  @override
  String get pleaseWait => 'Please wait.';

  @override
  String get profile => 'Profile';

  @override
  String get noReadings => 'No readings found';

  @override
  String get dateLabel => 'Date:';

  @override
  String get purchaseCredits => 'Purchase Credits';

  @override
  String insufficientCreditsMessage(Object required) {
    return 'You need $required credits to continue. Purchase more credits below.';
  }

  @override
  String nextFreeReadingInfo(Object hours) {
    return 'Your next free reading will be available in $hours hours.';
  }

  @override
  String get userInfo => 'User Info';

  @override
  String get dailyFreeReadings => 'Daily Free Readings';

  @override
  String get language => 'Language';

  @override
  String get settingsHelp => 'Adjust your language and manage your mystical tokens here.';

  @override
  String get celticCrossCurrentSituation => 'Current Situation';

  @override
  String get celticCrossChallenge => 'Challenge';

  @override
  String get celticCrossSubconscious => 'Subconscious';

  @override
  String get celticCrossPast => 'Past';

  @override
  String get celticCrossFuture => 'Possible Future';

  @override
  String get celticCrossNearFuture => 'Near Future';

  @override
  String get celticCrossPersonalStance => 'Personal Stance';

  @override
  String get celticCrossExternalInfluences => 'External Influences';

  @override
  String get celticCrossHopesFears => 'Hopes & Fears';

  @override
  String get celticCrossFinalOutcome => 'Final Outcome';

  @override
  String get brokenHeart => 'Broken Heart';

  @override
  String get brokenHeartDescription => 'Heal and understand emotional pain.';

  @override
  String get careerPathSpread => 'Career Path Spread';

  @override
  String get careerPathSpreadDescription => 'Detailed guidance for professional growth.';

  @override
  String get spiritualMystical => 'Spiritual & Mystical';

  @override
  String get spiritualMysticalDescription => 'Explore your inner self, dreams, and cosmic connections.';

  @override
  String get pastPresentFutureDescriptionLove => 'Understand the influences of past, present, and future in your love life.';

  @override
  String get mindBodySpiritDescriptionLove => 'Harmonize your mind, body, and spirit in the context of love.';

  @override
  String get fullMoonSpreadDescriptionLove => 'Uncover hidden messages in your love life with lunar energy.';

  @override
  String get problemSolutionDescriptionCareer => 'Get guidance to address challenges in your career.';

  @override
  String get horseshoeSpreadDescriptionCareer => 'Gain a broad perspective on your career.';

  @override
  String get problemSolutionDescriptionMoney => 'Get guidance to address financial challenges.';

  @override
  String get horseshoeSpreadDescriptionMoney => 'Gain a broad perspective on your finances.';

  @override
  String get pastPresentFutureDescriptionMoney => 'Explore your financial past, present, and future.';

  @override
  String get careerPathSpreadDescriptionMoney => 'Detailed guidance for financial growth.';

  @override
  String get astroLogicalCrossDescriptionGeneral => 'Align your path with the stars.';

  @override
  String get horseshoeSpreadDescriptionGeneral => 'Gain a broad perspective on your life.';

  @override
  String get pastPresentFutureDescriptionGeneral => 'Understand the influences of past, present, and future in your life.';

  @override
  String get mindBodySpiritDescriptionSpiritual => 'Harmonize your inner self with mind, body, and spirit.';

  @override
  String get dreamInterpretationDescriptionSpiritual => 'Decode the messages in your dreams with a spiritual perspective.';

  @override
  String get fullMoonSpreadDescriptionSpiritual => 'Gain spiritual clarity with lunar energy.';

  @override
  String get astroLogicalCrossDescriptionSpiritual => 'Align your spiritual path with the stars.';

  @override
  String get celticCrossDescriptionSpiritual => 'Receive a comprehensive analysis for your spiritual life.';

  @override
  String get spiritualDescription => 'Explore your inner self, dreams, and cosmic connections.';

  @override
  String get mindBodySpirit => 'Mind Body Spirit';

  @override
  String get mindBodySpiritDescription => 'Harmonize your inner self.';

  @override
  String get astroLogicalCross => 'Astrological Cross';

  @override
  String get astroLogicalCrossDescription => 'Align your path with the stars.';

  @override
  String get dreamInterpretation => 'Dream Interpretation';

  @override
  String get dreamInterpretationDescription => 'Decode the messages in your dreams.';

  @override
  String get horseshoeSpread => 'Horseshoe Spread';

  @override
  String get horseshoeSpreadDescription => 'A broad view of your situation.';

  @override
  String get fullMoonSpread => 'Full Moon Spread';

  @override
  String get fullMoonSpreadDescription => 'Harness lunar energy for clarity.';

  @override
  String get unveilTheStars => 'Unveil the Stars';

  @override
  String get unveilingMysticalPath => 'Unveiling the Mystical Path...';

  @override
  String get instructionsFlipAll => 'Flip all cards with a single tap.';

  @override
  String get instructionsReshuffle => 'Reshuffle the cards for a new draw.';

  @override
  String get instructionsViewResults => 'View the results once all cards are revealed.';

  @override
  String get problem => 'Problem';

  @override
  String get solution => 'Solution';

  @override
  String get dreamPast => 'Dream Past';

  @override
  String get dreamPresent => 'Dream Present';

  @override
  String get dreamFuture => 'Dream Future';

  @override
  String get fiveCardPathPast => 'Past';

  @override
  String get fiveCardPathPresent => 'Present';

  @override
  String get fiveCardPathChallenge => 'Challenge';

  @override
  String get fiveCardPathFuture => 'Future';

  @override
  String get fiveCardPathOutcome => 'Outcome';

  @override
  String get relationshipSelf => 'Self';

  @override
  String get relationshipPartner => 'Partner';

  @override
  String get relationshipPast => 'Past';

  @override
  String get relationshipPresent => 'Present';

  @override
  String get relationshipFuture => 'Future';

  @override
  String get relationshipStrengths => 'Strengths';

  @override
  String get relationshipChallenges => 'Challenges';

  @override
  String get mindBody => 'Mind-Body';

  @override
  String get mindSpirit => 'Mind-Spirit';

  @override
  String get bodySpirit => 'Body-Spirit';

  @override
  String get astroPast => 'Astro Past';

  @override
  String get astroPresent => 'Astro Present';

  @override
  String get astroFuture => 'Astro Future';

  @override
  String get astroChallenge => 'Astro Challenge';

  @override
  String get astroOutcome => 'Astro Outcome';

  @override
  String get brokenHeartCause => 'Cause';

  @override
  String get brokenHeartEmotion => 'Emotion';

  @override
  String get brokenHeartLesson => 'Lesson';

  @override
  String get brokenHeartHope => 'Hope';

  @override
  String get brokenHeartHealing => 'Healing';

  @override
  String get horseshoePast => 'Past';

  @override
  String get horseshoePresent => 'Present';

  @override
  String get horseshoeFuture => 'Future';

  @override
  String get horseshoeStrengths => 'Strengths';

  @override
  String get horseshoeObstacles => 'Obstacles';

  @override
  String get horseshoeAdvice => 'Advice';

  @override
  String get horseshoeOutcome => 'Outcome';

  @override
  String get careerPast => 'Career Past';

  @override
  String get careerPresent => 'Career Present';

  @override
  String get careerChallenge => 'Career Challenge';

  @override
  String get careerPotential => 'Career Potential';

  @override
  String get careerOutcome => 'Career Outcome';

  @override
  String get fullMoonPast => 'Full Moon Past';

  @override
  String get fullMoonPresent => 'Full Moon Present';

  @override
  String get fullMoonChallenge => 'Full Moon Challenge';

  @override
  String get fullMoonHope => 'Full Moon Hope';

  @override
  String get fullMoonOutcome => 'Full Moon Outcome';

  @override
  String get mysticalTokens => 'Mystical Tokens';

  @override
  String get errorLoadingReadings => 'Error loading readings';

  @override
  String get unknownSpread => 'Unknown spread';

  @override
  String get noInterpretation => 'No interpretation available';

  @override
  String get premium => 'Premium';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get english => 'English';

  @override
  String get languageChangedToEnglish => 'Language changed to English';

  @override
  String get turkish => 'Turkish';

  @override
  String get languageChangedToTurkish => 'Language changed to Turkish';

  @override
  String get tenTokens => '10 Tokens';

  @override
  String get fiftyTokens => '50 Tokens';

  @override
  String get hundredTokens => '100 Tokens';

  @override
  String get premiumSubscription => 'Premium Subscription';

  @override
  String get drawCards => 'Draw Cards';

  @override
  String get instructionsDrawCards => 'Use this button to manually draw the cards.';

  @override
  String get selectToDraw => 'Swipe to reveal your destiny';

  @override
  String get premiumDescription => 'Unlimited readings and exclusive content';

  @override
  String get bundleDescription => '50 credits + Premium subscription';

  @override
  String creditDescription(Object credits) {
    return '$credits credits for more readings';
  }

  @override
  String get premiumReadings => 'Premium Readings';

  @override
  String get confirmPurchase => 'Confirm Purchase';

  @override
  String get areYouSure => 'Are you sure you want to purchase';

  @override
  String get forText => 'for';

  @override
  String get confirm => 'Confirm';

  @override
  String get couponAlreadyUsed => 'This coupon has already been used.';

  @override
  String get paymentSuccessful => 'Ödeme Başarılı';

  @override
  String get arcana => 'Sır';

  @override
  String get suit => 'Takım';

  @override
  String get celticCrossConscious => 'Kelt Haçı Bilinçli';

  @override
  String get longPressHint => 'Uzun Basma İpucu';

  @override
  String get instructions => 'Talimatlar';

  @override
  String get slideToDrawCards => 'Kart Çekmek İçin Kaydırın';
}
