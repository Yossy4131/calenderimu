// カレンダーアプリのウィジェットテスト

import 'package:flutter_test/flutter_test.dart';

import 'package:calenderimu/main.dart';

void main() {
  testWidgets('Calendar app smoke test', (WidgetTester tester) async {
    // アプリを起動してフレームを描画
    await tester.pumpWidget(const CalendarApp());

    // カレンダー画面が表示されることを確認
    expect(find.text('カレンダー'), findsOneWidget);

    // 曜日ヘッダーが表示されることを確認
    expect(find.text('日'), findsOneWidget);
    expect(find.text('月'), findsOneWidget);
    expect(find.text('土'), findsOneWidget);

    // 今日ボタンが表示されることを確認
    expect(find.text('今日'), findsOneWidget);
  });
}
