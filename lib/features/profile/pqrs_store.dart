import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epub_reader/features/analytics/app_analytics.dart';
import 'package:epub_reader/features/profile/pqrs.dart';
import 'package:flutter/foundation.dart';

/// Writes a PQRS into the `pqrs` collection.
///
/// The write waits for the server. A phone without Firebase, or a write that
/// does not finish, throws so the form can stay open.
class FirestorePqrsChannel extends PqrsChannel {
  const FirestorePqrsChannel({this.firestore});

  final FirebaseFirestore? firestore;

  @override
  Future<void> submit(PqrsDraft draft, {required String locale}) async {
    if (firestore == null && !firebaseReady) {
      throw StateError('Firebase is not ready');
    }
    final store = firestore ?? FirebaseFirestore.instance;
    await store
        .collection(pqrsCollection)
        .add({
          ...pqrsFields(draft, platform: pqrsPlatform(), locale: locale),
          'createdAt': FieldValue.serverTimestamp(),
        })
        .timeout(const Duration(seconds: 20));
  }
}

String pqrsPlatform() {
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS => 'ios',
    TargetPlatform.android => 'android',
    _ => defaultTargetPlatform.name,
  };
}
