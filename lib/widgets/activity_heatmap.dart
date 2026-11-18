import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/date_utils_ext.dart';

class ActivityHeatmap extends StatelessWidget {
  final Map<String, int> activityByDate;
  const ActivityHeatmap({super.key, required this.activityByDate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseAccent = isDark ? AppColors.emeraldLight : AppColors.emeraldPrimary;
    final emptyColor = isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary;

    final today = DateUtilsExt.stripTime(DateTime.now());
    const weeks = 12;
    final start = today.subtract(const Duration(days: weeks * 7 - 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 5.0;
            final cellSize = ((constraints.maxWidth - (spacing * (weeks - 1))) / weeks)
                .clamp(12.0, 26.0);

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(weeks, (weekIdx) {
                return Column(
                  children: List.generate(7, (dayIdx) {
                    final date = start.add(Duration(days: weekIdx * 7 + dayIdx));
                    final key = DateUtilsExt.toDateKey(date);
                    final count = activityByDate[key] ?? 0;

                    Color cellColor;
                    if (count <= 0) {
                      cellColor = emptyColor;
                    } else if (count == 1) {
                      cellColor = baseAccent.withOpacity(0.28);
                    } else if (count <= 3) {
                      cellColor = baseAccent.withOpacity(0.58);
                    } else {
                      cellColor = baseAccent;
                    }

                    return Container(
                      width: cellSize,
                      height: cellSize,
                      margin: EdgeInsets.only(bottom: dayIdx < 6 ? spacing : 0),
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  }),
                );
              }),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Less', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: 6),
            ...[emptyColor, baseAccent.withOpacity(0.28), baseAccent.withOpacity(0.58), baseAccent]
                .map((c) => Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    )),
            const SizedBox(width: 6),
            Text('More', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}
