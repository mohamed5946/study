/// App-wide configuration.
///
/// The AI backend URL is injected at build time:
///   flutter build apk --release --dart-define=AI_BASE_URL=https://your-server.com
/// When it is empty the app runs in DEMO mode with sample answers.
class AppConfig {
  static const String aiBaseUrl =
      String.fromEnvironment('AI_BASE_URL', defaultValue: '');

  static bool get demo => aiBaseUrl.isEmpty;
}
