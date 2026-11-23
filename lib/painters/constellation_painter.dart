import 'dart:math';
import 'package:flutter/material.dart';
import '../models/day_entry.dart';
import '../utils/constants.dart';

class ConstellationPainter extends CustomPainter {
  final Map<int, DayEntry> entries;
  final int todayDayNumber;
  final int? selectedDayNumber;
  final double pulseValue; // 0.0 to 1.0 for smooth pulsing animation

  ConstellationPainter({
    required this.entries,
    required this.todayDayNumber,
    this.selectedDayNumber,
    this.pulseValue = 0.0,
  });

  // Calculate coordinates for day 1..365
  static Offset getDayPosition(int dayNumber, Size size) {
    const int cols = 14;
    const int rows = 26; // 14 * 26 = 364 + 1 = 365
    final int index = dayNumber - 1;
    final int row = index ~/ cols;
    final int col = index % cols;

    final double paddingX = size.width * 0.06;
    final double paddingY = size.height * 0.04;
    final double availWidth = size.width - (paddingX * 2);
    final double availHeight = size.height - (paddingY * 2);

    final double stepX = availWidth / (cols - 1);
    final double stepY = availHeight / (rows - 1);

    // Add organic subtle constellation waviness (like in the user's reference photo)
    final double offsetX = sin(row * 0.85 + col * 0.5) * (stepX * 0.16);
    final double offsetY = cos(col * 0.75 + row * 0.4) * (stepY * 0.14);

    return Offset(
      paddingX + col * stepX + offsetX,
      paddingY + row * stepY + offsetY,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw connecting constellation lines between nearby filled days
    final sortedEntries = entries.keys.toList()..sort();
    final linePaint = Paint()
      ..color = const Color(0x33A855F7)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < sortedEntries.length - 1; i++) {
      final d1 = sortedEntries[i];
      final d2 = sortedEntries[i + 1];
      if ((d2 - d1).abs() <= 3) {
        final pos1 = getDayPosition(d1, size);
        final pos2 = getDayPosition(d2, size);
        canvas.drawLine(pos1, pos2, linePaint);
      }
    }

    // 2. Draw all 365 days
    for (int day = 1; day <= 365; day++) {
      final pos = getDayPosition(day, size);
      final entry = entries[day];
      final bool isToday = (day == todayDayNumber);
      final bool isSelected = (day == selectedDayNumber);

      if (entry != null) {
        // --- FILLED DAY: Draw user's chosen shape & glowing aura ---
        final shapeColor = Color(entry.colorValue);

        // Soft outer glow
        final glowPaint = Paint()
          ..color = shapeColor.withOpacity(0.35 + 0.15 * pulseValue)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(pos, 10, glowPaint);

        // Inner glowing core circle
        final corePaint = Paint()
          ..color = shapeColor.withOpacity(0.2)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 8, corePaint);

        // Draw symbol
        final shapeInfo = AppConstants.shapes.firstWhere(
          (s) => s['id'] == entry.shape,
          orElse: () => {'symbol': '⭐'},
        );
        final String symbol = shapeInfo['symbol'] as String;

        final textSpan = TextSpan(
          text: symbol,
          style: TextStyle(
            fontSize: 12.0,
            color: shapeColor,
            shadows: [
              Shadow(
                color: shapeColor.withOpacity(0.9),
                blurRadius: 6,
              ),
            ],
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
        );
      } else {
        // --- EMPTY DAY: Soft periwinkle dot (matching reference image) ---
        // Subtle outer aura
        final emptyAuraPaint = Paint()
          ..color = AppConstants.emptyDotGlow
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(pos, 4.5, emptyAuraPaint);

        // Dot center
        final dotPaint = Paint()
          ..color = AppConstants.emptyDotColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 2.8, dotPaint);
      }

      // Today's Beacon Ring
      if (isToday) {
        final todayRingPaint = Paint()
          ..color = AppConstants.accentGold.withOpacity(0.6 + 0.4 * sin(pulseValue * pi))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6;
        final double ringRadius = 9.0 + (pulseValue * 3.5);
        canvas.drawCircle(pos, ringRadius, todayRingPaint);
      }

      // Selected Day Ring
      if (isSelected) {
        final selectPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(pos, 12.0, selectPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ConstellationPainter oldDelegate) {
    return oldDelegate.entries != entries ||
        oldDelegate.selectedDayNumber != selectedDayNumber ||
        oldDelegate.todayDayNumber != todayDayNumber ||
        oldDelegate.pulseValue != pulseValue;
  }
}
