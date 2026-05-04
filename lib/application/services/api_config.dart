/// Base URL for the Lumi HTTP API (courses, tutor, friends, videos, podcasts, etc.).
///
/// **Physical devices:** `http://localhost:3000` is wrong — it targets the
/// phone, not your PC. This project defaults to the hosted dev API so
/// `flutter run` on a real phone works without extra setup.
///
/// **Local backend** (simulator / emulator / LAN phone):
/// ```bash
/// flutter run --dart-define=LUMI_API_BASE_URL=http://localhost:3000
/// # Android emulator → host:
/// flutter run --dart-define=LUMI_API_BASE_URL=http://10.0.2.2:3000
/// # Phone on same Wi‑Fi as your machine (replace with your IP):
/// flutter run --dart-define=LUMI_API_BASE_URL=http://192.168.1.42:3000
/// ```
abstract final class ApiConfig {
  static const String _fromEnvironment = String.fromEnvironment(
    'LUMI_API_BASE_URL',
  );

  /// Prefer [LUMI_API_BASE_URL] when set at compile time; otherwise dev deploy.
  static String get origin => _fromEnvironment.isNotEmpty
      ? _fromEnvironment
      : 'https://lumi-api-dev.onrender.com';
}
