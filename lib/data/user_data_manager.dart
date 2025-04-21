// lib/data/user_data_manager.dart

import 'package:shared_preferences/shared_preferences.dart';

class UserDataManager {
  // --- Anahtarlar (Key Definitions) ---
  // _tokensKey public yapıldı (tokensKey)
  static const String tokensKey = 'mystical_tokens'; // <<< DEĞİŞİKLİK: Public yapıldı
  static const String _isPremiumKey = 'is_premium';
  // static const String _dailyFreeReadsKey = 'daily_free_reads'; // KALDIRILDI
  static const String _lastResetKey = 'last_reset'; // Günlük token için kullanılır
  static const String _userNameKey = 'user_name';
  static const String _userAgeKey = 'user_age';
  static const String _userGenderKey = 'user_gender';
  static const String _userInfoCollectedKey = 'user_info_collected';
  static const String _redeemedCouponsKey = 'redeemed_coupons'; // Kuponlar için
  static const String _firstTimeBonusGivenKey = 'first_time_bonus_given'; // İlk kullanım bonusu

  // --- Metotlar ---
  Future<void> saveTokens(double tokens) async {
    final prefs = await SharedPreferences.getInstance();
    // Public anahtar kullanıldı
    await prefs.setDouble(tokensKey, tokens.clamp(0, double.maxFinite));
  }

  Future<double> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    // Public anahtar kullanıldı
    return prefs.getDouble(tokensKey) ?? 0.0;
  }

  Future<void> savePremiumStatus(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isPremiumKey, isPremium);
  }

  Future<bool> isPremiumUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isPremiumKey) ?? false;
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
    if (name != null && name.isNotEmpty) { await prefs.setString(_userNameKey, name); } else { await prefs.remove(_userNameKey); }
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance(); return prefs.getString(_userNameKey);
  }

  Future<void> saveUserAge(int? age) async {
    final prefs = await SharedPreferences.getInstance();
    if (age != null && age > 0) { await prefs.setInt(_userAgeKey, age); } else { await prefs.remove(_userAgeKey); }
  }

  Future<int?> getUserAge() async {
    final prefs = await SharedPreferences.getInstance(); final age = prefs.getInt(_userAgeKey); return (age != null && age > 0) ? age : null;
  }

  Future<void> saveUserGender(String? gender) async {
    final prefs = await SharedPreferences.getInstance();
    if (gender != null && gender.isNotEmpty) { await prefs.setString(_userGenderKey, gender); } else { await prefs.remove(_userGenderKey); }
  }

  Future<String?> getUserGender() async {
    final prefs = await SharedPreferences.getInstance(); return prefs.getString(_userGenderKey);
  }

  Future<void> saveUserInfoCollected(bool collected) async {
    final prefs = await SharedPreferences.getInstance(); await prefs.setBool(_userInfoCollectedKey, collected);
  }

  Future<bool> getUserInfoCollected() async {
    final prefs = await SharedPreferences.getInstance(); return prefs.getBool(_userInfoCollectedKey) ?? false;
  }

  Future<bool> isCouponUsed(String code) async {
    if (code.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    final redeemedCoupons = prefs.getStringList(_redeemedCouponsKey) ?? [];
    return redeemedCoupons.contains(code.trim().toUpperCase());
  }

  Future<void> markCouponAsUsed(String code) async {
    if (code.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final redeemedCoupons = prefs.getStringList(_redeemedCouponsKey) ?? [];
    final upperCaseCode = code.trim().toUpperCase();
    if (!redeemedCoupons.contains(upperCaseCode)) {
      redeemedCoupons.add(upperCaseCode);
      await prefs.setStringList(_redeemedCouponsKey, redeemedCoupons);
    }
  }

  Future<bool> hasReceivedFirstTimeBonus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstTimeBonusGivenKey) ?? false;
  }

  Future<void> markFirstTimeBonusAsGiven() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeBonusGivenKey, true);
  }
}