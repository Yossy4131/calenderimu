import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

/// データクリーンアップサービス
/// 2ヶ月以上前のデータを自動削除する
class DataCleanupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  static const String _lastCleanupKey = 'last_cleanup_date';
  static const int _dataRetentionMonths = 2;

  /// ユーザーIDを取得
  String get _userId => _authService.currentUserId;

  /// データクリーンアップを実行（1日1回のみ）
  /// アプリ起動時に呼び出すことを想定
  Future<void> performCleanupIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCleanupDate = prefs.getString(_lastCleanupKey);
      final today = DateTime.now();
      final todayKey = _formatDateKey(today);

      // 今日既にクリーンアップ済みの場合はスキップ
      if (lastCleanupDate == todayKey) {
        print('Data cleanup already performed today');
        return;
      }

      // 毎月1日にのみクリーンアップを実行
      if (today.day == 1) {
        print('Performing monthly data cleanup...');
        await _cleanupOldData(today);

        // クリーンアップ実行日を保存
        await prefs.setString(_lastCleanupKey, todayKey);
        print('Data cleanup completed');
      }
    } catch (e) {
      print('Error during data cleanup: $e');
      // クリーンアップエラーはアプリの動作を妨げない
    }
  }

  /// 強制的にデータクリーンアップを実行（テスト用）
  Future<void> forceCleanup() async {
    try {
      final today = DateTime.now();
      print('Forcing data cleanup...');
      await _cleanupOldData(today);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastCleanupKey, _formatDateKey(today));
      print('Forced cleanup completed');
    } catch (e) {
      print('Error during forced cleanup: $e');
      rethrow;
    }
  }

  /// 2ヶ月以上前のデータを削除
  Future<void> _cleanupOldData(DateTime today) async {
    // 2ヶ月前の月の1日を計算
    final twoMonthsAgo = DateTime(
      today.year,
      today.month - _dataRetentionMonths,
      1,
    );
    final cutoffDate = DateTime(twoMonthsAgo.year, twoMonthsAgo.month, 1);
    final cutoffDateKey = _formatDateKey(cutoffDate);

    print('Deleting data older than: $cutoffDateKey');

    // 各コレクションから古いデータを削除
    await Future.wait([
      _deleteOldDocuments('tinnitus_records', cutoffDateKey),
      _deleteOldDocuments('medication_records', cutoffDateKey),
      _deleteOldDocuments('notes', cutoffDateKey),
      _deleteOldPeriodDocuments(cutoffDateKey),
    ]);
  }

  /// 指定したコレクションから古いドキュメントを削除
  Future<void> _deleteOldDocuments(
    String collectionName,
    String cutoffDateKey,
  ) async {
    try {
      final collectionRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection(collectionName);

      // すべてのドキュメントを取得
      final querySnapshot = await collectionRef.get();

      int deletedCount = 0;
      final batch = _firestore.batch();

      for (final doc in querySnapshot.docs) {
        // ドキュメントIDが日付キー（YYYY-MM-DD形式）と仮定
        final docId = doc.id;

        // cutoffDateKeyより古いデータを削除
        if (docId.compareTo(cutoffDateKey) < 0) {
          batch.delete(doc.reference);
          deletedCount++;
        }
      }

      if (deletedCount > 0) {
        await batch.commit();
        print('Deleted $deletedCount documents from $collectionName');
      }
    } catch (e) {
      print('Error deleting old documents from $collectionName: $e');
    }
  }

  /// 生理期間データから古いドキュメントを削除
  Future<void> _deleteOldPeriodDocuments(String cutoffDateKey) async {
    try {
      final collectionRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('period_records');

      final querySnapshot = await collectionRef.get();

      int deletedCount = 0;
      final batch = _firestore.batch();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final startDate = data['startDate'] as String?;
        final endDate = data['endDate'] as String?;

        // 開始日が削除対象期間より前で、かつ終了日があり削除対象期間より前の場合に削除
        if (startDate != null && startDate.compareTo(cutoffDateKey) < 0) {
          // 期間が終了していて、終了日も削除対象期間より前の場合のみ削除
          if (endDate != null && endDate.compareTo(cutoffDateKey) < 0) {
            batch.delete(doc.reference);
            deletedCount++;
          }
        }
      }

      if (deletedCount > 0) {
        await batch.commit();
        print('Deleted $deletedCount documents from period_records');
      }
    } catch (e) {
      print('Error deleting old period documents: $e');
    }
  }

  /// 日付をYYYY-MM-DD形式の文字列に変換
  String _formatDateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// 現在保持しているデータの最も古い日付を取得（デバッグ用）
  Future<String?> getOldestDataDate() async {
    try {
      String? oldestDate;

      // 各コレクションの最も古いドキュメントを確認
      final collections = [
        'tinnitus_records',
        'medication_records',
        'notes',
        'period_records',
      ];

      for (final collectionName in collections) {
        final collectionRef = _firestore
            .collection('users')
            .doc(_userId)
            .collection(collectionName);

        final querySnapshot = await collectionRef
            .orderBy(FieldPath.documentId)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final docId = querySnapshot.docs.first.id;
          if (oldestDate == null || docId.compareTo(oldestDate) < 0) {
            oldestDate = docId;
          }
        }
      }

      return oldestDate;
    } catch (e) {
      print('Error getting oldest data date: $e');
      return null;
    }
  }
}
