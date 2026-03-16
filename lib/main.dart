import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

/// アプリケーションのエントリーポイント
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Firebase App Checkの設定（開発中は無効化）
    // 本番環境で有効にする場合は、Firebaseコンソールで適切に設定してください
    if (!kDebugMode) {
      await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider(
          '6LfOBMAqAAAAAIa2_kCKokTh6rXYe4KWVS6fhW9K',
        ),
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.deviceCheck,
      );
    }

    // Firestoreの設定
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(const CalendarApp());
}

/// カレンダーアプリケーションのルートウィジェット
class CalendarApp extends StatelessWidget {
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'カレンダー',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF1DA1F2), // Twitterブルー
          secondary: const Color(0xFF1DA1F2),
          surface: Colors.white,
          background: const Color(0xFFF7F9F9), // 薄いグレー背景
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: const Color(0xFF14171A), // Twitterテキストカラー
          onBackground: const Color(0xFF14171A),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF14171A),
          elevation: 1,
        ),
        dividerColor: const Color(0xFFE1E8ED), // Twitter border color
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

/// 認証状態に応じて適切な画面を表示するラッパーウィジェット
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // 接続待ち
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ユーザーがサインイン済みか確認
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        // 未サインインの場合はログイン画面を表示
        return const LoginScreen();
      },
    );
  }
}
