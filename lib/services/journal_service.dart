import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class JournalEntry {
  const JournalEntry({
    required this.dateKey,
    required this.wentWell,
    required this.blockedBy,
    required this.createdAt,
  });

  final String dateKey;
  final String wentWell;
  final String blockedBy;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'dateKey': dateKey,
      'wentWell': wentWell,
      'blockedBy': blockedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      dateKey: map['dateKey'] as String,
      wentWell: map['wentWell'] as String? ?? '',
      blockedBy: map['blockedBy'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class JournalService {
  static const String _journalEntriesKey = 'focal_journal_entries';

  String _dateKey(DateTime date) {
    final String yyyy = date.year.toString().padLeft(4, '0');
    final String mm = date.month.toString().padLeft(2, '0');
    final String dd = date.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  Future<Map<String, JournalEntry>> _loadEntriesMap() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_journalEntriesKey);

    if (raw == null || raw.isEmpty) {
      return <String, JournalEntry>{};
    }

    final Map<String, dynamic> decoded =
        jsonDecode(raw) as Map<String, dynamic>;

    return decoded.map(
      (String key, dynamic value) => MapEntry<String, JournalEntry>(
        key,
        JournalEntry.fromMap(value as Map<String, dynamic>),
      ),
    );
  }

  Future<void> _saveEntriesMap(Map<String, JournalEntry> entries) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> serializable = entries.map(
      (String key, JournalEntry value) => MapEntry<String, dynamic>(
        key,
        value.toMap(),
      ),
    );
    await prefs.setString(_journalEntriesKey, jsonEncode(serializable));
  }

  Future<void> saveTodayEntry({
    required String wentWell,
    required String blockedBy,
  }) async {
    final DateTime now = DateTime.now();
    final String key = _dateKey(now);

    final Map<String, JournalEntry> entries = await _loadEntriesMap();
    entries[key] = JournalEntry(
      dateKey: key,
      wentWell: wentWell,
      blockedBy: blockedBy,
      createdAt: now,
    );

    await _saveEntriesMap(entries);
  }

  Future<JournalEntry?> getTodayEntry() async {
    final Map<String, JournalEntry> entries = await _loadEntriesMap();
    return entries[_dateKey(DateTime.now())];
  }

  Future<List<JournalEntry>> getLast7Entries() async {
    final Map<String, JournalEntry> entries = await _loadEntriesMap();
    final DateTime now = DateTime.now();

    final List<JournalEntry> result = <JournalEntry>[];
    for (int i = 6; i >= 0; i--) {
      final DateTime day = now.subtract(Duration(days: i));
      final JournalEntry? entry = entries[_dateKey(day)];
      if (entry != null) {
        result.add(entry);
      }
    }
    return result;
  }
}
