import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../core/state.dart';
import '../../core/widgets/glass.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(trProvider);
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        PageHeader(title: t('settings')),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('language'), style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  GlassChoice(
                    label: 'العربية',
                    selected: s.lang == 'ar',
                    onTap: () => n.setLang('ar'),
                  ),
                  GlassChoice(
                    label: 'English',
                    selected: s.lang == 'en',
                    onTap: () => n.setLang('en'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('theme'), style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  GlassChoice(
                    label: t('dark'),
                    selected: s.theme == ThemeMode.dark,
                    onTap: () => n.setTheme(ThemeMode.dark),
                  ),
                  GlassChoice(
                    label: t('light'),
                    selected: s.theme == ThemeMode.light,
                    onTap: () => n.setTheme(ThemeMode.light),
                  ),
                  GlassChoice(
                    label: t('system'),
                    selected: s.theme == ThemeMode.system,
                    onTap: () => n.setTheme(ThemeMode.system),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  t('reduce_anim'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Switch(value: s.reduceAnim, onChanged: n.setReduceAnim),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Row(
            children: [
              Icon(
                AppConfig.demo ? Icons.science_outlined : Icons.check_circle_rounded,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('ai_connection'),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppConfig.demo ? t('demo_mode') : t('connected'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('about'), style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(t('about_text'), style: const TextStyle(height: 1.5)),
              const SizedBox(height: 8),
              Text('v1.0.0', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
