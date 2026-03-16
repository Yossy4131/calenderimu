import 'package:flutter/material.dart';
import '../utils/calendar_utils.dart';

/// カレンダーのヘッダー（年月表示と前後月移動ボタン）
class CalendarHeader extends StatelessWidget {
  /// 表示する年
  final int year;

  /// 表示する月（1-12）
  final int month;

  /// 前月ボタンが押された時のコールバック
  final VoidCallback onPreviousMonth;

  /// 次月ボタンが押された時のコールバック
  final VoidCallback onNextMonth;

  /// 今日ボタンが押された時のコールバック
  final VoidCallback onToday;

  const CalendarHeader({
    super.key,
    required this.year,
    required this.month,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 前月ボタン
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPreviousMonth,
            tooltip: '前月',
          ),

          // 年月表示
          Expanded(
            child: Center(
              child: Text(
                '$year年 ${CalendarUtils.getMonthName(month)}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 今日ボタン
          TextButton(onPressed: onToday, child: const Text('今日')),

          // 次月ボタン
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNextMonth,
            tooltip: '次月',
          ),
        ],
      ),
    );
  }
}
