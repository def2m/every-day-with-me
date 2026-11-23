import 'dart:convert';

class DayEntry {
  final int dayNumber; // 1 - 365
  final String dateString; // "23 Kasım"
  final String shape; // "star", "moon", "heart", etc.
  final int colorValue; // 0xFF...
  final String title;
  final String note;
  final String mood;
  final DateTime updatedAt;

  DayEntry({
    required this.dayNumber,
    required this.dateString,
    required this.shape,
    required this.colorValue,
    this.title = '',
    required this.note,
    this.mood = '',
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
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory DayEntry.fromJson(String source) =>
      DayEntry.fromMap(json.decode(source) as Map<String, dynamic>);
}
