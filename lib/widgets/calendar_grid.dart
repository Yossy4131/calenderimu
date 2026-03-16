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
      child: Container(
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
            // 耳鳴りデータのインジケーター
            if (day.tinnitusData?.hasAnyData ?? false)
              const SizedBox(height: 2),
            if (day.tinnitusData?.hasAnyData ?? false)
              _buildTinnitusIndicator(day),
          ],
        ),
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
