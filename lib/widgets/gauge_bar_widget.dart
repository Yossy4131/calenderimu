import 'package:flutter/material.dart';

/// ゲージバー形式のレベル選択ウィジェット
class GaugeBarWidget extends StatelessWidget {
  /// 現在のレベル（1-10、未選択の場合はnull）
  final int? currentLevel;

  /// レベルが選択された時のコールバック
  final Function(int?) onLevelChanged;

  /// クリアボタンを表示するかどうか
  final bool showClearButton;

  const GaugeBarWidget({
    super.key,
    required this.currentLevel,
    required this.onLevelChanged,
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ゲージバー
        _buildGaugeBar(),
        const SizedBox(height: 12),
        // クリアボタン
        if (showClearButton && currentLevel != null)
          TextButton(
            onPressed: () => onLevelChanged(null),
            child: const Text('クリア'),
          ),
      ],
    );
  }

  /// ゲージバーを構築
  Widget _buildGaugeBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade300, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.5),
        child: Row(
          children: List.generate(10, (index) {
            final level = index + 1;
            final isSelected = currentLevel != null && level <= currentLevel!;
            final color = _getLevelColor(level);

            return Expanded(
              child: GestureDetector(
                onTap: () => onLevelChanged(level),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.12),
                    border: Border(
                      right: index < 9
                          ? const BorderSide(color: Colors.white, width: 1.5)
                          : BorderSide.none,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$level',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : color.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
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
