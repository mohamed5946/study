import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state.dart';
import '../../core/widgets/glass.dart';

class StudyPage extends ConsumerStatefulWidget {
  const StudyPage({super.key});

  @override
  ConsumerState<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends ConsumerState<StudyPage> {
  PlatformFile? _file;
  int _count = 10;
  String _difficulty = 'medium';
  bool _loadingExplain = false;
  bool _loadingExam = false;
  String? _result;

  Future<void> _pick() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );
    if (res == null || res.files.isEmpty) return;
    setState(() {
      _file = res.files.first;
      _result = null;
    });
  }

  Future<void> _run({required bool exam}) async {
    final t = ref.read(trProvider);
    final file = _file;
    if (file == null || file.bytes == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t('upload_first'))));
      return;
    }
    setState(() {
      if (exam) {
        _loadingExam = true;
      } else {
        _loadingExplain = true;
      }
    });
    try {
      final ai = ref.read(aiServiceProvider);
      final lang = ref.read(settingsProvider).lang;
      final text = exam
          ? await ai.generateExam(
              bytes: file.bytes!,
              fileName: file.name,
              lang: lang,
              count: _count,
              difficulty: _difficulty,
            )
          : await ai.explainPdf(bytes: file.bytes!, fileName: file.name, lang: lang);
      if (!mounted) return;
      setState(() => _result = text);
    } catch (_) {
      if (!mounted) return;
      setState(() => _result = t('error_retry'));
    } finally {
      if (mounted) {
        setState(() {
          _loadingExam = false;
          _loadingExplain = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(trProvider);
    final busy = _loadingExam || _loadingExplain;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        PageHeader(title: t('study_title')),
        const SizedBox(height: 8),
        Text(t('study_hint'), style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassButton(
                label: t('upload_pdf'),
                icon: Icons.upload_file_rounded,
                filled: false,
                expand: true,
                onPressed: busy ? null : _pick,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.picture_as_pdf_rounded, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _file?.name ?? t('no_file'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('questions_count'), style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final n in const [5, 10, 15, 20])
                    GlassChoice(
                      label: '$n',
                      selected: _count == n,
                      onTap: () => setState(() => _count = n),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(t('difficulty'), style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final d in const ['easy', 'medium', 'hard'])
                    GlassChoice(
                      label: t(d),
                      selected: _difficulty == d,
                      onTap: () => setState(() => _difficulty = d),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: GlassButton(
                label: t('explain'),
                icon: Icons.lightbulb_outline_rounded,
                filled: false,
                expand: true,
                loading: _loadingExplain,
                onPressed: busy ? null : () => _run(exam: false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GlassButton(
                label: t('generate_exam'),
                icon: Icons.quiz_rounded,
                expand: true,
                loading: _loadingExam,
                onPressed: busy ? null : () => _run(exam: true),
              ),
            ),
          ],
        ),
        if (_result != null) ...[
          const SizedBox(height: 18),
          FadeSlideIn(
            index: 0,
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t('result'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        tooltip: t('copy'),
                        icon: const Icon(Icons.copy_rounded, size: 20),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _result!));
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(t('copied'))));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SelectableText(_result!, style: const TextStyle(height: 1.5)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
