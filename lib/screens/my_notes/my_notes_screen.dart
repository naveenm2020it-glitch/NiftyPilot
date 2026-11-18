import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/date_utils_ext.dart';
import '../../widgets/apple_card.dart';
import '../trackers/tracker_sheets.dart';

class MyNotesScreen extends StatefulWidget {
  const MyNotesScreen({super.key});

  @override
  State<MyNotesScreen> createState() => _MyNotesScreenState();
}

class _MyNotesScreenState extends State<MyNotesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final l10n = AppLocalizations.of(context);

    final filtered = state.allNotes.where((n) {
      if (_query.trim().isEmpty) return true;
      final q = _query.toLowerCase();
      return n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q);
    }).toList();

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
                    Text(l10n.tr('my_notes'), style: Theme.of(context).textTheme.headlineMedium),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      onPressed: () => showNoteEditorSheet(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    hintText: l10n.tr('search_notes'),
                  ),
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  AppleCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(l10n.tr('no_notes')),
                      ),
                    ),
                  )
                else
                  ...filtered.map(
                    (note) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppleCard(
                        onTap: () => showNoteEditorSheet(context, existing: note),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    note.title,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                  onPressed: () => state.deleteNote(note.id),
                                ),
                              ],
                            ),
                            if (note.content.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                note.content,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                            const SizedBox(height: 10),
                            Text(
                              'Updated ${DateUtilsExt.formatShortDate(note.updatedAt)} • ${DateUtilsExt.formatTime(note.updatedAt)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
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
