/// Backend API configuration.
///
/// Override at build/run time with `--dart-define=API_BASE_URL=...`.
/// The default targets `10.0.2.2`, which the Android emulator resolves to
/// the host machine's `localhost` (use `localhost` for iOS simulator/desktop,
/// or a LAN IP for a physical device).
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 5);
}
