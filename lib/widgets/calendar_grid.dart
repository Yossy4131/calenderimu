import 'package:flutter/material.dart';
import '../models/calendar_day.dart';
import '../utils/calendar_utils.dart';
import '../constants/app_constants.dart';

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
        _buildWeekdayHeader(),

        // 日付グリッド
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingSmall),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: AppConstants.calendarGridCrossAxisRatio,
              crossAxisSpacing: AppConstants.calendarGridSpacing,
              mainAxisSpacing: AppConstants.calendarGridSpacing,
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
  Widget _buildWeekdayHeader() {
    final weekdayNames = CalendarUtils.getWeekdayNames();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        children: weekdayNames.map((name) {
          return Expanded(
            child: Center(
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.getWeekdayColor(name),
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
      textColor = day.date.weekday == DateTime.sunday
          ? Colors.red.shade700
          : Colors.blue.shade700;
    } else {
      textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onDayTapped(day.date),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          child: Stack(
            children: [
              // メインコンテナ
              Positioned.fill(
                child: Container(
                  padding: const EdgeInsets.all(2.0),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 日付（今日は青い円、生理開始日はピンク色の円で囲む）
                      Container(
                        width: AppConstants.calendarCellSize,
                        height: AppConstants.calendarCellSize,
                        decoration: day.isToday
                            ? const BoxDecoration(
                                color: AppConstants.primaryColor,
                                shape: BoxShape.circle,
                              )
                            : (day.periodStatus == PeriodStatus.start ||
                                  day.periodStatus ==
                                      PeriodStatus.startConfirmed)
                            ? BoxDecoration(
                                color: Colors.pink.shade400,
                                shape: BoxShape.circle,
                              )
                            : null,
                        child: Center(
                          child: Text(
                            '${day.date.day}',
                            style: TextStyle(
                              color:
                                  (day.isToday ||
                                      day.periodStatus == PeriodStatus.start ||
                                      day.periodStatus ==
                                          PeriodStatus.startConfirmed)
                                  ? Colors.white
                                  : textColor,
                              fontSize: AppConstants.calendarDateFontSize,
                              fontWeight:
                                  day.isToday ||
                                      day.periodStatus == PeriodStatus.start ||
                                      day.periodStatus ==
                                          PeriodStatus.startConfirmed
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),
                      // 耳鳴りデータのインジケーター
                      if (day.tinnitusData?.hasAnyData ?? false)
                        Padding(
                          padding: const EdgeInsets.only(top: 1.0),
                          child: _buildTinnitusIndicator(day),
                        ),
                    ],
                  ),
                ),
              ),
              // 生理期間の横棒
              if (day.periodStatus != null &&
                  day.periodStatus != PeriodStatus.start)
                _buildPeriodBar(day),
            ],
          ),
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
        if (data.morningLevel != null)
          _buildLevelDot(data.morningLevel!, day.isSelected),
        if (data.afternoonLevel != null)
          _buildLevelDot(data.afternoonLevel!, day.isSelected),
        if (data.eveningLevel != null)
          _buildLevelDot(data.eveningLevel!, day.isSelected),
      ],
    );
  }

  /// レベルドットを構築
  Widget _buildLevelDot(int level, bool isOnSelectedDay) {
    return Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: AppColors.getLevelColor(level),
        shape: BoxShape.circle,
      ),
    );
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
}
