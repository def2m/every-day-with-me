import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/day_entry.dart';
import '../utils/constants.dart';

class StorageService {
  static const String _storageKey = 'gun365_entries_v1';

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
      ),
      DayEntry(
        dayNumber: (today > 5) ? today - 3 : 15,
        dateString: AppConstants.getTurkishDate((today > 5) ? today - 3 : 15),
        shape: 'heart',
        colorValue: 0xFFFB7185,
        title: 'Huzurlu Akşam',
        note: 'Bugün sevdiklerimle kahve içip uzun uzun sohbet ettik. Çok iyi geldi.',
        mood: '💖 Romantik',
      ),
      DayEntry(
        dayNumber: (today > 10) ? today - 7 : 45,
        dateString: AppConstants.getTurkishDate((today > 10) ? today - 7 : 45),
        shape: 'moon',
        colorValue: 0xFFA855F7,
        title: 'Gece Yürüyüşü',
        note: 'Yıldızların altında sakin bir yürüyüş. Zihnim tertemiz oldu.',
        mood: '☕ Huzurlu',
      ),
      DayEntry(
        dayNumber: (today > 15) ? today - 12 : 80,
        dateString: AppConstants.getTurkishDate((today > 15) ? today - 12 : 80),
        shape: 'flower',
        colorValue: 0xFF34D399,
        title: 'Bahar Esintisi',
        note: 'Bugün kendime yeni bir kitap aldım ve parkta okudum.',
        mood: '🌸 Mutlu',
      ),
      DayEntry(
        dayNumber: (today > 25) ? today - 20 : 120,
        dateString: AppConstants.getTurkishDate((today > 25) ? today - 20 : 120),
        shape: 'sun',
        colorValue: 0xFFFB923C,
        title: 'Güneşli ve Verimli Gün',
        note: 'Erken uyandım, tüm işlerimi erkenden hallettim. Kendimle gurur duyuyorum.',
        mood: '⚡ Enerjik',
      ),
    ];

    for (final s in samples) {
      await saveEntry(s);
    }
  }

  /// Clear all entries
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
