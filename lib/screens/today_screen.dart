import 'package:flutter/material.dart';
import '../models/day_entry.dart';
import '../utils/constants.dart';
import '../widgets/shape_selector.dart';
import '../widgets/note_detail_sheet.dart';

class TodayScreen extends StatefulWidget {
  final Map<int, DayEntry> entries;
  final Function(DayEntry) onSaveEntry;
  final Function(int) onDeleteEntry;

  const TodayScreen({
    super.key,
    required this.entries,
    required this.onSaveEntry,
    required this.onDeleteEntry,
  });

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  String _shape = 'star';
  int _colorValue = 0xFFFFD700;
  String _mood = AppConstants.moods.first;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveTodayEntry(int todayNum) {
    final noteText = _noteController.text.trim();
    if (noteText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bugünün için bir iki cümle not yaz ✨'),
          backgroundColor: Color(0xFFE11D48),
        ),
      );
      return;
    }

    final entry = DayEntry(
      dayNumber: todayNum,
      dateString: AppConstants.getTurkishDate(todayNum),
      shape: _shape,
      colorValue: _colorValue,
      title: _titleController.text.trim(),
      note: noteText,
      mood: _mood,
      updatedAt: DateTime.now(),
    );

    widget.onSaveEntry(entry);
    _titleController.clear();
    _noteController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bugünün yıldızı gökyüzüne eklendi! ✨⭐'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  // Calculate streak
  int _calculateStreak(int todayNum) {
    int streak = 0;
    for (int day = todayNum; day >= 1; day--) {
      if (widget.entries.containsKey(day)) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final today = AppConstants.getTodayDayOfYear();
    final todayEntry = widget.entries[today];
    final activeColor = Color(_colorValue);
    final streak = _calculateStreak(today);
    final remainingDays = 365 - today;

    return Scaffold(
      backgroundColor: AppConstants.spaceDarkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1C1D42), Color(0xFF10132C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppConstants.accentGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppConstants.accentGold.withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.flash_on_rounded, color: AppConstants.accentGold, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '$streak Günlük Seri',
                                style: const TextStyle(
                                  color: AppConstants.accentGold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Kalan: $remainingDays Gün',
                          style: const TextStyle(
                            color: AppConstants.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppConstants.getTurkishDate(today),
                      style: const TextStyle(
                        color: AppConstants.textLight,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Yılın $today. Günü',
                      style: const TextStyle(
                        color: AppConstants.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // If today has already been written
              if (todayEntry != null) ...[
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppConstants.spaceSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Color(todayEntry.colorValue).withOpacity(0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(todayEntry.colorValue).withOpacity(0.15),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(todayEntry.colorValue).withOpacity(0.2),
                              border: Border.all(color: Color(todayEntry.colorValue)),
                            ),
                            child: Center(
                              child: Text(
                                AppConstants.shapes.firstWhere(
                                  (s) => s['id'] == todayEntry.shape,
                                  orElse: () => {'symbol': '⭐'},
                                )['symbol'] as String,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bugünün Yıldızı Parlıyor ✨',
                                  style: TextStyle(
                                    color: AppConstants.textLight,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (todayEntry.mood.isNotEmpty)
                                  Text(
                                    todayEntry.mood,
                                    style: const TextStyle(
                                      color: AppConstants.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (todayEntry.title.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            todayEntry.title,
                            style: TextStyle(
                              color: Color(todayEntry.colorValue),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          todayEntry.note,
                          style: const TextStyle(
                            color: AppConstants.textLight,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: true,
                                  builder: (ctx) => NoteDetailSheet(
                                    entry: todayEntry,
                                    onEdit: () {
                                      // populate fields to edit
                                      setState(() {
                                        _shape = todayEntry.shape;
                                        _colorValue = todayEntry.colorValue;
                                        _mood = todayEntry.mood;
                                        _titleController.text = todayEntry.title;
                                        _noteController.text = todayEntry.note;
                                      });
                                    },
                                    onDelete: () => widget.onDeleteEntry(today),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.remove_red_eye_rounded, size: 16),
                              label: const Text('Detayları Gör'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppConstants.textLight,
                                side: const BorderSide(color: Colors.white24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Write Today's Entry form
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppConstants.spaceSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Bugünün Yıldızını Seç & Anını Yaz',
                        style: TextStyle(
                          color: AppConstants.textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Shapes and Colors
                      ShapeSelector(
                        selectedShape: _shape,
                        onShapeChanged: (val) => setState(() => _shape = val),
                        selectedColorValue: _colorValue,
                        onColorChanged: (val) => setState(() => _colorValue = val),
                      ),

                      const SizedBox(height: 18),

                      // Moods
                      const Text(
                        'Günün Hissi',
                        style: TextStyle(
                          color: AppConstants.textLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppConstants.moods.map((m) {
                          final isSelected = (_mood == m);
                          return ChoiceChip(
                            label: Text(m),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setState(() => _mood = m);
                            },
                            selectedColor: activeColor.withOpacity(0.25),
                            backgroundColor: AppConstants.spaceCard,
                            labelStyle: TextStyle(
                              color: isSelected ? activeColor : AppConstants.textMuted,
                              fontSize: 12,
                            ),
                            side: BorderSide(
                              color: isSelected ? activeColor : Colors.white12,
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 18),

                      // Title
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(color: AppConstants.textLight, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Bugünün Başlığı (İsteğe bağlı)',
                          hintStyle: const TextStyle(color: AppConstants.textMuted, fontSize: 13),
                          filled: true,
                          fillColor: AppConstants.spaceCard,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Note
                      TextField(
                        controller: _noteController,
                        style: const TextStyle(color: AppConstants.textLight, fontSize: 14),
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Bugün nasıldı? Neler oldu, ne hissettin?',
                          hintStyle: const TextStyle(color: AppConstants.textMuted, fontSize: 13),
                          filled: true,
                          fillColor: AppConstants.spaceCard,
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () => _saveTodayEntry(today),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: activeColor,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          shadowColor: activeColor.withOpacity(0.5),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Bugünü Gökyüzüne Kaydet',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
