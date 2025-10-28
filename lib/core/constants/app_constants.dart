class AppConstants {
  // App Info
  static const String appName = 'Qarz Daftari';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Qarzlarni oson boshqaring';

  // SharedPreferences Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyThemeMode = 'theme_mode';
  static const String keyCurrency = 'currency';

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Currencies
  static const List<String> currencies = ['UZS', 'USD', 'RUB'];
  static const String defaultCurrency = 'UZS';

  // Database
  static const String databaseName = 'qarz_daftari.db';
  static const int databaseVersion = 1;

  // Date Formats
  static const String dateFormat = 'dd.MM.yyyy';
  static const String dateTimeFormat = 'dd.MM.yyyy HH:mm';
}
