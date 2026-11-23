import 'package:flutter/material.dart';
import '../models/day_entry.dart';
import '../utils/constants.dart';
import '../widgets/note_detail_sheet.dart';
import '../widgets/note_editor_sheet.dart';

class NotesScreen extends StatefulWidget {
  final Map<int, DayEntry> entries;
  final Function(DayEntry) onSaveEntry;
  final Function(int) onDeleteEntry;

  const NotesScreen({
    super.key,
    required this.entries,
    required this.onSaveEntry,
    required this.onDeleteEntry,
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _searchQuery = '';
  String? _selectedShapeFilter;

  @override
  Widget build(BuildContext context) {
    // Sort entries descending (most recent days first)
    final allEntries = widget.entries.values.toList()
      ..sort((a, b) => b.dayNumber.compareTo(a.dayNumber));

    // Filter by search and shape
    final filtered = allEntries.where((entry) {
      final matchesQuery = _searchQuery.isEmpty ||
          entry.note.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          entry.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          entry.dateString.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesShape =
          _selectedShapeFilter == null || entry.shape == _selectedShapeFilter;
      return matchesQuery && matchesShape;
    }).toList();

    return Scaffold(
      backgroundColor: AppConstants.spaceDarkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 8),
              child: Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Günlük & Anılar',
                        style: TextStyle(
                          color: AppConstants.textLight,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Yıldızlarına bıraktığın tüm notlar',
                        style: TextStyle(
                          color: AppConstants.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppConstants.spaceSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      '${filtered.length} Not',
                      style: const TextStyle(
                        color: AppConstants.textLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: AppConstants.textLight, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Notlarda veya tarihlerde ara...',
                  hintStyle: const TextStyle(color: AppConstants.textMuted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppConstants.textMuted, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppConstants.textMuted, size: 18),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  filled: true,
                  fillColor: AppConstants.spaceSurface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Shape Filter Chips (Horizontal)
            if (allEntries.isNotEmpty)
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Tümü'),
                        selected: _selectedShapeFilter == null,
                        onSelected: (_) => setState(() => _selectedShapeFilter = null),
                        selectedColor: AppConstants.accentGold.withOpacity(0.25),
                        backgroundColor: AppConstants.spaceSurface,
                        labelStyle: TextStyle(
                          color: _selectedShapeFilter == null
                              ? AppConstants.accentGold
                              : AppConstants.textMuted,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: _selectedShapeFilter == null
                              ? AppConstants.accentGold
                              : Colors.white12,
                        ),
                      ),
                    ),
                    ...AppConstants.shapes.where((shape) {
                      return allEntries.any((e) => e.shape == shape['id']);
                    }).map((shape) {
                      final isSelected = (_selectedShapeFilter == shape['id']);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('${shape['symbol']} ${shape['name']}'),
                          selected: isSelected,
                          onSelected: (val) {
                            setState(() {
                              _selectedShapeFilter = isSelected ? null : (shape['id'] as String);
                            });
                          },
                          selectedColor: AppConstants.accentGold.withOpacity(0.25),
                          backgroundColor: AppConstants.spaceSurface,
                          labelStyle: TextStyle(
                            color: isSelected ? AppConstants.accentGold : AppConstants.textMuted,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppConstants.accentGold : Colors.white12,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Notes List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: AppConstants.spaceSurface,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                size: 48,
                                color: AppConstants.emptyDotColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Henüz Not Eklenmemiş',
                              style: TextStyle(
                                color: AppConstants.textLight,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '365 Gün haritasından dilediğin bir güne dokunarak şeklini seç ve ilk hatıranı kaydet!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppConstants.textMuted,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final entry = filtered[index];
                        final shapeColor = Color(entry.colorValue);
                        final shapeInfo = AppConstants.shapes.firstWhere(
                          (s) => s['id'] == entry.shape,
                          orElse: () => {'symbol': '⭐', 'name': 'Yıldız'},
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppConstants.spaceSurface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (ctx) => NoteDetailSheet(
                                  entry: entry,
                                  onEdit: () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      isScrollControlled: true,
                                      builder: (ctx) => NoteEditorSheet(
                                        dayNumber: entry.dayNumber,
                                        existingEntry: entry,
                                        onSave: widget.onSaveEntry,
                                      ),
                                    );
                                  },
                                  onDelete: () => widget.onDeleteEntry(entry.dayNumber),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Shape Icon Badge
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: shapeColor.withOpacity(0.18),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: shapeColor.withOpacity(0.7), width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: shapeColor.withOpacity(0.3),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        shapeInfo['symbol'] as String,
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Note Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Date & Day #
                                        Row(
                                          children: [
                                            Text(
                                              entry.dateString,
                                              style: const TextStyle(
                                                color: AppConstants.textLight,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '#${entry.dayNumber}',
                                              style: const TextStyle(
                                                color: AppConstants.textMuted,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const Spacer(),
                                            if (entry.mood.isNotEmpty)
                                              Text(
                                                entry.mood,
                                                style: const TextStyle(
                                                  color: AppConstants.textMuted,
                                                  fontSize: 11,
                                                ),
                                              ),
                                          ],
                                        ),
                                        if (entry.title.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            entry.title,
                                            style: TextStyle(
                                              color: shapeColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 6),
                                        Text(
                                          entry.note,
                                          style: const TextStyle(
                                            color: AppConstants.textLight,
                                            fontSize: 13,
                                            height: 1.4,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
