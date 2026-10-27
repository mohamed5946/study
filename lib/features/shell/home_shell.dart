import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state.dart';
import '../../core/widgets/glass.dart';
import '../ai/chat_page.dart';
import '../home/home_page.dart';
import '../more/more_page.dart';
import '../schedule/schedule_page.dart';
import '../study/study_page.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(trProvider);
    final tab = ref.watch(tabProvider);
    final reduce = ref.watch(settingsProvider.select((s) => s.reduceAnim));
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    const pages = <Widget>[
      HomePage(),
      SchedulePage(),
      ChatPage(),
      StudyPage(),
      MorePage(),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: reduce ? 0 : 280),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: KeyedSubtree(key: ValueKey(tab), child: pages[tab]),
        ),
      ),
      bottomNavigationBar: keyboardOpen
          ? const SizedBox.shrink()
          : GlassBottomBar(
              index: tab,
              onTap: (i) => ref.read(tabProvider.notifier).state = i,
              items: [
                NavItem(Icons.home_rounded, t('home')),
                NavItem(Icons.calendar_month_rounded, t('schedule')),
                NavItem(Icons.auto_awesome_rounded, t('ai')),
                NavItem(Icons.menu_book_rounded, t('study')),
                NavItem(Icons.grid_view_rounded, t('more')),
              ],
            ),
    );
  }
}
