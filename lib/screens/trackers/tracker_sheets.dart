import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/event_model.dart';
import '../../models/habit_model.dart';
import '../../models/journal_model.dart';
import '../../models/note_model.dart';
import '../../models/task_model.dart';
import '../../providers/app_state_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_utils_ext.dart';
import '../../widgets/apple_card.dart';
import '../../widgets/progress_charts.dart';

Future<void> showTaskFormSheet(
  BuildContext context, {
  TaskModel? existing,
  String? defaultDateKey,
}) async {
  final titleCtrl = TextEditingController(text: existing?.title ?? '');
  final descCtrl = TextEditingController(text: existing?.description ?? '');
  String dateKey = existing?.dateKey ?? defaultDateKey ?? DateUtilsExt.toDateKey(DateTime.now());
  String? scheduledTime = existing?.scheduledTime;
  TaskPriority priority = existing?.priority ?? TaskPriority.medium;
  DateTime? reminderAt = existing?.reminderAt;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final l10n = AppLocalizations.of(ctx);
      return StatefulBuilder(
        builder: (ctx, setState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    existing == null ? l10n.tr('add_task') : l10n.tr('edit_task'),
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleCtrl,
                    autofocus: existing == null,
                    decoration: InputDecoration(hintText: l10n.tr('title')),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(hintText: l10n.tr('description')),
                  ),
                  const SizedBox(height: 14),
                  Text(l10n.tr('priority'), style: Theme.of(ctx).textTheme.labelMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: TaskPriority.values.map((p) {
                      final selected = priority == p;
                      final color = p == TaskPriority.high
                          ? AppColors.terracotta
                          : (p == TaskPriority.medium ? AppColors.amberOchre : AppColors.oliveMoss);
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Center(child: Text(l10n.tr(p.name))),
                            selected: selected,
                            selectedColor: color.withOpacity(0.2),
                            onSelected: (_) => setState(() => priority = p),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.calendar_today_rounded, size: 16),
                        label: Text(dateKey),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: DateUtilsExt.fromDateKey(dateKey),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setState(() => dateKey = DateUtilsExt.toDateKey(picked));
                          }
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.schedule_rounded, size: 16),
                        label: Text(scheduledTime ?? l10n.tr('scheduled_time')),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              scheduledTime =
                                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.notifications_outlined, size: 16),
                        label: Text(
                          reminderAt != null
                              ? DateUtilsExt.formatTime(reminderAt!)
                              : l10n.tr('reminder'),
                        ),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            final base = DateUtilsExt.fromDateKey(dateKey);
                            setState(() {
                              reminderAt = DateTime(
                                base.year,
                                base.month,
                                base.day,
                                picked.hour,
                                picked.minute,
                              );
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.emeraldPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      if (titleCtrl.text.trim().isEmpty) return;
                      await ctx.read<AppStateProvider>().addOrUpdateTask(
                            id: existing?.id,
                            title: titleCtrl.text,
                            description: descCtrl.text,
                            dateKey: dateKey,
                            scheduledTime: scheduledTime,
                            priority: priority,
                            reminderAt: reminderAt,
                            isCompleted: existing?.isCompleted ?? false,
                            completedAt: existing?.completedAt,
                            sortOrder: existing?.sortOrder,
                          );
                      HapticFeedback.mediumImpact();
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(l10n.tr('save'), style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> showHabitFormSheet(BuildContext context, {HabitModel? existing}) async {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  int iconIndex = existing?.iconIndex ?? 0;
  int colorValue = existing?.colorValue ?? AppColors.emeraldPrimary.value;
  HabitFrequency freq = existing?.frequency ?? HabitFrequency.daily;
  List<int> weekdays = List<int>.from(existing?.customWeekdays ?? [1, 2, 3, 4, 5, 6, 7]);
  int targetCount = existing?.targetCount ?? 1;
  String? reminderTime = existing?.reminderTime;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final l10n = AppLocalizations.of(ctx);
      const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

      return StatefulBuilder(
        builder: (ctx, setState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    existing == null ? l10n.tr('add_habit') : l10n.tr('edit_habit'),
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(hintText: l10n.tr('title')),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppColors.habitSwatches.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, idx) {
                        final swatch = AppColors.habitSwatches[idx];
                        final selected = swatch.value == colorValue;
                        return GestureDetector(
                          onTap: () => setState(() => colorValue = swatch.value),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: swatch,
                              shape: BoxShape.circle,
                              border: selected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 46,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppConstants.habitIcons.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, idx) {
                        final selected = idx == iconIndex;
                        return GestureDetector(
                          onTap: () => setState(() => iconIndex = idx),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: selected
                                  ? Color(colorValue).withOpacity(0.2)
                                  : (isDark
                                      ? AppColors.darkSurfaceSecondary
                                      : AppColors.lightSurfaceSecondary),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              AppConstants.habitIcons[idx],
                              color: selected ? Color(colorValue) : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<HabitFrequency>(
                    segments: const [
                      ButtonSegment(value: HabitFrequency.daily, label: Text('Daily')),
                      ButtonSegment(value: HabitFrequency.weekly, label: Text('Weekly')),
                      ButtonSegment(value: HabitFrequency.custom, label: Text('Custom')),
                    ],
                    selected: {freq},
                    onSelectionChanged: (set) => setState(() => freq = set.first),
                  ),
                  if (freq != HabitFrequency.daily) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        final dayNum = i + 1;
                        final active = weekdays.contains(dayNum);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (active && weekdays.length > 1) {
                                weekdays.remove(dayNum);
                              } else if (!active) {
                                weekdays.add(dayNum);
                              }
                            });
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: active
                                ? Color(colorValue)
                                : (isDark
                                    ? AppColors.darkSurfaceSecondary
                                    : AppColors.lightSurfaceSecondary),
                            child: Text(
                              dayNames[i],
                              style: TextStyle(
                                color: active ? Colors.white : null,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text('Daily Target: $targetCount',
                          style: Theme.of(ctx).textTheme.titleSmall),
                      const Spacer(),
                      IconButton(
                        onPressed: targetCount > 1
                            ? () => setState(() => targetCount--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      IconButton(
                        onPressed: () => setState(() => targetCount++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.alarm_rounded, size: 16),
                        label: Text(reminderTime ?? l10n.tr('reminder')),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: const TimeOfDay(hour: 8, minute: 0),
                          );
                          if (picked != null) {
                            setState(() {
                              reminderTime =
                                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(colorValue),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty) return;
                      await ctx.read<AppStateProvider>().addOrUpdateHabit(
                            id: existing?.id,
                            name: nameCtrl.text,
                            iconIndex: iconIndex,
                            colorValue: colorValue,
                            frequency: freq,
                            customWeekdays: weekdays,
                            targetCount: targetCount,
                            reminderTime: reminderTime,
                            isPaused: existing?.isPaused ?? false,
                          );
                      HapticFeedback.mediumImpact();
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(l10n.tr('save'), style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> showEventFormSheet(
  BuildContext context, {
  EventModel? existing,
  String? defaultDateKey,
}) async {
  final titleCtrl = TextEditingController(text: existing?.title ?? '');
  final descCtrl = TextEditingController(text: existing?.description ?? '');
  String dateKey = existing?.dateKey ?? defaultDateKey ?? DateUtilsExt.toDateKey(DateTime.now());
  String startTime = existing?.startTime ?? '09:00';
  String endTime = existing?.endTime ?? '10:00';
  String category = existing?.category ?? AppConstants.eventCategories.first;
  EventRecurrence recurrence = existing?.recurrence ?? EventRecurrence.none;
  DateTime? reminderAt = existing?.reminderAt;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final l10n = AppLocalizations.of(ctx);
      return StatefulBuilder(
        builder: (ctx, setState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    existing == null ? l10n.tr('add_event') : l10n.tr('edit_event'),
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(hintText: l10n.tr('title')),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(hintText: l10n.tr('description')),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.calendar_month_rounded, size: 16),
                        label: Text(dateKey),
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: ctx,
                            initialDate: DateUtilsExt.fromDateKey(dateKey),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (d != null) setState(() => dateKey = DateUtilsExt.toDateKey(d));
                        },
                      ),
                      ActionChip(
                        label: Text('Start: $startTime'),
                        onPressed: () async {
                          final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                          if (t != null) {
                            setState(() => startTime =
                                '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
                          }
                        },
                      ),
                      ActionChip(
                        label: Text('End: $endTime'),
                        onPressed: () async {
                          final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                          if (t != null) {
                            setState(() => endTime =
                                '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
                          }
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.notifications_outlined, size: 16),
                        label: Text(reminderAt != null
                            ? DateUtilsExt.formatTime(reminderAt!)
                            : l10n.tr('reminder')),
                        onPressed: () async {
                          final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                          if (t != null) {
                            final base = DateUtilsExt.fromDateKey(dateKey);
                            setState(() => reminderAt =
                                DateTime(base.year, base.month, base.day, t.hour, t.minute));
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: AppConstants.eventCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => category = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<EventRecurrence>(
                    value: recurrence,
                    decoration: const InputDecoration(labelText: 'Repeat'),
                    items: EventRecurrence.values
                        .map((r) => DropdownMenuItem(
                            value: r, child: Text(r.name[0].toUpperCase() + r.name.substring(1))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => recurrence = v);
                    },
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.terracotta,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      if (titleCtrl.text.trim().isEmpty) return;
                      await ctx.read<AppStateProvider>().addOrUpdateEvent(
                            id: existing?.id,
                            title: titleCtrl.text,
                            description: descCtrl.text,
                            dateKey: dateKey,
                            startTime: startTime,
                            endTime: endTime,
                            category: category,
                            recurrence: recurrence,
                            status: existing?.status ?? EventStatus.scheduled,
                            reminderAt: reminderAt,
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(l10n.tr('save'), style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> showNoteEditorSheet(BuildContext context, {NoteModel? existing}) async {
  final titleCtrl = TextEditingController(text: existing?.title ?? '');
  final bodyCtrl = TextEditingController(text: existing?.content ?? '');

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final l10n = AppLocalizations.of(ctx);
      return Container(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                existing == null ? l10n.tr('add_note') : l10n.tr('edit_note'),
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(hintText: l10n.tr('title')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtrl,
                maxLines: 6,
                decoration: const InputDecoration(hintText: 'Write your note...'),
              ),
              const SizedBox(height: 18),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.emeraldPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty && bodyCtrl.text.trim().isEmpty) return;
                  await ctx.read<AppStateProvider>().addOrUpdateNote(
                        id: existing?.id,
                        title: titleCtrl.text,
                        content: bodyCtrl.text,
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(l10n.tr('save'), style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showJournalSheet(BuildContext context, {JournalModel? existing}) async {
  final titleCtrl = TextEditingController(text: existing?.title ?? '');
  final contentCtrl = TextEditingController(text: existing?.content ?? '');

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final l10n = AppLocalizations.of(ctx);
      final state = ctx.watch<AppStateProvider>();

      return Container(
        height: MediaQuery.of(ctx).size.height * 0.82,
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.tr('journal'), style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(hintText: l10n.tr('title')),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Reflect on your day...'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.copperBronze,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty && contentCtrl.text.trim().isEmpty) return;
                await ctx.read<AppStateProvider>().addOrUpdateJournal(
                      id: existing?.id,
                      title: titleCtrl.text,
                      content: contentCtrl.text,
                    );
                titleCtrl.clear();
                contentCtrl.clear();
                HapticFeedback.lightImpact();
              },
              child: Text(l10n.tr('save'), style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),
            Text('Recent Entries', style: Theme.of(ctx).textTheme.titleSmall),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: state.allJournals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final entry = state.allJournals[i];
                  return AppleCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.title, style: Theme.of(ctx).textTheme.titleSmall),
                              const SizedBox(height: 2),
                              Text(
                                '${entry.dateKey} • ${DateUtilsExt.formatTime(entry.createdAt)}',
                                style: Theme.of(ctx).textTheme.bodySmall,
                              ),
                              if (entry.content.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(entry.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 20),
                          onPressed: () => ctx.read<AppStateProvider>().deleteJournal(entry.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showWaterSheet(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final l10n = AppLocalizations.of(ctx);
      final state = ctx.watch<AppStateProvider>();
      final todayKey = DateUtilsExt.toDateKey(DateTime.now());
      final totalToday = state.waterTotalForDate(todayKey);
      final target = state.settings.dailyWaterTargetMl;
      final progress = (totalToday / (target <= 0 ? 2500 : target)).clamp(0.0, 1.0);
      final todayLogs = state.allWaterRecords.where((w) => w.dateKey == todayKey).toList();

      return Container(
        height: MediaQuery.of(ctx).size.height * 0.72,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Text(l10n.tr('water'), style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            CompletionRing(
              progress: progress,
              centerLabel: '${(progress * 100).round()}%',
              color: AppColors.pineTeal,
              size: 112,
            ),
            const SizedBox(height: 10),
            Text(
              '$totalToday ml / $target ml',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [250, 500, 750].map((ml) {
                return FilledButton.tonal(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ctx.read<AppStateProvider>().logWater(ml);
                  },
                  child: Text('+$ml ml'),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: todayLogs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final log = todayLogs[i];
                  return AppleCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.water_drop_rounded, color: AppColors.pineTeal, size: 20),
                        const SizedBox(width: 10),
                        Text('${log.amountMl} ml', style: Theme.of(ctx).textTheme.titleSmall),
                        const Spacer(),
                        Text(DateUtilsExt.formatTime(log.recordedAt),
                            style: Theme.of(ctx).textTheme.bodySmall),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          onPressed: () => ctx.read<AppStateProvider>().deleteWaterRecord(log.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showExerciseSheet(BuildContext context) async {
  final activityCtrl = TextEditingController();
  final durationCtrl = TextEditingController(text: '30');
  final notesCtrl = TextEditingController();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final l10n = AppLocalizations.of(ctx);
      final state = ctx.watch<AppStateProvider>();

      return Container(
        height: MediaQuery.of(ctx).size.height * 0.78,
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.tr('exercise'), style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: activityCtrl,
              decoration: InputDecoration(hintText: l10n.tr('activity_name')),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: durationCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: l10n.tr('duration_mins')),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notesCtrl,
              decoration: InputDecoration(hintText: l10n.tr('description')),
            ),
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.terracotta,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                if (activityCtrl.text.trim().isEmpty) return;
                final mins = int.tryParse(durationCtrl.text.trim()) ?? 30;
                await ctx.read<AppStateProvider>().logExercise(
                      activityName: activityCtrl.text,
                      durationMinutes: mins <= 0 ? 15 : mins,
                      notes: notesCtrl.text,
                    );
                activityCtrl.clear();
                notesCtrl.clear();
              },
              child: Text(l10n.tr('save'), style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: state.allExerciseRecords.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final rec = state.allExerciseRecords[i];
                  return AppleCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${rec.activityName} • ${rec.durationMinutes} min',
                                  style: Theme.of(ctx).textTheme.titleSmall),
                              Text(rec.dateKey, style: Theme.of(ctx).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          onPressed: () =>
                              ctx.read<AppStateProvider>().deleteExerciseRecord(rec.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showSleepSheet(BuildContext context) async {
  TimeOfDay bedtime = const TimeOfDay(hour: 22, minute: 30);
  TimeOfDay wakeTime = const TimeOfDay(hour: 6, minute: 30);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final l10n = AppLocalizations.of(ctx);
      final state = ctx.watch<AppStateProvider>();

      return StatefulBuilder(
        builder: (ctx, setState) {
          final now = DateTime.now();
          final bedDt = DateTime(now.year, now.month, now.day, bedtime.hour, bedtime.minute);
          var wakeDt = DateTime(now.year, now.month, now.day, wakeTime.hour, wakeTime.minute);
          if (!wakeDt.isAfter(bedDt)) wakeDt = wakeDt.add(const Duration(days: 1));
          final durationMins = wakeDt.difference(bedDt).inMinutes;

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.72,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.tr('sleep'), style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppleCard(
                        onTap: () async {
                          final picked = await showTimePicker(context: ctx, initialTime: bedtime);
                          if (picked != null) setState(() => bedtime = picked);
                        },
                        child: Column(
                          children: [
                            Text(l10n.tr('bedtime'), style: Theme.of(ctx).textTheme.bodySmall),
                            const SizedBox(height: 4),
                            Text(bedtime.format(ctx), style: Theme.of(ctx).textTheme.titleMedium),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppleCard(
                        onTap: () async {
                          final picked = await showTimePicker(context: ctx, initialTime: wakeTime);
                          if (picked != null) setState(() => wakeTime = picked);
                        },
                        child: Column(
                          children: [
                            Text(l10n.tr('wake_time'), style: Theme.of(ctx).textTheme.bodySmall),
                            const SizedBox(height: 4),
                            Text(wakeTime.format(ctx), style: Theme.of(ctx).textTheme.titleMedium),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Duration: ${DateUtilsExt.formatMinutesAsDuration(durationMins)}',
                    style: Theme.of(ctx).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.espressoUmber,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    await ctx.read<AppStateProvider>().logSleep(
                          bedtime: bedDt,
                          wakeTime: wakeDt,
                        );
                    HapticFeedback.lightImpact();
                  },
                  child: Text(l10n.tr('save'), style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ListView.separated(
                    itemCount: state.allSleepRecords.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final rec = state.allSleepRecords[i];
                      return AppleCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${DateUtilsExt.formatMinutesAsDuration(rec.durationMinutes)} • ${rec.dateKey}',
                                    style: Theme.of(ctx).textTheme.titleSmall,
                                  ),
                                  Text(
                                    '${DateUtilsExt.formatTime(rec.bedtime)} → ${DateUtilsExt.formatTime(rec.wakeTime)}',
                                    style: Theme.of(ctx).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18),
                              onPressed: () =>
                                  ctx.read<AppStateProvider>().deleteSleepRecord(rec.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> showMoodSheet(BuildContext context) async {
  int selectedMood = 4;
  final noteCtrl = TextEditingController();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final l10n = AppLocalizations.of(ctx);
      final state = ctx.watch<AppStateProvider>();

      const moods = [
        (1, 'Low', Icons.sentiment_very_dissatisfied_rounded),
        (2, 'Tired', Icons.sentiment_dissatisfied_rounded),
        (3, 'Calm', Icons.sentiment_neutral_rounded),
        (4, 'Good', Icons.sentiment_satisfied_rounded),
        (5, 'Radiant', Icons.sentiment_very_satisfied_rounded),
      ];

      return StatefulBuilder(
        builder: (ctx, setState) {
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.74,
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.tr('how_feeling'), style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: moods.map((m) {
                    final (lvl, label, icon) = m;
                    final active = selectedMood == lvl;
                    return GestureDetector(
                      onTap: () => setState(() => selectedMood = lvl),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.roseClay.withOpacity(0.2)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              size: 30,
                              color: active ? AppColors.roseClay : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(label, style: Theme.of(ctx).textTheme.bodySmall),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: noteCtrl,
                  decoration: InputDecoration(hintText: l10n.tr('description')),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.roseClay,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    await ctx.read<AppStateProvider>().logMood(
                          moodLevel: selectedMood,
                          note: noteCtrl.text,
                        );
                    noteCtrl.clear();
                    HapticFeedback.lightImpact();
                  },
                  child: Text(l10n.tr('save'), style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ListView.separated(
                    itemCount: state.allMoodRecords.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final rec = state.allMoodRecords[i];
                      return AppleCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${rec.label} • ${rec.dateKey}',
                                      style: Theme.of(ctx).textTheme.titleSmall),
                                  if (rec.note.isNotEmpty)
                                    Text(rec.note, style: Theme.of(ctx).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18),
                              onPressed: () =>
                                  ctx.read<AppStateProvider>().deleteMoodRecord(rec.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
