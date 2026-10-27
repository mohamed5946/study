import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/models.dart';

/// Everything the app needs from an AI backend.
/// Swap implementations to change provider without touching the UI.
abstract class AiService {
  Future<String> chat(List<ChatMsg> history, {required String lang});

  Future<List<ScheduleItem>> parseTimetable({
    required Uint8List bytes,
    required String fileName,
    required List<String> courses,
  });

  Future<String> explainPdf({
    required Uint8List bytes,
    required String fileName,
    required String lang,
  });

  Future<String> generateExam({
    required Uint8List bytes,
    required String fileName,
    required String lang,
    required int count,
    required String difficulty,
  });
}

/// Talks to your own server (which holds the AI key).
///
/// Expected endpoints (all POST, JSON):
///   /chat            { messages:[{role,content}], lang }            -> { reply }
///   /timetable       { file_b64, file_name, courses:[...] }          -> { items:[{course,type,day,start,end,place,instructor}] }
///   /pdf/explain     { file_b64, file_name, lang }                   -> { text }
///   /pdf/exam        { file_b64, file_name, lang, count, difficulty }-> { text }
/// "day" is 1..7 (Monday = 1), "start"/"end" are "HH:mm".
class HttpAiService implements AiService {
  final String baseUrl;
  HttpAiService(String url) : baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final r = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 120));
    if (r.statusCode != 200) {
      throw Exception('HTTP ${r.statusCode}');
    }
    return jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
  }

  @override
  Future<String> chat(List<ChatMsg> history, {required String lang}) async {
    final res = await _post('/chat', {
      'messages': history.map((m) => m.toJson()).toList(),
      'lang': lang,
    });
    return (res['reply'] ?? '').toString();
  }

  @override
  Future<List<ScheduleItem>> parseTimetable({
    required Uint8List bytes,
    required String fileName,
    required List<String> courses,
  }) async {
    final res = await _post('/timetable', {
      'file_b64': base64Encode(bytes),
      'file_name': fileName,
      'courses': courses,
    });
    final list = (res['items'] as List? ?? []);
    return list
        .map((e) => ScheduleItem.fromJson({
              ...Map<String, dynamic>.from(e as Map),
              'id': newId(),
            }))
        .toList();
  }

  @override
  Future<String> explainPdf({
    required Uint8List bytes,
    required String fileName,
    required String lang,
  }) async {
    final res = await _post('/pdf/explain', {
      'file_b64': base64Encode(bytes),
      'file_name': fileName,
      'lang': lang,
    });
    return (res['text'] ?? '').toString();
  }

  @override
  Future<String> generateExam({
    required Uint8List bytes,
    required String fileName,
    required String lang,
    required int count,
    required String difficulty,
  }) async {
    final res = await _post('/pdf/exam', {
      'file_b64': base64Encode(bytes),
      'file_name': fileName,
      'lang': lang,
      'count': count,
      'difficulty': difficulty,
    });
    return (res['text'] ?? '').toString();
  }
}

/// Offline sample answers so the app is usable (and demo-able) with no server.
class MockAiService implements AiService {
  Future<void> _wait() => Future.delayed(const Duration(milliseconds: 900));

  @override
  Future<String> chat(List<ChatMsg> history, {required String lang}) async {
    await _wait();
    final last = history.isNotEmpty ? history.last.content : '';
    if (lang == 'ar') {
      return 'ده رد تجريبي (Demo). سؤالك كان: "$last".\n\nلما توصّل التطبيق بسيرفر الـ AI هتاخد شرح حقيقي وحل خطوة بخطوة.';
    }
    return 'This is a demo reply. Your question was: "$last".\n\nOnce the app is connected to your AI server you will get a real explanation and step-by-step solutions.';
  }

  @override
  Future<List<ScheduleItem>> parseTimetable({
    required Uint8List bytes,
    required String fileName,
    required List<String> courses,
  }) async {
    await _wait();
    // Sample schedule built from the course names only (demo).
    const days = [6, 7, 1, 2, 3];
    final out = <ScheduleItem>[];
    for (var i = 0; i < courses.length; i++) {
      final day = days[i % days.length];
      final startH = 9 + (i % 4) * 2;
      out.add(ScheduleItem(
        id: newId(),
        course: courses[i],
        type: 'lecture',
        day: day,
        start: startH * 60,
        end: startH * 60 + 90,
        place: 'Hall ${i + 1}',
      ));
      out.add(ScheduleItem(
        id: newId(),
        course: courses[i],
        type: 'section',
        day: days[(i + 2) % days.length],
        start: (startH + 1) * 60,
        end: (startH + 1) * 60 + 60,
        place: 'Lab ${i + 1}',
      ));
    }
    return out;
  }

  @override
  Future<String> explainPdf({
    required Uint8List bytes,
    required String fileName,
    required String lang,
  }) async {
    await _wait();
    if (lang == 'ar') {
      return 'شرح تجريبي لملف "$fileName":\n\n1) الفكرة الأساسية للمحاضرة.\n2) أهم المصطلحات.\n3) مثال مبسط.\n\nالشرح الحقيقي هيظهر بعد ربط التطبيق بسيرفر الـ AI.';
    }
    return 'Demo explanation for "$fileName":\n\n1) Main idea of the lecture.\n2) Key terms.\n3) A simple example.\n\nThe real explanation appears once the app is connected to your AI server.';
  }

  @override
  Future<String> generateExam({
    required Uint8List bytes,
    required String fileName,
    required String lang,
    required int count,
    required String difficulty,
  }) async {
    await _wait();
    final b = StringBuffer();
    if (lang == 'ar') {
      b.writeln('امتحان تجريبي ($count سؤال - $difficulty) من "$fileName":\n');
      for (var i = 1; i <= (count < 3 ? count : 3); i++) {
        b.writeln('س$i) سؤال تجريبي رقم $i؟');
        b.writeln('   أ) اختيار 1    ب) اختيار 2    ج) اختيار 3    د) اختيار 4\n');
      }
      b.writeln('الأسئلة الحقيقية هتتولد من محتوى الملف بعد ربط السيرفر.');
    } else {
      b.writeln('Demo exam ($count questions - $difficulty) from "$fileName":\n');
      for (var i = 1; i <= (count < 3 ? count : 3); i++) {
        b.writeln('Q$i) Sample question number $i?');
        b.writeln('   a) Option 1    b) Option 2    c) Option 3    d) Option 4\n');
      }
      b.writeln('Real questions are generated from the file content once the server is connected.');
    }
    return b.toString();
  }
}
