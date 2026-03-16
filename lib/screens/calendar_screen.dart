import 'package:flutter/material.dart';
import '../utils/calendar_utils.dart';
import '../widgets/calendar_header.dart';
import '../widgets/calendar_grid.dart';

/// カレンダー画面
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late int _currentYear;
  late int _currentMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentYear = now.year;
    _currentMonth = now.month;
  }

  /// 前月に移動
  void _goToPreviousMonth() {
    setState(() {
      final previous = CalendarUtils.getPreviousMonth(
        _currentYear,
        _currentMonth,
      );
      _currentYear = previous.year;
      _currentMonth = previous.month;
    });
  }

  /// 次月に移動
  void _goToNextMonth() {
    setState(() {
      final next = CalendarUtils.getNextMonth(_currentYear, _currentMonth);
      _currentYear = next.year;
      _currentMonth = next.month;
    });
  }

  /// 今日の日付に移動
  void _goToToday() {
    setState(() {
      final now = DateTime.now();
      _currentYear = now.year;
      _currentMonth = now.month;
      _selectedDate = now;
    });
  }

  /// 日付がタップされた時の処理
  void _onDayTapped(DateTime date) {
    setState(() {
      _selectedDate = date;
    });

    // 選択された日付の詳細を表示
    _showDateDetails(date);
  }

  /// 選択された日付の詳細を表示
  void _showDateDetails(DateTime date) {
    final formattedDate = '${date.year}年${date.month}月${date.day}日';
    final weekdayNames = ['月', '火', '水', '木', '金', '土', '日'];
    final weekday = weekdayNames[date.weekday - 1];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '$weekday曜日',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('閉じる'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // カレンダーの日付リストを生成
    final days = CalendarUtils.generateCalendarDays(
      year: _currentYear,
      month: _currentMonth,
      selectedDate: _selectedDate,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // カレンダーヘッダー
            CalendarHeader(
              year: _currentYear,
              month: _currentMonth,
              onPreviousMonth: _goToPreviousMonth,
              onNextMonth: _goToNextMonth,
              onToday: _goToToday,
            ),

            const Divider(height: 1),

            // カレンダーグリッド
            Expanded(
              child: CalendarGrid(days: days, onDayTapped: _onDayTapped),
            ),
          ],
        ),
      ),
    );
  }
}
