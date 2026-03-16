import 'package:flutter/material.dart';
import '../utils/calendar_utils.dart';
import '../widgets/calendar_header.dart';
import '../widgets/calendar_grid.dart';
import '../services/tinnitus_service.dart';
import '../models/tinnitus_data.dart';
import 'date_detail_screen.dart';

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
  final TinnitusService _tinnitusService = TinnitusService();
  Map<String, TinnitusData> _tinnitusDataMap = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentYear = now.year;
    _currentMonth = now.month;
    _loadMonthData();
  }

  /// 月のデータを読み込む
  Future<void> _loadMonthData() async {
    setState(() {
      _isLoading = true;
    });

    final data = await _tinnitusService.getTinnitusDataForMonth(
      _currentYear,
      _currentMonth,
    );

    setState(() {
      _tinnitusDataMap = data;
      _isLoading = false;
    });
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
    _loadMonthData();
  }

  /// 次月に移動
  void _goToNextMonth() {
    setState(() {
      final next = CalendarUtils.getNextMonth(_currentYear, _currentMonth);
      _currentYear = next.year;
      _currentMonth = next.month;
    });
    _loadMonthData();
  }

  /// 今日の日付に移動
  void _goToToday() {
    setState(() {
      final now = DateTime.now();
      _currentYear = now.year;
      _currentMonth = now.month;
      _selectedDate = now;
    });
    _loadMonthData();
  }

  /// 日付がタップされた時の処理
  void _onDayTapped(DateTime date) async {
    setState(() {
      _selectedDate = date;
    });

    // 日付詳細画面に遷移
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DateDetailScreen(date: date)),
    );

    // 戻ってきたらデータを再読み込み
    _loadMonthData();
  }

  @override
  Widget build(BuildContext context) {
    // カレンダーの日付リストを生成
    final days = CalendarUtils.generateCalendarDays(
      year: _currentYear,
      month: _currentMonth,
      selectedDate: _selectedDate,
      tinnitusDataMap: _tinnitusDataMap,
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

            // ローディングインジケーター
            if (_isLoading) const LinearProgressIndicator(minHeight: 2),

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
