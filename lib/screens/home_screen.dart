import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'tinnitus_chart_screen.dart';
import '../services/auth_service.dart';

/// ホーム画面（ボトムナビゲーションバー付き）
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();

  // 画面リスト
  final List<Widget> _screens = [
    const CalendarScreen(),
    const TinnitusChartScreen(),
  ];

  /// サインアウト処理
  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('サインアウト'),
        content: const Text('サインアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('サインアウト'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _authService.signOut();
        // AuthWrapperがStreamBuilderで自動的にログイン画面に遷移
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('サインアウトエラー: $e')));
        }
      }
    }
  }

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
