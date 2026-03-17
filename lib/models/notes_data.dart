import 'package:cloud_firestore/cloud_firestore.dart';

/// 備考データを表すモデルクラス
class NotesData {
  /// 日付（YYYY-MM-DD形式の文字列）
  final String dateKey;

  /// 備考内容
  final String? notes;

  /// 最終更新日時
  final DateTime? lastUpdated;

  const NotesData({required this.dateKey, this.notes, this.lastUpdated});

  /// Firestoreドキュメントから変換
  factory NotesData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      return NotesData(dateKey: doc.id);
    }

    return NotesData(
      dateKey: doc.id,
      notes: data['notes'] as String?,
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  /// Firestoreドキュメントに変換
  Map<String, dynamic> toFirestore() {
    return {'notes': notes, 'lastUpdated': FieldValue.serverTimestamp()};
  }

  /// DateTimeから日付キーを生成
  static String dateKeyFromDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// コピーを作成（一部プロパティを変更可能）
  NotesData copyWith({String? dateKey, String? notes, DateTime? lastUpdated}) {
    return NotesData(
      dateKey: dateKey ?? this.dateKey,
      notes: notes ?? this.notes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// データが入力されているかどうか
  bool get hasData {
    return notes != null && notes!.isNotEmpty;
  }
}
