import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/day_entry.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../widgets/shape_selector.dart';
import '../widgets/note_detail_sheet.dart';
import '../widgets/note_editor_sheet.dart';

class TodayScreen extends StatefulWidget {
  final Map<int, DayEntry> entries;
  final Map<int, List<DailyTask>> tasks;
  final Function(DayEntry) onSaveEntry;
  final Function(int) onDeleteEntry;
  final Function(int, List<DailyTask>) onSaveTasks;

  const TodayScreen({
    super.key,
    required this.entries,
    required this.tasks,
    required this.onSaveEntry,
    required this.onDeleteEntry,
    required this.onSaveTasks,
  });

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  String _shape = 'star';
  int _colorValue = 0xFFFFD700;
  String _mood = AppConstants.moods.first;
  String _mealType = AppConstants.mealTypes.first;
  List<String> _photoPaths = [];
  bool _isEditingToday = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _mealController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  late DateTime _calendarMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _calendarMonth = DateTime(now.year, now.month, 1);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _mealController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        final savedPath = await StorageService.savePhotoPermanently(image.path);
        if (mounted) {
          setState(() => _photoPaths.add(savedPath));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fotoğraf seçilemedi: $e')),
        );
      }
    }
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
      mealType: _mealType,
      mealNote: _mealController.text.trim(),
      photoPaths: _photoPaths,
      updatedAt: DateTime.now(),
    );

    widget.onSaveEntry(entry);
    setState(() {
      _isEditingToday = false;
      _titleController.clear();
      _noteController.clear();
      _mealController.clear();
      _photoPaths = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bugünün yıldızı gökyüzüne eklendi! ✨⭐'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _addTask(int todayNum) {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;
    final current = List<DailyTask>.from(widget.tasks[todayNum] ?? []);
    current.add(DailyTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: text,
      isDone: false,
    ));
    _taskController.clear();
    widget.onSaveTasks(todayNum, current);
  }

  void _toggleTask(int todayNum, String taskId) {
    final current = List<DailyTask>.from(widget.tasks[todayNum] ?? []);
    final idx = current.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      current[idx] = current[idx].copyWith(isDone: !current[idx].isDone);
      widget.onSaveTasks(todayNum, current);
    }
  }

  void _deleteTask(int todayNum, String taskId) {
    final current = List<DailyTask>.from(widget.tasks[todayNum] ?? []);
    current.removeWhere((t) => t.id == taskId);
    widget.onSaveTasks(todayNum, current);
  }

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

  void _openCalendarDay(int dayNumber) {
    final existing = widget.entries[dayNumber];
    if (existing != null) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => NoteDetailSheet(
          entry: existing,
          onEdit: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (ctx) => NoteEditorSheet(
                dayNumber: dayNumber,
                existingEntry: existing,
                onSave: widget.onSaveEntry,
              ),
            );
          },
          onDelete: () => widget.onDeleteEntry(dayNumber),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => NoteEditorSheet(
          dayNumber: dayNumber,
          existingEntry: null,
          onSave: widget.onSaveEntry,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = AppConstants.getTodayDayOfYear();
    final todayEntry = widget.entries[today];
    final todayTasks = widget.tasks[today] ?? [];
    final activeColor = Color(_colorValue);
    final streak = _calculateStreak(today);

    return Scaffold(
      backgroundColor: AppConstants.spaceDarkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Card (Gün Ay Yıl)
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
                    const SizedBox(height: 12),
                    Text(
                      AppConstants.getTurkishDate(today),
                      style: const TextStyle(
                        color: AppConstants.textLight,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Today's Note Card or Editor Form
              if (todayEntry != null && !_isEditingToday) ...[
                _buildSavedTodayCard(today, todayEntry),
              ] else ...[
                _buildTodayForm(today, activeColor, todayEntry != null),
              ],

              const SizedBox(height: 20),

              // 3. Calendar directly below the note
              _buildCalendarCard(today),

              const SizedBox(height: 20),

              // 4. Daily Tasks Checklist
              _buildTasksCard(today, todayTasks),

              const SizedBox(height: 20),

              // 5. Weekly Mood & Eating Analysis
              _buildWeeklyAnalysisCard(today),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedTodayCard(int today, DayEntry todayEntry) {
    final shapeColor = Color(todayEntry.colorValue);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppConstants.spaceSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: shapeColor.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: shapeColor.withOpacity(0.15),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: shapeColor.withOpacity(0.2),
                  border: Border.all(color: shapeColor),
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
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (todayEntry.mood.isNotEmpty)
                          Text(
                            todayEntry.mood,
                            style: const TextStyle(color: AppConstants.textMuted, fontSize: 12),
                          ),
                        if (todayEntry.mealType.isNotEmpty)
                          Text(
                            '• ${todayEntry.mealType}',
                            style: const TextStyle(color: Color(0xFF34D399), fontSize: 12),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (todayEntry.title.isNotEmpty) ...[
            Text(
              todayEntry.title,
              style: TextStyle(
                color: shapeColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            todayEntry.note,
            style: const TextStyle(
              color: AppConstants.textLight,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (todayEntry.mealNote.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '🍽️ ${todayEntry.mealNote}',
              style: const TextStyle(color: AppConstants.textMuted, fontSize: 12),
            ),
          ],
          if (todayEntry.photoPaths.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: todayEntry.photoPaths.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(todayEntry.photoPaths[idx]),
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      color: AppConstants.spaceCard,
                      child: const Icon(Icons.broken_image, color: AppConstants.textMuted),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditingToday = true;
                      _shape = todayEntry.shape;
                      _colorValue = todayEntry.colorValue;
                      _mood = todayEntry.mood.isNotEmpty ? todayEntry.mood : AppConstants.moods.first;
                      _mealType = todayEntry.mealType.isNotEmpty ? todayEntry.mealType : AppConstants.mealTypes.first;
                      _photoPaths = List<String>.from(todayEntry.photoPaths);
                      _titleController.text = todayEntry.title;
                      _noteController.text = todayEntry.note;
                      _mealController.text = todayEntry.mealNote;
                    });
                  },
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Düzenle'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.textLight,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openCalendarDay(today),
                  icon: const Icon(Icons.remove_red_eye_rounded, size: 16),
                  label: const Text('Detaylar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.accentGold,
                    side: BorderSide(color: AppConstants.accentGold.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayForm(int today, Color activeColor, bool isUpdating) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.spaceSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Bugünün Yıldızını Seç & Anını Yaz',
                  style: TextStyle(
                    color: AppConstants.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isUpdating)
                IconButton(
                  onPressed: () => setState(() => _isEditingToday = false),
                  icon: const Icon(Icons.close, color: AppConstants.textMuted, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 16),

          ShapeSelector(
            selectedShape: _shape,
            onShapeChanged: (val) => setState(() => _shape = val),
            selectedColorValue: _colorValue,
            onColorChanged: (val) => setState(() => _colorValue = val),
          ),

          const SizedBox(height: 18),

          const Text(
            'Bugün Nasılsın?',
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
                side: BorderSide(color: isSelected ? activeColor : Colors.white12),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          const Text(
            'Bugün Ne Yedin? (Yemek Düzeni)',
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
            children: AppConstants.mealTypes.map((mt) {
              final isSelected = (_mealType == mt);
              return ChoiceChip(
                label: Text(mt),
                selected: isSelected,
                onSelected: (val) {
                  if (val) setState(() => _mealType = mt);
                },
                selectedColor: const Color(0xFF34D399).withOpacity(0.25),
                backgroundColor: AppConstants.spaceCard,
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF34D399) : AppConstants.textMuted,
                  fontSize: 12,
                ),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF34D399) : Colors.white12,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _mealController,
            style: const TextStyle(color: AppConstants.textLight, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Ne yediğini yaz (örn: Kahvaltı, salata, makarna...)',
              hintStyle: const TextStyle(color: AppConstants.textMuted, fontSize: 12),
              filled: true,
              fillColor: AppConstants.spaceCard,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

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

          const SizedBox(height: 14),

          // Photo Picker
          Row(
            children: [
              const Text(
                'Fotoğraf Ekle',
                style: TextStyle(
                  color: AppConstants.textLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.add_photo_alternate_rounded, color: AppConstants.accentGold, size: 18),
                label: const Text('Galeriden Seç', style: TextStyle(color: AppConstants.accentGold, fontSize: 12)),
              ),
            ],
          ),
          if (_photoPaths.isNotEmpty)
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photoPaths.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_photoPaths[idx]),
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 3,
                      right: 3,
                      child: GestureDetector(
                        onTap: () => setState(() => _photoPaths.removeAt(idx)),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 13),
                        ),
                      ),
                    ),
                  ],
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              shadowColor: activeColor.withOpacity(0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, size: 18),
                const SizedBox(width: 8),
                Text(
                  isUpdating ? 'Notu Güncelle' : 'Bugünü Gökyüzüne Kaydet',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(int today) {
    final year = _calendarMonth.year;
    final month = _calendarMonth.month;
    final daysCount = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday; // 1 = Mon .. 7 = Sun
    final leadingEmpty = firstWeekday - 1;
    final monthTitle = '${AppConstants.monthNames[month - 1]} $year';

    const weekDays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppConstants.spaceSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, color: AppConstants.accentGold, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Takvim',
                style: TextStyle(
                  color: AppConstants.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _calendarMonth = DateTime(year, month - 1, 1);
                  });
                },
                icon: const Icon(Icons.chevron_left_rounded, color: AppConstants.textLight),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Text(
                monthTitle,
                style: const TextStyle(
                  color: AppConstants.textLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  setState(() {
                    _calendarMonth = DateTime(year, month + 1, 1);
                  });
                },
                icon: const Icon(Icons.chevron_right_rounded, color: AppConstants.textLight),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weekday Headers
          Row(
            children: weekDays
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            color: AppConstants.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: leadingEmpty + daysCount,
            itemBuilder: (context, index) {
              if (index < leadingEmpty) {
                return const SizedBox.shrink();
              }
              final day = index - leadingEmpty + 1;
              final date = DateTime(year, month, day);
              final dayNum = AppConstants.getDayNumberFromDate(date);
              final entry = widget.entries[dayNum];
              final isToday = (dayNum == today && date.year == DateTime.now().year);

              final shapeSymbol = entry != null
                  ? (AppConstants.shapes.firstWhere(
                      (s) => s['id'] == entry.shape,
                      orElse: () => {'symbol': '⭐'},
                    )['symbol'] as String)
                  : null;

              return GestureDetector(
                onTap: () => _openCalendarDay(dayNum),
                child: Container(
                  decoration: BoxDecoration(
                    color: entry != null
                        ? Color(entry.colorValue).withOpacity(0.18)
                        : AppConstants.spaceCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isToday
                          ? AppConstants.accentGold
                          : (entry != null
                              ? Color(entry.colorValue).withOpacity(0.5)
                              : Colors.white10),
                      width: isToday ? 1.6 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          color: isToday ? AppConstants.accentGold : AppConstants.textLight,
                          fontSize: shapeSymbol != null ? 10 : 12,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      if (shapeSymbol != null)
                        Text(shapeSymbol, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTasksCard(int today, List<DailyTask> todayTasks) {
    final completedCount = todayTasks.where((t) => t.isDone).length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppConstants.spaceSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF38BDF8), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Bugünün Görevleri',
                style: TextStyle(
                  color: AppConstants.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (todayTasks.isNotEmpty)
                Text(
                  '$completedCount / ${todayTasks.length}',
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Add Task Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskController,
                  onSubmitted: (_) => _addTask(today),
                  style: const TextStyle(color: AppConstants.textLight, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Yeni görev ekle...',
                    hintStyle: const TextStyle(color: AppConstants.textMuted, fontSize: 12),
                    filled: true,
                    fillColor: AppConstants.spaceCard,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _addTask(today),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.all(12),
                  minimumSize: const Size(44, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Icon(Icons.add_rounded, size: 20),
              ),
            ],
          ),

          if (todayTasks.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...todayTasks.map((task) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppConstants.spaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: task.isDone
                        ? const Color(0xFF34D399).withOpacity(0.3)
                        : Colors.white10,
                  ),
                ),
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: Checkbox(
                    value: task.isDone,
                    onChanged: (_) => _toggleTask(today, task.id),
                    activeColor: const Color(0xFF34D399),
                    checkColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      color: task.isDone ? AppConstants.textMuted : AppConstants.textLight,
                      fontSize: 13,
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppConstants.textMuted, size: 18),
                    onPressed: () => _deleteTask(today, task.id),
                  ),
                ),
              );
            }),
          ] else ...[
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Bugün için henüz görev eklenmedi ✨',
                style: TextStyle(color: AppConstants.textMuted, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklyAnalysisCard(int today) {
    final startDay = (today - 6) < 1 ? 1 : (today - 6);
    final weekEntries = <DayEntry>[];
    for (int d = startDay; d <= today; d++) {
      final e = widget.entries[d];
      if (e != null) weekEntries.add(e);
    }

    final Map<String, int> moodCounts = {};
    final Map<String, int> mealCounts = {};
    final Map<String, Map<String, int>> mealToMood = {};

    for (final e in weekEntries) {
      if (e.mood.isNotEmpty) {
        moodCounts[e.mood] = (moodCounts[e.mood] ?? 0) + 1;
      }
      if (e.mealType.isNotEmpty) {
        mealCounts[e.mealType] = (mealCounts[e.mealType] ?? 0) + 1;
        if (e.mood.isNotEmpty) {
          mealToMood.putIfAbsent(e.mealType, () => {});
          mealToMood[e.mealType]![e.mood] = (mealToMood[e.mealType]![e.mood] ?? 0) + 1;
        }
      }
    }

    // Find top correlation
    String? insightText;
    if (mealToMood.isNotEmpty) {
      String bestMeal = '';
      String bestMood = '';
      int bestCount = 0;
      mealToMood.forEach((meal, moodsMap) {
        moodsMap.forEach((mood, count) {
          if (count > bestCount) {
            bestCount = count;
            bestMeal = meal;
            bestMood = mood;
          }
        });
      });
      if (bestMeal.isNotEmpty && bestMood.isNotEmpty) {
        insightText =
            'Bu hafta "$bestMeal" tercih ettiğin günlerde en çok "$bestMood" hissettin ($bestCount gün).';
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppConstants.spaceSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: Color(0xFFA855F7), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Haftalık Ruh Hali & Yemek Analizi',
                  style: TextStyle(
                    color: AppConstants.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${weekEntries.length}/7 Gün',
                style: const TextStyle(color: AppConstants.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (weekEntries.isEmpty) ...[
            const Text(
              'Son 7 güne ait kayıt bulunamadı. Günlük not, ruh hali ve yemek düzenini girdikçe haftalık analizin burada oluşacaktır ✨',
              style: TextStyle(color: AppConstants.textMuted, fontSize: 12, height: 1.4),
            ),
          ] else ...[
            if (moodCounts.isNotEmpty) ...[
              const Text(
                'Ruh Hali Dağılımı',
                style: TextStyle(
                  color: AppConstants.textLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...moodCounts.entries.map((entry) {
                final ratio = entry.value / weekEntries.length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key, style: const TextStyle(color: AppConstants.textLight, fontSize: 12)),
                          Text('${entry.value} gün', style: const TextStyle(color: AppConstants.textMuted, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio,
                          backgroundColor: AppConstants.spaceCard,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA855F7)),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            if (mealCounts.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Yemek Düzeni',
                style: TextStyle(
                  color: AppConstants.textLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...mealCounts.entries.map((entry) {
                final ratio = entry.value / weekEntries.length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key, style: const TextStyle(color: AppConstants.textLight, fontSize: 12)),
                          Text('${entry.value} gün', style: const TextStyle(color: AppConstants.textMuted, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio,
                          backgroundColor: AppConstants.spaceCard,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            if (insightText != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFA855F7).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFA855F7).withOpacity(0.35)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFFA855F7), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insightText,
                        style: const TextStyle(
                          color: AppConstants.textLight,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
