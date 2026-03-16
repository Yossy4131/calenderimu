import 'package:flutter/material.dart';
import '../models/calendar_day.dart';
import '../utils/calendar_utils.dart';

/// カレンダーのグリッド表示ウィジェット
class CalendarGrid extends StatelessWidget {
  /// 表示する日付のリスト
  final List<CalendarDay> days;

  /// 日付がタップされた時のコールバック
  final Function(DateTime) onDayTapped;

  const CalendarGrid({
    super.key,
    required this.days,
    required this.onDayTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 曜日ヘッダー
        _buildWeekdayHeader(context),

        // 日付グリッド
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              return _buildDayCell(context, days[index]);
            },
          ),
        ),
      ],
    );
  }

  /// 曜日ヘッダーを構築
  Widget _buildWeekdayHeader(BuildContext context) {
    final weekdayNames = CalendarUtils.getWeekdayNames();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: weekdayNames.map((name) {
          return Expanded(
            child: Center(
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getWeekdayColor(name),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 日付セルを構築
  Widget _buildDayCell(BuildContext context, CalendarDay day) {
    final theme = Theme.of(context);
    final isWeekend =
        day.date.weekday == DateTime.saturday ||
        day.date.weekday == DateTime.sunday;

    Color textColor;
    if (!day.isCurrentMonth) {
      textColor = Colors.grey.shade400;
    } else if (isWeekend) {
      if (day.date.weekday == DateTime.sunday) {
        textColor = Colors.red.shade700;
      } else {
        textColor = Colors.blue.shade700;
      }
    } else {
      textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    }

    return InkWell(
      onTap: () => onDayTapped(day.date),
      borderRadius: BorderRadius.circular(8.0),
      child: Stack(
        children: [
          // メインコンテナ
          Container(
            decoration: BoxDecoration(
              color: _getCellBackgroundColor(day, theme),
              borderRadius: BorderRadius.circular(20.0), // より丸みを帯びたデザイン
              border: day.isToday && !day.isSelected
                  ? Border.all(color: const Color(0xFF1DA1F2), width: 2.0)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 日付
                Text(
                  '${day.date.day}',
                  style: TextStyle(
                    color: day.isSelected ? Colors.white : textColor,
                    fontWeight: day.isToday || day.isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                // 生理期間のインジケーター（開始日のみ表示）
                if (day.periodStatus == PeriodStatus.start ||
                    day.periodStatus == PeriodStatus.startConfirmed)
                  const SizedBox(height: 2),
                if (day.periodStatus == PeriodStatus.start ||
                    day.periodStatus == PeriodStatus.startConfirmed)
                  Icon(
                    Icons.water_drop,
                    size: 12,
                    color: day.isSelected ? Colors.white : Colors.pink.shade400,
                  ),
                // 耳鳴りデータのインジケーター
                if (day.tinnitusData?.hasAnyData ?? false)
                  const SizedBox(height: 2),
                if (day.tinnitusData?.hasAnyData ?? false)
                  _buildTinnitusIndicator(day),
              ],
            ),
          ),
          // 生理期間の横棒
          if (day.periodStatus != null &&
              day.periodStatus != PeriodStatus.start)
            _buildPeriodBar(day),
        ],
      ),
    );
  }

  /// 耳鳴りデータのインジケーターを構築
  Widget _buildTinnitusIndicator(CalendarDay day) {
    final data = day.tinnitusData;
    if (data == null || !data.hasAnyData) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (data.morningLevel != null) _buildLevelDot(data.morningLevel!),
        if (data.afternoonLevel != null) _buildLevelDot(data.afternoonLevel!),
        if (data.eveningLevel != null) _buildLevelDot(data.eveningLevel!),
      ],
    );
  }

  /// レベルドットを構築
  Widget _buildLevelDot(int level) {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: _getLevelColor(level),
        shape: BoxShape.circle,
      ),
    );
  }

  /// レベルに応じた色を取得
  Color _getLevelColor(int level) {
    if (level <= 3) {
      return Colors.green;
    } else if (level <= 6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// 生理期間の横棒を構築
  Widget _buildPeriodBar(CalendarDay day) {
    // 期間中と終了日で横棒の形状を変える
    BorderRadius borderRadius;
    EdgeInsets margin;

    if (day.periodStatus == PeriodStatus.startConfirmed) {
      // 開始日（期間確定）：左側のみ丸める
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(2),
        bottomLeft: Radius.circular(2),
      );
      margin = EdgeInsets.zero;
    } else if (day.periodStatus == PeriodStatus.during) {
      // 期間中：左右いっぱいに横棒を表示（連続して見える）
      borderRadius = BorderRadius.zero;
      margin = EdgeInsets.zero;
    } else if (day.periodStatus == PeriodStatus.end) {
      // 終了日：右側のみ丸める
      borderRadius = const BorderRadius.only(
        topRight: Radius.circular(2),
        bottomRight: Radius.circular(2),
      );
      margin = EdgeInsets.zero;
    } else {
      // デフォルト
      borderRadius = BorderRadius.circular(2);
      margin = const EdgeInsets.symmetric(horizontal: 4);
    }

    return Positioned(
      bottom: 4,
      left: 0,
      right: 0,
      child: Container(
        height: 4,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.pink.shade400,
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  /// セルの背景色を取得
  Color _getCellBackgroundColor(CalendarDay day, ThemeData theme) {
    if (day.isSelected) {
      return const Color(0xFF1DA1F2); // Twitterブルー
    }
    if (day.isToday) {
      return const Color(0xFF1DA1F2).withOpacity(0.08);
    }
    return Colors.transparent;
  }

  /// 曜日の色を取得
  Color _getWeekdayColor(String weekdayName) {
    if (weekdayName == '日') {
      return Colors.red.shade700;
    } else if (weekdayName == '土') {
      return Colors.blue.shade700;
    } else {
      return Colors.black87;
    }
  }
}
