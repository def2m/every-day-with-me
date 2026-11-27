import 'dart:convert';

class DayEntry {
  final int dayNumber; // 1 - 365
  final String dateString; // "27 Kasım 2026"
  final String shape; // "star", "moon", "heart", etc.
  final int colorValue; // 0xFF...
  final String title;
  final String note;
  final String mood;
  final String mealType; // "🥗 Sağlıklı", "🍲 Ev Yemeği", etc.
  final String mealNote; // What user ate
  final List<String> photoPaths; // Local file paths
  final DateTime updatedAt;

  DayEntry({
    required this.dayNumber,
    required this.dateString,
    required this.shape,
    required this.colorValue,
    this.title = '',
    required this.note,
    this.mood = '',
    this.mealType = '',
    this.mealNote = '',
    this.photoPaths = const [],
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'dayNumber': dayNumber,
      'dateString': dateString,
      'shape': shape,
      'colorValue': colorValue,
      'title': title,
      'note': note,
      'mood': mood,
      'mealType': mealType,
      'mealNote': mealNote,
      'photoPaths': photoPaths,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DayEntry.fromMap(Map<String, dynamic> map) {
    return DayEntry(
      dayNumber: map['dayNumber'] as int,
      dateString: map['dateString'] as String? ?? '',
      shape: map['shape'] as String? ?? 'star',
      colorValue: map['colorValue'] as int? ?? 0xFFFFD700,
      title: map['title'] as String? ?? '',
      note: map['note'] as String? ?? '',
      mood: map['mood'] as String? ?? '',
      mealType: map['mealType'] as String? ?? '',
      mealNote: map['mealNote'] as String? ?? '',
      photoPaths: (map['photoPaths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory DayEntry.fromJson(String source) =>
      DayEntry.fromMap(json.decode(source) as Map<String, dynamic>);
}

class DailyTask {
  final String id;
  final String title;
  final bool isDone;

  DailyTask({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  DailyTask copyWith({String? title, bool? isDone}) {
    return DailyTask(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
    };
  }

  factory DailyTask.fromMap(Map<String, dynamic> map) {
    return DailyTask(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title'] as String? ?? '',
      isDone: map['isDone'] as bool? ?? false,
    );
  }
}
