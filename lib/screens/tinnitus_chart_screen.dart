import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/tinnitus_service.dart';
import '../models/tinnitus_data.dart';

/// 耳鳴りレベルのグラフ表示画面
class TinnitusChartScreen extends StatefulWidget {
  const TinnitusChartScreen({super.key});

  @override
  State<TinnitusChartScreen> createState() => _TinnitusChartScreenState();
}

class _TinnitusChartScreenState extends State<TinnitusChartScreen> {
  final TinnitusService _tinnitusService = TinnitusService();
  int _selectedPeriod = 7; // デフォルトは7日間
  List<TinnitusData> _chartData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  /// グラフ用データを読み込む
  Future<void> _loadChartData() async {
    setState(() {
      _isLoading = true;
    });

    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: _selectedPeriod - 1));

    // 期間内の全日付のデータを取得
    final List<TinnitusData> dataList = [];
    for (int i = 0; i < _selectedPeriod; i++) {
      final date = startDate.add(Duration(days: i));
      final data = await _tinnitusService.getTinnitusData(date);
      if (data != null && data.hasAnyData) {
        dataList.add(data);
      } else {
        // データがない日は空のデータとして追加
        dataList.add(
          TinnitusData(dateKey: TinnitusData.dateKeyFromDateTime(date)),
        );
      }
    }

    setState(() {
      _chartData = dataList;
      _isLoading = false;
    });
  }

  /// 期間を変更
  void _changePeriod(int days) {
    setState(() {
      _selectedPeriod = days;
    });
    _loadChartData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            _buildHeader(),
            const Divider(height: 1),

            // 期間選択ボタン
            _buildPeriodSelector(),

            // グラフエリア
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _chartData.isEmpty
                  ? const Center(child: Text('データがありません'))
                  : _buildChart(),
            ),

            // 凡例
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  /// ヘッダーを構築
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(Icons.show_chart, size: 28, color: const Color(0xFF1DA1F2)),
          const SizedBox(width: 12),
          const Text(
            '耳鳴りレベルの推移',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// 期間選択ボタンを構築
  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPeriodButton('7日', 7),
          _buildPeriodButton('14日', 14),
          _buildPeriodButton('30日', 30),
          _buildPeriodButton('90日', 90),
        ],
      ),
    );
  }

  /// 期間ボタンを構築
  Widget _buildPeriodButton(String label, int days) {
    final isSelected = _selectedPeriod == days;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: () => _changePeriod(days),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? const Color(0xFF1DA1F2)
                : Colors.grey.shade200,
            foregroundColor: isSelected ? Colors.white : Colors.black87,
            elevation: isSelected ? 2 : 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  /// グラフを構築
  Widget _buildChart() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 3,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
            },
            getDrawingVerticalLine: (value) {
              return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: _getBottomTitles,
                interval: _selectedPeriod <= 7 ? 3 : (_selectedPeriod / 7 * 3),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: _getLeftTitles,
                interval: 2,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300),
          ),
          minX: 0,
          maxX: (_chartData.length * 3 - 1).toDouble(),
          minY: 0,
          maxY: 10,
          lineBarsData: _buildLineBarsData(),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: _getTooltipItems,
            ),
          ),
        ),
      ),
    );
  }

  /// 下部タイトル（日付）を取得
  Widget _getBottomTitles(double value, TitleMeta meta) {
    // X軸は時間帯ごと（0=1日朝, 1=1日昼, 2=1日夜, 3=2日朝...）
    final index = value.toInt();
    final dayIndex = index ~/ 3; // 日のインデックス
    final timeIndex = index % 3; // 時間帯（0=朝, 1=昼, 2=夜）

    // 朝のポイントのみ日付を表示
    if (timeIndex == 0 && dayIndex >= 0 && dayIndex < _chartData.length) {
      final data = _chartData[dayIndex];
      final parts = data.dateKey.split('-');
      if (parts.length == 3) {
        return SideTitleWidget(
          meta: meta,
          child: Text(
            '${parts[1]}/${parts[2]}',
            style: const TextStyle(fontSize: 10),
          ),
        );
      }
    }
    return const Text('');
  }

  /// 左側タイトル（レベル）を取得
  Widget _getLeftTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      meta: meta,
      child: Text(
        value.toInt().toString(),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  /// 折れ線グラフのデータを構築
  List<LineChartBarData> _buildLineBarsData() {
    // 時系列順にすべてのデータを並べる（1日朝→1日昼→1日夜→2日朝...）
    final allSpots = <FlSpot>[];

    for (int i = 0; i < _chartData.length; i++) {
      final data = _chartData[i];

      // 朝のデータ
      if (data.morningLevel != null) {
        allSpots.add(FlSpot((i * 3).toDouble(), data.morningLevel!.toDouble()));
      }

      // 昼のデータ
      if (data.afternoonLevel != null) {
        allSpots.add(
          FlSpot((i * 3 + 1).toDouble(), data.afternoonLevel!.toDouble()),
        );
      }

      // 夜のデータ
      if (data.eveningLevel != null) {
        allSpots.add(
          FlSpot((i * 3 + 2).toDouble(), data.eveningLevel!.toDouble()),
        );
      }
    }

    return [
      // 1本の線で時系列順に表示
      LineChartBarData(
        spots: allSpots,
        isCurved: false,
        color: const Color(0xFF1DA1F2),
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }

  /// ツールチップのアイテムを取得
  List<LineTooltipItem> _getTooltipItems(List<LineBarSpot> touchedSpots) {
    return touchedSpots.map((LineBarSpot touchedSpot) {
      final index = touchedSpot.x.toInt();
      final dayIndex = index ~/ 3;
      final timeIndex = index % 3;

      String timeLabel;
      if (timeIndex == 0) {
        timeLabel = '朝';
      } else if (timeIndex == 1) {
        timeLabel = '昼';
      } else {
        timeLabel = '夜';
      }

      // 日付を取得
      String dateLabel = '';
      if (dayIndex >= 0 && dayIndex < _chartData.length) {
        final data = _chartData[dayIndex];
        final parts = data.dateKey.split('-');
        if (parts.length == 3) {
          dateLabel = '${parts[1]}/${parts[2]} ';
        }
      }

      return LineTooltipItem(
        '$dateLabel$timeLabel: ${touchedSpot.y.toInt()}',
        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      );
    }).toList();
  }

  /// 凡例を構築
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 20, height: 3, color: const Color(0xFF1DA1F2)),
          const SizedBox(width: 8),
          const Text('耳鳴りレベル（朝→昼→夜の順）', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
