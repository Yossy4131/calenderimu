import 'package:cloud_firestore/cloud_firestore.dart';

/// 生理期間データモデル
/// 生理期間は開始日をドキュメントIDとして管理し、開始日から終了日までの範囲を表す
class PeriodData {
  /// 期間の開始日（YYYY-MM-DD形式、ドキュメントIDとしても使用）
  final String startDate;

  /// 期間の終了日（YYYY-MM-DD形式）
  /// nullの場合は期間が進行中
  final String? endDate;

  /// 最終更新日時
  final DateTime? lastUpdated;

  const PeriodData({required this.startDate, this.endDate, this.lastUpdated});

  /// 期間が進行中かどうか
  bool get isOngoing => endDate == null;

  /// 指定された日付がこの期間内かどうかを判定
  bool containsDate(String dateKey) {
    if (dateKey.compareTo(startDate) < 0) {
      return false; // 開始日より前
    }
    if (endDate == null) {
      return true; // 進行中なので開始日以降は全て含む
    }
    return dateKey.compareTo(endDate!) <= 0; // 終了日以下
  }

  /// Firestoreドキュメントから変換
  factory PeriodData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      return PeriodData(startDate: doc.id);
    }

    return PeriodData(
      startDate: doc.id,
      endDate: data['endDate'] as String?,
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  /// Firestoreドキュメントに変換
  Map<String, dynamic> toFirestore() {
    return {
      'startDate': startDate,
      'endDate': endDate,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  /// DateTimeから日付キーを生成
  static String dateKeyFromDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// コピーを作成（一部プロパティを変更可能）
  PeriodData copyWith({
    String? startDate,
    String? endDate,
    DateTime? lastUpdated,
  }) {
    return PeriodData(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'PeriodData(startDate: $startDate, endDate: $endDate, isOngoing: $isOngoing)';
  }
}
