import 'package:logger/logger.dart';

/// Global logger instance for easy access throughout the app.
/// This allows all components to use a centralized logger without
/// importing from main.dart
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2, // number of method calls to be displayed
    errorMethodCount: 8, // number of method calls if stacktrace is provided
    lineLength: 120, // width of the output
    colors: true, // Colorful log messages
    printEmojis: true, // Print an emoji for each log message
    dateTimeFormat:
        DateTimeFormat.onlyTimeAndSinceStart, // Zaman bilgisini gösterir
    noBoxingByDefault: false, // Logları kutular içinde gösterir
  ),
);

/// Set logger level for the application - call this during app initialization
void configureLogger({required bool isProduction}) {
  Logger.level = isProduction ? Level.info : Level.debug;
}
