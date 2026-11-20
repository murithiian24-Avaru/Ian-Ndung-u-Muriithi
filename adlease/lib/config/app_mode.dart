import 'package:flutter/foundation.dart';

/// Explicit application mode, chosen at build time with
/// `--dart-define=APP_MODE=demo` or `--dart-define=APP_MODE=firebase_emulator`.
///
/// There is deliberately no "auto" value and no runtime switching: a Firebase
/// error must never change the mode (no silent fallback to demo).
///
/// Release builds reject BOTH modes. No production mode exists yet; adding one
/// needs a separate, explicitly approved change.
enum AppMode { demo, firebaseEmulator }

class AppModeException implements Exception {
  const AppModeException(this.message);

  final String message;

  @override
  String toString() => 'AppModeException: $message';
}

extension AppModeX on AppMode {
  /// Demo mode must always be visibly marked in the UI.
  bool get showsDemoMarker => this == AppMode.demo;

  bool get usesFirebase => this == AppMode.firebaseEmulator;
}

const String _kRawAppMode = String.fromEnvironment('APP_MODE');

/// Pure resolver, kept separate from the build environment so it can be tested.
///
/// Outside release builds an unset value keeps today's behaviour (demo).
/// Unknown values are rejected loudly. Release builds are always rejected.
AppMode resolveAppMode({required String raw, required bool isReleaseBuild}) {
  if (isReleaseBuild) {
    throw const AppModeException(
      'Release builds are not supported in this phase: neither demo nor '
      'firebase_emulator mode may ship, and no production mode exists yet.',
    );
  }
  final value = raw.isEmpty ? 'demo' : raw;
  switch (value) {
    case 'demo':
      return AppMode.demo;
    case 'firebase_emulator':
      return AppMode.firebaseEmulator;
    default:
      throw AppModeException(
        'Unknown APP_MODE "$value". Use "demo" or "firebase_emulator".',
      );
  }
}

AppMode currentAppMode() =>
    resolveAppMode(raw: _kRawAppMode, isReleaseBuild: kReleaseMode);
