import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Initializes Firebase only when explicitly requested for local development.
/// This intentionally uses a demo project so emulator mode cannot silently
/// fall through to live Firebase resources.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static const bool _useEmulators = bool.fromEnvironment(
    'ADLEASE_USE_FIREBASE_EMULATORS',
    defaultValue: false,
  );
  static const String _configuredHost = String.fromEnvironment(
    'ADLEASE_FIREBASE_EMULATOR_HOST',
    defaultValue: '',
  );

  static bool get isEnabled => _useEmulators;

  static Future<void> initialize() async {
    if (!_useEmulators) return;
    if (!kDebugMode) {
      throw StateError(
        'Firebase Emulator mode is only permitted in debug builds.',
      );
    }

    final host = _configuredHost.isNotEmpty
        ? _configuredHost
        : (defaultTargetPlatform == TargetPlatform.android
              ? '10.0.2.2'
              : '127.0.0.1');

    await Firebase.initializeApp(demoProjectId: 'demo-adlease');

    // Connect every client SDK used by the current backend foundation.
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
  }
}
