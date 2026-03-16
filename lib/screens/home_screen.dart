import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'tinnitus_chart_screen.dart';

/// ホーム画面（ボトムナビゲーションバー付き）
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // 画面リスト
  final List<Widget> _screens = [
    const CalendarScreen(),
    const TinnitusChartScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF1DA1F2),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'カレンダー',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'グラフ'),
        ],
      ),
    );
  }
}
