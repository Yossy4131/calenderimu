import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase認証を管理するサービスクラス
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: []);

  /// 現在のユーザーを取得
  User? get currentUser => _auth.currentUser;

  /// 現在のユーザーIDを取得（nullの場合はdefault_user）
  String get currentUserId => _auth.currentUser?.uid ?? 'default_user';

  /// 認証状態のストリーム
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Googleアカウントでサインイン
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Googleサインインフローを開始
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // ユーザーがサインインをキャンセル
        return null;
      }

      // 認証情報を取得
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 認証情報からクレデンシャルを作成
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebaseにサインイン
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign-In error: $e');
      rethrow;
    }
  }

  /// サインアウト
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      print('Sign-out error: $e');
      rethrow;
    }
  }

  /// メールアドレスで新規登録
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Email sign-up error: $e');
      rethrow;
    }
  }

  /// メールアドレスでサインイン
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Email sign-in error: $e');
      rethrow;
    }
  }

  /// 匿名サインイン（開発/テスト用）
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print('Anonymous sign-in error: $e');
      rethrow;
    }
  }
}
