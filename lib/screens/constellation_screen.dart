import 'package:flutter/material.dart';
import '../models/day_entry.dart';
import '../utils/constants.dart';
import '../painters/constellation_painter.dart';
import '../widgets/note_editor_sheet.dart';
import '../widgets/note_detail_sheet.dart';

class ConstellationScreen extends StatefulWidget {
  final Map<int, DayEntry> entries;
  final Function(DayEntry) onSaveEntry;
  final Function(int) onDeleteEntry;

  const ConstellationScreen({
    super.key,
    required this.entries,
    required this.onSaveEntry,
    required this.onDeleteEntry,
  });

  @override
  State<ConstellationScreen> createState() => _ConstellationScreenState();
}

class _ConstellationScreenState extends State<ConstellationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int? _selectedDay;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onCanvasTap(TapUpDetails details, Size canvasSize) {
    final localPos = details.localPosition;
    int? closestDay;
    double minDistance = 24.0; // Touch hit radius in pixels

    for (int day = 1; day <= 365; day++) {
      final pos = ConstellationPainter.getDayPosition(day, canvasSize);
      final dist = (pos - localPos).distance;
      if (dist < minDistance) {
        minDistance = dist;
        closestDay = day;
      }
    }

    if (closestDay != null) {
      _openDay(closestDay);
    }
  }

  void _openDay(int dayNumber) {
    setState(() => _selectedDay = dayNumber);
    final entry = widget.entries[dayNumber];

    if (entry != null) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => NoteDetailSheet(
          entry: entry,
          onEdit: () {
            _openEditor(dayNumber, entry);
          },
          onDelete: () {
            widget.onDeleteEntry(dayNumber);
            setState(() => _selectedDay = null);
          },
        ),
      ).then((_) {
        if (mounted) setState(() => _selectedDay = null);
      });
    } else {
      _openEditor(dayNumber, null);
    }
  }

  void _openEditor(int dayNumber, DayEntry? existing) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => NoteEditorSheet(
        dayNumber: dayNumber,
        existingEntry: existing,
        onSave: (newEntry) {
          widget.onSaveEntry(newEntry);
          setState(() => _selectedDay = null);
        },
      ),
    ).then((_) {
      if (mounted) setState(() => _selectedDay = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = AppConstants.getTodayDayOfYear();
    final filledCount = widget.entries.length;
    final percent = ((filledCount / 365) * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: AppConstants.spaceDarkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '365 Gün',
                        style: TextStyle(
                          color: AppConstants.textLight,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppConstants.accentGold,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$filledCount / 365 Yıldız Aydınlatıldı (%$percent)',
                            style: const TextStyle(
                              color: AppConstants.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Jump to Today button
                  InkWell(
                    onTap: () => _openDay(today),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppConstants.spaceSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppConstants.accentGold.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: AppConstants.accentGold, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            AppConstants.getTurkishDate(today),
                            style: const TextStyle(
                              color: AppConstants.textLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: filledCount / 365,
                  backgroundColor: AppConstants.spaceCard,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.accentGold),
                  minHeight: 3,
                ),
              ),
            ),

            // Constellation Canvas (Fixed, no zoom)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

                  return GestureDetector(
                    onTapUp: (details) => _onCanvasTap(details, canvasSize),
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: canvasSize,
                          painter: ConstellationPainter(
                            entries: widget.entries,
                            todayDayNumber: today,
                            selectedDayNumber: _selectedDay,
                            pulseValue: _animController.value,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Bottom helper hint
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Text(
                'Bir güne dokunarak şeklini ver ve anını kaydet ✨',
                style: TextStyle(
                  color: AppConstants.textMuted,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
