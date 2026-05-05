import 'package:cloud_firestore/cloud_firestore.dart';

import '../database/db_helper.dart';

class FirestoreFailure implements Exception {
  final String message;

  const FirestoreFailure(this.message);
}

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('Users');

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection('Posts');

  Future<void> createOrUpdateUser({
    required String uid,
    required String email,
    String? displayName,
  }) async {
    try {
      final userDocument = _users.doc(uid);
      final snapshot = await userDocument.get();
      final userData = <String, dynamic>{
        'uid': uid,
        'email': email.trim(),
        'displayName': displayName?.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!snapshot.exists) {
        userData['createdAt'] = FieldValue.serverTimestamp();
      }

      await userDocument.set(userData, SetOptions(merge: true));
    } on FirebaseException catch (error) {
      throw FirestoreFailure(_messageForCode(error.code));
    }
  }

  Future<DocumentReference<Map<String, dynamic>>> addPost({
    required String userId,
    required String name,
    required String description,
    required String imagePath,
    required String date,
  }) async {
    try {
      return await _posts.add({
        'userId': userId,
        'name': name,
        'description': description,
        'imagePath': imagePath,
        'date': date,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      throw FirestoreFailure(_messageForCode(error.code));
    }
  }

  Future<DocumentReference<Map<String, dynamic>>> addPostFromPlace({
    required String userId,
    required Place place,
  }) {
    return addPost(
      userId: userId,
      name: place.name,
      description: place.description,
      imagePath: place.imagePath,
      date: place.date,
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> postsStream() {
    try {
      return _posts
          .orderBy('createdAt', descending: true)
          .snapshots()
          .handleError((Object error) {
            if (error is FirebaseException) {
              throw FirestoreFailure(_messageForCode(error.code));
            }

            throw error;
          });
    } on FirebaseException catch (error) {
      throw FirestoreFailure(_messageForCode(error.code));
    }
  }

  Future<List<Map<String, dynamic>>> getPosts() async {
    try {
      final snapshot = await _posts
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((document) => {'id': document.id, ...document.data()})
          .toList();
    } on FirebaseException catch (error) {
      throw FirestoreFailure(_messageForCode(error.code));
    }
  }

  String _messageForCode(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Firestore erişim izni reddedildi. Güvenlik kurallarını kontrol edin.';
      case 'unavailable':
        return 'Firestore servisine ulaşılamıyor. İnternet bağlantınızı kontrol edin.';
      default:
        return 'Firestore işlemi başarısız oldu. Lütfen tekrar deneyin.';
    }
  }
}
