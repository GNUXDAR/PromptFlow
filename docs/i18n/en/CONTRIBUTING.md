# Contributing to PromptFlow

> Translated from the [Spanish original](../../../CONTRIBUTING.md). If they differ, the original prevails.

Thanks for your interest in PromptFlow! This guide explains how to propose changes, from fixing a typo to adding a complete feature. It is meant to be read top to bottom the first time and consulted section by section afterwards.

> **Note:** if this is your first contribution to an open source project, don't worry about getting everything perfect. A small, well-intentioned PR is better than none; we'll help you with the rest during review.

## Table of contents

1. [Ways to contribute](#ways-to-contribute)
2. [Before you start](#before-you-start)
3. [Setting up your environment](#setting-up-your-environment)
4. [Branching model](#branching-model)
5. [Making your changes](#making-your-changes)
6. [Commit messages](#commit-messages)
7. [Opening a pull request](#opening-a-pull-request)
8. [The review process](#the-review-process)
9. [After the merge](#after-the-merge)
10. [Translations](#translations)
11. [Etiquette and code of conduct](#etiquette-and-code-of-conduct)
12. [Getting help](#getting-help)

---

## Ways to contribute

It's not all code. All of these contributions are valuable:

| Type | Examples |
|---|---|
| **Reporting bugs** | Something fails, looks wrong, or scrolling isn't smooth on your machine. |
| **Proposing ideas** | A new feature, a shortcut, a script format. |
| **Code** | Fixes, features, performance, tests. |
| **Documentation** | Typos, clarifications, examples, diagrams. |
| **Translations** | New languages or improvements to existing ones ([see below](#translations)). |
| **Hardware testing** | Bluetooth pedals, tablets, Raspberry Pi, Wi‑Fi networks with client isolation. |
| **Reviewing PRs** | Testing someone else's PR and commenting on what you saw. |

## Before you start

### Check whether it already exists

Before opening an issue or starting to code, search the open [issues](https://github.com/GNUXDAR/PromptFlow/issues) and [pull requests](https://github.com/GNUXDAR/PromptFlow/pulls). If someone is already working on the same thing, comment there instead of duplicating the effort.

### Open an issue for big changes

| Size of the change | Do you need an issue first? |
|---|---|
| Typo, broken link, confusing text | No: open the PR directly. |
| Fix for a small, clear bug | Recommended, not required. |
| New feature, behavior change, protocol or architecture change | **Yes.** Agreeing on the approach first keeps your work from being rejected over a design disagreement. |

> **Tip:** comment "I'll take this" on the issue so nobody else picks it up. If you can't continue later, just let us know: that's fine.

### Starter issues

Issues labeled `good first issue` are scoped and explained for first-time contributors. Those labeled `help wanted` are important and looking for volunteers.

## Setting up your environment

### Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) stable (Dart 3).
- Linux: Flutter desktop dependencies (`clang`, `cmake`, `ninja-build`, `libgtk-3-dev`).
- Android (optional): Android SDK and a device or emulator.

### Fork and clone

```bash
# 1. Fork on GitHub ("Fork" button) and clone it
git clone https://github.com/<your-username>/PromptFlow.git
cd PromptFlow

# 2. Add the original repository as "upstream"
git remote add upstream https://github.com/GNUXDAR/PromptFlow.git

# 3. Install dependencies and check that everything works
flutter pub get
flutter analyze
flutter test
```

### Voice (optional)

```bash
tool/setup_vosk_linux.sh      # libvosk + Spanish model for Linux
```

## Branching model

| Branch | What it's for | Who writes to it? |
|---|---|---|
| `main` | Published releases. Always stable. | Maintainers only, when publishing a release. |
| `develop` | Integration of what will be released next. **Target of every PR.** | Nobody directly: only through PRs. |
| `type/description` | Your work. One branch per topic. | You. |

> **Important:** never commit directly to `main` or `develop`, and never open a PR against `main`. Everything goes in through a PR to `develop`.

### Branch names

Use `type/short-description` in lowercase with hyphens:

| Prefix | Use | Example |
|---|---|---|
| `feat/` | New feature | `feat/follower-mode` |
| `fix/` | Bug fix | `fix/pause-marker-skip` |
| `docs/` | Documentation only | `docs/protocol-examples` |
| `i18n/` | Translations | `i18n/add-turkish` |
| `perf/` | Performance | `perf/painter-culling` |
| `refactor/` | Restructuring without behavior change | `refactor/controller-commands` |
| `test/` | Tests only | `test/remote-reconnect` |
| `chore/` | Build, dependencies, CI | `chore/bump-flutter` |

```bash
git fetch upstream
git switch -c fix/pause-marker-skip upstream/develop
```

## Making your changes

### One PR, one topic

A PR should do **one thing only**. If you fix a bug and find another one along the way, open two PRs. Small PRs get reviewed sooner and more carefully.

| Size | Recommendation |
|---|---|
| < 200 lines | Ideal. |
| 200–600 lines | Acceptable; explain the structure well in the description. |
| > 600 lines | Split it into several PRs, or open an issue to plan the parts. |

### Respect the architecture

Read [`docs/ARCHITECTURE.md`](ARCHITECTURE.md) before touching code. The rules that get checked most in review are:

- `domain/` does not depend on Flutter widgets, sockets or files.
- Every control action is a `PrompterCommand` and goes through `PrompterController.execute`, whether it comes from the keyboard, the pedal, the remote control or voice.
- Nothing inside the animation loop rebuilds widgets per frame.
- If you change the protocol, update [`docs/PROTOCOL.md`](PROTOCOL.md). If the change breaks compatibility, bump the `v` field.
- User-visible strings go in `lib/l10n/`, never hardcoded (see [Translations](#translations)).

### Tests

- Every bug fix must come with a test that fails without the fix.
- Every new feature with logic (engine, parser, protocol, voice) must come with tests.
- For the scroll engine, use `ScrollEngine.manual()` and `advance()`: tests are deterministic and don't depend on the clock.

### Before pushing

```bash
dart format lib test integration_test
flutter analyze        # no warnings
flutter test           # all green
```

## Commit messages

We use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```
type(scope): imperative summary, no trailing period

Optional body: the why of the change, not the how.
Wrap lines at ~72 characters.

Fixes #123
```

- **type**: `feat`, `fix`, `docs`, `i18n`, `perf`, `refactor`, `test`, `chore`.
- **scope** (optional): `engine`, `parser`, `remote`, `voice`, `editor`, `android`, `linux`, `l10n`…

| ✅ Good | ❌ Bad |
|---|---|
| `fix(engine): stop exactly on pause markers at high WPM` | `fixes` |
| `feat(remote): add follower role to the protocol` | `misc changes in remote and engine and docs` |
| `docs(protocol): document cmd.goto payload` | `Update PROTOCOL.md` |

> **Note:** the commits on your branch are combined into one (*squash*) on merge, so what matters most is the **PR title**, which becomes the final message.

## Opening a pull request

### 1. Update your branch

```bash
git fetch upstream
git rebase upstream/develop
git push origin fix/pause-marker-skip
```

### 2. Create the PR against `develop`

On GitHub, click "Compare & pull request" and check:

- **base repository:** `GNUXDAR/PromptFlow`, **base:** `develop`
- **head repository:** your fork, **compare:** your branch

### 3. Title

Follow the same format as commits: `type(scope): summary`. It will be the final commit message.

### 4. Description

The PR template fills itself in. A good PR answers four questions:

1. **What changes?** A one- or two-sentence summary.
2. **Why?** The problem it solves, with a link to the issue: `Fixes #123` (closes it on merge) or `Refs #123` (only mentions it).
3. **How do I test it?** Concrete steps so the reviewer can reproduce the result.
4. **What did you verify?** The template checklist, ticked honestly. If there's something you couldn't test (for example, you don't have an Android device), say so.

If the change is visual, add **before and after** screenshots or a short video.

> **Example of a good description**
>
> The engine skipped the `[PAUSE 2s]` marker when two markers fell on the same line above 300 WPM, because only one marker was processed per frame.
>
> Fixes #42
>
> **How to test:** open `test/fixtures/double_pause.md` at 350 WPM; it should stop twice.
>
> - [x] New test `double pause on the same line` (fails without the fix)
> - [x] `flutter analyze` / `flutter test`
> - [ ] Tested on Android (I don't have a device)

### 5. Draft PR

If you want early feedback on unfinished work, open the PR as a **Draft**. Mark it "Ready for review" when it's ready.

### 6. PRs that depend on others (stacked)

If your PR needs another one that hasn't been merged yet, set that PR's branch as the base and say so in the description: "Depends on #12". When the first one is merged, GitHub will switch the base to `develop` automatically.

## The review process

### What to expect

- A first response within **about 7 days**. If more than two weeks go by without news, comment on the PR as a reminder: that's welcome.
- One or more comments with suggestions. That's normal and doesn't mean the PR is bad.
- The automated checks (analysis and tests) have to pass.

### Responding to comments

- Make the changes in **new commits** on the same branch. Don't rewrite history (`push --force`) after someone has reviewed: that way the reviewer sees only what changed.
- Reply to every comment: "Done in abc123", or explain why you're proposing something else. Disagreeing with reasons is part of a good review.
- Whoever opened a conversation is the one who marks it as resolved.

### Approval criteria

A PR is merged when:

- [ ] It does one thing and the description explains the what and the why.
- [ ] It respects the architecture and the conventions in this guide.
- [ ] It has tests for the new logic and all checks pass.
- [ ] UI strings are in `lib/l10n/`.
- [ ] Affected documentation is up to date.
- [ ] At least one maintainer has approved it.

A maintainer merges it with **Squash and merge** into `develop`.

## After the merge

- Delete your branch (GitHub offers a button).
- Sync your fork:
  ```bash
  git switch develop
  git fetch upstream
  git merge --ff-only upstream/develop
  git push origin develop
  ```
- Your change will reach `main` in the next published release.

## Translations

UI strings live in `lib/l10n/app_<language>.arb`. The reference file is `app_en.arb`.

- **Fixing a translation:** edit that language's `.arb` and open an `i18n/…` PR.
- **Adding a language:** copy `app_en.arb` to `app_<code>.arb`, translate **only the values** (never the keys or the `{placeholders}`) and check it with `flutter gen-l10n`.
- **Translated documentation:** lives in `docs/i18n/<language>/`. The Spanish original prevails: if you change a document, mention in the PR that the translations are now out of date, or update them.

## Etiquette and code of conduct

This project follows the [Contributor Covenant 2.1](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). In short:

- Be kind and patient: behind every PR and every review is a person giving up their free time.
- Criticize the code, not the people.
- Assume good faith and ask before assuming.
- Write in Spanish or English, whichever you prefer.

Unacceptable behavior can be reported privately to the maintainers through an issue marked as confidential or by direct message on GitHub.

## Getting help

- **Questions about how to do something:** open an issue with the `question` label.
- **Questions about your PR:** ask in the PR itself.
- **Project references:** [`docs/ARCHITECTURE.md`](ARCHITECTURE.md) and [`docs/PROTOCOL.md`](PROTOCOL.md).

Thanks for contributing! 💛
