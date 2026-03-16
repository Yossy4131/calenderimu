import 'package:flutter/material.dart';

/// アプリケーション全体で使用する定数
class AppConstants {
  // プライベートコンストラクタ（インスタンス化を防ぐ）
  AppConstants._();

  // ===== 色定数 =====
  static const Color primaryColor = Color(0xFF1DA1F2); // Twitterブルー
  static const Color textColor = Color(0xFF14171A); // Twitterテキストカラー
  static const Color backgroundColor = Color(0xFFF7F9F9); // 薄いグレー背景
  static const Color dividerColor = Color(0xFFE1E8ED); // Twitter border color

  // ===== サイズ定数 =====
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 20.0;
  static const double borderRadiusCircular = 30.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 28.0;

  // ===== カレンダー定数 =====
  static const double calendarCellSize = 26.0;
  static const double calendarDateFontSize = 15.0;
  static const double calendarPeriodIconSize = 10.0;
  static const double calendarGridCrossAxisRatio = 0.85;
  static const double calendarGridSpacing = 4.0;

  // ===== 耳鳴りレベル定数 =====
  static const int tinnitusLevelMin = 0;
  static const int tinnitusLevelMax = 10;
  static const Map<String, int> tinnitusLevelThresholds = {
    'low': 3,
    'medium': 6,
  };

  // ===== グラフ定数 =====
  static const List<int> chartPeriodOptions = [7, 14, 30, 60];
  static const int defaultChartPeriod = 7;

  // ===== データ保持期間 =====
  static const int dataRetentionMonths = 2;

  // ===== アニメーション定数 =====
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);

  // ===== 週間の曜日 =====
  static const List<String> weekdayNames = ['月', '火', '水', '木', '金', '土', '日'];

  // ===== エラーメッセージ =====
  static const String errorGeneric = 'エラーが発生しました';
  static const String errorNetwork = 'ネットワークエラーが発生しました';
  static const String errorAuth = '認証エラーが発生しました';
  static const String errorDataLoad = 'データの読み込みに失敗しました';
  static const String errorDataSave = 'データの保存に失敗しました';
}

/// 色のヘルパークラス
class AppColors {
  AppColors._();

  /// レベルに応じた色を取得
  static Color getLevelColor(int level) {
    if (level <= AppConstants.tinnitusLevelThresholds['low']!) {
      return Colors.green;
    } else if (level <= AppConstants.tinnitusLevelThresholds['medium']!) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// 曜日の色を取得
  static Color getWeekdayColor(String weekdayName) {
    if (weekdayName == '日') {
      return Colors.red.shade700;
    } else if (weekdayName == '土') {
      return Colors.blue.shade700;
    }
    return Colors.black87;
  }
}
