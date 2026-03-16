import 'package:flutter/material.dart';

/// 生理期間記録用ウィジェット
/// 生理開始前は「生理開始」ボタン、生理中は「生理終了」ボタンを表示
class PeriodTrackingWidget extends StatelessWidget {
  final bool? isPeriod;
  final VoidCallback onStartPeriod;
  final VoidCallback onEndPeriod;

  const PeriodTrackingWidget({
    super.key,
    required this.isPeriod,
    required this.onStartPeriod,
    required this.onEndPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final bool currentlyInPeriod = isPeriod ?? false;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.pink.shade400,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  '生理記録',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                // 状態バッジ
                if (currentlyInPeriod)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.pink.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: Colors.pink.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '生理中',
                          style: TextStyle(
                            color: Colors.pink.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // 生理開始/終了ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: currentlyInPeriod ? onEndPeriod : onStartPeriod,
                icon: Icon(
                  currentlyInPeriod ? Icons.check_circle : Icons.play_arrow,
                  size: 20,
                ),
                label: Text(
                  currentlyInPeriod ? '生理終了' : '生理開始',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentlyInPeriod
                      ? Colors.grey.shade400
                      : Colors.pink.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            // 説明テキスト
            const SizedBox(height: 12),
            Text(
              currentlyInPeriod ? 'この日を最終日として生理を終了します' : 'この日から生理を開始します',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
