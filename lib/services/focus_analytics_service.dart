import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FocusAnalyticsService {
  static const String _focusByDateKey = 'focal_focus_minutes_by_date';

  String _dateKey(DateTime date) {
    final DateTime d = DateTime(date.year, date.month, date.day);
    final String yyyy = d.year.toString().padLeft(4, '0');
    final String mm = d.month.toString().padLeft(2, '0');
    final String dd = d.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  Future<Map<String, int>> _loadFocusMap() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_focusByDateKey);

    if (raw == null || raw.isEmpty) {
      return <String, int>{};
    }

    final Map<String, dynamic> decoded =
        jsonDecode(raw) as Map<String, dynamic>;

    return decoded.map(
      (String key, dynamic value) => MapEntry<String, int>(
        key,
        (value as num).toInt(),
      ),
    );
  }

  Future<void> _saveFocusMap(Map<String, int> focusMap) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(focusMap);
    await prefs.setString(_focusByDateKey, encoded);
  }

  Future<void> addFocusMinutes(DateTime date, int minutes) async {
    if (minutes <= 0) return;

    final Map<String, int> focusMap = await _loadFocusMap();
    final String key = _dateKey(date);
    focusMap[key] = (focusMap[key] ?? 0) + minutes;
    await _saveFocusMap(focusMap);
  }

  Future<int> getTodayFocusMinutes() async {
    final Map<String, int> focusMap = await _loadFocusMap();
    return focusMap[_dateKey(DateTime.now())] ?? 0;
  }

  Future<List<int>> getLast7DaysFocusMinutes() async {
    final Map<String, int> focusMap = await _loadFocusMap();
    final DateTime now = DateTime.now();

    return List<int>.generate(7, (int index) {
      final DateTime day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - index));
      return focusMap[_dateKey(day)] ?? 0;
    });
  }
}
