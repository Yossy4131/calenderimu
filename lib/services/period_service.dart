import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/period_data.dart';

/// 生理期間データのFirestore操作を管理するサービスクラス
/// 生理期間は開始日をドキュメントIDとして管理する
class PeriodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'period_records';

  /// ユーザーIDを取得（今は固定値、将来的にはFirebase Authと連携）
  String get _userId => 'default_user';

  /// コレクションの参照を取得
  CollectionReference get _collection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection(_collectionName);
  }

  /// 指定日を含む生理期間を取得
  Future<PeriodData?> getPeriodContainingDate(DateTime date) async {
    try {
      final dateKey = PeriodData.dateKeyFromDateTime(date);
      
      // 全件取得してクライアント側でフィルタリング（インデックス不要）
      final querySnapshot = await _collection.get();

      // 指定日を含む期間を探す
      for (final doc in querySnapshot.docs) {
        final periodData = PeriodData.fromFirestore(doc);
        if (periodData.containsDate(dateKey)) {
          return periodData;
        }
      }

      return null;
    } catch (e) {
      print('Error getting period containing date: $e');
      return null;
    }
  }

  /// 現在進行中の生理期間を取得
  Future<PeriodData?> getOngoingPeriod() async {
    try {
      // 全件取得してクライアント側でフィルタリング（インデックス不要）
      final querySnapshot = await _collection.get();

      // endDateがnullのドキュメントを探す
      PeriodData? ongoingPeriod;
      String? latestStartDate;

      for (final doc in querySnapshot.docs) {
        final periodData = PeriodData.fromFirestore(doc);
        if (periodData.isOngoing) {
          // 複数ある場合は最新のものを選択（開始日が最も遅いもの）
          if (latestStartDate == null || 
              periodData.startDate.compareTo(latestStartDate) > 0) {
            ongoingPeriod = periodData;
            latestStartDate = periodData.startDate;
          }
        }
      }

      return ongoingPeriod;
    } catch (e) {
      print('Error getting ongoing period: $e');
      return null;
    }
  }

  /// 生理期間を開始（指定日から新しい期間を開始）
  Future<void> startPeriod(DateTime date) async {
    try {
      final dateKey = PeriodData.dateKeyFromDateTime(date);
      
      // 既に進行中の期間があれば、前日で終了させる
      final ongoingPeriod = await getOngoingPeriod();
      if (ongoingPeriod != null) {
        final prevDay = date.subtract(const Duration(days: 1));
        final prevDayKey = PeriodData.dateKeyFromDateTime(prevDay);
        await _collection.doc(ongoingPeriod.startDate).update({
          'endDate': prevDayKey,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      // 新しい期間を作成
      final newPeriod = PeriodData(
        startDate: dateKey,
        endDate: null, // 進行中
      );

      await _collection.doc(dateKey).set(newPeriod.toFirestore());
    } catch (e) {
      print('Error starting period: $e');
      rethrow;
    }
  }

  /// 生理期間を終了（進行中の期間を指定日で終了）
  Future<void> endPeriod(DateTime date) async {
    try {
      final dateKey = PeriodData.dateKeyFromDateTime(date);
      
      // 進行中の期間を取得
      final ongoingPeriod = await getOngoingPeriod();
      
      if (ongoingPeriod == null) {
        throw Exception('終了する生理期間が見つかりません');
      }

      // 進行中の期間を指定日で終了
      await _collection.doc(ongoingPeriod.startDate).update({
        'endDate': dateKey,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error ending period: $e');
      rethrow;
    }
  }

  /// 指定月の生理期間データを一括取得
  Future<List<PeriodData>> getPeriodDataForMonth(
    int year,
    int month,
  ) async {
    try {
      // 全件取得してクライアント側でフィルタリング（インデックス不要）
      final querySnapshot = await _collection.get();

      // 月の範囲を計算
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);
      final firstKey = PeriodData.dateKeyFromDateTime(firstDay);
      final lastKey = PeriodData.dateKeyFromDateTime(lastDay);

      // 指定月に関連する期間をフィルタリング
      final List<PeriodData> periodsInMonth = [];
      for (final doc in querySnapshot.docs) {
        final periodData = PeriodData.fromFirestore(doc);
        
        // 開始日が月の範囲内、または期間が月の範囲と重なる場合
        final startDate = periodData.startDate;
        final endDate = periodData.endDate ?? lastKey; // 進行中の場合は月末まで
        
        // 期間が指定月と重なるかチェック
        if ((startDate.compareTo(lastKey) <= 0) && 
            (endDate.compareTo(firstKey) >= 0)) {
          periodsInMonth.add(periodData);
        }
      }

      return periodsInMonth;
    } catch (e) {
      print('Error getting monthly period data: $e');
      return [];
    }
  }

  /// 全ての生理期間データを削除（デバッグ用）
  Future<void> deleteAllPeriods() async {
    try {
      final querySnapshot = await _collection.get();
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting all periods: $e');
      rethrow;
    }
  }

  /// 指定された開始日の生理期間を削除
  Future<void> deletePeriod(String startDateKey) async {
    try {
      await _collection.doc(startDateKey).delete();
    } catch (e) {
      print('Error deleting period: $e');
      rethrow;
    }
  }
}
