import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ShapeSelector extends StatelessWidget {
  final String selectedShape;
  final ValueChanged<String> onShapeChanged;
  final int selectedColorValue;
  final ValueChanged<int> onColorChanged;

  const ShapeSelector({
    super.key,
    required this.selectedShape,
    required this.onShapeChanged,
    required this.selectedColorValue,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Shapes section
        const Text(
          'Günün Şeklini Seç',
          style: TextStyle(
            color: AppConstants.textLight,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.shapes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final shape = AppConstants.shapes[index];
              final bool isSelected = (shape['id'] == selectedShape);
              final activeColor = Color(selectedColorValue);

              return GestureDetector(
                onTap: () => onShapeChanged(shape['id'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 54,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withOpacity(0.2)
                        : AppConstants.spaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? activeColor : Colors.white12,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: activeColor.withOpacity(0.35),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        shape['symbol'] as String,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        shape['name'] as String,
                        style: TextStyle(
                          color: isSelected ? activeColor : AppConstants.textMuted,
                          fontSize: 9,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 18),

        // 2. Colors section
        const Text(
          'Işıltı Rengi',
          style: TextStyle(
            color: AppConstants.textLight,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.colors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final colData = AppConstants.colors[index];
              final col = colData['color'] as Color;
              final val = colData['value'] as int;
              final bool isSelected = (val == selectedColorValue);

              return GestureDetector(
                onTap: () => onColorChanged(val),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: col,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: col.withOpacity(isSelected ? 0.7 : 0.3),
                        blurRadius: isSelected ? 10 : 4,
                        spreadRadius: isSelected ? 2 : 0,
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 18, color: Colors.black87)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
