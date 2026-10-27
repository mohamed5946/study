import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state.dart';
import '../../core/widgets/class_tile.dart';
import '../../core/widgets/glass.dart';
import '../../models/models.dart';
import 'add_class_sheet.dart';
import 'import_timetable_page.dart';

/// Week starts on Saturday (common in Egypt): Sat, Sun, Mon, ... Fri.
const List<int> kWeekOrder = [6, 7, 1, 2, 3, 4, 5];

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  int _day = DateTime.now().weekday;

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(trProvider);
    final all = ref.watch(scheduleProvider);
    final list = all.where((e) => e.day == _day).toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        PageHeader(title: t('schedule')),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: GlassButton(
                label: t('add_class'),
                icon: Icons.add_rounded,
                expand: true,
                onPressed: () => showAddClassSheet(context, initialDay: _day),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GlassButton(
                label: t('import_timetable'),
                icon: Icons.document_scanner_rounded,
                filled: false,
                expand: true,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ImportTimetablePage()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: kWeekOrder.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final d = kWeekOrder[i];
              return GlassChoice(
                label: t.day(d),
                selected: d == _day,
                onTap: () => setState(() => _day = d),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (list.isEmpty)
          GlassCard(child: Text(t('empty_schedule')))
        else
          for (var i = 0; i < list.length; i++)
            FadeSlideIn(
              key: ValueKey('${_day}_${list[i].id}'),
              index: i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ClassTile(
                  item: list[i],
                  onDelete: () =>
                      ref.read(scheduleProvider.notifier).remove(list[i].id),
                ),
              ),
            ),
      ],
    );
  }
}

/// Convenience used by other files.
ScheduleItem buildItem({
  required String course,
  required String type,
  required int day,
  required int start,
  required int end,
  String place = '',
  String instructor = '',
}) =>
    ScheduleItem(
      id: newId(),
      course: course,
      type: type,
      day: day,
      start: start,
      end: end,
      place: place,
      instructor: instructor,
    );
