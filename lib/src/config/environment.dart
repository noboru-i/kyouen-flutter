/// Environment configuration using dart-define values
class Environment {
  Environment._();

  /// API base URL
  /// Default: https://kyouen.app/v2/
  /// Dev: https://dev.kyouen.app/v2/ (example)
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://kyouen.app/v2/',
  );

  /// Firebase project ID
  /// Default: my-android-server (production)
  /// Dev: api-project-732262258565-dev (example)
  static const firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'my-android-server',
  );

  /// Environment type
  /// Values: 'dev', 'prod'
  /// Default: 'prod'
  static const environmentType = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'prod',
  );

  /// Whether this is development environment
  static bool get isDevelopment => environmentType == 'dev';

  /// Whether this is production environment
  static bool get isProduction => environmentType == 'prod';

  /// App name with environment prefix
  static String get appName {
    const baseAppName = '詰め共円';
    return isDevelopment ? 'DEV $baseAppName' : baseAppName;
  }
}
