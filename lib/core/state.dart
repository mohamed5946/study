import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import '../services/ai_service.dart';
import 'config.dart';
import 'l10n.dart';

/// Overridden in main() with the loaded SharedPreferences instance.
final prefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('prefsProvider must be overridden'),
);

// ---------------------------------------------------------------- Settings

class Settings {
  final String lang; // 'ar' | 'en'
  final ThemeMode theme;
  final bool reduceAnim;

  const Settings({
    required this.lang,
    required this.theme,
    required this.reduceAnim,
  });

  Settings copyWith({String? lang, ThemeMode? theme, bool? reduceAnim}) =>
      Settings(
        lang: lang ?? this.lang,
        theme: theme ?? this.theme,
        reduceAnim: reduceAnim ?? this.reduceAnim,
      );
}

class SettingsNotifier extends Notifier<Settings> {
  @override
  Settings build() {
    final p = ref.read(prefsProvider);
    final themeName = p.getString('theme') ?? 'dark';
    return Settings(
      lang: p.getString('lang') ?? 'ar',
      theme: ThemeMode.values.firstWhere(
        (m) => m.name == themeName,
        orElse: () => ThemeMode.dark,
      ),
      reduceAnim: p.getBool('reduce') ?? false,
    );
  }

  void setLang(String lang) {
    ref.read(prefsProvider).setString('lang', lang);
    state = state.copyWith(lang: lang);
  }

  void setTheme(ThemeMode mode) {
    ref.read(prefsProvider).setString('theme', mode.name);
    state = state.copyWith(theme: mode);
  }

  void setReduceAnim(bool v) {
    ref.read(prefsProvider).setBool('reduce', v);
    state = state.copyWith(reduceAnim: v);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);

final trProvider = Provider<Tr>(
  (ref) => Tr(ref.watch(settingsProvider.select((s) => s.lang))),
);

/// Selected bottom tab (0 Home, 1 Schedule, 2 AI, 3 Study, 4 More).
final tabProvider = StateProvider<int>((ref) => 0);

// ---------------------------------------------------------------- Schedule

class ScheduleNotifier extends Notifier<List<ScheduleItem>> {
  @override
  List<ScheduleItem> build() {
    final raw = ref.read(prefsProvider).getString('schedule');
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => ScheduleItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void _save() {
    ref
        .read(prefsProvider)
        .setString('schedule', jsonEncode(state.map((e) => e.toJson()).toList()));
  }

  void add(ScheduleItem item) {
    state = [...state, item];
    _save();
  }

  void addAll(List<ScheduleItem> items) {
    state = [...state, ...items];
    _save();
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
    _save();
  }
}

final scheduleProvider =
    NotifierProvider<ScheduleNotifier, List<ScheduleItem>>(ScheduleNotifier.new);

// ---------------------------------------------------------------------- AI

final aiServiceProvider = Provider<AiService>((ref) {
  if (AppConfig.demo) return MockAiService();
  return HttpAiService(AppConfig.aiBaseUrl);
});

class ChatState {
  final List<ChatMsg> messages;
  final bool loading;
  const ChatState({required this.messages, required this.loading});
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    final raw = ref.read(prefsProvider).getString('chat');
    var msgs = <ChatMsg>[];
    if (raw != null) {
      try {
        msgs = (jsonDecode(raw) as List)
            .map((e) => ChatMsg.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (_) {}
    }
    return ChatState(messages: msgs, loading: false);
  }

  void _save(List<ChatMsg> msgs) {
    final keep = msgs.length > 100 ? msgs.sublist(msgs.length - 100) : msgs;
    ref
        .read(prefsProvider)
        .setString('chat', jsonEncode(keep.map((m) => m.toJson()).toList()));
  }

  Future<void> send(String text) async {
    final t = text.trim();
    if (t.isEmpty || state.loading) return;
    final msgs = [...state.messages, ChatMsg('user', t)];
    state = ChatState(messages: msgs, loading: true);
    String reply;
    try {
      reply = await ref
          .read(aiServiceProvider)
          .chat(msgs, lang: ref.read(settingsProvider).lang);
    } catch (_) {
      reply = ref.read(trProvider)('error_retry');
    }
    final done = [...msgs, ChatMsg('assistant', reply)];
    state = ChatState(messages: done, loading: false);
    _save(done);
  }

  void clear() {
    state = const ChatState(messages: [], loading: false);
    ref.read(prefsProvider).remove('chat');
  }
}

final chatProvider =
    NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
