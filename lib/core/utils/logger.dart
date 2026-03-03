import 'package:logger/logger.dart';

/// App-wide logger singleton.
///
/// Uses [PrettyPrinter] in debug mode.
/// In release builds, [Logger] respects [Level.off] to prevent log leakage.
final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  level: const bool.fromEnvironment('dart.vm.product') ? Level.off : Level.trace,
);
