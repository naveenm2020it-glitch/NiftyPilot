import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/app_state_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/activity_heatmap.dart';
import '../../widgets/apple_card.dart';
import '../../widgets/progress_charts.dart';

class MyProgressScreen extends StatefulWidget {
  const MyProgressScreen({super.key});

  @override
  State<MyProgressScreen> createState() => _MyProgressScreenState();
}

class _MyProgressScreenState extends State<MyProgressScreen> {
  ProgressPeriod _period = ProgressPeriod.weekly;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final completed = state.completedTasksInPeriod(_period);
    final pending = state.pendingTasksInPeriod(_period);
    final habitRate = state.habitCompletionRateInPeriod(_period);
    final heatmap = state.buildActivityHeatmap();
    final weeklySeries = state.last7DaysProductivitySeries();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(l10n.tr('my_progress'), style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 14),

                SegmentedButton<ProgressPeriod>(
                  segments: [
                    ButtonSegment(value: ProgressPeriod.daily, label: Text(l10n.tr('period_daily'))),
                    ButtonSegment(value: ProgressPeriod.weekly, label: Text(l10n.tr('period_weekly'))),
                    ButtonSegment(value: ProgressPeriod.monthly, label: Text(l10n.tr('period_monthly'))),
                    ButtonSegment(value: ProgressPeriod.yearly, label: Text(l10n.tr('period_yearly'))),
                  ],
                  selected: {_period},
                  onSelectionChanged: (s) => setState(() => _period = s.first),
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: AppleCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.tr('completed'), style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 6),
                            Text(
                              '$completed',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: isDark
                                        ? AppColors.emeraldLight
                                        : AppColors.emeraldPrimary,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text('${l10n.tr('pending')}: $pending',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppleCard(
                        child: Row(
                          children: [
                            CompletionRing(
                              progress: habitRate,
                              centerLabel: '${(habitRate * 100).round()}%',
                              color: AppColors.terracotta,
                              size: 68,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.tr('habit_consistency'),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                AppleCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.tr('productivity_chart'),
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 14),
                      WeeklyProductivityChart(values: weeklySeries),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                AppleCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.tr('activity_heatmap'),
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 14),
                      ActivityHeatmap(activityByDate: heatmap),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                if (state.allHabits.isNotEmpty) ...[
                  Text(l10n.tr('streak_leaders'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  ...state.allHabits.map((habit) {
                    final stats = state.statsForHabit(habit);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppleCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Color(habit.colorValue),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(habit.name, style: Theme.of(context).textTheme.titleSmall),
                            ),
                            Text(
                              '${l10n.tr('current_streak')}: ${stats.currentStreak}d  •  ${l10n.tr('longest_streak')}: ${stats.longestStreak}d',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
