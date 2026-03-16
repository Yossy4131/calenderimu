import 'package:flutter/material.dart';
import '../models/tinnitus_data.dart';
import '../models/medication_data.dart';
import '../services/tinnitus_service.dart';
import '../services/medication_service.dart';
import '../services/period_service.dart';
import '../widgets/tinnitus_rating_widget.dart';
import '../widgets/medication_check_widget.dart';
import '../widgets/period_tracking_widget.dart';

/// 日付詳細画面（耳鳴り評価入力画面）
class DateDetailScreen extends StatefulWidget {
  final DateTime date;

  const DateDetailScreen({super.key, required this.date});

  @override
  State<DateDetailScreen> createState() => _DateDetailScreenState();
}

class _DateDetailScreenState extends State<DateDetailScreen> {
  final TinnitusService _tinnitusService = TinnitusService();
  final MedicationService _medicationService = MedicationService();
  final PeriodService _periodService = PeriodService();
  bool _isLoading = true;
  bool _hasUnsavedChanges = false;

  // 編集中のローカルデータ
  int? _editingMorningLevel;
  int? _editingAfternoonLevel;
  int? _editingEveningLevel;
  bool _editingMorningTaken = false;
  bool _editingAfternoonTaken = false;
  bool _editingEveningTaken = false;
  bool _editingIsPeriod = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// データを読み込む
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final tinnitusData = await _tinnitusService.getTinnitusData(widget.date);
    final medicationData =
        await _medicationService.getMedicationData(widget.date);
    // 最新の生理期間が進行中かどうかを取得
    final ongoingPeriod = await _periodService.getOngoingPeriod();

    setState(() {
      // ローカル編集用データを初期化
      _editingMorningLevel = tinnitusData?.morningLevel;
      _editingAfternoonLevel = tinnitusData?.afternoonLevel;
      _editingEveningLevel = tinnitusData?.eveningLevel;
      _editingMorningTaken = medicationData?.morningTaken ?? false;
      _editingAfternoonTaken = medicationData?.afternoonTaken ?? false;
      _editingEveningTaken = medicationData?.eveningTaken ?? false;
      // 進行中の期間があるかどうか（最新ドキュメントのendDateがnull）
      _editingIsPeriod = ongoingPeriod != null;
      
      _isLoading = false;
      _hasUnsavedChanges = false;
    });
  }

  /// レベルを更新（ローカル状態のみ）
  void _updateLevel(String timeOfDay, int? level) {
    setState(() {
      switch (timeOfDay) {
        case 'morning':
          _editingMorningLevel = level;
          break;
        case 'afternoon':
          _editingAfternoonLevel = level;
          break;
        case 'evening':
          _editingEveningLevel = level;
          break;
      }
      _hasUnsavedChanges = true;
    });
  }

  /// 服用状況を更新（ローカル状態のみ）
  void _updateTaken(String timeOfDay, bool taken) {
    setState(() {
      switch (timeOfDay) {
        case 'morning':
          _editingMorningTaken = taken;
          break;
        case 'afternoon':
          _editingAfternoonTaken = taken;
          break;
        case 'evening':
          _editingEveningTaken = taken;
          break;
      }
      _hasUnsavedChanges = true;
    });
  }

  /// 生理期間を開始
  Future<void> _startPeriod() async {
    try {
      await _periodService.startPeriod(widget.date);
      setState(() {
        _editingIsPeriod = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('生理期間を開始しました'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Start period error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 生理期間を終了
  Future<void> _endPeriod() async {
    try {
      await _periodService.endPeriod(widget.date);
      setState(() {
        _editingIsPeriod = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('生理期間を終了しました'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('End period error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// すべてのデータを保存
  Future<void> _saveAllData() async {
    try {
      // 耳鳴りデータを保存
      final tinnitusData = TinnitusData(
        dateKey: TinnitusData.dateKeyFromDateTime(widget.date),
        morningLevel: _editingMorningLevel,
        afternoonLevel: _editingAfternoonLevel,
        eveningLevel: _editingEveningLevel,
      );

      // 服薬データを保存
      final medicationData = MedicationData(
        dateKey: MedicationData.dateKeyFromDateTime(widget.date),
        morningTaken: _editingMorningTaken,
        afternoonTaken: _editingAfternoonTaken,
        eveningTaken: _editingEveningTaken,
      );

      // 並列で保存（生理記録は期間として別管理されているため含めない）
      await Future.wait([
        _tinnitusService.saveTinnitusData(tinnitusData),
        _medicationService.saveMedicationData(medicationData),
      ]);

      setState(() {
        _hasUnsavedChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存されました'),
            duration: Duration(seconds: 1),
          ),
        );
        // 保存後に画面を閉じる
        Navigator.pop(context);
      }
    } catch (e) {
      print('Save error: $e');
      if (mounted) {
        String errorMessage = 'エラーが発生しました';

        if (e.toString().contains('Unable to establish connection')) {
          errorMessage = 'Firestoreへの接続に失敗しました。\n'
              'Firebaseコンソールでfirestoreが有効化されているか確認してください。';
        } else if (e.toString().contains('permission-denied')) {
          errorMessage = 'アクセス権限がありません。\n'
              'Firestoreのセキュリティルールを確認してください。';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: '詳細',
              textColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('エラー詳細'),
                    content: SingleChildScrollView(child: Text(e.toString())),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('閉じる'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${widget.date.year}年${widget.date.month}月${widget.date.day}日';
    final weekdayNames = ['月', '火', '水', '木', '金', '土', '日'];
    final weekday = weekdayNames[widget.date.weekday - 1];

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        if (_hasUnsavedChanges) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('未保存の変更があります'),
              content: const Text('変更を保存せずに戻りますか？'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('キャンセル'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('破棄'),
                ),
              ],
            ),
          );

          if (shouldPop == true && context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formattedDate, style: const TextStyle(fontSize: 18)),
              Text(
                '$weekday曜日',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 服薬記録ウィジェット
                  MedicationCheckWidget(
                    medicationData: MedicationData(
                      dateKey: MedicationData.dateKeyFromDateTime(widget.date),
                      morningTaken: _editingMorningTaken,
                      afternoonTaken: _editingAfternoonTaken,
                      eveningTaken: _editingEveningTaken,
                    ),
                    onTakenChanged: _updateTaken,
                  ),

                  const SizedBox(height: 32),

                  // 耳鳴り評価ウィジェット
                  TinnitusRatingWidget(
                    tinnitusData: TinnitusData(
                      dateKey: TinnitusData.dateKeyFromDateTime(widget.date),
                      morningLevel: _editingMorningLevel,
                      afternoonLevel: _editingAfternoonLevel,
                      eveningLevel: _editingEveningLevel,
                    ),
                    onLevelChanged: _updateLevel,
                  ),

                  const SizedBox(height: 32),

                  // 生理記録ウィジェット
                  PeriodTrackingWidget(
                    isPeriod: _editingIsPeriod,
                    onStartPeriod: _startPeriod,
                    onEndPeriod: _endPeriod,
                  ),

                  const SizedBox(height: 32),

                  // 保存ボタン
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _saveAllData,
                      icon: const Icon(Icons.check),
                      label: const Text(
                        '保存して戻る',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1DA1F2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // クリアボタン
                  if ((_editingMorningLevel != null ||
                          _editingAfternoonLevel != null ||
                          _editingEveningLevel != null) ||
                      (_editingMorningTaken ||
                          _editingAfternoonTaken ||
                          _editingEveningTaken) ||
                      _editingIsPeriod)
                    Center(
                      child: TextButton.icon(
                        onPressed: _showClearConfirmation,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('すべてクリア'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
      ),
    );
  }

  /// すべてクリアの確認ダイアログを表示
  Future<void> _showClearConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('確認'),
          content: const Text(
              'この日のすべての記録を削除しますか？\n（耳鳴り記録と服薬記録が削除されます）\n\n※ 生理記録は期間として管理されているため削除されません'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        // 耳鳴りデータと薬の服用データを削除（生理記録は期間管理のため含めない）
        await Future.wait([
          _tinnitusService.deleteTinnitusData(widget.date),
          _medicationService.deleteMedicationData(widget.date),
        ]);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('削除しました'),
              duration: Duration(seconds: 1),
            ),
          );
          // カレンダー画面に戻る
          Navigator.pop(context);
        }
      } catch (e) {
        print('Delete error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('エラーが発生しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
