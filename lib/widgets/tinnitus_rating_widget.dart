import 'package:flutter/material.dart';
import '../models/tinnitus_data.dart';
import 'gauge_bar_widget.dart';

/// 耳鳴り評価ウィジェット（朝昼夜の3つのセクション）
class TinnitusRatingWidget extends StatelessWidget {
  /// 耳鳴りデータ
  final TinnitusData? tinnitusData;

  /// レベルが変更された時のコールバック
  final Function(String timeOfDay, int? level) onLevelChanged;

  const TinnitusRatingWidget({
    super.key,
    required this.tinnitusData,
    required this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 平均レベル表示（常に表示）
        _buildAverageCard(),

        const SizedBox(height: 24),

        // 朝の耳鳴り
        _buildTimeSection('朝', '🌅', tinnitusData?.morningLevel, 'morning'),

        const SizedBox(height: 24),

        // 昼の耳鳴り
        _buildTimeSection('昼', '☀️', tinnitusData?.afternoonLevel, 'afternoon'),

        const SizedBox(height: 24),

        // 夜の耳鳴り
        _buildTimeSection('夜', '🌙', tinnitusData?.eveningLevel, 'evening'),
      ],
    );
  }

  /// 平均レベルカードを構築
  Widget _buildAverageCard() {
    final avg = tinnitusData?.averageLevel;

    return Card(
      color: const Color(0xFF1DA1F2).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.analytics, color: Color(0xFF1DA1F2)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '平均レベル',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    avg != null ? avg.toStringAsFixed(1) : '-',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1DA1F2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 時間帯セクションを構築
  Widget _buildTimeSection(
    String label,
    String emoji,
    int? currentLevel,
    String timeOfDay,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (currentLevel != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getLevelColor(currentLevel),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$currentLevel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        GaugeBarWidget(
          currentLevel: currentLevel,
          onLevelChanged: (level) => onLevelChanged(timeOfDay, level),
        ),
      ],
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
}
