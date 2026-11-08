# Leitfaden für Beiträge zu PromptFlow

> Aus dem spanischen Original übersetzt. Bei Abweichungen gilt das [Original](../../../CONTRIBUTING.md).

Danke für dein Interesse an PromptFlow! Dieser Leitfaden erklärt, wie du Änderungen vorschlägst – vom Beheben eines Tippfehlers bis zum Hinzufügen einer kompletten Funktion. Er ist dafür gedacht, beim ersten Mal von oben nach unten gelesen und danach abschnittsweise nachgeschlagen zu werden.

> **Hinweis:** Wenn das dein erster Beitrag zu einem Open-Source-Projekt ist, mach dir keine Sorgen, alles perfekt zu machen. Ein kleiner PR mit guter Absicht ist besser als keiner; beim Review helfen wir dir mit dem Rest.

## Inhaltsverzeichnis

1. [Möglichkeiten beizutragen](#möglichkeiten-beizutragen)
2. [Bevor du anfängst](#bevor-du-anfängst)
3. [Umgebung einrichten](#umgebung-einrichten)
4. [Branch-Modell](#branch-modell)
5. [Änderungen vornehmen](#änderungen-vornehmen)
6. [Commit-Nachrichten](#commit-nachrichten)
7. [Einen Pull Request öffnen](#einen-pull-request-öffnen)
8. [Der Review-Prozess](#der-review-prozess)
9. [Nach dem Merge](#nach-dem-merge)
10. [Übersetzungen](#übersetzungen)
11. [Umgangsformen und Verhaltenskodex](#umgangsformen-und-verhaltenskodex)
12. [Hilfe bekommen](#hilfe-bekommen)

---

## Möglichkeiten beizutragen

Nicht alles ist Code. All diese Beiträge sind wertvoll:

| Art | Beispiele |
|---|---|
| **Fehler melden** | Etwas schlägt fehl, sieht falsch aus oder das Scrollen ist auf deinem Gerät nicht flüssig. |
| **Ideen vorschlagen** | Eine neue Funktion, ein Tastenkürzel, ein Skriptformat. |
| **Code** | Fehlerbehebungen, Funktionen, Performance, Tests. |
| **Dokumentation** | Tippfehler, Klarstellungen, Beispiele, Diagramme. |
| **Übersetzungen** | Neue Sprachen oder Verbesserungen bestehender ([siehe unten](#übersetzungen)). |
| **Hardware-Tests** | Bluetooth-Pedale, Tablets, Raspberry Pi, WLAN-Netze mit Client-Isolation. |
| **PRs reviewen** | Den PR einer anderen Person testen und kommentieren, was dir aufgefallen ist. |

## Bevor du anfängst

### Prüfe, ob es das schon gibt

Bevor du ein Issue eröffnest oder mit dem Programmieren beginnst, durchsuche die offenen [Issues](https://github.com/GNUXDAR/PromptFlow/issues) und [Pull Requests](https://github.com/GNUXDAR/PromptFlow/pulls). Wenn schon jemand an derselben Sache arbeitet, kommentiere dort, statt die Arbeit doppelt zu machen.

### Eröffne ein Issue für größere Änderungen

| Umfang der Änderung | Vorher ein Issue nötig? |
|---|---|
| Tippfehler, defekter Link, unklarer Text | Nein: Öffne direkt den PR. |
| Behebung eines kleinen, klaren Bugs | Empfohlen, nicht verpflichtend. |
| Neue Funktion, geändertes Verhalten, Änderung am Protokoll oder an der Architektur | **Ja.** Wer den Ansatz vorher abstimmt, verhindert, dass die Arbeit wegen einer Meinungsverschiedenheit beim Design abgelehnt wird. |

> **Tipp:** Kommentiere im Issue „Ich übernehme das“, damit niemand sonst es aufgreift. Wenn du später nicht weitermachen kannst, sag Bescheid: Das ist kein Problem.

### Issues für den Einstieg

Issues mit dem Label `good first issue` sind klar abgegrenzt und für Neulinge erklärt. Die mit `help wanted` sind wichtig und suchen Freiwillige.

## Umgebung einrichten

### Voraussetzungen

- [Flutter](https://docs.flutter.dev/get-started/install) Stable (Dart 3).
- Linux: Desktop-Abhängigkeiten von Flutter (`clang`, `cmake`, `ninja-build`, `libgtk-3-dev`).
- Android (optional): Android SDK und ein Gerät oder Emulator.

### Fork und Klonen

```bash
# 1. Erstelle auf GitHub einen Fork (Schaltfläche „Fork“) und klone ihn
git clone https://github.com/<dein-benutzer>/PromptFlow.git
cd PromptFlow

# 2. Füge das Original-Repository als „upstream“ hinzu
git remote add upstream https://github.com/GNUXDAR/PromptFlow.git

# 3. Installiere die Abhängigkeiten und prüfe, ob alles funktioniert
flutter pub get
flutter analyze
flutter test
```

### Sprache (optional)

```bash
tool/setup_vosk_linux.sh      # libvosk + spanisches Modell für Linux
```

## Branch-Modell

| Branch | Wofür er da ist | Wer schreibt? |
|---|---|---|
| `main` | Veröffentlichte Versionen. Immer stabil. | Nur Maintainer, beim Veröffentlichen einer Version. |
| `develop` | Integration dessen, was als Nächstes veröffentlicht wird. **Ziel aller PRs.** | Niemand direkt: nur über PRs. |
| `typ/beschreibung` | Deine Arbeit. Ein Branch pro Thema. | Du. |

> **Wichtig:** Committe nie direkt auf `main` oder `develop` und öffne keinen PR gegen `main`. Alles kommt über einen PR nach `develop`.

### Branch-Namen

Verwende `typ/kurze-beschreibung` in Kleinbuchstaben und mit Bindestrichen:

| Präfix | Verwendung | Beispiel |
|---|---|---|
| `feat/` | Neue Funktion | `feat/follower-mode` |
| `fix/` | Behebung eines Bugs | `fix/pause-marker-skip` |
| `docs/` | Nur Dokumentation | `docs/protocol-examples` |
| `i18n/` | Übersetzungen | `i18n/add-turkish` |
| `perf/` | Performance | `perf/painter-culling` |
| `refactor/` | Umstrukturierung ohne Verhaltensänderung | `refactor/controller-commands` |
| `test/` | Nur Tests | `test/remote-reconnect` |
| `chore/` | Build, Abhängigkeiten, CI | `chore/bump-flutter` |

```bash
git fetch upstream
git switch -c fix/pause-marker-skip upstream/develop
```

## Änderungen vornehmen

### Ein PR, ein Thema

Ein PR sollte **genau eine Sache** tun. Wenn du einen Bug behebst und dabei einen weiteren entdeckst, öffne zwei PRs. Kleine PRs werden schneller und sorgfältiger reviewt.

| Umfang | Empfehlung |
|---|---|
| < 200 Zeilen | Ideal. |
| 200–600 Zeilen | Akzeptabel; erkläre die Struktur gut in der Beschreibung. |
| > 600 Zeilen | Teile ihn in mehrere PRs auf oder eröffne ein Issue, um die Teile zu planen. |

### Halte dich an die Architektur

Lies [`docs/ARCHITECTURE.md`](../en/ARCHITECTURE.md), bevor du Code anfasst. Die Regeln, auf die im Review am meisten geachtet wird:

- `domain/` hängt nicht von Flutter-Widgets, Sockets oder Dateien ab.
- Jede Steueraktion ist ein `PrompterCommand` und läuft über `PrompterController.execute`, egal ob sie von der Tastatur, vom Pedal, von der Fernbedienung oder von der Sprache kommt.
- Nichts in der Animationsschleife baut Widgets pro Frame neu auf.
- Wenn du das Protokoll änderst, aktualisiere [`docs/PROTOCOL.md`](../en/PROTOCOL.md). Bricht die Änderung die Kompatibilität, erhöhe das Feld `v`.
- Für Nutzer sichtbare Texte gehören nach `lib/l10n/` und werden nie direkt in den Code geschrieben (siehe [Übersetzungen](#übersetzungen)).

### Tests

- Jede Fehlerbehebung braucht einen Test, der ohne die Behebung fehlschlägt.
- Jede neue Funktion mit Logik (Engine, Parser, Protokoll, Sprache) braucht Tests.
- Verwende für die Scroll-Engine `ScrollEngine.manual()` und `advance()`: Die Tests sind deterministisch und hängen nicht von der Uhr ab.

### Vor dem Pushen

```bash
dart format lib test integration_test
flutter analyze        # ohne Warnungen
flutter test           # alles grün
```

## Commit-Nachrichten

Wir verwenden [Conventional Commits](https://www.conventionalcommits.org/de/v1.0.0/):

```
typ(bereich): Zusammenfassung im Imperativ, ohne Punkt am Ende

Optionaler Body: das Warum der Änderung, nicht das Wie.
Zeilen bei ~72 Zeichen umbrechen.

Fixes #123
```

- **typ**: `feat`, `fix`, `docs`, `i18n`, `perf`, `refactor`, `test`, `chore`.
- **bereich** (optional): `engine`, `parser`, `remote`, `voice`, `editor`, `android`, `linux`, `l10n`…

| ✅ Gut | ❌ Schlecht |
|---|---|
| `fix(engine): stop exactly on pause markers at high WPM` | `arreglos` |
| `feat(remote): add follower role to the protocol` | `cambios varios en remote y engine y docs` |
| `docs(protocol): document cmd.goto payload` | `Update PROTOCOL.md` |

> **Hinweis:** Die Commits deines Branches werden beim Merge zu einem einzigen zusammengefasst (*Squash*). Am wichtigsten ist daher der **Titel des PR**, der zur endgültigen Commit-Nachricht wird.

## Einen Pull Request öffnen

### 1. Aktualisiere deinen Branch

```bash
git fetch upstream
git rebase upstream/develop
git push origin fix/pause-marker-skip
```

### 2. Erstelle den PR gegen `develop`

Klicke auf GitHub auf „Compare & pull request“ und prüfe:

- **base repository:** `GNUXDAR/PromptFlow`, **base:** `develop`
- **head repository:** dein Fork, **compare:** dein Branch

### 3. Titel

Folge demselben Format wie bei den Commits: `typ(bereich): Zusammenfassung`. Das wird die Nachricht des endgültigen Commits.

### 4. Beschreibung

Die PR-Vorlage wird automatisch eingefügt. Ein guter PR beantwortet vier Fragen:

1. **Was ändert sich?** Eine Zusammenfassung in ein oder zwei Sätzen.
2. **Warum?** Das gelöste Problem, mit Link zum Issue: `Fixes #123` (schließt es beim Merge) oder `Refs #123` (erwähnt es nur).
3. **Wie teste ich das?** Konkrete Schritte, damit die reviewende Person das Ergebnis nachvollziehen kann.
4. **Was hast du überprüft?** Die Checkliste der Vorlage, ehrlich abgehakt. Wenn du etwas nicht testen konntest (zum Beispiel, weil du kein Android-Gerät hast), sag es.

Bei visuellen Änderungen füge Screenshots oder ein kurzes Video **vorher und nachher** hinzu.

> **Beispiel für eine gute Beschreibung**
>
> Die Engine übersprang die Marke `[PAUSE 2s]`, wenn zwei Marken bei mehr als 300 WPM in dieselbe Zeile fielen, weil pro Frame nur eine Marke verarbeitet wurde.
>
> Fixes #42
>
> **So testest du es:** Öffne `test/fixtures/double_pause.md` mit 350 WPM; es muss zweimal anhalten.
>
> - [x] Neuer Test `pausa doble en la misma línea` (schlägt ohne die Behebung fehl)
> - [x] `flutter analyze` / `flutter test`
> - [ ] Auf Android getestet (ich habe kein Gerät)

### 5. PR als Entwurf

Wenn du frühes Feedback zu einer unfertigen Arbeit möchtest, öffne den PR als **Draft**. Markiere ihn als „Ready for review“, wenn er fertig ist.

### 6. PRs, die von anderen abhängen (gestapelt)

Wenn dein PR einen anderen braucht, der noch nicht integriert ist, setze den Branch dieses anderen PR als Basis und vermerke es in der Beschreibung: „Hängt ab von #12“. Sobald der erste integriert ist, ändert GitHub die Basis automatisch auf `develop`.

## Der Review-Prozess

### Was dich erwartet

- Eine erste Antwort innerhalb von **etwa 7 Tagen**. Wenn mehr als zwei Wochen ohne Rückmeldung vergehen, kommentiere im PR, um daran zu erinnern: Das ist ausdrücklich erwünscht.
- Ein oder mehrere Kommentare mit Vorschlägen. Das ist normal und bedeutet nicht, dass der PR schlecht ist.
- Die automatischen Prüfungen (Analyse und Tests) müssen bestehen.

### Auf Kommentare antworten

- Nimm die Änderungen in **neuen Commits** auf demselben Branch vor. Schreibe die Historie nicht um (`push --force`), nachdem jemand reviewt hat: So sieht die reviewende Person nur, was sich geändert hat.
- Antworte auf jeden Kommentar: „Erledigt in abc123“, oder erkläre, warum du etwas anderes vorschlägst. Begründeter Widerspruch gehört zu einem guten Review.
- Wer eine Konversation eröffnet hat, markiert sie auch als gelöst.

### Kriterien für die Freigabe

Ein PR wird integriert, wenn er:

- [ ] Genau eine Sache tut und die Beschreibung das Was und das Warum erklärt.
- [ ] Die Architektur und die Konventionen dieses Leitfadens einhält.
- [ ] Tests für die neue Logik hat und alle Prüfungen bestehen.
- [ ] Die Oberflächentexte in `lib/l10n/` hat.
- [ ] Die betroffene Dokumentation aktualisiert.
- [ ] Von mindestens einem Maintainer freigegeben wurde.

Der Merge erfolgt durch einen Maintainer per **Squash and merge** nach `develop`.

## Nach dem Merge

- Lösche deinen Branch (GitHub bietet dafür eine Schaltfläche).
- Synchronisiere deinen Fork:
  ```bash
  git switch develop
  git fetch upstream
  git merge --ff-only upstream/develop
  git push origin develop
  ```
- Deine Änderung landet mit der nächsten veröffentlichten Version in `main`.

## Übersetzungen

Die Texte der Oberfläche liegen in `lib/l10n/app_<sprache>.arb`. Die Referenzdatei ist `app_en.arb`.

- **Eine Übersetzung korrigieren:** Bearbeite die `.arb`-Datei dieser Sprache und öffne einen PR `i18n/…`.
- **Eine Sprache hinzufügen:** Kopiere `app_en.arb` als `app_<code>.arb`, übersetze **nur die Werte** (nie die Schlüssel oder die `{placeholders}`) und prüfe mit `flutter gen-l10n`.
- **Übersetzte Dokumentation:** liegt in `docs/i18n/<sprache>/`. Das spanische Original ist maßgeblich: Wenn du ein Dokument änderst, weise im PR darauf hin, dass die Übersetzungen nun veraltet sind, oder aktualisiere sie.

## Umgangsformen und Verhaltenskodex

Dieses Projekt folgt dem [Contributor Covenant 2.1](https://www.contributor-covenant.org/de/version/2/1/code_of_conduct/). Kurz gesagt:

- Sei freundlich und geduldig: Hinter jedem PR und jedem Review steht ein Mensch, der seine Freizeit investiert.
- Kritisiere den Code, nicht die Menschen.
- Geh von guten Absichten aus und frag nach, bevor du etwas unterstellst.
- Schreib auf Spanisch oder Englisch, wie du möchtest.

Inakzeptables Verhalten kann den Maintainern vertraulich gemeldet werden, über ein als vertraulich markiertes Issue oder per Direktnachricht auf GitHub.

## Hilfe bekommen

- **Fragen, wie man etwas macht:** Eröffne ein Issue mit dem Label `question`.
- **Fragen zu deinem PR:** Frag direkt im PR.
- **Projektreferenzen:** [`docs/ARCHITECTURE.md`](../en/ARCHITECTURE.md) und [`docs/PROTOCOL.md`](../en/PROTOCOL.md).

Danke für deinen Beitrag! 💛
