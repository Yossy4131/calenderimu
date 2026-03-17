import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notes_data.dart';

/// 備考データを管理するサービスクラス
class NotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 現在のユーザーIDを取得
  String? get _userId => _auth.currentUser?.uid;

  /// 備考データのコレクション参照を取得
  CollectionReference? _getNotesCollection() {
    final userId = _userId;
    if (userId == null) return null;
    return _firestore.collection('users').doc(userId).collection('notes');
  }

  /// 指定した日付の備考データを取得
  Future<NotesData?> getNotesData(DateTime date) async {
    final collection = _getNotesCollection();
    if (collection == null) return null;

    final dateKey = NotesData.dateKeyFromDateTime(date);
    final doc = await collection.doc(dateKey).get();

    if (!doc.exists) return null;

    return NotesData.fromFirestore(doc);
  }

  /// 備考データを保存
  Future<void> saveNotesData(NotesData data) async {
    final collection = _getNotesCollection();
    if (collection == null) {
      throw Exception('ユーザーが認証されていません');
    }

    await collection
        .doc(data.dateKey)
        .set(data.toFirestore(), SetOptions(merge: true));
  }

  /// 備考データを削除
  Future<void> deleteNotesData(DateTime date) async {
    final collection = _getNotesCollection();
    if (collection == null) return;

    final dateKey = NotesData.dateKeyFromDateTime(date);
    await collection.doc(dateKey).delete();
  }

  /// 指定した日付範囲の備考データを取得
  Future<List<NotesData>> getNotesDataRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final collection = _getNotesCollection();
    if (collection == null) return [];

    final startKey = NotesData.dateKeyFromDateTime(startDate);
    final endKey = NotesData.dateKeyFromDateTime(endDate);

    final querySnapshot = await collection
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: startKey)
        .where(FieldPath.documentId, isLessThanOrEqualTo: endKey)
        .get();

    return querySnapshot.docs
        .map((doc) => NotesData.fromFirestore(doc))
        .toList();
  }

  /// 指定した日付より前の備考データを削除
  Future<void> deleteNotesDataBefore(DateTime date) async {
    final collection = _getNotesCollection();
    if (collection == null) return;

    final dateKey = NotesData.dateKeyFromDateTime(date);

    final querySnapshot = await collection
        .where(FieldPath.documentId, isLessThan: dateKey)
        .get();

    final batch = _firestore.batch();
    for (final doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
