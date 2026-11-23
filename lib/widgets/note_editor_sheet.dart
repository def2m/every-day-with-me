import 'package:flutter/material.dart';
import '../models/day_entry.dart';
import '../utils/constants.dart';
import 'shape_selector.dart';

class NoteEditorSheet extends StatefulWidget {
  final int dayNumber;
  final DayEntry? existingEntry;
  final ValueChanged<DayEntry> onSave;

  const NoteEditorSheet({
    super.key,
    required this.dayNumber,
    this.existingEntry,
    required this.onSave,
  });

  @override
  State<NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<NoteEditorSheet> {
  late String _shape;
  late int _colorValue;
  late String _mood;
  late TextEditingController _titleController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final e = widget.existingEntry;
    _shape = e?.shape ?? 'star';
    _colorValue = e?.colorValue ?? 0xFFFFD700;
    _mood = e?.mood ?? AppConstants.moods.first;
    _titleController = TextEditingController(text: e?.title ?? '');
    _noteController = TextEditingController(text: e?.note ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final noteText = _noteController.text.trim();
    if (noteText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen günlüğün için birkaç cümle yaz ✨'),
          backgroundColor: Color(0xFFE11D48),
        ),
      );
      return;
    }

    final entry = DayEntry(
      dayNumber: widget.dayNumber,
      dateString: AppConstants.getTurkishDate(widget.dayNumber),
      shape: _shape,
      colorValue: _colorValue,
      title: _titleController.text.trim(),
      note: noteText,
      mood: _mood,
      updatedAt: DateTime.now(),
    );

    widget.onSave(entry);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = AppConstants.getTurkishDate(widget.dayNumber);
    final activeColor = Color(_colorValue);

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppConstants.spaceSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header: Date & Day number
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: activeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: activeColor.withOpacity(0.4)),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: activeColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: AppConstants.textLight,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Yılın ${widget.dayNumber}. Günü',
                        style: const TextStyle(
                          color: AppConstants.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: AppConstants.textMuted),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Shape and Color Selectors
            ShapeSelector(
              selectedShape: _shape,
              onShapeChanged: (newShape) => setState(() => _shape = newShape),
              selectedColorValue: _colorValue,
              onColorChanged: (newColor) => setState(() => _colorValue = newColor),
            ),

            const SizedBox(height: 18),

            // Mood Tags
            const Text(
              'Ruh Hali',
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
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? activeColor : Colors.white12,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            // Title input
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppConstants.textLight, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Başlık veya Günün Özeti (İsteğe bağlı)',
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

            // Note body input
            TextField(
              controller: _noteController,
              style: const TextStyle(color: AppConstants.textLight, fontSize: 15),
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Bugün neler yaşadın? Aklından ve kalbinden geçenler...',
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

            const SizedBox(height: 22),

            // Save Button
            ElevatedButton(
              onPressed: _submit,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sparkles, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    widget.existingEntry == null ? 'Günü Aydınlat & Kaydet' : 'Notu Güncelle',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
