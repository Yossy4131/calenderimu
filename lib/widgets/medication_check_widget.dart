import 'package:flutter/material.dart';
import '../models/medication_data.dart';

/// 薬の服用チェックウィジェット（朝昼晩のチェックボックス）
class MedicationCheckWidget extends StatelessWidget {
  /// 服用データ
  final MedicationData? medicationData;

  /// 服用状況が変更された時のコールバック
  final Function(String timeOfDay, bool taken) onTakenChanged;

  const MedicationCheckWidget({
    super.key,
    required this.medicationData,
    required this.onTakenChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトルと服用状況サマリー
            _buildHeader(),

            const SizedBox(height: 20),

            // 服用チェックリスト
            _buildCheckItem(
              '朝',
              '🌅',
              medicationData?.morningTaken ?? false,
              'morning',
            ),
            const SizedBox(height: 12),
            _buildCheckItem(
              '昼',
              '☀️',
              medicationData?.afternoonTaken ?? false,
              'afternoon',
            ),
            const SizedBox(height: 12),
            _buildCheckItem(
              '夜',
              '🌙',
              medicationData?.eveningTaken ?? false,
              'evening',
            ),
          ],
        ),
      ),
    );
  }

  /// ヘッダーを構築
  Widget _buildHeader() {
    final takenCount = medicationData?.takenCount ?? 0;
    final allTaken = medicationData?.allTaken ?? false;

    return Row(
      children: [
        const Icon(Icons.medication, color: Color(0xFF1DA1F2), size: 28),
        const SizedBox(width: 8),
        const Text(
          '服薬記録',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: allTaken ? Colors.green : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$takenCount / 3',
            style: TextStyle(
              color: allTaken ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  /// チェック項目を構築
  Widget _buildCheckItem(
    String label,
    String emoji,
    bool isTaken,
    String timeOfDay,
  ) {
    return InkWell(
      onTap: () => onTakenChanged(timeOfDay, !isTaken),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isTaken
              ? const Color(0xFF1DA1F2).withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isTaken
                ? const Color(0xFF1DA1F2).withOpacity(0.3)
                : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // チェックボックス
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isTaken ? const Color(0xFF1DA1F2) : Colors.white,
                border: Border.all(
                  color: isTaken
                      ? const Color(0xFF1DA1F2)
                      : Colors.grey.shade400,
                  width: 2.5,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: isTaken
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1DA1F2).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isTaken
                  ? const Icon(Icons.check, color: Colors.white, size: 22)
                  : null,
            ),
            const SizedBox(width: 16),
            // 絵文字
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            // ラベル
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: isTaken ? TextDecoration.lineThrough : null,
                  decorationThickness: 2,
                  color: isTaken ? Colors.grey : Colors.black87,
                ),
              ),
            ),
            // 服用済みバッジ
            if (isTaken)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1DA1F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '済',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
