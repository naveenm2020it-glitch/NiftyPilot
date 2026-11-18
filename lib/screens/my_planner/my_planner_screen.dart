import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/event_model.dart';
import '../../providers/app_state_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_utils_ext.dart';
import '../../widgets/apple_card.dart';
import '../trackers/tracker_sheets.dart';

enum PlannerViewMode { monthly, weekly, daily, agenda }

class MyPlannerScreen extends StatefulWidget {
  const MyPlannerScreen({super.key});

  @override
  State<MyPlannerScreen> createState() => _MyPlannerScreenState();
}

class _MyPlannerScreenState extends State<MyPlannerScreen> {
  PlannerViewMode _viewMode = PlannerViewMode.monthly;
  DateTime _selectedDate = DateUtilsExt.stripTime(DateTime.now());
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  void _navigatePrevious() {
    setState(() {
      switch (_viewMode) {
        case PlannerViewMode.monthly:
          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
          _selectedDate = _focusedMonth;
          break;
        case PlannerViewMode.weekly:
          _selectedDate = _selectedDate.subtract(const Duration(days: 7));
          _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
          break;
        case PlannerViewMode.daily:
        case PlannerViewMode.agenda:
          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
          _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
          break;
      }
    });
  }

  void _navigateNext() {
    setState(() {
      switch (_viewMode) {
        case PlannerViewMode.monthly:
          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
          _selectedDate = _focusedMonth;
          break;
        case PlannerViewMode.weekly:
          _selectedDate = _selectedDate.add(const Duration(days: 7));
          _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
          break;
        case PlannerViewMode.daily:
        case PlannerViewMode.agenda:
          _selectedDate = _selectedDate.add(const Duration(days: 1));
          _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
          break;
      }
    });
  }

  void _goToday() {
    final now = DateUtilsExt.stripTime(DateTime.now());
    setState(() {
      _selectedDate = now;
      _focusedMonth = DateTime(now.year, now.month, 1);
    });
  }

  Future<void> _editDateNoteDialog(
    BuildContext context,
    AppStateProvider state,
    String dateKey,
  ) async {
    final existing = state.dateNoteFor(dateKey);
    final ctrl = TextEditingController(text: existing?.content ?? '');
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${AppLocalizations.of(ctx).tr('date_notes')} ($dateKey)'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(ctx).tr('add_date_note'),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await state.saveDateNote(dateKey, ctrl.text);
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
    final selectedKey = DateUtilsExt.toDateKey(_selectedDate);

    final dayEvents = state.eventsForDate(_selectedDate);
    final dayTasks = state.tasksForDate(selectedKey);
    final dayNote = state.dateNoteFor(selectedKey);

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
                  children: [
                    Text(l10n.tr('my_planner'), style: Theme.of(context).textTheme.headlineMedium),
                    const Spacer(),
                    TextButton(
                      onPressed: _goToday,
                      child: Text(l10n.tr('today')),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      onPressed: () => showEventFormSheet(context, defaultDateKey: selectedKey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                SegmentedButton<PlannerViewMode>(
                  segments: [
                    ButtonSegment(value: PlannerViewMode.monthly, label: Text(l10n.tr('monthly'))),
                    ButtonSegment(value: PlannerViewMode.weekly, label: Text(l10n.tr('weekly'))),
                    ButtonSegment(value: PlannerViewMode.daily, label: Text(l10n.tr('daily'))),
                    ButtonSegment(value: PlannerViewMode.agenda, label: Text(l10n.tr('agenda'))),
                  ],
                  selected: {_viewMode},
                  onSelectionChanged: (set) => setState(() => _viewMode = set.first),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: _navigatePrevious,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          _viewMode == PlannerViewMode.monthly
                              ? DateFormat('MMMM yyyy').format(_focusedMonth)
                              : DateUtilsExt.formatShortDate(_selectedDate),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: _navigateNext,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_viewMode == PlannerViewMode.monthly)
                  _buildMonthGrid(context, state, isDark)
                else if (_viewMode == PlannerViewMode.weekly)
                  _buildWeekStrip(context, state, isDark),

                const SizedBox(height: 18),

                if (_viewMode == PlannerViewMode.agenda)
                  _buildAgendaList(context, state)
                else ...[
                  Row(
                    children: [
                      Text(
                        DateUtilsExt.formatReadableDate(_selectedDate),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.edit_note_rounded, size: 18),
                        label: Text(l10n.tr('date_notes')),
                        onPressed: () => _editDateNoteDialog(context, state, selectedKey),
                      ),
                    ],
                  ),
                  if (dayNote != null && dayNote.content.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    AppleCard(
                      backgroundColor: isDark
                          ? AppColors.amberSoftDark
                          : AppColors.amberSoftLight,
                      onTap: () => _editDateNoteDialog(context, state, selectedKey),
                      child: Row(
                        children: [
                          const Icon(Icons.sticky_note_2_rounded,
                              color: AppColors.amberOchre, size: 18),
                          const SizedBox(width: 10),
                          Expanded(child: Text(dayNote.content)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (dayEvents.isEmpty && dayTasks.isEmpty)
                    AppleCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(l10n.tr('no_events_date')),
                        ),
                      ),
                    )
                  else ...[
                    ...dayEvents.map((ev) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _EventCard(event: ev),
                        )),
                    ...dayTasks.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppleCard(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            onTap: () => showTaskFormSheet(context, existing: t),
                            child: Row(
                              children: [
                                Icon(
                                  t.isCompleted
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: AppColors.emeraldPrimary,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(t.title)),
                                if (t.scheduledTime != null)
                                  Text(t.scheduledTime!,
                                      style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                        )),
                  ],
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(BuildContext context, AppStateProvider state, bool isDark) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final leadingBlanks = (firstDay.weekday - 1) % 7;
    final totalCells = leadingBlanks + daysInMonth;
    final today = DateUtilsExt.stripTime(DateTime.now());
    const headers = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return AppleCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: headers
                .map((h) => Expanded(
                      child: Center(
                        child: Text(h, style: Theme.of(context).textTheme.labelSmall),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 4,
              childAspectRatio: 0.92,
            ),
            itemBuilder: (_, idx) {
              if (idx < leadingBlanks) return const SizedBox.shrink();
              final dayNum = idx - leadingBlanks + 1;
              final cellDate = DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
              final key = DateUtilsExt.toDateKey(cellDate);
              final isSelected = DateUtilsExt.isSameDay(cellDate, _selectedDate);
              final isToday = DateUtilsExt.isSameDay(cellDate, today);

              final hasTask = state.tasksForDate(key).isNotEmpty;
              final hasEvent = state.eventsForDate(cellDate).isNotEmpty;
              final hasNote = state.dateNoteFor(key) != null;

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = cellDate),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.emeraldPrimary
                        : (isToday
                            ? AppColors.terracotta.withOpacity(0.14)
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isToday ? AppColors.terracotta : null),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (hasEvent)
                            _dot(isSelected ? Colors.white : AppColors.terracotta),
                          if (hasTask)
                            _dot(isSelected ? Colors.white : AppColors.emeraldPrimary),
                          if (hasNote)
                            _dot(isSelected ? Colors.white : AppColors.amberOchre),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(
        width: 4,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );

  Widget _buildWeekStrip(BuildContext context, AppStateProvider state, bool isDark) {
    final start = DateUtilsExt.startOfWeek(_selectedDate);
    final today = DateUtilsExt.stripTime(DateTime.now());
    return AppleCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: List.generate(7, (i) {
          final day = start.add(Duration(days: i));
          final isSelected = DateUtilsExt.isSameDay(day, _selectedDate);
          final isToday = DateUtilsExt.isSameDay(day, today);
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDate = day),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.emeraldPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E').format(day).substring(0, 1),
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white70 : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : (isToday ? AppColors.terracotta : null),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAgendaList(BuildContext context, AppStateProvider state) {
    final start = DateUtilsExt.stripTime(DateTime.now());
    final items = <Widget>[];
    for (int i = 0; i < 14; i++) {
      final day = start.add(Duration(days: i));
      final evs = state.eventsForDate(day);
      final tks = state.tasksForDate(DateUtilsExt.toDateKey(day));
      if (evs.isEmpty && tks.isEmpty) continue;
      items.add(
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            DateUtilsExt.formatReadableDate(day),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      );
      for (final e in evs) {
        items.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _EventCard(event: e),
        ));
      }
      for (final t in tks) {
        items.add(Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppleCard(
            padding: const EdgeInsets.all(12),
            child: Text('• ${t.title}'),
          ),
        ));
      }
    }
    if (items.isEmpty) {
      return AppleCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(AppLocalizations.of(context).tr('no_events_date')),
          ),
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: items);
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppStateProvider>();
    final isDone = event.status == EventStatus.completed;
    return AppleCard(
      padding: const EdgeInsets.all(14),
      onTap: () => showEventFormSheet(context, existing: event),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: isDone ? AppColors.emeraldPrimary : AppColors.terracotta,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${event.startTime} – ${event.endTime} • ${event.category}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isDone ? AppColors.emeraldPrimary : null,
            ),
            onPressed: () => state.cycleEventStatus(event),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            onPressed: () => state.deleteEvent(event.id),
          ),
        ],
      ),
    );
  }
}
