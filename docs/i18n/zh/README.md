# PromptFlow

> 译自[西班牙语原文](../../../README.md)。如有出入，以原文为准。

适用于 Linux 和 Android 的提词器：按屏幕刷新率平滑滚动、水平/垂直镜像、脚本中的停顿与提示标记（cue）、通过局域网（WebSocket）远程控制、蓝牙踏板，以及本地语音跟随（Vosk）。

```bash
flutter pub get
flutter run -d linux          # 提词器 + 控制服务器
flutter run -d <android-id>   # 提词器或遥控器
flutter test                  # 引擎、解析器、协议（真实套接字）和语音
```

### 语音跟随（可选，离线）

借助本地语音识别引擎 [Vosk](https://alphacephei.com/vosk/)，文本会跟随你说话的节奏前进。目前提供 11 种语言的模型：es、en、pt、fr、de、it、ru、zh、ja、ko 和 hi。

- **Android：** 打开一个脚本，进入 **设置 → 语音**。选择语言，点击 *下载模型*，然后点击 HUD 上的麦克风。首次使用时，应用会请求麦克风权限。
- **Linux：** 先安装一次引擎，然后在应用内或通过脚本下载模型：
  ```bash
  tool/setup_vosk_linux.sh      # libvosk + 西班牙语模型
  flutter run -d linux
  ```
  使用 PulseAudio/PipeWire 的默认麦克风。

* 架构与技术栈选型说明：[`docs/ARCHITECTURE.md`](../en/ARCHITECTURE.md)
* WebSocket/UDP 协议：[`docs/PROTOCOL.md`](../en/PROTOCOL.md)
* 滚动引擎：[`lib/engine/scroll_engine.dart`](../../../lib/engine/scroll_engine.dart) + [`lib/engine/prompter_painter.dart`](../../../lib/engine/prompter_painter.dart)

## 快捷键（键盘和踏板）

| 按键 | 操作 |
|---|---|
| Space / Enter / Play-Pause | 播放 / 暂停 |
| Page Up / ← | 后退 5 秒 |
| Page Down / → | 前进 5 秒 |
| ↑ / ↓ | ±10 WPM |
| H / V | 水平 / 垂直镜像 |
| + / − | 字号 |
| Home | 回到开头 |
| S | 设置 |
| Esc | 退出 |

触摸屏手势：双击播放或暂停，垂直拖动以滚动脚本，单击显示 HUD。

## 参与贡献

欢迎贡献！代码、真机测试、文档、翻译或想法，每一份都有价值。

**请先阅读[贡献指南](CONTRIBUTING.md)。** 要点如下：

1. 从 `develop` 新建分支，命名格式为 `tipo/descripcion`（`feat/…`、`fix/…`、`docs/…`、`i18n/…`）。
2. 将 pull request **提交到 `develop`**。`main` 只接收已发布的版本。
3. 提交之前：`flutter analyze` 无警告，`flutter test` 全部通过。

### 从哪里开始

- **优化语音跟随**：使用不同语言的真实录音进行调校（增益、死区、对齐器窗口）。
- **阿拉伯语语音模型**：如果出现适合移动端的小型模型。
- **`follower` 角色**：第二台设备跟随主提词器显示脚本。
- **朗读期间屏幕常亮**（`wakelock_plus`）。
- **打包**：Linux 的 Flatpak 或 AppImage，以及 Android 构建。
- **真机测试**：蓝牙踏板、平板、Raspberry Pi（ARM64）以及启用了客户端隔离的 Wi‑Fi 网络。

发现了 bug 或有新想法？请提交 [issue](https://github.com/GNUXDAR/PromptFlow/issues/new/choose)。

## 许可证

[MIT](../../../LICENSE) © 2026 Arturo Cabrera。提交贡献即表示你同意你的贡献以同一许可证发布。
