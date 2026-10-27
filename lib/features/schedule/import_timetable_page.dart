import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state.dart';
import '../../core/widgets/class_tile.dart';
import '../../core/widgets/glass.dart';
import '../../models/models.dart';

/// Step 1: pick timetable file + type registered courses.
/// Step 2: review the AI result, remove mistakes, save.
class ImportTimetablePage extends ConsumerStatefulWidget {
  const ImportTimetablePage({super.key});

  @override
  ConsumerState<ImportTimetablePage> createState() => _ImportTimetablePageState();
}

class _ImportTimetablePageState extends ConsumerState<ImportTimetablePage> {
  final _courses = TextEditingController();
  PlatformFile? _file;
  bool _loading = false;
  String? _error;
  List<ScheduleItem>? _result;

  @override
  void dispose() {
    _courses.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (res == null || res.files.isEmpty) return;
    setState(() => _file = res.files.first);
  }

  List<String> _parseCourses() => _courses.text
      .split(RegExp(r'[,،\n]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _build() async {
    final t = ref.read(trProvider);
    final file = _file;
    final courses = _parseCourses();
    if (file == null || file.bytes == null || courses.isEmpty) {
      setState(() => _error = t('error_retry'));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await ref.read(aiServiceProvider).parseTimetable(
            bytes: file.bytes!,
            fileName: file.name,
            courses: courses,
          );
      if (!mounted) return;
      setState(() => _result = items);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = t('error_retry'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _save() {
    final t = ref.read(trProvider);
    final items = _result ?? [];
    ref.read(scheduleProvider.notifier).addAll(items);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('saved'))));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(trProvider);
    final result = _result;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  tooltip: t('back'),
                ),
                Expanded(
                  child: Text(
                    t(result == null ? 'import_timetable' : 'review_schedule'),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (result == null) ...[
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassButton(
                      label: t('pick_file'),
                      icon: Icons.upload_file_rounded,
                      filled: false,
                      expand: true,
                      onPressed: _pickFile,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _file?.name ?? t('no_file'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SectionTitle(t('my_courses')),
              GlassTextField(
                controller: _courses,
                hint: t('courses_hint'),
                minLines: 3,
                maxLines: 6,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 18),
              GlassButton(
                label: t('build_schedule'),
                icon: Icons.auto_awesome_rounded,
                expand: true,
                loading: _loading,
                onPressed: _build,
              ),
            ] else ...[
              Text(t('review_hint'), style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 14),
              for (var i = 0; i < result.length; i++)
                FadeSlideIn(
                  index: i,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ClassTile(
                      item: result[i],
                      onDelete: () => setState(() {
                        _result = [...result]..removeAt(i);
                      }),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              GlassButton(
                label: t('save_schedule'),
                icon: Icons.check_rounded,
                expand: true,
                onPressed: result.isEmpty ? null : _save,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
