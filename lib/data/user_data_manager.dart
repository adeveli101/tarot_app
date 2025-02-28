// lib/data/user_data_manager.dart
import 'package:shared_preferences/shared_preferences.dart';

class UserDataManager {
  static const String _tokensKey = 'mystical_tokens';
  static const String _isPremiumKey = 'is_premium';
  static const String _dailyFreeReadsKey = 'daily_free_reads';
  static const String _lastResetKey = 'last_reset';

  // Tokenları kaydet
  Future<void> saveTokens(double tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_tokensKey, tokens);
  }

  // Tokenları al
  Future<double> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_tokensKey) ?? 0.0;
  }

  // Premium durumunu kaydet
  Future<void> savePremiumStatus(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isPremiumKey, isPremium);
  }

  // Premium durumunu al
  Future<bool> isPremiumUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isPremiumKey) ?? false;
  }

  // Günlük ücretsiz okuma sayısını kaydet
  Future<void> saveDailyFreeReads(int reads) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyFreeReadsKey, reads);
  }

  // Günlük ücretsiz okuma sayısını al
  Future<int> getDailyFreeReads() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dailyFreeReadsKey) ?? 0;
  }

  // Son reset tarihini kaydet
  Future<void> saveLastReset(int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastResetKey, timestamp);
  }

  // Son reset tarihini al
  Future<int> getLastReset() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastResetKey) ?? 0;
  }
}