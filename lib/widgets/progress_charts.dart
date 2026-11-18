import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WeeklyProductivityChart extends StatelessWidget {
  final List<double> values;
  const WeeklyProductivityChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? AppColors.emeraldLight : AppColors.emeraldPrimary;
    final trackColor = isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary;
    final maxVal = values.fold<double>(1.0, (m, v) => max(m, v));

    final now = DateTime.now();
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return SizedBox(
      height: 148,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final day = now.subtract(Duration(days: 6 - i));
          final dayLabel = labels[(day.weekday - 1) % 7];
          final ratio = (values[i] / maxVal).clamp(0.06, 1.0);
          final isToday = i == values.length - 1;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    values[i].toInt().toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isToday ? barColor : null,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: values[i] == 0 ? 0.08 : ratio,
                        widthFactor: 0.72,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          decoration: BoxDecoration(
                            color: values[i] == 0
                                ? trackColor
                                : (isToday ? AppColors.terracotta : barColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dayLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isToday ? AppColors.terracotta : null,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class CompletionRing extends StatelessWidget {
  final double progress;
  final String centerLabel;
  final Color color;
  final double size;

  const CompletionRing({
    super.key,
    required this.progress,
    required this.centerLabel,
    required this.color,
    this.size = 78,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0),
              activeColor: color,
              trackColor: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
              strokeWidth: 7,
            ),
          ),
          Text(
            centerLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color trackColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.activeColor != activeColor;
}
