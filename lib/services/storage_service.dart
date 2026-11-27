import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/day_entry.dart';
import '../utils/constants.dart';

class StorageService {
  static const String _storageKey = 'gun365_entries_v1';
  static const String _tasksKey = 'gun365_tasks_v1';

  /// Load all entries mapped by dayNumber (1..365)
  static Future<Map<int, DayEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return {};
    }

    try {
      final Map<String, dynamic> decoded = json.decode(jsonStr);
      final Map<int, DayEntry> result = {};
      decoded.forEach((key, val) {
        final dayNum = int.tryParse(key);
        if (dayNum != null && val is Map<String, dynamic>) {
          result[dayNum] = DayEntry.fromMap(val);
        }
      });
      return result;
    } catch (e) {
      return {};
    }
  }

  /// Save or update an entry
  static Future<void> saveEntry(DayEntry entry) async {
    final entries = await loadEntries();
    entries[entry.dayNumber] = entry;
    await _persist(entries);
  }

  /// Delete an entry
  static Future<void> deleteEntry(int dayNumber) async {
    final entries = await loadEntries();
    if (entries.containsKey(dayNumber)) {
      entries.remove(dayNumber);
      await _persist(entries);
    }
  }

  /// Persist entire map
  static Future<void> _persist(Map<int, DayEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> raw = {};
    entries.forEach((key, val) {
      raw[key.toString()] = val.toMap();
    });
    await prefs.setString(_storageKey, json.encode(raw));
  }

  /// Load all daily tasks mapped by dayNumber (1..365)
  static Future<Map<int, List<DailyTask>>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_tasksKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return {};
    }

    try {
      final Map<String, dynamic> decoded = json.decode(jsonStr);
      final Map<int, List<DailyTask>> result = {};
      decoded.forEach((key, val) {
        final dayNum = int.tryParse(key);
        if (dayNum != null && val is List) {
          result[dayNum] = val
              .whereType<Map<String, dynamic>>()
              .map((m) => DailyTask.fromMap(m))
              .toList();
        }
      });
      return result;
    } catch (e) {
      return {};
    }
  }

  /// Save tasks for a specific day
  static Future<void> saveTasksForDay(int dayNumber, List<DailyTask> tasks) async {
    final allTasks = await loadTasks();
    if (tasks.isEmpty) {
      allTasks.remove(dayNumber);
    } else {
      allTasks[dayNumber] = tasks;
    }
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> raw = {};
    allTasks.forEach((key, val) {
      raw[key.toString()] = val.map((t) => t.toMap()).toList();
    });
    await prefs.setString(_tasksKey, json.encode(raw));
  }

  /// Save a picked photo permanently into app documents directory
  static Future<String> savePhotoPermanently(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDir.path}/gun365_photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    final ext = sourcePath.split('.').last;
    final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final destFile = await File(sourcePath).copy('${photosDir.path}/$fileName');
    return destFile.path;
  }

  /// Export backup JSON
  static Future<String> exportBackupJson() async {
    final entries = await loadEntries();
    final Map<String, dynamic> raw = {};
    entries.forEach((key, val) {
      raw[key.toString()] = val.toMap();
    });
    return json.encode(raw);
  }

  /// Import backup JSON
  static Future<bool> importBackupJson(String jsonContent) async {
    try {
      final Map<String, dynamic> decoded = json.decode(jsonContent);
      final Map<int, DayEntry> result = {};
      decoded.forEach((key, val) {
        final dayNum = int.tryParse(key);
        if (dayNum != null && val is Map<String, dynamic>) {
          result[dayNum] = DayEntry.fromMap(val);
        }
      });
      await _persist(result);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Populate sample entries for demo / preview
  static Future<void> loadSampleData() async {
    final today = AppConstants.getTodayDayOfYear();
    final samples = [
      DayEntry(
        dayNumber: today,
        dateString: AppConstants.getTurkishDate(today),
        shape: 'star',
        colorValue: 0xFFFFD700,
        title: 'Gökyüzü Başlangıcı',
        note: 'Bugün 365 günlüğümün ilk yıldızını parlattım. Her günüm bir yıldıza dönüşecek!',
        mood: '✨ Harika',
        mealType: '🥗 Sağlıklı',
        mealNote: 'Kahvaltıda avokado ve yumurta, akşam ızgara sebze',
      ),
      DayEntry(
        dayNumber: (today > 5) ? today - 3 : 15,
        dateString: AppConstants.getTurkishDate((today > 5) ? today - 3 : 15),
        shape: 'heart',
        colorValue: 0xFFFB7185,
        title: 'Huzurlu Akşam',
        note: 'Bugün sevdiklerimle kahve içip uzun uzun sohbet ettik. Çok iyi geldi.',
        mood: '💖 Romantik',
        mealType: '🍲 Ev Yemeği',
        mealNote: 'Mercimek çorbası ve fırında tavuk',
      ),
      DayEntry(
        dayNumber: (today > 10) ? today - 7 : 45,
        dateString: AppConstants.getTurkishDate((today > 10) ? today - 7 : 45),
        shape: 'moon',
        colorValue: 0xFFA855F7,
        title: 'Gece Yürüyüşü',
        note: 'Yıldızların altında sakin bir yürüyüş. Zihnim tertemiz oldu.',
        mood: '☕ Huzurlu',
        mealType: '🥪 Hafif / Pratik',
        mealNote: 'Yoğurt, yulaf ve meyve',
      ),
    ];

    for (final s in samples) {
      await saveEntry(s);
    }
  }

  /// Clear all entries and tasks completely
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    await prefs.remove(_tasksKey);
  }
}
