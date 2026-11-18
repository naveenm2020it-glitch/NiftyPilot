import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/localization/app_localizations.dart';
import '../theme/app_colors.dart';

enum QuickAddType {
  task,
  habit,
  event,
  note,
  journal,
  water,
  exercise,
  sleep,
  mood,
}

class QuickAddSheet extends StatelessWidget {
  final ValueChanged<QuickAddType> onSelect;
  const QuickAddSheet({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      (QuickAddType.task, l10n.tr('task'), Icons.check_circle_outline_rounded, AppColors.emeraldPrimary),
      (QuickAddType.habit, l10n.tr('habit'), Icons.loop_rounded, AppColors.oliveMoss),
      (QuickAddType.event, l10n.tr('event'), Icons.event_rounded, AppColors.terracotta),
      (QuickAddType.note, l10n.tr('note'), Icons.sticky_note_2_outlined, AppColors.amberOchre),
      (QuickAddType.journal, l10n.tr('journal'), Icons.auto_stories_outlined, AppColors.copperBronze),
      (QuickAddType.water, l10n.tr('water'), Icons.water_drop_outlined, AppColors.pineTeal),
      (QuickAddType.exercise, l10n.tr('exercise'), Icons.directions_run_rounded, AppColors.terracotta),
      (QuickAddType.sleep, l10n.tr('sleep'), Icons.nights_stay_outlined, AppColors.espressoUmber),
      (QuickAddType.mood, l10n.tr('mood'), Icons.sentiment_satisfied_alt_rounded, AppColors.roseClay),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.tr('quick_add'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, index) {
                final (type, label, icon, accent) = items[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop();
                    onSelect(type);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceSecondary
                          : AppColors.lightSurfaceSecondary,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: accent, size: 22),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
