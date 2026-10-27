import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../core/state.dart';
import '../../core/theme.dart';
import '../../core/widgets/class_tile.dart';
import '../../core/widgets/glass.dart';
import '../../models/models.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(trProvider);
    final items = ref.watch(scheduleProvider);
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;

    final today = items.where((e) => e.day == now.weekday).toList()
      ..sort((x, y) => x.start.compareTo(y.start));
    ScheduleItem? next;
    for (final e in today) {
      if (e.end > nowMin) {
        next = e;
        break;
      }
    }

    final greet = now.hour < 12
        ? t('good_morning')
        : (now.hour < 18 ? t('good_afternoon') : t('good_evening'));

    var i = 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        FadeSlideIn(
          index: i++,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greet, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(
                t('app_name'),
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (AppConfig.demo)
          FadeSlideIn(
            index: i++,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GlassCard(
                radius: 18,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t('demo_banner'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        FadeSlideIn(index: i++, child: _NextClassCard(next: next, nowMin: nowMin)),
        const SizedBox(height: 18),
        FadeSlideIn(
          index: i++,
          child: SectionTitle(t('quick_actions')),
        ),
        FadeSlideIn(
          index: i++,
          child: Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.auto_awesome_rounded,
                  label: t('ask_ai'),
                  onTap: () => ref.read(tabProvider.notifier).state = 2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.upload_file_rounded,
                  label: t('upload_pdf'),
                  onTap: () => ref.read(tabProvider.notifier).state = 3,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.add_circle_outline_rounded,
                  label: t('add_class'),
                  onTap: () => ref.read(tabProvider.notifier).state = 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FadeSlideIn(index: i++, child: SectionTitle(t('today'))),
        if (today.isEmpty)
          FadeSlideIn(
            index: i++,
            child: GlassCard(
              child: Text(t('no_classes_today')),
            ),
          )
        else
          for (final e in today)
            FadeSlideIn(
              index: i++,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ClassTile(item: e),
              ),
            ),
      ],
    );
  }
}

class _NextClassCard extends ConsumerWidget {
  final ScheduleItem? next;
  final int nowMin;
  const _NextClassCard({required this.next, required this.nowMin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(trProvider);
    final n = next;

    String status = '';
    if (n != null) {
      status = nowMin >= n.start
          ? t('running_now')
          : '${t('starts_in')} ${n.start - nowMin} ${t('min')}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kViolet, kCyan],
        ),
        boxShadow: [
          BoxShadow(
            color: withA(kViolet, 0.45),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('next_class'),
            style: TextStyle(
              color: withA(Colors.white, 0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (n == null)
            Text(
              t('no_next'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            )
          else ...[
            Text(
              n.course,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                _Info(Icons.schedule_rounded, '${fmtHm(n.start)} - ${fmtHm(n.end)}'),
                if (n.place.isNotEmpty) _Info(Icons.place_outlined, n.place),
                _Info(Icons.timelapse_rounded, status),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Info(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      );
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GlassCard(
        radius: 22,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
}
