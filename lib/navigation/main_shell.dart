import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/localization/app_localizations.dart';
import '../providers/app_state_provider.dart';
import '../screens/my_day/my_day_screen.dart';
import '../screens/my_notes/my_notes_screen.dart';
import '../screens/my_planner/my_planner_screen.dart';
import '../screens/my_progress/my_progress_screen.dart';
import '../screens/trackers/tracker_sheets.dart';
import '../theme/app_colors.dart';
import '../widgets/quick_add_sheet.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  void _handleQuickAdd(BuildContext context, QuickAddType type) {
    switch (type) {
      case QuickAddType.task:
        showTaskFormSheet(context);
        break;
      case QuickAddType.habit:
        showHabitFormSheet(context);
        break;
      case QuickAddType.event:
        showEventFormSheet(context);
        break;
      case QuickAddType.note:
        showNoteEditorSheet(context);
        break;
      case QuickAddType.journal:
        showJournalSheet(context);
        break;
      case QuickAddType.water:
        showWaterSheet(context);
        break;
      case QuickAddType.exercise:
        showExerciseSheet(context);
        break;
      case QuickAddType.sleep:
        showSleepSheet(context);
        break;
      case QuickAddType.mood:
        showMoodSheet(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const screens = [
      MyDayScreen(),
      MyPlannerScreen(),
      MyNotesScreen(),
      MyProgressScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: state.currentTabIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 68,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                .withOpacity(0.96),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavTabItem(
                icon: Icons.wb_sunny_outlined,
                activeIcon: Icons.wb_sunny_rounded,
                label: l10n.tr('my_day'),
                selected: state.currentTabIndex == 0,
                onTap: () => state.setTabIndex(0),
              ),
              _NavTabItem(
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today_rounded,
                label: l10n.tr('my_planner'),
                selected: state.currentTabIndex == 1,
                onTap: () => state.setTabIndex(1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (_) => QuickAddSheet(
                        onSelect: (type) => _handleQuickAdd(context, type),
                      ),
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.emeraldPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                  ),
                ),
              ),
              _NavTabItem(
                icon: Icons.description_outlined,
                activeIcon: Icons.description_rounded,
                label: l10n.tr('my_notes'),
                selected: state.currentTabIndex == 2,
                onTap: () => state.setTabIndex(2),
              ),
              _NavTabItem(
                icon: Icons.insights_outlined,
                activeIcon: Icons.insights_rounded,
                label: l10n.tr('my_progress'),
                selected: state.currentTabIndex == 3,
                onTap: () => state.setTabIndex(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTabItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.emeraldLight : AppColors.emeraldPrimary;
    final inactiveColor = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? activeIcon : icon,
              size: 22,
              color: selected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
