import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/calendar_screen.dart';

/// アプリケーションのエントリーポイント
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

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
      home: const CalendarScreen(),
    );
  }
}
