import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/state.dart';
import 'core/theme.dart';
import 'core/widgets/glass.dart';
import 'features/shell/home_shell.dart';

class StudentAssistantApp extends ConsumerWidget {
  const StudentAssistantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    return MaterialApp(
      title: 'Study Assistant Cloud',
      debugShowCheckedModeBanner: false,
      locale: Locale(s.lang),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: s.theme,
      theme: buildTheme(Brightness.light, s.lang),
      darkTheme: buildTheme(Brightness.dark, s.lang),
      builder: (context, child) => GlassBackground(child: child ?? const SizedBox()),
      home: const HomeShell(),
    );
  }
}
