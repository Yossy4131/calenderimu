import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// 共通で使用するウィジェット
class CommonWidgets {
  CommonWidgets._();

  /// グラデーション背景のコンテナ
  static Widget gradientContainer({
    required Widget child,
    List<Color>? colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:
              colors ??
              [
                AppConstants.primaryColor,
                AppConstants.primaryColor.withOpacity(0.7),
              ],
        ),
      ),
      child: child,
    );
  }

  /// カード型のコンテナ
  static Widget card({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      margin:
          margin ?? const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      padding: padding ?? const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: child,
    );
  }

  /// セクションヘッダー
  static Widget sectionHeader({
    required String title,
    IconData? icon,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppConstants.iconSizeMedium,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(width: AppConstants.paddingSmall),
          ],
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (trailing != null) ...[const Spacer(), trailing],
        ],
      ),
    );
  }

  /// ローディングインジケーター
  static Widget loadingIndicator({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppConstants.primaryColor,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            Text(message, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ],
      ),
    );
  }

  /// 空のデータ表示
  static Widget emptyData({required String message, IconData? icon}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  /// プライマリボタン
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusCircular,
            ),
          ),
          elevation: 4,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// アウトラインボタン
  static Widget outlineButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppConstants.primaryColor,
        side: const BorderSide(color: AppConstants.primaryColor, width: 2),
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.borderRadiusCircular,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon),
            const SizedBox(width: AppConstants.paddingSmall),
          ],
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// エラー表示ダイアログ
  static void showErrorDialog(
    BuildContext context, {
    required String message,
    String title = 'エラー',
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// 確認ダイアログ
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'OK',
    String cancelText = 'キャンセル',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// スナックバーを表示
  static void showSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppConstants.primaryColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
