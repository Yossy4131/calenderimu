import 'package:cloud_firestore/cloud_firestore.dart';

/// 耳鳴りデータを表すモデルクラス
class TinnitusData {
  /// 日付（YYYY-MM-DD形式の文字列）
  final String dateKey;

  /// 朝の耳鳴りレベル（1-10、未入力の場合はnull）
  final int? morningLevel;

  /// 昼の耳鳴りレベル（1-10、未入力の場合はnull）
  final int? afternoonLevel;

  /// 夜の耳鳴りレベル（1-10、未入力の場合はnull）
  final int? eveningLevel;

  /// 最終更新日時
  final DateTime? lastUpdated;

  const TinnitusData({
    required this.dateKey,
    this.morningLevel,
    this.afternoonLevel,
    this.eveningLevel,
    this.lastUpdated,
  });

  /// Firestoreドキュメントから変換
  factory TinnitusData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      return TinnitusData(dateKey: doc.id);
    }

    return TinnitusData(
      dateKey: doc.id,
      morningLevel: data['morningLevel'] as int?,
      afternoonLevel: data['afternoonLevel'] as int?,
      eveningLevel: data['eveningLevel'] as int?,
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  /// Firestoreドキュメントに変換
  Map<String, dynamic> toFirestore() {
    return {
      'morningLevel': morningLevel,
      'afternoonLevel': afternoonLevel,
      'eveningLevel': eveningLevel,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  /// DateTimeから日付キーを生成
  static String dateKeyFromDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// コピーを作成（一部プロパティを変更可能）
  TinnitusData copyWith({
    String? dateKey,
    int? morningLevel,
    int? afternoonLevel,
    int? eveningLevel,
    DateTime? lastUpdated,
  }) {
    return TinnitusData(
      dateKey: dateKey ?? this.dateKey,
      morningLevel: morningLevel ?? this.morningLevel,
      afternoonLevel: afternoonLevel ?? this.afternoonLevel,
      eveningLevel: eveningLevel ?? this.eveningLevel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// 平均レベルを計算（入力されている値のみ）
  double? get averageLevel {
    final levels = [
      morningLevel,
      afternoonLevel,
      eveningLevel,
    ].where((level) => level != null).cast<int>().toList();

    if (levels.isEmpty) return null;

    return levels.reduce((a, b) => a + b) / levels.length;
  }

  /// データが入力されているかどうか
  bool get hasAnyData {
    return morningLevel != null ||
        afternoonLevel != null ||
        eveningLevel != null;
  }
}
