# デプロイ前チェックリスト

このファイルは、本番環境へのデプロイ前に確認すべき項目のチェックリストです。

## セキュリティ確認

- [ ] `.gitignore`に機密情報が含まれているか確認
- [ ] `**/*_secret.json`ファイルがコミットされていないか確認
- [ ] `**/*_credentials.json`ファイルがコミットされていないか確認
- [ ] ハードコードされたパスワードやトークンが存在しないか確認

## Firebaseコンソール設定

- [ ] Firebase Authenticationが有効化されている
  - [ ] メール/パスワード認証が有効
  - [ ] 承認済みドメインに以下が登録されている
    - [ ] `localhost`（開発用）
    - [ ] `calender-imu.firebaseapp.com`（デフォルト）
    - [ ] `calender-imu.web.app`（デフォルト）

- [ ] Cloud Firestoreが有効化されている
  - [ ] セキュリティルールがデプロイされている
  - [ ] ルールが正しく動作することを確認

- [ ] Firebase App Check（本番環境のみ）
  - [ ] App Checkが有効化されている
  - [ ] reCAPTCHA v3が登録されている（Web）
  - [ ] Play Integrityが設定されている（Android）
  - [ ] App Attestが設定されている（iOS）

## コード確認

- [ ] `lib/main.dart`のApp Check設定を確認
  - [ ] 開発環境：コメントアウト
  - [ ] 本番環境：有効化

- [ ] デバッグログが適切に条件分岐されている
  - [ ] `if (kDebugMode)`で保護されている
  - [ ] 本番環境で不要なログが出力されない

## ビルド確認

- [ ] Web版ビルドが成功する
  ```bash
  flutter build web --release
  ```

- [ ] Android版ビルドが成功する（該当する場合）
  ```bash
  flutter build apk --release
  ```

- [ ] iOS版ビルドが成功する（該当する場合）
  ```bash
  flutter build ios --release
  ```

## デプロイ前テスト

- [ ] ログイン機能が正常に動作する
  - [ ] メール/パスワードログイン

- [ ] カレンダー表示が正常
- [ ] データの保存が正常に動作
- [ ] データの読み込みが正常に動作
- [ ] グラフが正しく表示される
- [ ] 2ヶ月データ保持が正常に動作

## デプロイ

- [ ] Firestoreセキュリティルールをデプロイ
  ```bash
  firebase deploy --only firestore:rules
  ```

- [ ] Web版をFirebase Hostingにデプロイ（該当する場合）
  ```bash
  firebase deploy --only hosting
  ```

- [ ] デプロイ後、本番環境で動作確認

## デプロイ後確認

- [ ] 本番環境でログインできる
- [ ] データの保存・読み込みが正常
- [ ] エラーがFirebaseコンソールに記録されていないか確認
- [ ] App Checkが正常に動作している（本番環境のみ）

## ロールバック準備

- [ ] 前バージョンのバックアップがある
- [ ] ロールバック手順を理解している
- [ ] Firebase Hostingの過去バージョンが保持されている

---

## 注意事項

### 公開可能なファイル
以下のファイルは公開APIキーを含みますが、Gitにコミット可能です：
- `lib/firebase_options.dart`
- `.firebaserc`
- `firestore.rules`

これらはFirestoreセキュリティルールと認証によって保護されます。

### 非公開ファイル
以下のファイルは絶対にGitにコミットしないでください：
- サービスアカウントキー
- プライベートAPIキー
- データベースのシークレット

---

**最終確認日**: _________

**確認者**: _________
