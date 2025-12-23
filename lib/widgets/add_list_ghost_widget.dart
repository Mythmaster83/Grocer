import 'package:flutter/material.dart';
import 'package:grocer_app/utils/text_style_helper.dart';
import 'package:grocer_app/services/preferences_service.dart';

class DottedBorderPainter extends CustomPainter {
  final double borderRadius;
  final Color borderColor;

  DottedBorderPainter({this.borderRadius = 0.0, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 3.0;
    const dashSpace = 8.0;

    // Draw rectangle border with dots (no rounded corners)
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw dotted border by drawing small circles along the path
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0;
      while (distance < pathMetric.length) {
        final tangent = pathMetric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 1.5, paint);
        }
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AddListGhostWidget extends StatelessWidget {
  final VoidCallback onAdd;
  final String caption;

  const AddListGhostWidget({
    super.key,
    required this.onAdd,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = PreferencesService.isDarkMode.value;
    final backgroundColor = isDarkMode 
        ? Colors.white70.withAlpha(25)
        : Colors.grey[200];
    
    // Border color: darker in dark mode, lighter in light mode
    final borderColor = isDarkMode
        ? Colors.white70.withAlpha(180) // Darker (more visible) in dark mode
        : Colors.grey[400]!; // Lighter in light mode
    
    // Responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 600 ? 800.0 : double.infinity;
    
    return ValueListenableBuilder<double>(
      valueListenable: PreferencesService.textSize,
      builder: (context, textSize, _) => ValueListenableBuilder<bool>(
        valueListenable: PreferencesService.isDarkMode,
        builder: (context, isDarkMode, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 280.0,
                  maxWidth: maxWidth,
                  minHeight: 50.0,
                  maxHeight: 75.0,
                ),
                child: GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    constraints: BoxConstraints(
                      minHeight: 50.0,
                      maxHeight: 75.0,
                    ),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      // No border radius, no borders
                    ),
                    child: CustomPaint(
                      painter: DottedBorderPainter(borderRadius: 0.0, borderColor: borderColor),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 24,
                            color: isDarkMode ? Colors.white70 : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              caption,
                              style: TextStyleHelper.body(
                                color: isDarkMode ? Colors.white70 : Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
