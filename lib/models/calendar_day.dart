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

  const CalendarDay({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    this.isSelected = false,
  });

  /// 日付のコピーを作成（一部プロパティを変更可能）
  CalendarDay copyWith({
    DateTime? date,
    bool? isCurrentMonth,
    bool? isToday,
    bool? isSelected,
  }) {
    return CalendarDay(
      date: date ?? this.date,
      isCurrentMonth: isCurrentMonth ?? this.isCurrentMonth,
      isToday: isToday ?? this.isToday,
      isSelected: isSelected ?? this.isSelected,
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
