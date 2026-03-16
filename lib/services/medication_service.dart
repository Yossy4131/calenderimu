import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication_data.dart';

/// 薬の服用データのFirestore操作を管理するサービスクラス
class MedicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'medication_records';

  /// ユーザーIDを取得（今は固定値、将来的にはFirebase Authと連携）
  String get _userId => 'default_user';

  /// コレクションの参照を取得
  CollectionReference get _collection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection(_collectionName);
  }

  /// 指定日の服用データを取得
  Future<MedicationData?> getMedicationData(DateTime date) async {
    try {
      final dateKey = MedicationData.dateKeyFromDateTime(date);
      final doc = await _collection.doc(dateKey).get();

      if (!doc.exists) {
        return null;
      }

      return MedicationData.fromFirestore(doc);
    } catch (e) {
      print('Error getting medication data: $e');
      return null;
    }
  }

  /// 指定日の服用データをストリームで取得
  Stream<MedicationData?> watchMedicationData(DateTime date) {
    final dateKey = MedicationData.dateKeyFromDateTime(date);
    return _collection.doc(dateKey).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return MedicationData.fromFirestore(doc);
    });
  }

  /// 服用データを保存または更新
  Future<void> saveMedicationData(MedicationData data) async {
    try {
      await _collection.doc(data.dateKey).set(
            data.toFirestore(),
            SetOptions(merge: true),
          );
    } catch (e) {
      print('Error saving medication data: $e');
      rethrow;
    }
  }

  /// 朝の服用状況を更新
  Future<void> updateMorningTaken(DateTime date, bool taken) async {
    try {
      final dateKey = MedicationData.dateKeyFromDateTime(date);
      await _collection.doc(dateKey).set(
        {
          'morningTaken': taken,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error updating morning medication: $e');
      rethrow;
    }
  }

  /// 昼の服用状況を更新
  Future<void> updateAfternoonTaken(DateTime date, bool taken) async {
    try {
      final dateKey = MedicationData.dateKeyFromDateTime(date);
      await _collection.doc(dateKey).set(
        {
          'afternoonTaken': taken,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error updating afternoon medication: $e');
      rethrow;
    }
  }

  /// 夜の服用状況を更新
  Future<void> updateEveningTaken(DateTime date, bool taken) async {
    try {
      final dateKey = MedicationData.dateKeyFromDateTime(date);
      await _collection.doc(dateKey).set(
        {
          'eveningTaken': taken,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error updating evening medication: $e');
      rethrow;
    }
  }

  /// 指定月の服用データを一括取得
  Future<Map<String, MedicationData>> getMedicationDataForMonth(
    int year,
    int month,
  ) async {
    try {
      // 月の最初と最後の日付を計算
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);

      final firstKey = MedicationData.dateKeyFromDateTime(firstDay);
      final lastKey = MedicationData.dateKeyFromDateTime(lastDay);

      final querySnapshot = await _collection
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: firstKey)
          .where(FieldPath.documentId, isLessThanOrEqualTo: lastKey)
          .get();

      final Map<String, MedicationData> dataMap = {};
      for (final doc in querySnapshot.docs) {
        dataMap[doc.id] = MedicationData.fromFirestore(doc);
      }

      return dataMap;
    } catch (e) {
      print('Error getting monthly medication data: $e');
      return {};
    }
  }

  /// 指定日の服用データを削除
  Future<void> deleteMedicationData(DateTime date) async {
    try {
      final dateKey = MedicationData.dateKeyFromDateTime(date);
      await _collection.doc(dateKey).delete();
    } catch (e) {
      print('Error deleting medication data: $e');
      rethrow;
    }
  }
}
