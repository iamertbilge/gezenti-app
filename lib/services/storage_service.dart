import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadPostImage({
    required File imageFile,
    required String userId,
    required void Function(double progress) onProgress,
  }) async {
    final millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref().child(
      'posts/$userId/$millisecondsSinceEpoch.jpg',
    );
    final uploadTask = ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    late final StreamSubscription<TaskSnapshot> subscription;
    subscription = uploadTask.snapshotEvents.listen((snapshot) {
      final totalBytes = snapshot.totalBytes;
      final progress = totalBytes <= 0
          ? 0.0
          : (snapshot.bytesTransferred / totalBytes).clamp(0.0, 1.0);

      onProgress(progress.toDouble());
    });

    try {
      await uploadTask;
      onProgress(1.0);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } finally {
      await subscription.cancel();
    }
  }
}
