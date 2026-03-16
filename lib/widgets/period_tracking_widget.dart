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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: Colors.pink.shade400,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '生理記録',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                // 状態バッジ
                if (currentlyInPeriod)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade400,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          '生理中',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            // 生理開始/終了ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: currentlyInPeriod ? onEndPeriod : onStartPeriod,
                icon: Icon(
                  currentlyInPeriod ? Icons.check_circle : Icons.play_arrow,
                  size: 22,
                ),
                label: Text(
                  currentlyInPeriod ? '生理終了' : '生理開始',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentlyInPeriod
                      ? Colors.grey.shade400
                      : Colors.pink.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: currentlyInPeriod ? 0 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
