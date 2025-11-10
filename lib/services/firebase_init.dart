import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../firebase_options.dart';

/// Completer that completes when Firebase init finishes (true = success)
final Completer<bool> firebaseInitCompleter = Completer<bool>();

/// Initialize Firebase safely across platforms.
///
/// - On web we require the `DefaultFirebaseOptions`.
/// - On mobile/desktop we try native initialization first and fall back to
///   `DefaultFirebaseOptions` if native config isn't present.
Future<void> safeInitializeFirebase() async {
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      try {
        // Try native config (google-services.json / GoogleService-Info.plist)
        await Firebase.initializeApp();
      } catch (_) {
        // Fallback to generated options if native config missing
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    }

    // Configure storage retry timings (no await, these are void)
    FirebaseStorage.instance.setMaxUploadRetryTime(const Duration(seconds: 15));
    FirebaseStorage.instance.setMaxOperationRetryTime(const Duration(seconds: 15));

    // Configure Firestore with a reasonable cache to reduce long ops
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 10485760, // 10 MB
    );

    if (!firebaseInitCompleter.isCompleted) firebaseInitCompleter.complete(true);
    print('safeInitializeFirebase: Firebase initialized successfully');
  } catch (e, st) {
    if (!firebaseInitCompleter.isCompleted) firebaseInitCompleter.complete(false);
    print('safeInitializeFirebase: Firebase init error: $e\n$st');
  }
}

/// Wait for Firebase initialization to finish (with timeout).
/// Returns true on success, false on failure/timeout.
Future<bool> ensureFirebaseInitialized({Duration timeout = const Duration(seconds: 10)}) async {
  try {
    return await firebaseInitCompleter.future.timeout(timeout, onTimeout: () => false);
  } catch (_) {
    return false;
  }
}
