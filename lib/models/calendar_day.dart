import 'tinnitus_data.dart';

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

  const CalendarDay({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    this.isSelected = false,
    this.tinnitusData,
  });

  /// 日付のコピーを作成（一部プロパティを変更可能）
  CalendarDay copyWith({
    DateTime? date,
    bool? isCurrentMonth,
    bool? isToday,
    bool? isSelected,
    TinnitusData? tinnitusData,
  }) {
    return CalendarDay(
      date: date ?? this.date,
      isCurrentMonth: isCurrentMonth ?? this.isCurrentMonth,
      isToday: isToday ?? this.isToday,
      isSelected: isSelected ?? this.isSelected,
      tinnitusData: tinnitusData ?? this.tinnitusData,
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
