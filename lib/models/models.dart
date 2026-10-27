/// Parses "HH:mm" (or an int of minutes) into minutes since midnight.
int parseHm(dynamic v, int fallback) {
  if (v is int) return v;
  if (v is String) {
    final m = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(v);
    if (m != null) {
      return int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!);
    }
  }
  return fallback;
}

/// Formats minutes since midnight as "HH:mm".
String fmtHm(int minutes) {
  final h = (minutes ~/ 60) % 24;
  final m = minutes % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

int _idCounter = 0;
String newId() => '${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

/// One lecture or section in the weekly schedule.
/// [day] follows DateTime.weekday (Monday = 1 ... Sunday = 7).
class ScheduleItem {
  final String id;
  final String course;
  final String type; // 'lecture' | 'section'
  final int day;
  final int start; // minutes since midnight
  final int end;
  final String place;
  final String instructor;

  const ScheduleItem({
    required this.id,
    required this.course,
    required this.type,
    required this.day,
    required this.start,
    required this.end,
    this.place = '',
    this.instructor = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'course': course,
        'type': type,
        'day': day,
        'start': start,
        'end': end,
        'place': place,
        'instructor': instructor,
      };

  factory ScheduleItem.fromJson(Map<String, dynamic> j) {
    int day = j['day'] is int ? j['day'] as int : (int.tryParse('${j['day']}') ?? 1);
    if (day < 1) day = 1;
    if (day > 7) day = 7;
    return ScheduleItem(
      id: (j['id'] ?? newId()).toString(),
      course: (j['course'] ?? '').toString(),
      type: j['type'] == 'section' ? 'section' : 'lecture',
      day: day,
      start: parseHm(j['start'], 540),
      end: parseHm(j['end'], 630),
      place: (j['place'] ?? '').toString(),
      instructor: (j['instructor'] ?? '').toString(),
    );
  }
}

/// A chat message. [role] is 'user' or 'assistant'.
class ChatMsg {
  final String role;
  final String content;
  const ChatMsg(this.role, this.content);

  Map<String, dynamic> toJson() => {'role': role, 'content': content};

  factory ChatMsg.fromJson(Map<String, dynamic> j) =>
      ChatMsg((j['role'] ?? 'user').toString(), (j['content'] ?? '').toString());
}
