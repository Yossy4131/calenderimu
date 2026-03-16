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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1DA1F2).withOpacity(0.1),
              const Color(0xFF1DA1F2).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1DA1F2).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Color(0xFF1DA1F2),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '平均耳鳴りレベル',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      avg != null ? avg.toStringAsFixed(1) : '-',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1DA1F2),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (avg != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getLevelColor(avg.round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    avg <= 3 ? '低' : (avg <= 6 ? '中' : '高'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
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
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: currentLevel != null
              ? _getLevelColor(currentLevel).withOpacity(0.3)
              : Colors.grey.shade200,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: currentLevel != null
                        ? _getLevelColor(currentLevel).withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (currentLevel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getLevelColor(currentLevel),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _getLevelColor(currentLevel).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '$currentLevel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            GaugeBarWidget(
              currentLevel: currentLevel,
              onLevelChanged: (level) => onLevelChanged(timeOfDay, level),
            ),
          ],
        ),
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
}
