# tarot_fal

Your personal Tarot guide where mysticism meets the digital world.

This application is designed to offer users in-depth guidance and insight into love, career, money, and general life topics through various Tarot spreads. It utilizes Gemini AI to generate personalized and meaningful interpretations.

## Key Features

* **Multiple Tarot Spreads:** Perform various readings including Single Card, Past-Present-Future, Celtic Cross, Relationship Spread, Problem-Solution, Career Path, Astrological Cross, and more.
* **Category Selection:** Focus your readings on specific areas like Love, Career, Money, General, or Spiritual.
* **AI-Powered Interpretations:** Receive detailed and personalized interpretations based on the selected cards and category, powered by Google Gemini AI.
* **User Credits (Mystical Tokens):** Utilizes an in-app credit system to perform readings.
* **Daily Rewards:** Offers users a chance to earn free credits regularly.
* **Localization:** Supports English (EN) and Turkish (TR) languages.
* **Notification System:** Informs users when daily rewards are available via local notifications.
* **User Profile & History:** (Likely) Saves past readings and allows profile management.
* **In-App Purchases:** Option to purchase credit packs or premium features.
* **Coupon Code System:** Redeem promotional codes to gain credits.

## Tech Stack

* **Flutter:** Cross-platform mobile application development framework.
* **Bloc / flutter_bloc:** State management library.
* **Firebase:**
    * Authentication (Anonymous users)
    * Firestore (For reading history, etc.)
    * (Likely) Crashlytics, Analytics
* **Google Gemini AI:** For generating Tarot interpretations.
* **flutter_localizations / intl:** Internationalization and localization.
* **flutter_local_notifications:** For local notifications.
* **shared_preferences:** For storing simple data (user preferences, tokens, etc.).
* **permission_handler:** For managing notification permissions.
* **(Likely) in_app_purchase:** For handling in-app purchases.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

* [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
* [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

*Note: This README content is based on the code snippets and discussions from our conversation. You can add or remove sections based on the exact details of your project.*