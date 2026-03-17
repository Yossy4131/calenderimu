import 'package:flutter/material.dart';
import '../models/tinnitus_data.dart';
import '../models/medication_data.dart';
import '../models/notes_data.dart';
import '../services/tinnitus_service.dart';
import '../services/medication_service.dart';
import '../services/period_service.dart';
import '../services/notes_service.dart';
import '../widgets/tinnitus_rating_widget.dart';
import '../widgets/medication_check_widget.dart';
import '../widgets/period_tracking_widget.dart';
import '../widgets/notes_widget.dart';

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
  final NotesService _notesService = NotesService();
  bool _isLoading = true;
  bool _hasUnsavedChanges = false;

  // 編集中のローカルデータ
  int? _editingMorningLevel;
  int? _editingAfternoonLevel;
  int? _editingEveningLevel;
  String _editingNotes = '';
  bool _editingMorningTaken = false;
  bool _editingAfternoonTaken = false;
  bool _editingEveningTaken = false;
  bool _editingIsPeriod = false;

  // テキストコントローラー
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// データを読み込む
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tinnitusData = await _tinnitusService.getTinnitusData(widget.date);
      final medicationData = await _medicationService.getMedicationData(
        widget.date,
      );
      final notesData = await _notesService.getNotesData(widget.date);
      // 最新の生理期間が進行中かどうかを取得
      final ongoingPeriod = await _periodService.getOngoingPeriod();

      setState(() {
        // ローカル編集用データを初期化
        _editingMorningLevel = tinnitusData?.morningLevel;
        _editingAfternoonLevel = tinnitusData?.afternoonLevel;
        _editingEveningLevel = tinnitusData?.eveningLevel;
        _editingNotes = notesData?.notes ?? '';
        _notesController.text = _editingNotes;
        _editingMorningTaken = medicationData?.morningTaken ?? false;
        _editingAfternoonTaken = medicationData?.afternoonTaken ?? false;
        _editingEveningTaken = medicationData?.eveningTaken ?? false;
        // 進行中の期間があるかどうか（最新ドキュメントのendDateがnull）
        _editingIsPeriod = ongoingPeriod != null;

        _isLoading = false;
        _hasUnsavedChanges = false;
      });
    } catch (e) {
      print('Load data error: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('データの読み込みに失敗しました: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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

      // 備考データを保存
      final notesData = NotesData(
        dateKey: NotesData.dateKeyFromDateTime(widget.date),
        notes: _editingNotes.isEmpty ? null : _editingNotes,
      );

      // 並列で保存（生理記録は期間として別管理されているため含めない）
      await Future.wait([
        _tinnitusService.saveTinnitusData(tinnitusData),
        _medicationService.saveMedicationData(medicationData),
        _notesService.saveNotesData(notesData),
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
          errorMessage =
              'Firestoreへの接続に失敗しました。\n'
              'Firebaseコンソールでfirestoreが有効化されているか確認してください。';
        } else if (e.toString().contains('permission-denied')) {
          errorMessage =
              'アクセス権限がありません。\n'
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 64),

                        // 服薬記録ウィジェット
                        MedicationCheckWidget(
                          medicationData: MedicationData(
                            dateKey: MedicationData.dateKeyFromDateTime(
                              widget.date,
                            ),
                            morningTaken: _editingMorningTaken,
                            afternoonTaken: _editingAfternoonTaken,
                            eveningTaken: _editingEveningTaken,
                          ),
                          onTakenChanged: _updateTaken,
                        ),

                        const SizedBox(height: 24),

                        // 耳鳴り評価ウィジェット
                        TinnitusRatingWidget(
                          tinnitusData: TinnitusData(
                            dateKey: TinnitusData.dateKeyFromDateTime(
                              widget.date,
                            ),
                            morningLevel: _editingMorningLevel,
                            afternoonLevel: _editingAfternoonLevel,
                            eveningLevel: _editingEveningLevel,
                          ),
                          onLevelChanged: _updateLevel,
                        ),

                        const SizedBox(height: 24),

                        // 生理記録ウィジェット
                        PeriodTrackingWidget(
                          isPeriod: _editingIsPeriod,
                          onStartPeriod: _startPeriod,
                          onEndPeriod: _endPeriod,
                        ),

                        const SizedBox(height: 24),

                        // 備考欄ウィジェット
                        NotesWidget(
                          notesData: NotesData(
                            dateKey: NotesData.dateKeyFromDateTime(widget.date),
                            notes: _editingNotes,
                          ),
                          controller: _notesController,
                          onNotesChanged: (value) {
                            setState(() {
                              _editingNotes = value;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),

                        const SizedBox(height: 32),

                        // 保存ボタン
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _saveAllData,
                            icon: const Icon(Icons.check, size: 24),
                            label: const Text(
                              '保存して戻る',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1DA1F2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                              shadowColor: const Color(
                                0xFF1DA1F2,
                              ).withOpacity(0.4),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // クリアボタン
                        if ((_editingMorningLevel != null ||
                                _editingAfternoonLevel != null ||
                                _editingEveningLevel != null ||
                                _editingNotes.isNotEmpty) ||
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

                  // 戻るボタン
                  Positioned(
                    top: 8,
                    left: 8,
                    child: SafeArea(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 2,
                        ),
                        onPressed: () async {
                          if (_hasUnsavedChanges) {
                            final shouldPop = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('未保存の変更があります'),
                                content: const Text('変更を保存せずに戻りますか？'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('キャンセル'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('破棄'),
                                  ),
                                ],
                              ),
                            );

                            if (shouldPop == true && context.mounted) {
                              Navigator.pop(context);
                            }
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ),
                ],
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
            'この日のすべての記録を削除しますか？\n（耳鳴り記録、備考、服薬記録が削除されます）\n\n※ 生理記録は期間として管理されているため削除されません',
          ),
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
        // 耳鳴りデータ、備考、薬の服用データを削除（生理記録は期間管理のため含めない）
        await Future.wait([
          _tinnitusService.deleteTinnitusData(widget.date),
          _medicationService.deleteMedicationData(widget.date),
          _notesService.deleteNotesData(widget.date),
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
