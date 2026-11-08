# PromptFlow

> [スペイン語の原文](../../../README.md)からの翻訳です。内容に相違がある場合は原文が優先されます。

Linux と Android 向けのテレプロンプター：画面のリフレッシュレートに合わせたなめらかなスクロール、水平/垂直ミラー、原稿内のポーズとキュー、LAN 経由のリモートコントロール（WebSocket）、Bluetooth ペダル、ローカル音声追従（Vosk）に対応しています。

```bash
flutter pub get
flutter run -d linux          # プロンプター + 制御サーバー
flutter run -d <android-id>   # プロンプターまたはリモコン
flutter test                  # エンジン、パーサー、プロトコル（実ソケット）、音声
```

### 音声追従（オプション、オフライン）

ローカルで動作する音声認識 [Vosk](https://alphacephei.com/vosk/) により、テキストがあなたの話すペースに合わせて進みます。モデルは 11 言語で利用できます：es、en、pt、fr、de、it、ru、zh、ja、ko、hi。

- **Android：** 原稿を開き、**設定 → 音声** に進みます。言語を選び、*モデルをダウンロード* をタップしてから、HUD のマイクをタップします。初回はアプリがマイクの権限を求めます。
- **Linux：** エンジンを一度インストールし、アプリ内またはスクリプトでモデルをダウンロードします：
  ```bash
  tool/setup_vosk_linux.sh      # libvosk + スペイン語モデル
  flutter run -d linux
  ```
  PulseAudio/PipeWire の既定のマイクが使われます。

* アーキテクチャと技術スタックの選定理由：[`docs/ARCHITECTURE.md`](../en/ARCHITECTURE.md)
* WebSocket/UDP プロトコル：[`docs/PROTOCOL.md`](../en/PROTOCOL.md)
* スクロールエンジン：[`lib/engine/scroll_engine.dart`](../../../lib/engine/scroll_engine.dart) + [`lib/engine/prompter_painter.dart`](../../../lib/engine/prompter_painter.dart)

## ショートカット（キーボードとペダル）

| キー | 動作 |
|---|---|
| Space / Enter / Play-Pause | 再生 / 一時停止 |
| Page Up / ← | 5 秒戻る |
| Page Down / → | 5 秒進む |
| ↑ / ↓ | ±10 WPM |
| H / V | 水平 / 垂直ミラー |
| + / − | 文字サイズ |
| Home | 先頭に戻る |
| S | 設定 |
| Esc | 終了 |

タッチスクリーンのジェスチャー：ダブルタップで再生または一時停止、縦方向のドラッグで原稿をスクロール、シングルタップで HUD を表示します。

## コントリビュート

コントリビューションを歓迎します！コード、実機でのテスト、ドキュメント、翻訳、アイデアなど、どれも力になります。

**まず[コントリビューションガイド](CONTRIBUTING.md)をお読みください。** 要点は次のとおりです：

1. `develop` から `tipo/descripcion` 形式（`feat/…`、`fix/…`、`docs/…`、`i18n/…`）で新しいブランチを作成します。
2. pull request は **`develop` に向けて**作成します。`main` はリリース済みのバージョンだけを受け入れます。
3. 送信する前に：`flutter analyze` で警告がなく、`flutter test` がすべて成功していること。

### どこから始めるか

- **音声追従の調整**：さまざまな言語の実際の録音を使って調整します（ゲイン、デッドゾーン、アライナーのウィンドウ）。
- **アラビア語の音声モデル**：モバイル向けの小さなモデルが登場した場合。
- **`follower` ロール**：メインのプロンプターに追従して原稿を表示する 2 台目のデバイス。
- **読み上げ中に画面を常時点灯**（`wakelock_plus`）。
- **パッケージング**：Linux 向けの Flatpak または AppImage と、Android のビルド。
- **実機でのテスト**：Bluetooth ペダル、タブレット、Raspberry Pi（ARM64）、クライアント分離が有効な Wi‑Fi ネットワーク。

バグを見つけた、またはアイデアがありますか？[issue](https://github.com/GNUXDAR/PromptFlow/issues/new/choose) を作成してください。

## ライセンス

[MIT](../../../LICENSE) © 2026 Arturo Cabrera。コントリビュートすることで、あなたの貢献がこれと同じライセンスで公開されることに同意したものとみなされます。
