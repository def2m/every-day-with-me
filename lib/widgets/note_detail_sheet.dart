import 'dart:io';
import 'package:flutter/material.dart';
import '../models/day_entry.dart';
import '../utils/constants.dart';

class NoteDetailSheet extends StatelessWidget {
  final DayEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteDetailSheet({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final shapeColor = Color(entry.colorValue);
    final shapeInfo = AppConstants.shapes.firstWhere(
      (s) => s['id'] == entry.shape,
      orElse: () => {'symbol': '⭐', 'name': 'Yıldız'},
    );

    return Container(
      padding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 32),
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
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Glowing Shape Hero
            Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: shapeColor.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: shapeColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: shapeColor.withOpacity(0.4),
                      blurRadius: 18,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    shapeInfo['symbol'] as String,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Gün Ay Yıl Date
            Center(
              child: Text(
                entry.dateString,
                style: const TextStyle(
                  color: AppConstants.textLight,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  if (entry.mood.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.spaceCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        entry.mood,
                        style: const TextStyle(
                          color: AppConstants.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (entry.mealType.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34D399).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF34D399).withOpacity(0.4)),
                      ),
                      child: Text(
                        entry.mealType,
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Note Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppConstants.spaceCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (entry.title.isNotEmpty) ...[
                    Text(
                      entry.title,
                      style: TextStyle(
                        color: shapeColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Text(
                    entry.note,
                    style: const TextStyle(
                      color: AppConstants.textLight,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  if (entry.mealNote.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🍽️ ', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            entry.mealNote,
                            style: const TextStyle(
                              color: AppConstants.textMuted,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Photos Gallery
            if (entry.photoPaths.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: entry.photoPaths.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, idx) {
                    final path = entry.photoPaths[idx];
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            backgroundColor: Colors.black,
                            insetPadding: const EdgeInsets.all(12),
                            child: Stack(
                              children: [
                                Center(
                                  child: Image.file(File(path), fit: BoxFit.contain),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 100,
                            height: 100,
                            color: AppConstants.spaceCard,
                            child: const Icon(Icons.broken_image, color: AppConstants.textMuted),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons: Edit and Delete
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onEdit();
                    },
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Düzenle'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.textLight,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppConstants.spaceSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        title: const Text(
                          'Notu Sil?',
                          style: TextStyle(color: AppConstants.textLight),
                        ),
                        content: const Text(
                          'Bu günün notunu ve şeklini silmek istediğine emin misin? Gün tekrar boş bir yıldıza dönecektir.',
                          style: TextStyle(color: AppConstants.textMuted),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Vazgeç', style: TextStyle(color: AppConstants.textMuted)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              Navigator.of(context).pop();
                              onDelete();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE11D48),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Sil'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFB7185)),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0x22FB7185),
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
