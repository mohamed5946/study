# Student Assistant (Phase 1)

Flutter app for Android. Liquid Glass design, Arabic/English (RTL), dark/light mode.

## What is in this version
- Home: greeting, next class, today's classes, quick actions
- Schedule: week view (Sat to Fri), add/delete classes, import a timetable (PDF/image) + registered courses, review then save
- AI chat: history saved on the device
- Study: upload a PDF, explain it, generate an exam (count + difficulty)
- Settings: language, theme, reduce animations

## What is NOT in this version yet
- Login / accounts (Supabase)
- Class reminders (notifications)
- Phases 2 to 4 features

## Build the APK

### Option A: no installs (GitHub Actions)
1. Create a GitHub repo and upload this folder.
2. Go to Actions > "Build APK" > Run workflow.
3. Download `student-assistant-apk` from the finished run and install the APK on your phone.

### Option B: on your computer (needs Flutter installed)
```
bash setup.sh
flutter run                       # on a connected phone or emulator
flutter build apk --release       # APK at build/app/outputs/flutter-apk/app-release.apk
```
(Windows: run the steps inside `setup.sh` by hand, or use Git Bash / WSL.)

## Demo mode vs real AI
Without a server the app is in **demo mode**: chat, PDF explain, exam and timetable import return sample content, so you can test the design and flow.

To get real AI, build your own small server (it holds the AI key, never the app) and pass its URL:
```
flutter build apk --release --dart-define=AI_BASE_URL=https://your-server.com
```
Endpoints the app calls (POST, JSON):

| Path | Body | Response |
|---|---|---|
| `/chat` | `{messages:[{role,content}], lang}` | `{reply}` |
| `/timetable` | `{file_b64, file_name, courses:[...]}` | `{items:[{course,type,day,start,end,place,instructor}]}` |
| `/pdf/explain` | `{file_b64, file_name, lang}` | `{text}` |
| `/pdf/exam` | `{file_b64, file_name, lang, count, difficulty}` | `{text}` |

`type` is `lecture` or `section`, `day` is 1..7 (Monday = 1), `start`/`end` are `"HH:mm"`.

## Project layout
```
lib/
  main.dart, app.dart
  core/        theme, strings (l10n), state (Riverpod), widgets/ (glass design system)
  models/      ScheduleItem, ChatMsg
  services/    AiService (HTTP + demo implementations)
  features/    home, schedule, ai, study, more, shell
```
