# PromptFlow 贡献指南

> 译自[西班牙语原文](../../../CONTRIBUTING.md)。如有出入，以原文为准。

感谢你对 PromptFlow 感兴趣！本指南介绍如何提出修改，从修正一个错别字到添加一项完整的功能。第一次建议从头到尾通读，之后可按章节查阅。

> **注意：** 如果这是你第一次为开源项目做贡献，不必担心做得不够完美。一个出发点良好的小 PR 胜过没有 PR；其余的部分我们会在审查时帮你完善。

## 目录

1. [贡献方式](#贡献方式)
2. [开始之前](#开始之前)
3. [准备环境](#准备环境)
4. [分支模型](#分支模型)
5. [进行修改](#进行修改)
6. [提交信息](#提交信息)
7. [发起 pull request](#发起-pull-request)
8. [审查流程](#审查流程)
9. [合并之后](#合并之后)
10. [翻译](#翻译)
11. [礼仪与行为准则](#礼仪与行为准则)
12. [获取帮助](#获取帮助)

---

## 贡献方式

贡献不只是代码。以下这些都很有价值：

| 类型 | 示例 |
|---|---|
| **报告错误** | 某个功能出错、显示异常，或在你的设备上滚动不流畅。 |
| **提出想法** | 新功能、新快捷键、新的脚本格式。 |
| **代码** | 修复、功能、性能、测试。 |
| **文档** | 错别字、说明补充、示例、图表。 |
| **翻译** | 新增语言或改进现有语言（[见下文](#翻译)）。 |
| **硬件测试** | 蓝牙踏板、平板、Raspberry Pi、启用了客户端隔离的 Wi‑Fi 网络。 |
| **审查 PR** | 测试他人的 PR，并评论你观察到的情况。 |

## 开始之前

### 先搜索是否已存在

在提交 issue 或开始编码之前，请先搜索已打开的 [issues](https://github.com/GNUXDAR/PromptFlow/issues) 和 [pull requests](https://github.com/GNUXDAR/PromptFlow/pulls)。如果已有人在做同样的事，请在那里留言，避免重复劳动。

### 较大的修改请先提交 issue

| 修改规模 | 是否需要先提交 issue？ |
|---|---|
| 错别字、失效链接、表述不清 | 不需要：直接提交 PR。 |
| 修复一个小而明确的 bug | 建议，但非必需。 |
| 新功能、行为变更、协议或架构变更 | **需要。** 事先就方案达成一致，可以避免你的工作因设计分歧而被拒绝。 |

> **提示：** 在 issue 中留言“我来负责”，这样其他人就不会重复认领。如果之后无法继续，告诉大家一声就好，没关系。

### 适合入门的 issue

带有 `good first issue` 标签的 issue 范围明确、说明清晰，适合初次参与的人。带有 `help wanted` 标签的 issue 很重要，正在寻找志愿者。

## 准备环境

### 环境要求

- [Flutter](https://docs.flutter.dev/get-started/install) 稳定版（Dart 3）。
- Linux：Flutter 桌面端依赖（`clang`、`cmake`、`ninja-build`、`libgtk-3-dev`）。
- Android（可选）：Android SDK 以及一台设备或模拟器。

### Fork 与克隆

```bash
# 1. 在 GitHub 上 fork（“Fork”按钮），然后克隆
git clone https://github.com/<你的用户名>/PromptFlow.git
cd PromptFlow

# 2. 将原始仓库添加为 “upstream”
git remote add upstream https://github.com/GNUXDAR/PromptFlow.git

# 3. 安装依赖并确认一切正常
flutter pub get
flutter analyze
flutter test
```

### 语音（可选）

```bash
tool/setup_vosk_linux.sh      # libvosk + 适用于 Linux 的西班牙语模型
```

## 分支模型

| 分支 | 用途 | 谁来写入？ |
|---|---|---|
| `main` | 已发布的版本。始终稳定。 | 仅维护者，在发布版本时。 |
| `develop` | 集成即将发布的内容。**所有 PR 的目标分支。** | 任何人都不能直接写入：只能通过 PR。 |
| `tipo/descripcion` | 你的工作。每个主题一个分支。 | 你。 |

> **重要：** 切勿直接向 `main` 或 `develop` 提交 commit，也不要向 `main` 发起 PR。所有修改都通过向 `develop` 发起的 PR 合入。

### 分支命名

使用 `tipo/descripcion-corta` 格式，全部小写，用连字符分隔：

| 前缀 | 用途 | 示例 |
|---|---|---|
| `feat/` | 新功能 | `feat/follower-mode` |
| `fix/` | 修复 bug | `fix/pause-marker-skip` |
| `docs/` | 仅文档 | `docs/protocol-examples` |
| `i18n/` | 翻译 | `i18n/add-turkish` |
| `perf/` | 性能 | `perf/painter-culling` |
| `refactor/` | 不改变行为的重构 | `refactor/controller-commands` |
| `test/` | 仅测试 | `test/remote-reconnect` |
| `chore/` | 构建、依赖、CI | `chore/bump-flutter` |

```bash
git fetch upstream
git switch -c fix/pause-marker-skip upstream/develop
```

## 进行修改

### 一个 PR，一个主题

一个 PR 应该**只做一件事**。如果你在修复一个 bug 时又发现了另一个，请分别提交两个 PR。小的 PR 审查得更快，也更仔细。

| 规模 | 建议 |
|---|---|
| < 200 行 | 理想。 |
| 200–600 行 | 可以接受；请在描述中把结构解释清楚。 |
| > 600 行 | 拆分成多个 PR，或先提交 issue 规划各部分。 |

### 遵守架构

修改代码前请阅读 [`docs/ARCHITECTURE.md`](../en/ARCHITECTURE.md)。审查时最常检查的规则有：

- `domain/` 不依赖 Flutter 组件（widget）、套接字或文件。
- 每个控制操作都是一个 `PrompterCommand`，并经由 `PrompterController.execute` 执行，无论它来自键盘、踏板、遥控器还是语音。
- 动画循环内不得逐帧重建组件。
- 如果修改了协议，请同步更新 [`docs/PROTOCOL.md`](../en/PROTOCOL.md)。如果修改破坏了兼容性，请递增 `v` 字段。
- 面向用户的文本放在 `lib/l10n/` 中，绝不直接写在代码里（参见[翻译](#翻译)）。

### 测试

- 每个 bug 修复都应附带一个在没有该修复时会失败的测试。
- 每个包含逻辑的新功能（引擎、解析器、协议、语音）都应附带测试。
- 对于滚动引擎，请使用 `ScrollEngine.manual()` 和 `advance()`：测试是确定性的，不依赖时钟。

### 推送之前

```bash
dart format lib test integration_test
flutter analyze        # 无警告
flutter test           # 全部通过
```

## 提交信息

我们使用 [Conventional Commits（约定式提交）](https://www.conventionalcommits.org/zh-hans/v1.0.0/)：

```
类型(范围): 祈使语气的摘要，结尾不加句号

可选的正文：说明修改的原因，而不是做法。
每行控制在约 72 个字符以内。

Fixes #123
```

- **类型**：`feat`、`fix`、`docs`、`i18n`、`perf`、`refactor`、`test`、`chore`。
- **范围**（可选）：`engine`、`parser`、`remote`、`voice`、`editor`、`android`、`linux`、`l10n`…

| ✅ 正确 | ❌ 错误 |
|---|---|
| `fix(engine): stop exactly on pause markers at high WPM` | `arreglos` |
| `feat(remote): add follower role to the protocol` | `cambios varios en remote y engine y docs` |
| `docs(protocol): document cmd.goto payload` | `Update PROTOCOL.md` |

> **注意：** 合并时，你分支上的 commit 会被压缩（*squash*）为一个，因此最重要的是 **PR 标题**，它会成为最终的提交信息。

## 发起 pull request

### 1. 更新你的分支

```bash
git fetch upstream
git rebase upstream/develop
git push origin fix/pause-marker-skip
```

### 2. 向 `develop` 发起 PR

在 GitHub 上点击 “Compare & pull request”，并确认：

- **base repository:** `GNUXDAR/PromptFlow`，**base:** `develop`
- **head repository:** 你的 fork，**compare:** 你的分支

### 3. 标题

与 commit 使用相同的格式：`类型(范围): 摘要`。它将成为最终 commit 的信息。

### 4. 描述

PR 模板会自动填充。一个好的 PR 会回答四个问题：

1. **改了什么？** 用一两句话概括。
2. **为什么？** 它解决的问题，并链接到 issue：`Fixes #123`（合并时自动关闭）或 `Refs #123`（仅引用）。
3. **如何测试？** 给出具体步骤，让审查者能复现结果。
4. **你验证了什么？** 如实勾选模板中的检查清单。如果有无法测试的内容（例如你没有 Android 设备），请说明。

如果是视觉上的修改，请附上修改**前后**的截图或短视频。

> **优秀描述示例**
>
> 当速度超过 300 WPM 且同一行中有两个标记时，引擎会跳过 `[PAUSE 2s]` 标记，因为每帧只处理一个标记。
>
> Fixes #42
>
> **如何测试：** 以 350 WPM 打开 `test/fixtures/double_pause.md`；应当停顿两次。
>
> - [x] 新测试 `pausa doble en la misma línea`（没有修复时会失败）
> - [x] `flutter analyze` / `flutter test`
> - [ ] 在 Android 上测试（我没有设备）

### 5. 草稿 PR

如果你希望对尚未完成的工作尽早获得反馈，请将 PR 作为 **Draft** 打开。准备好后，再将其标记为 “Ready for review”。

### 6. 依赖其他 PR 的 PR（堆叠 PR）

如果你的 PR 依赖另一个尚未合并的 PR，请将那个 PR 的分支设为 base，并在描述中注明：“依赖 #12”。第一个 PR 合并后，GitHub 会自动把 base 改为 `develop`。

## 审查流程

### 预期情况

- 大约 **7 天内**会得到首次回复。如果超过两周仍无消息，欢迎在 PR 中留言提醒。
- 会收到一条或多条附带建议的评论。这很正常，并不代表 PR 不好。
- 自动检查（分析和测试）必须通过。

### 回复评论

- 在同一分支上以**新的 commit** 进行修改。有人审查之后不要改写历史（`push --force`）：这样审查者只会看到改动的部分。
- 回复每条评论：“已在 abc123 中完成”，或解释你为何提出不同方案。有理有据地表达异议是良好审查的一部分。
- 由发起讨论的人将其标记为已解决。

### 批准标准

满足以下条件时，PR 才会被合并：

- [ ] 只做一件事，且描述说明了做了什么以及为什么。
- [ ] 遵守本指南中的架构和约定。
- [ ] 新逻辑有测试，且所有检查均通过。
- [ ] 界面文本位于 `lib/l10n/` 中。
- [ ] 受影响的文档已更新。
- [ ] 至少一名维护者已批准。

合并由维护者在 `develop` 上通过 **Squash and merge** 完成。

## 合并之后

- 删除你的分支（GitHub 提供了一个按钮）。
- 同步你的 fork：
  ```bash
  git switch develop
  git fetch upstream
  git merge --ff-only upstream/develop
  git push origin develop
  ```
- 你的修改会随下一个发布版本进入 `main`。

## 翻译

界面文本位于 `lib/l10n/app_<语言>.arb`。参考文件是 `app_en.arb`。

- **修正翻译：** 编辑该语言的 `.arb` 文件，并提交一个 `i18n/…` PR。
- **新增语言：** 将 `app_en.arb` 复制为 `app_<代码>.arb`，**只翻译值**（切勿翻译键或 `{placeholders}`），并用 `flutter gen-l10n` 检查。
- **已翻译的文档：** 位于 `docs/i18n/<语言>/`。以西班牙语原文为准：如果你修改了某个文档，请在 PR 中说明相应译文已过时，或者一并更新译文。

## 礼仪与行为准则

本项目遵循 [Contributor Covenant 2.1](https://www.contributor-covenant.org/zh-cn/version/2/1/code_of_conduct/)。简而言之：

- 友善且耐心：每个 PR 和每次审查背后，都是一个人在投入自己的业余时间。
- 批评代码，而不是批评人。
- 假定对方是善意的，先提问再下结论。
- 用西班牙语或英语书写均可，随你喜欢。

不可接受的行为可以通过标记为机密的 issue 或 GitHub 私信，私下告知维护者。

## 获取帮助

- **不知道如何做某件事：** 提交一个带有 `question` 标签的 issue。
- **关于你的 PR 的疑问：** 直接在该 PR 中提问。
- **项目参考资料：** [`docs/ARCHITECTURE.md`](../en/ARCHITECTURE.md) 和 [`docs/PROTOCOL.md`](../en/PROTOCOL.md)。

感谢你的贡献！💛
