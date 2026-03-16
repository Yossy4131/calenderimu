import 'tinnitus_data.dart';

/// 生理期間の状態
enum PeriodStatus {
  /// 期間開始日（endDateがnullの場合、水滴アイコンのみ）
  start,

  /// 期間開始日（endDateがある場合、水滴アイコン + 横棒）
  startConfirmed,

  /// 期間中（開始日と終了日の間）
  during,

  /// 期間終了日
  end,
}

/// カレンダーの日付を表すモデルクラス
class CalendarDay {
  /// 日付
  final DateTime date;

  /// 現在の月に属する日付かどうか
  final bool isCurrentMonth;

  /// 今日かどうか
  final bool isToday;

  /// 選択されているかどうか
  final bool isSelected;

  /// 耳鳴りデータ
  final TinnitusData? tinnitusData;

  /// 生理期間の情報（開始日、期間中、終了日のいずれか）
  final PeriodStatus? periodStatus;

  const CalendarDay({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    this.isSelected = false,
    this.tinnitusData,
    this.periodStatus,
  });

  /// 日付のコピーを作成（一部プロパティを変更可能）
  CalendarDay copyWith({
    DateTime? date,
    bool? isCurrentMonth,
    bool? isToday,
    bool? isSelected,
    TinnitusData? tinnitusData,
    PeriodStatus? periodStatus,
  }) {
    return CalendarDay(
      date: date ?? this.date,
      isCurrentMonth: isCurrentMonth ?? this.isCurrentMonth,
      isToday: isToday ?? this.isToday,
      isSelected: isSelected ?? this.isSelected,
      tinnitusData: tinnitusData ?? this.tinnitusData,
      periodStatus: periodStatus ?? this.periodStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CalendarDay &&
        other.date.year == date.year &&
        other.date.month == date.month &&
        other.date.day == date.day;
  }

  @override
  int get hashCode => date.hashCode;
}
