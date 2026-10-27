import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state.dart';
import '../../core/widgets/glass.dart';
import '../../models/models.dart';
import 'schedule_page.dart';

Future<void> showAddClassSheet(BuildContext context, {required int initialDay}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => AddClassSheet(initialDay: initialDay),
  );
}

class AddClassSheet extends ConsumerStatefulWidget {
  final int initialDay;
  const AddClassSheet({super.key, required this.initialDay});

  @override
  ConsumerState<AddClassSheet> createState() => _AddClassSheetState();
}

class _AddClassSheetState extends ConsumerState<AddClassSheet> {
  final _course = TextEditingController();
  final _place = TextEditingController();
  final _instructor = TextEditingController();
  String _type = 'lecture';
  late int _day = widget.initialDay;
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 10, minute: 30);

  @override
  void dispose() {
    _course.dispose();
    _place.dispose();
    _instructor.dispose();
    super.dispose();
  }

  int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _pick(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  void _save() {
    final t = ref.read(trProvider);
    final messenger = ScaffoldMessenger.of(context);
    if (_course.text.trim().isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(t('course_required'))));
      return;
    }
    if (_minutes(_end) <= _minutes(_start)) {
      messenger.showSnackBar(SnackBar(content: Text(t('time_invalid'))));
      return;
    }
    ref.read(scheduleProvider.notifier).add(buildItem(
          course: _course.text.trim(),
          type: _type,
          day: _day,
          start: _minutes(_start),
          end: _minutes(_end),
          place: _place.text.trim(),
          instructor: _instructor.text.trim(),
        ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(trProvider);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + bottom),
      child: GlassCard(
        radius: 28,
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('add_class'),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              GlassTextField(controller: _course, hint: t('course')),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: GlassTextField(controller: _place, hint: t('place'))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassTextField(controller: _instructor, hint: t('instructor')),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children: [
                  GlassChoice(
                    label: t('lecture'),
                    selected: _type == 'lecture',
                    onTap: () => setState(() => _type = 'lecture'),
                  ),
                  GlassChoice(
                    label: t('section'),
                    selected: _type == 'section',
                    onTap: () => setState(() => _type = 'section'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final d in kWeekOrder)
                    GlassChoice(
                      label: t.day(d),
                      selected: _day == d,
                      onTap: () => setState(() => _day = d),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: '${t('start')}: ${fmtHm(_minutes(_start))}',
                      icon: Icons.schedule_rounded,
                      filled: false,
                      expand: true,
                      onPressed: () => _pick(true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassButton(
                      label: '${t('end')}: ${fmtHm(_minutes(_end))}',
                      icon: Icons.schedule_rounded,
                      filled: false,
                      expand: true,
                      onPressed: () => _pick(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: t('cancel'),
                      filled: false,
                      expand: true,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassButton(
                      label: t('save'),
                      icon: Icons.check_rounded,
                      expand: true,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
