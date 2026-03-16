import 'package:cloud_firestore/cloud_firestore.dart';

/// 薬の服用データを表すモデルクラス
class MedicationData {
  /// 日付（YYYY-MM-DD形式の文字列）
  final String dateKey;

  /// 朝の服用状況
  final bool morningTaken;

  /// 昼の服用状況
  final bool afternoonTaken;

  /// 夜の服用状況
  final bool eveningTaken;

  /// 最終更新日時
  final DateTime? lastUpdated;

  const MedicationData({
    required this.dateKey,
    this.morningTaken = false,
    this.afternoonTaken = false,
    this.eveningTaken = false,
    this.lastUpdated,
  });

  /// Firestoreドキュメントから変換
  factory MedicationData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      return MedicationData(dateKey: doc.id);
    }

    return MedicationData(
      dateKey: doc.id,
      morningTaken: data['morningTaken'] as bool? ?? false,
      afternoonTaken: data['afternoonTaken'] as bool? ?? false,
      eveningTaken: data['eveningTaken'] as bool? ?? false,
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  /// Firestoreドキュメントに変換
  Map<String, dynamic> toFirestore() {
    return {
      'morningTaken': morningTaken,
      'afternoonTaken': afternoonTaken,
      'eveningTaken': eveningTaken,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  /// DateTimeから日付キーを生成
  static String dateKeyFromDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// コピーを作成（一部プロパティを変更可能）
  MedicationData copyWith({
    String? dateKey,
    bool? morningTaken,
    bool? afternoonTaken,
    bool? eveningTaken,
    DateTime? lastUpdated,
  }) {
    return MedicationData(
      dateKey: dateKey ?? this.dateKey,
      morningTaken: morningTaken ?? this.morningTaken,
      afternoonTaken: afternoonTaken ?? this.afternoonTaken,
      eveningTaken: eveningTaken ?? this.eveningTaken,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// 少なくとも1つでも服用したかどうか
  bool get hasAnyTaken {
    return morningTaken || afternoonTaken || eveningTaken;
  }

  /// すべて服用したかどうか
  bool get allTaken {
    return morningTaken && afternoonTaken && eveningTaken;
  }

  /// 服用回数
  int get takenCount {
    int count = 0;
    if (morningTaken) count++;
    if (afternoonTaken) count++;
    if (eveningTaken) count++;
    return count;
  }
}
