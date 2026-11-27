import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/day_entry.dart';
import '../services/storage_service.dart';
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
  late String _mealType;
  late List<String> _photoPaths;
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late TextEditingController _mealController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final e = widget.existingEntry;
    _shape = e?.shape ?? 'star';
    _colorValue = e?.colorValue ?? 0xFFFFD700;
    _mood = e?.mood ?? AppConstants.moods.first;
    _mealType = e?.mealType ?? AppConstants.mealTypes.first;
    _photoPaths = List<String>.from(e?.photoPaths ?? []);
    _titleController = TextEditingController(text: e?.title ?? '');
    _noteController = TextEditingController(text: e?.note ?? '');
    _mealController = TextEditingController(text: e?.mealNote ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _mealController.dispose();
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
      mealType: _mealType,
      mealNote: _mealController.text.trim(),
      photoPaths: _photoPaths,
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

            // Header: Gün Ay Yıl
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
                  child: Text(
                    formattedDate,
                    style: const TextStyle(
                      color: AppConstants.textLight,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: AppConstants.textMuted),
                ),
              ],
            ),

            const SizedBox(height: 20),

            ShapeSelector(
              selectedShape: _shape,
              onShapeChanged: (newShape) => setState(() => _shape = newShape),
              selectedColorValue: _colorValue,
              onColorChanged: (newColor) => setState(() => _colorValue = newColor),
            ),

            const SizedBox(height: 18),

            // Mood
            const Text(
              'Bugün Nasılsın? (Ruh Hali)',
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

            // Meal section
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
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

            const SizedBox(height: 16),

            // Photo Picker Section
            Row(
              children: [
                const Text(
                  'Günün Fotoğrafları',
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
                  label: const Text('Fotoğraf Ekle', style: TextStyle(color: AppConstants.accentGold, fontSize: 13)),
                ),
              ],
            ),
            if (_photoPaths.isNotEmpty)
              SizedBox(
                height: 82,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photoPaths.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, idx) {
                    final path = _photoPaths[idx];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(path),
                            width: 82,
                            height: 82,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 82,
                              height: 82,
                              color: AppConstants.spaceCard,
                              child: const Icon(Icons.broken_image, color: AppConstants.textMuted),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _photoPaths.removeAt(idx)),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.black87,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

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
                  const Icon(Icons.auto_awesome_rounded, size: 18),
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
