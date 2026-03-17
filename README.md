# Calenderimu

耳鳴り・服薬・生理を記録するカレンダーアプリケーション

## 機能

- 📅 **カレンダー表示**: 月間カレンダーで日々の記録を管理
- 🔊 **耳鳴りレベル記録**: 朝・昼・晩の3回、5段階で記録
- 💊 **服薬記録**: 朝・昼・晩の服薬状況を記録
- 🩸 **生理記録**: 生理期間の開始・終了を記録
- 🔐 **ユーザー認証**: メールアドレスとパスワードでログイン
- 🗄️ **自動データ管理**: 2ヶ月以上前のデータを自動削除

## 技術スタック

- **Framework**: Flutter (Web/Mobile対応)
- **Backend**: Firebase
  - Firebase Authentication (メール/パスワード認証)
  - Cloud Firestore (データベース)
  - Firebase App Check (セキュリティ)
- **State Management**: StatefulWidget
- **Charts**: fl_chart

## セットアップ

### 前提条件

- Flutter SDK 3.0以上
- Firebase CLI
- Node.js (Firebase CLIに必要)

### 1. リポジトリのクローン

```bash
git clone https://github.com/Yossy4131/calenderimu.git
cd calenderimu
```

### 2. 依存関係のインストール

```bash
flutter pub get
```

### 3. Firebase設定

#### 3.1 Firebaseプロジェクトの作成

1. [Firebase Console](https://console.firebase.google.com/)でプロジェクトを作成
2. Authentication、Firestore Databaseを有効化

#### 3.2 Firebase設定ファイルの生成

```bash
# Firebase CLIをインストール
npm install -g firebase-tools

# Firebaseにログイン
firebase login

# FlutterFireCLIをインストール
dart pub global activate flutterfire_cli

# Firebase設定を生成
flutterfire configure
```

これで`lib/firebase_options.dart`が自動生成されます。

#### 3.3 Android設定（Android向けの場合）

FlutterFire CLIの設定後、`android/app/google-services.json`が自動生成されます。

#### 3.4 Firestoreセキュリティルールのデプロイ

```bash
firebase deploy --only firestore:rules
```

### 4. 実行

#### Web版

```bash
flutter run -d chrome
```

#### Android版

```bash
flutter run -d <device-id>
```

#### iOS版

```bash
flutter run -d <device-id>
```

## Firebaseのセキュリティ設定

### Firestoreセキュリティルール

プロジェクトには`firestore.rules`ファイルが含まれており、以下のセキュリティが実装されています：

- ✅ 認証されたユーザーのみアクセス可能
- ✅ ユーザーは自分のデータのみ読み書き可能
- ✅ すべての未認証アクセスをブロック

### Firebase App Check

本番環境では、Firebase App Checkを有効化することを推奨します：

1. Firebase ConsoleでApp Checkを有効化
2. Web: reCAPTCHA v3を登録
3. Android: Play Integrityを設定
4. iOS: App Attestを設定
5. `lib/main.dart`の以下のコメントを解除：

```dart
// 現在コメントアウトされているApp Check設定を有効化
```

## プロジェクト構造

```
lib/
├── main.dart                    # アプリエントリーポイント
├── firebase_options.dart        # Firebase設定（自動生成）
├── constants/
│   └── app_constants.dart       # 定数定義
├── models/                      # データモデル
│   ├── calendar_day.dart
│   ├── tinnitus_data.dart
│   ├── medication_data.dart
│   └── period_data.dart
├── screens/                     # 画面
│   ├── login_screen.dart
│   ├── sign_up_screen.dart
│   ├── home_screen.dart
│   ├── calendar_screen.dart
│   ├── date_detail_screen.dart
│   └── tinnitus_chart_screen.dart
├── services/                    # ビジネスロジック
│   ├── auth_service.dart
│   ├── tinnitus_service.dart
│   ├── medication_service.dart
│   ├── period_service.dart
│   └── data_cleanup_service.dart
├── utils/
│   └── calendar_utils.dart      # カレンダー用ユーティリティ
└── widgets/                     # 再利用可能なウィジェット
    ├── common_widgets.dart
    ├── calendar_grid.dart
    ├── calendar_header.dart
    ├── tinnitus_rating_widget.dart
    ├── medication_check_widget.dart
    └── period_tracking_widget.dart
```

## 環境変数とセキュリティ

### Gitにコミットしないファイル

`.gitignore`で以下のファイルが除外されています：

- `android/app/google-services.json` - 自動生成可能
- `ios/Runner/GoogleService-Info.plist` - 自動生成可能
- `**/*_secret.json` - 秘密鍵ファイル
- `**/*_credentials.json` - 認証情報ファイル

### Gitにコミットするファイル

以下のファイルは公開APIキーを含みますが、コミット可能です：

- `lib/firebase_options.dart` - クライアント側で使用する公開設定
- `.firebaserc` - プロジェクトID（公開情報）
- `firestore.rules` - セキュリティルール

⚠️ **注意**: これらのファイルに含まれるAPIキーは、Firestoreセキュリティルールとユーザー認証によって保護されます。

## データ管理

### 自動データクリーンアップ

- 2ヶ月以上前のデータは自動的に削除されます
- アプリ起動時に毎月1回チェックが実行されます
- 削除されるデータ：
  - 耳鳴りレベル記録
  - 服薬記録
  - 生理記録

## ビルド

### Web版ビルド

```bash
flutter build web --release
```

> **注**: グラフ表示のために、`web/index.html`にCanvasKitレンダラーを強制する設定が含まれています。

ビルド成果物は`build/web/`に出力されます。

### Android版ビルド

```bash
flutter build apk --release
# または
flutter build appbundle --release
```

### iOS版ビルド

```bash
flutter build ios --release
```

## デプロイ

### Firebase Hostingへのデプロイ（Web版）

```bash
# firebase.jsonの設定を確認
firebase init hosting

# Web版ビルド
flutter build web --release

# デプロイ
firebase deploy --only hosting
```

> **重要**: デプロイ後は必ずブラウザのキャッシュをクリアしてください（Ctrl + Shift + R）。

## トラブルシューティング

### メールログインエラー

- Firebase Consoleでメール/パスワード認証が有効化されているか確認
- 承認済みドメインに`localhost`とデプロイ先のドメインが登録されているか確認

### Firestoreアクセスエラー

- Firestoreセキュリティルールがデプロイされているか確認
- ユーザーが正しくログインしているか確認

### App Checkエラー

開発中は`lib/main.dart`でApp Checkをコメントアウトしてください。

## ライセンス

このプロジェクトは個人用途のアプリケーションです。

## 作成者

Yossy4131
