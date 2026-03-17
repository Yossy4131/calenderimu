import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'calendar_screen.dart';
import '../services/data_cleanup_service.dart';
import '../constants/app_constants.dart';

/// ホーム画面（ボトムナビゲーションバー付き）
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DataCleanupService _cleanupService = DataCleanupService();

  @override
  void initState() {
    super.initState();
    // アプリ起動時に古いデータをクリーンアップ
    _performDataCleanup();
  }

  /// データクリーンアップを実行
  Future<void> _performDataCleanup() async {
    try {
      await _cleanupService.performCleanupIfNeeded();
    } catch (e) {
      if (kDebugMode) {
        print('Data cleanup error: $e');
      }
      // エラーが発生してもアプリの動作には影響させない
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CalendarScreen());
  }
}
