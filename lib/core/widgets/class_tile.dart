import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/models.dart';
import '../state.dart';
import '../theme.dart';
import 'glass.dart';

/// One lecture / section row used on Home and Schedule.
class ClassTile extends ConsumerWidget {
  final ScheduleItem item;
  final VoidCallback? onDelete;
  const ClassTile({super.key, required this.item, this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(trProvider);
    final color = item.type == 'lecture' ? kViolet : kCyan;
    final subtitle = [
      t(item.type),
      if (item.place.isNotEmpty) item.place,
      if (item.instructor.isNotEmpty) item.instructor,
    ].join(' • ');

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 46,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.course,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fmtHm(item.start),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                fmtHm(item.end),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: t('delete'),
            ),
        ],
      ),
    );
  }
}
