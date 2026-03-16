import '../models/calendar_day.dart';
import '../models/tinnitus_data.dart';
import '../models/period_data.dart';

/// カレンダー関連のユーティリティ関数を提供するクラス
class CalendarUtils {
  /// 指定された年月のカレンダーに表示する日付のリストを生成
  ///
  /// [year] 年
  /// [month] 月（1-12）
  /// [selectedDate] 選択されている日付（オプション）
  /// [tinnitusDataMap] 耳鳴りデータのマップ（オプション）
  /// [periodDataList] 生理期間データのリスト（オプション）
  ///
  /// 返り値: カレンダーに表示する日付のリスト（前月末・当月・次月初を含む）
  static List<CalendarDay> generateCalendarDays({
    required int year,
    required int month,
    DateTime? selectedDate,
    Map<String, TinnitusData>? tinnitusDataMap,
    List<PeriodData>? periodDataList,
  }) {
    final List<CalendarDay> days = [];
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final today = DateTime.now();

    // 月の最初の日の曜日（0: 日曜日, 6: 土曜日）
    final int firstWeekday = firstDayOfMonth.weekday % 7;

    // 前月の日付を追加
    final previousMonthLastDay = DateTime(year, month, 0);
    for (int i = firstWeekday - 1; i >= 0; i--) {
      final date = previousMonthLastDay.subtract(Duration(days: i));
      final dateKey = TinnitusData.dateKeyFromDateTime(date);
      days.add(
        CalendarDay(
          date: date,
          isCurrentMonth: false,
          isToday: _isSameDay(date, today),
          isSelected: selectedDate != null && _isSameDay(date, selectedDate),
          tinnitusData: tinnitusDataMap?[dateKey],
          periodStatus: _getPeriodStatus(dateKey, periodDataList),
        ),
      );
    }

    // 当月の日付を追加
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(year, month, day);
      final dateKey = TinnitusData.dateKeyFromDateTime(date);
      days.add(
        CalendarDay(
          date: date,
          isCurrentMonth: true,
          isToday: _isSameDay(date, today),
          isSelected: selectedDate != null && _isSameDay(date, selectedDate),
          tinnitusData: tinnitusDataMap?[dateKey],
          periodStatus: _getPeriodStatus(dateKey, periodDataList),
        ),
      );
    }

    // 次月の日付を追加（6週分 = 42日になるまで）
    final remainingDays = 42 - days.length;
    for (int day = 1; day <= remainingDays; day++) {
      final date = DateTime(year, month + 1, day);
      final dateKey = TinnitusData.dateKeyFromDateTime(date);
      days.add(
        CalendarDay(
          date: date,
          isCurrentMonth: false,
          isToday: _isSameDay(date, today),
          isSelected: selectedDate != null && _isSameDay(date, selectedDate),
          tinnitusData: tinnitusDataMap?[dateKey],
          periodStatus: _getPeriodStatus(dateKey, periodDataList),
        ),
      );
    }

    return days;
  }

  /// 2つの日付が同じ日かどうかを判定
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 指定された日付の生理期間状態を取得
  static PeriodStatus? _getPeriodStatus(
    String dateKey,
    List<PeriodData>? periodDataList,
  ) {
    if (periodDataList == null || periodDataList.isEmpty) {
      return null;
    }

    // dateKeyを含む期間を探す
    for (final periodData in periodDataList) {
      // 開始日の場合
      if (periodData.startDate == dateKey) {
        // endDateがnullの場合（進行中）のみ開始日マークを表示
        if (periodData.endDate == null) {
          return PeriodStatus.start;
        }
        // 開始日と終了日が同じ場合は開始日扱い
        if (periodData.endDate == dateKey) {
          return PeriodStatus.start;
        }
        // 期間がある場合は開始日確定として扱う（水滴アイコン + 横棒）
        return PeriodStatus.startConfirmed;
      }

      // 終了日の場合
      if (periodData.endDate == dateKey) {
        return PeriodStatus.end;
      }

      // 期間中の場合（endDateが確定している場合のみ背景色表示）
      if (periodData.endDate != null && periodData.containsDate(dateKey)) {
        return PeriodStatus.during;
      }
    }

    return null;
  }

  /// 月名を取得（日本語）
  static String getMonthName(int month) {
    const monthNames = [
      '1月',
      '2月',
      '3月',
      '4月',
      '5月',
      '6月',
      '7月',
      '8月',
      '9月',
      '10月',
      '11月',
      '12月',
    ];
    return monthNames[month - 1];
  }

  /// 曜日名を取得（日本語、短縮形）
  static List<String> getWeekdayNames() {
    return ['日', '月', '火', '水', '木', '金', '土'];
  }

  /// 前月の年月を取得
  static ({int year, int month}) getPreviousMonth(int year, int month) {
    if (month == 1) {
      return (year: year - 1, month: 12);
    } else {
      return (year: year, month: month - 1);
    }
  }

  /// 次月の年月を取得
  static ({int year, int month}) getNextMonth(int year, int month) {
    if (month == 12) {
      return (year: year + 1, month: 1);
    } else {
      return (year: year, month: month + 1);
    }
  }
}
