import 'package:firebase_auth/firebase_auth.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    _validateCredentials(email: email, password: password);

    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_messageForCode(error.code));
    }
  }

  Future<UserCredential> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _validateCredentials(email: email, password: password);

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final normalizedDisplayName = displayName?.trim();
      if (normalizedDisplayName != null && normalizedDisplayName.isNotEmpty) {
        await credential.user?.updateDisplayName(normalizedDisplayName);
      }

      return credential;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_messageForCode(error.code));
    }
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  void _validateCredentials({required String email, required String password}) {
    if (email.trim().isEmpty) {
      throw const AuthFailure('E-posta alanı boş bırakılamaz.');
    }

    if (password.isEmpty) {
      throw const AuthFailure('Şifre alanı boş bırakılamaz.');
    }

    if (password.length < 6) {
      throw const AuthFailure('Şifre en az 6 karakter olmalıdır.');
    }
  }

  String _messageForCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Geçerli bir e-posta adresi giriniz.';
      case 'user-disabled':
        return 'Bu kullanıcı hesabı devre dışı bırakılmış.';
      case 'user-not-found':
        return 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor.';
      case 'weak-password':
        return 'Şifre en az 6 karakter olmalıdır.';
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin.';
      default:
        return 'İşlem başarısız oldu. Lütfen tekrar deneyin.';
    }
  }
}
