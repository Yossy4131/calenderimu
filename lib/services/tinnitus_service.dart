import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tinnitus_data.dart';
import 'auth_service.dart';

/// 耳鳴りデータのFirestore操作を管理するサービスクラス
class TinnitusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  static const String _collectionName = 'tinnitus_records';

  /// ユーザーIDを取得
  String get _userId => _authService.currentUserId;

  /// コレクションの参照を取得
  CollectionReference get _collection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection(_collectionName);
  }

  /// 指定日の耳鳴りデータを取得
  Future<TinnitusData?> getTinnitusData(DateTime date) async {
    try {
      final dateKey = TinnitusData.dateKeyFromDateTime(date);
      final doc = await _collection.doc(dateKey).get();

      if (!doc.exists) {
        return null;
      }

      return TinnitusData.fromFirestore(doc);
    } catch (e) {
      print('Error getting tinnitus data: $e');
      return null;
    }
  }

  /// 指定日の耳鳴りデータをストリームで取得
  Stream<TinnitusData?> watchTinnitusData(DateTime date) {
    final dateKey = TinnitusData.dateKeyFromDateTime(date);
    return _collection.doc(dateKey).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return TinnitusData.fromFirestore(doc);
    });
  }

  /// 耳鳴りデータを保存または更新
  Future<void> saveTinnitusData(TinnitusData data) async {
    try {
      await _collection
          .doc(data.dateKey)
          .set(data.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving tinnitus data: $e');
      rethrow;
    }
  }

  /// 朝の耳鳴りレベルを更新
  Future<void> updateMorningLevel(DateTime date, int? level) async {
    try {
      final dateKey = TinnitusData.dateKeyFromDateTime(date);
      await _collection.doc(dateKey).set({
        'morningLevel': level,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating morning level: $e');
      rethrow;
    }
  }

  /// 昼の耳鳴りレベルを更新
  Future<void> updateAfternoonLevel(DateTime date, int? level) async {
    try {
      final dateKey = TinnitusData.dateKeyFromDateTime(date);
      await _collection.doc(dateKey).set({
        'afternoonLevel': level,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating afternoon level: $e');
      rethrow;
    }
  }

  /// 夜の耳鳴りレベルを更新
  Future<void> updateEveningLevel(DateTime date, int? level) async {
    try {
      final dateKey = TinnitusData.dateKeyFromDateTime(date);
      await _collection.doc(dateKey).set({
        'eveningLevel': level,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating evening level: $e');
      rethrow;
    }
  }

  /// 指定月の耳鳴りデータを一括取得
  Future<Map<String, TinnitusData>> getTinnitusDataForMonth(
    int year,
    int month,
  ) async {
    try {
      // 月の最初と最後の日付を計算
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);

      final firstKey = TinnitusData.dateKeyFromDateTime(firstDay);
      final lastKey = TinnitusData.dateKeyFromDateTime(lastDay);

      final querySnapshot = await _collection
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: firstKey)
          .where(FieldPath.documentId, isLessThanOrEqualTo: lastKey)
          .get();

      final Map<String, TinnitusData> dataMap = {};
      for (final doc in querySnapshot.docs) {
        dataMap[doc.id] = TinnitusData.fromFirestore(doc);
      }

      return dataMap;
    } catch (e) {
      print('Error getting monthly tinnitus data: $e');
      return {};
    }
  }

  /// 指定日の耳鳴りデータを削除
  Future<void> deleteTinnitusData(DateTime date) async {
    try {
      final dateKey = TinnitusData.dateKeyFromDateTime(date);
      await _collection.doc(dateKey).delete();
    } catch (e) {
      print('Error deleting tinnitus data: $e');
      rethrow;
    }
  }
}
