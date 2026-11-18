import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/habit_model.dart';
import '../../models/task_model.dart';
import '../../providers/app_state_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_utils_ext.dart';
import '../../widgets/apple_card.dart';
import '../settings/settings_screen.dart';
import '../trackers/tracker_sheets.dart';

class MyDayScreen extends StatelessWidget {
  const MyDayScreen({super.key});

  String _greetingKey() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'good_morning';
    if (hour >= 12 && hour < 17) return 'good_afternoon';
    if (hour >= 17 && hour < 21) return 'good_evening';
    return 'good_night';
  }

  Future<void> _editNameDialog(BuildContext context, AppStateProvider state) async {
    final ctrl = TextEditingController(text: state.settings.userName);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx).tr('profile_name')),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await state.updateSettings(state.settings.copyWith(userName: ctrl.text.trim()));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();
    final todayKey = DateUtilsExt.toDateKey(today);

    final todayTasks = state.tasksForDate(todayKey);
    final activeTodayTasks = todayTasks.where((t) => !t.isCompleted).toList();
    final completedTodayTasks = todayTasks.where((t) => t.isCompleted).toList();
    final overdueTasks = state.overdueIncompleteTasks;

    final userName = state.settings.userName.trim();
    final greeting = l10n.tr(_greetingKey());
    final displayGreeting = userName.isEmpty ? greeting : '$greeting, $userName';

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _editNameDialog(context, state),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateUtilsExt.formatReadableDate(
                                today,
                                locale: state.settings.languageCode,
                              ).toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    displayGreeting,
                                    style: Theme.of(context).textTheme.headlineMedium,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.edit_rounded,
                                  size: 16,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                        side: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 0.8,
                        ),
                      ),
                      icon: const Icon(Icons.tune_rounded, size: 20),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                if (state.dailyQuote != null)
                  AppleCard(
                    backgroundColor: isDark
                        ? AppColors.emeraldSoftDark
                        : AppColors.emeraldSoftLight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.tr('daily_wisdom'),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: isDark
                                        ? AppColors.emeraldLight
                                        : AppColors.emeraldPrimary,
                                  ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                state.refreshDailyQuote();
                              },
                              child: Icon(
                                Icons.refresh_rounded,
                                size: 16,
                                color: isDark
                                    ? AppColors.emeraldLight
                                    : AppColors.emeraldPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '“${state.dailyQuote!.textForLocale(state.settings.languageCode)}”',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '— ${state.dailyQuote!.author}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 22),

                Text(l10n.tr('wellness_pulse'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _WellnessChip(
                        icon: Icons.water_drop_rounded,
                        label: '${state.waterTotalForDate(todayKey)} ml',
                        color: AppColors.pineTeal,
                        onTap: () => showWaterSheet(context),
                      ),
                      const SizedBox(width: 8),
                      _WellnessChip(
                        icon: Icons.auto_stories_rounded,
                        label: l10n.tr('journal'),
                        color: AppColors.copperBronze,
                        onTap: () => showJournalSheet(context),
                      ),
                      const SizedBox(width: 8),
                      _WellnessChip(
                        icon: Icons.directions_run_rounded,
                        label: l10n.tr('exercise'),
                        color: AppColors.terracotta,
                        onTap: () => showExerciseSheet(context),
                      ),
                      const SizedBox(width: 8),
                      _WellnessChip(
                        icon: Icons.nights_stay_rounded,
                        label: l10n.tr('sleep'),
                        color: AppColors.espressoUmber,
                        onTap: () => showSleepSheet(context),
                      ),
                      const SizedBox(width: 8),
                      _WellnessChip(
                        icon: Icons.sentiment_satisfied_alt_rounded,
                        label: l10n.tr('mood'),
                        color: AppColors.roseClay,
                        onTap: () => showMoodSheet(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Text(l10n.tr('todays_tasks'), style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      onPressed: () => showTaskFormSheet(context, defaultDateKey: todayKey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (activeTodayTasks.isEmpty && completedTodayTasks.isEmpty)
                  AppleCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(l10n.tr('no_tasks'), style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    ),
                  )
                else ...[
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activeTodayTasks.length,
                    onReorder: (oldIdx, newIdx) =>
                        state.reorderTasksForDate(todayKey, oldIdx, newIdx),
                    itemBuilder: (context, idx) {
                      final task = activeTodayTasks[idx];
                      return Padding(
                        key: ValueKey(task.id),
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TaskRowCard(task: task),
                      );
                    },
                  ),
                  if (completedTodayTasks.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.tr('completed')} (${completedTodayTasks.length})',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    ...completedTodayTasks.map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _TaskRowCard(task: t),
                      ),
                    ),
                  ],
                ],

                if (overdueTasks.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    '${l10n.tr('overdue_tasks')} (${overdueTasks.length})',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: AppColors.terracotta),
                  ),
                  const SizedBox(height: 8),
                  ...overdueTasks.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _TaskRowCard(task: t, showDateBadge: true),
                    ),
                  ),
                ],

                if (state.completedTaskHistory.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(
                      '${l10n.tr('completed_history')} (${state.completedTaskHistory.length})',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    children: state.completedTaskHistory.take(15).map((t) {
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.check_circle_rounded,
                            color: AppColors.emeraldPrimary, size: 18),
                        title: Text(
                          t.title,
                          style: const TextStyle(decoration: TextDecoration.lineThrough),
                        ),
                        subtitle: Text(t.dateKey),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          onPressed: () => state.deleteTask(t.id),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 22),

                Row(
                  children: [
                    Text(l10n.tr('habits'), style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      onPressed: () => showHabitFormSheet(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (state.allHabits.isEmpty)
                  AppleCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(l10n.tr('no_habits'), style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    ),
                  )
                else
                  ...state.allHabits.map(
                    (habit) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _HabitRowCard(habit: habit, todayKey: todayKey),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _WellnessChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _WellnessChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 7),
            Text(label, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}

class _TaskRowCard extends StatelessWidget {
  final TaskModel task;
  final bool showDateBadge;

  const _TaskRowCard({required this.task, this.showDateBadge = false});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppStateProvider>();
    final priorityColor = task.priority == TaskPriority.high
        ? AppColors.terracotta
        : (task.priority == TaskPriority.medium ? AppColors.amberOchre : AppColors.oliveMoss);

    return AppleCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => showTaskFormSheet(context, existing: task),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              state.toggleTaskCompletion(task);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: task.isCompleted ? AppColors.emeraldPrimary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted ? AppColors.emeraldPrimary : priorityColor,
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted
                            ? Theme.of(context).textTheme.bodySmall?.color
                            : null,
                      ),
                ),
                if (task.description.isNotEmpty || task.scheduledTime != null || showDateBadge)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      [
                        if (showDateBadge) task.dateKey,
                        if (task.scheduledTime != null) task.scheduledTime!,
                        if (task.description.isNotEmpty) task.description,
                      ].join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
          if (!task.isCompleted)
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.drag_indicator_rounded, size: 18, color: Colors.grey),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            onPressed: () => state.deleteTask(task.id),
          ),
        ],
      ),
    );
  }
}

class _HabitRowCard extends StatelessWidget {
  final HabitModel habit;
  final String todayKey;

  const _HabitRowCard({required this.habit, required this.todayKey});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final l10n = AppLocalizations.of(context);
    final count = state.habitCountOnDate(habit.id, todayKey);
    final done = count >= habit.targetCount;
    final stats = state.statsForHabit(habit);
    final accent = Color(habit.colorValue);
    final iconData = AppConstants.habitIcons[habit.iconIndex % AppConstants.habitIcons.length];

    return AppleCard(
      padding: const EdgeInsets.all(14),
      onTap: () => showHabitFormSheet(context, existing: habit),
      child: Row(
        children: [
          GestureDetector(
            onTap: habit.isPaused
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    state.incrementHabitToday(habit, dateKey: todayKey);
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: done ? accent : accent.withOpacity(0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                done ? Icons.check_rounded : iconData,
                color: done ? Colors.white : accent,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        habit.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (habit.isPaused) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.amberSoftLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.tr('paused'),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.amberOchre,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$count/${habit.targetCount} • 🔥 ${stats.currentStreak}d  🏆 ${stats.longestStreak}d  • ${l10n.tr('missed_days')}: ${stats.missedDays}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'pause') state.toggleHabitPause(habit);
              if (val == 'edit') showHabitFormSheet(context, existing: habit);
              if (val == 'delete') state.deleteHabit(habit.id);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'pause',
                child: Text(habit.isPaused ? l10n.tr('resume') : l10n.tr('pause')),
              ),
              PopupMenuItem(value: 'edit', child: Text(l10n.tr('edit'))),
              PopupMenuItem(value: 'delete', child: Text(l10n.tr('delete'))),
            ],
          ),
        ],
      ),
    );
  }
}
