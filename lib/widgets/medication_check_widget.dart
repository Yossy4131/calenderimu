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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // タイトルと服用状況サマリー
        _buildHeader(),

        const SizedBox(height: 16),

        // 服用チェックリスト
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _buildCheckItem(
                  '朝',
                  '🌅',
                  medicationData?.morningTaken ?? false,
                  'morning',
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                _buildCheckItem(
                  '昼',
                  '☀️',
                  medicationData?.afternoonTaken ?? false,
                  'afternoon',
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                _buildCheckItem(
                  '夜',
                  '🌙',
                  medicationData?.eveningTaken ?? false,
                  'evening',
                ),
              ],
            ),
          ),
        ),
      ],
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
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Row(
          children: [
            // チェックボックス
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isTaken ? const Color(0xFF1DA1F2) : Colors.transparent,
                border: Border.all(
                  color: isTaken ? const Color(0xFF1DA1F2) : Colors.grey.shade400,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isTaken
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // 絵文字
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            // ラベル
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  decoration: isTaken ? TextDecoration.lineThrough : null,
                  color: isTaken ? Colors.grey : Colors.black87,
                ),
              ),
            ),
            // 服用済みバッジ
            if (isTaken)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '服用済',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
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
