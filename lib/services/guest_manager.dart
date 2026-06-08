import 'package:shared_preferences/shared_preferences.dart';

class GuestManager {
  static const String _isGuestKey = 'is_guest';
  static const String _questionCountKey = 'question_count';
  static const String _lastDateKey = 'last_date';
  static const int dailyLimit = 3;

  static Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isGuestKey)?? false;
  }

  static Future<void> setGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isGuestKey, true);
    await _resetCountIfNewDay();
  }

  static Future<void> clearGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isGuestKey, false);
  }

  static Future<bool> hasReachedLimit() async {
    await _resetCountIfNewDay();
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_questionCountKey)?? 0;
    return count >= dailyLimit;
  }

  static Future<void> incrementQuestionCount() async {
    await _resetCountIfNewDay();
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_questionCountKey)?? 0;
    await prefs.setInt(_questionCountKey, count + 1);
  }

  static Future<void> _resetCountIfNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_lastDateKey);
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    if (lastDate!= today) {
      await prefs.setInt(_questionCountKey, 0);
      await prefs.setString(_lastDateKey, today);
    }
  }

  static Future<int> getRemainingQuestions() async {
    await _resetCountIfNewDay();
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_questionCountKey)?? 0;
    return dailyLimit - count;
  }
}