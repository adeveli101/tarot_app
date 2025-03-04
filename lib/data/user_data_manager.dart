import 'package:shared_preferences/shared_preferences.dart';

class UserDataManager {
  static const String _tokensKey = 'mystical_tokens';
  static const String _isPremiumKey = 'is_premium';
  static const String _dailyFreeReadsKey = 'daily_free_reads';
  static const String _lastResetKey = 'last_reset';
  static const String _userNameKey = 'user_name';
  static const String _userAgeKey = 'user_age';
  static const String _userGenderKey = 'user_gender';
  static const String _userInfoCollectedKey = 'user_info_collected';

  Future<void> saveTokens(double tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_tokensKey, tokens);
  }

  Future<double> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_tokensKey) ?? 0.0;
  }

  Future<void> savePremiumStatus(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isPremiumKey, isPremium);
  }

  Future<bool> isPremiumUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isPremiumKey) ?? false;
  }

  Future<void> saveDailyFreeReads(int reads) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyFreeReadsKey, reads);
  }

  Future<int> getDailyFreeReads() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dailyFreeReadsKey) ?? 0;
  }

  Future<void> saveLastReset(int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastResetKey, timestamp);
  }

  Future<int> getLastReset() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastResetKey) ?? 0;
  }

  Future<void> saveUserName(String? name) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) {
      await prefs.setString(_userNameKey, name);
    } else {
      await prefs.remove(_userNameKey);
    }
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  Future<void> saveUserAge(int? age) async {
    final prefs = await SharedPreferences.getInstance();
    if (age != null) {
      await prefs.setInt(_userAgeKey, age);
    } else {
      await prefs.remove(_userAgeKey);
    }
  }

  Future<int?> getUserAge() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userAgeKey);
  }

  Future<void> saveUserGender(String? gender) async {
    final prefs = await SharedPreferences.getInstance();
    if (gender != null) {
      await prefs.setString(_userGenderKey, gender);
    } else {
      await prefs.remove(_userGenderKey);
    }
  }

  Future<String?> getUserGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userGenderKey);
  }

  Future<void> saveUserInfoCollected(bool collected) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_userInfoCollectedKey, collected);
  }

  Future<bool> getUserInfoCollected() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_userInfoCollectedKey) ?? false;
  }
}