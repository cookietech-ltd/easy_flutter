class AppSettings {
  final String baseUrl;
  final int appVersionCode;
  final String appVersionName;
  final bool enableLogging;

  AppSettings({
    required this.baseUrl,
    required this.appVersionCode,
    required this.appVersionName,
    this.enableLogging = false,
  });

  /// Factory method for development settings
  factory AppSettings.dev() {
    return AppSettings(
      baseUrl: 'https://dev.api.example.com',
      appVersionCode: 1,
      appVersionName: '1.0.0-dev',
      enableLogging: true,
    );
  }

  /// Factory method for production settings
  factory AppSettings.prod() {
    return AppSettings(
      baseUrl: 'https://api.example.com',
      appVersionCode: 100,
      appVersionName: '1.0.0',
      enableLogging: false,
    );
  }

  @override
  String toString() {
    return 'AppSettings(baseUrl: $baseUrl, appVersionCode: $appVersionCode, appVersionName: $appVersionName, enableLogging: $enableLogging)';
  }
}
