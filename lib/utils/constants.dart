import 'package:flutter/material.dart';

class AppConstants {
  // Deep cosmic colors matching reference image
  static const Color spaceDarkBg = Color(0xFF070818);
  static const Color spaceSurface = Color(0xFF10132C);
  static const Color spaceCard = Color(0xFF161938);
  static const Color emptyDotColor = Color(0xFF7474DB); // Periwinkle/lavender violet dot
  static const Color emptyDotGlow = Color(0x667474DB);
  static const Color textLight = Color(0xFFECEFF8);
  static const Color textMuted = Color(0xFF8D93AB);
  static const Color accentGold = Color(0xFFFFD700);

  // Available Shapes
  static const List<Map<String, dynamic>> shapes = [
    {'id': 'star', 'name': 'Yıldız', 'symbol': '⭐', 'icon': Icons.star_rounded},
    {'id': 'moon', 'name': 'Hilal', 'symbol': '🌙', 'icon': Icons.nightlight_round},
    {'id': 'sun', 'name': 'Güneş', 'symbol': '☀️', 'icon': Icons.wb_sunny_rounded},
    {'id': 'heart', 'name': 'Kalp', 'symbol': '💖', 'icon': Icons.favorite_rounded},
    {'id': 'flower', 'name': 'Çiçek', 'symbol': '🌸', 'icon': Icons.local_florist_rounded},
    {'id': 'sparkle', 'name': 'Kıvılcım', 'symbol': '✦', 'icon': Icons.auto_awesome_rounded},
    {'id': 'diamond', 'name': 'Elmas', 'symbol': '💎', 'icon': Icons.diamond_rounded},
    {'id': 'clover', 'name': 'Yonca', 'symbol': '🍀', 'icon': Icons.eco_rounded},
    {'id': 'butterfly', 'name': 'Kelebek', 'symbol': '🦋', 'icon': Icons.flutter_dash_rounded},
    {'id': 'fire', 'name': 'Ateş', 'symbol': '🔥', 'icon': Icons.local_fire_department_rounded},
    {'id': 'leaf', 'name': 'Yaprak', 'symbol': '🌿', 'icon': Icons.park_rounded},
    {'id': 'planet', 'name': 'Gezegen', 'symbol': '🪐', 'icon': Icons.public_rounded},
    {'id': 'coffee', 'name': 'Kahve', 'symbol': '☕', 'icon': Icons.coffee_rounded},
    {'id': 'bolt', 'name': 'Şimşek', 'symbol': '⚡', 'icon': Icons.bolt_rounded},
    {'id': 'candle', 'name': 'Mum', 'symbol': '🕯️', 'icon': Icons.light_rounded},
    {'id': 'dove', 'name': 'Barış', 'symbol': '🕊️', 'icon': Icons.flight_rounded},
  ];

  // Available Colors for Shapes
  static const List<Map<String, dynamic>> colors = [
    {'name': 'Altın', 'color': Color(0xFFFFD700), 'value': 0xFFFFD700},
    {'name': 'Kozmik Mor', 'color': Color(0xFFA855F7), 'value': 0xFFA855F7},
    {'name': 'Gök Mavisi', 'color': Color(0xFF38BDF8), 'value': 0xFF38BDF8},
    {'name': 'Gül Pembesi', 'color': Color(0xFFFB7185), 'value': 0xFFFB7185},
    {'name': 'Zümrüt', 'color': Color(0xFF34D399), 'value': 0xFF34D399},
    {'name': 'Gün Batımı', 'color': Color(0xFFFB923C), 'value': 0xFFFB923C},
    {'name': 'Saf Beyaz', 'color': Color(0xFFFFFFFF), 'value': 0xFFFFFFFF},
    {'name': 'Yakut Kırmızı', 'color': Color(0xFFEF4444), 'value': 0xFFEF4444},
  ];

  // Moods
  static const List<String> moods = [
    '✨ Harika',
    '🌸 Mutlu',
    '☕ Huzurlu',
    '💭 Düşünceli',
    '😴 Yorgun',
    '💖 Romantik',
    '⚡ Enerjik',
    '🌧️ Hüzünlü',
  ];

  // Month days count in a standard non-leap year (365 days)
  static const List<int> daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  static const List<String> monthNames = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];

  /// Converts a day number (1 - 365) to Turkish formatted date string
  /// e.g. 1 -> "1 Ocak", 32 -> "1 Şubat"
  static String getTurkishDate(int dayNumber, [int? year]) {
    if (dayNumber < 1) dayNumber = 1;
    if (dayNumber > 365) dayNumber = 365;

    int remaining = dayNumber;
    for (int i = 0; i < daysInMonth.length; i++) {
      if (remaining <= daysInMonth[i]) {
        final day = remaining;
        final month = monthNames[i];
        final yr = year ?? DateTime.now().year;
        return '$day $month $yr';
      }
      remaining -= daysInMonth[i];
    }
    return '31 Aralık';
  }

  /// Calculates day of year (1 - 365) for today
  static int getTodayDayOfYear() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, 1, 1);
    final diff = now.difference(firstDay).inDays + 1;
    if (diff > 365) return 365;
    if (diff < 1) return 1;
    return diff;
  }
}
