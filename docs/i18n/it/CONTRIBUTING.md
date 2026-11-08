# Guida per contribuire a PromptFlow

> Tradotto dall'originale in spagnolo. In caso di discrepanze, prevale l'[originale](../../../CONTRIBUTING.md).

Grazie per il tuo interesse in PromptFlow! Questa guida spiega come proporre modifiche, dalla correzione di un refuso all'aggiunta di una funzionalità completa. È pensata per essere letta dall'inizio alla fine la prima volta e consultata per sezioni in seguito.

> **Nota:** se è il tuo primo contributo a un progetto open source, non preoccuparti di fare tutto alla perfezione. Una PR piccola e fatta con buone intenzioni è meglio di nessuna; durante la revisione ti aiuteremo con il resto.

## Indice

1. [Modi di contribuire](#modi-di-contribuire)
2. [Prima di iniziare](#prima-di-iniziare)
3. [Preparare l'ambiente](#preparare-lambiente)
4. [Modello dei branch](#modello-dei-branch)
5. [Apportare le modifiche](#apportare-le-modifiche)
6. [Messaggi di commit](#messaggi-di-commit)
7. [Aprire una pull request](#aprire-una-pull-request)
8. [Il processo di revisione](#il-processo-di-revisione)
9. [Dopo il merge](#dopo-il-merge)
10. [Traduzioni](#traduzioni)
11. [Galateo e codice di condotta](#galateo-e-codice-di-condotta)
12. [Ottenere aiuto](#ottenere-aiuto)

---

## Modi di contribuire

Non è tutto codice. Tutti questi contributi sono preziosi:

| Tipo | Esempi |
|---|---|
| **Segnalare errori** | Qualcosa non funziona, si vede male o lo scorrimento non è fluido sul tuo computer. |
| **Proporre idee** | Una nuova funzionalità, una scorciatoia, un formato di copione. |
| **Codice** | Correzioni, funzionalità, prestazioni, test. |
| **Documentazione** | Refusi, chiarimenti, esempi, diagrammi. |
| **Traduzioni** | Nuove lingue o miglioramenti a quelle esistenti ([vedi sotto](#traduzioni)). |
| **Test su hardware** | Pedali Bluetooth, tablet, Raspberry Pi, reti Wi‑Fi con isolamento. |
| **Revisionare PR** | Provare la PR di un'altra persona e commentare ciò che hai visto. |

## Prima di iniziare

### Controlla se esiste già

Prima di aprire una issue o iniziare a programmare, cerca tra le [issue](https://github.com/GNUXDAR/PromptFlow/issues) e le [pull request](https://github.com/GNUXDAR/PromptFlow/pulls) aperte. Se qualcuno sta già lavorando alla stessa cosa, commenta lì invece di duplicare lo sforzo.

### Apri una issue per le modifiche importanti

| Entità della modifica | Serve prima una issue? |
|---|---|
| Refuso, link non funzionante, testo poco chiaro | No: apri direttamente la PR. |
| Correzione di un bug piccolo e chiaro | Consigliato, non obbligatorio. |
| Nuova funzionalità, modifica del comportamento, modifica del protocollo o dell'architettura | **Sì.** Concordare prima l'approccio evita che il tuo lavoro venga rifiutato per un disaccordo di design. |

> **Consiglio:** commenta nella issue «Me ne occupo io» così nessun altro la prende. Se poi non riesci a continuare, avvisa: non c'è problema.

### Issue per iniziare

Le issue con l'etichetta `good first issue` sono circoscritte e spiegate per chi arriva per la prima volta. Quelle con `help wanted` sono importanti e cercano volontari.

## Preparare l'ambiente

### Requisiti

- [Flutter](https://docs.flutter.dev/get-started/install) stabile (Dart 3).
- Linux: dipendenze desktop di Flutter (`clang`, `cmake`, `ninja-build`, `libgtk-3-dev`).
- Android (opzionale): Android SDK e un dispositivo o un emulatore.

### Fork e clonazione

```bash
# 1. Crea un fork da GitHub (pulsante «Fork») e clonalo
git clone https://github.com/<tuo-utente>/PromptFlow.git
cd PromptFlow

# 2. Aggiungi il repository originale come «upstream»
git remote add upstream https://github.com/GNUXDAR/PromptFlow.git

# 3. Installa le dipendenze e verifica che tutto funzioni
flutter pub get
flutter analyze
flutter test
```

### Voce (opzionale)

```bash
tool/setup_vosk_linux.sh      # libvosk + modello spagnolo per Linux
```

## Modello dei branch

| Branch | A cosa serve | Chi ci scrive? |
|---|---|---|
| `main` | Versioni pubblicate. Sempre stabile. | Solo i maintainer, quando pubblicano una versione. |
| `develop` | Integrazione di ciò che verrà pubblicato a breve. **Destinazione di tutte le PR.** | Nessuno direttamente: solo tramite PR. |
| `tipo/descrizione` | Il tuo lavoro. Un branch per argomento. | Tu. |

> **Importante:** non fare mai commit diretti su `main` né su `develop`, e non aprire PR verso `main`. Tutto entra tramite una PR verso `develop`.

### Nomi dei branch

Usa `tipo/descrizione-breve` in minuscolo e con trattini:

| Prefisso | Uso | Esempio |
|---|---|---|
| `feat/` | Nuova funzionalità | `feat/follower-mode` |
| `fix/` | Correzione di un bug | `fix/pause-marker-skip` |
| `docs/` | Solo documentazione | `docs/protocol-examples` |
| `i18n/` | Traduzioni | `i18n/add-turkish` |
| `perf/` | Prestazioni | `perf/painter-culling` |
| `refactor/` | Riorganizzazione senza modifiche al comportamento | `refactor/controller-commands` |
| `test/` | Solo test | `test/remote-reconnect` |
| `chore/` | Build, dipendenze, CI | `chore/bump-flutter` |

```bash
git fetch upstream
git switch -c fix/pause-marker-skip upstream/develop
```

## Apportare le modifiche

### Una PR, un argomento

Una PR deve fare **una sola cosa**. Se correggi un bug e ne scopri un altro, apri due PR. Le PR piccole vengono revisionate prima e con più attenzione.

| Dimensione | Raccomandazione |
|---|---|
| < 200 righe | Ideale. |
| 200–600 righe | Accettabile; spiega bene la struttura nella descrizione. |
| > 600 righe | Dividila in più PR, oppure apri una issue per pianificare le parti. |

### Rispetta l'architettura

Leggi [`docs/ARCHITECTURE.md`](../en/ARCHITECTURE.md) prima di toccare il codice. Le regole più controllate in revisione sono:

- `domain/` non dipende da widget di Flutter, socket né file.
- Ogni azione di controllo è un `PrompterCommand` e passa da `PrompterController.execute`, che arrivi dalla tastiera, dal pedale, dal telecomando o dalla voce.
- Niente all'interno del ciclo di animazione ricostruisce widget a ogni frame.
- Se modifichi il protocollo, aggiorna [`docs/PROTOCOL.md`](../en/PROTOCOL.md). Se la modifica rompe la compatibilità, incrementa il campo `v`.
- I testi visibili all'utente vanno in `lib/l10n/`, mai scritti direttamente nel codice (vedi [Traduzioni](#traduzioni)).

### Test

- Ogni correzione di bug deve includere un test che fallisca senza la correzione.
- Ogni nuova funzionalità con logica (motore, parser, protocollo, voce) deve includere dei test.
- Per il motore di scorrimento usa `ScrollEngine.manual()` e `advance()`: i test sono deterministici e non dipendono dall'orologio.

### Prima di fare push

```bash
dart format lib test integration_test
flutter analyze        # senza avvisi
flutter test           # tutto verde
```

## Messaggi di commit

Usiamo [Conventional Commits](https://www.conventionalcommits.org/it/v1.0.0/):

```
tipo(ambito): riepilogo all'imperativo, senza punto finale

Corpo opzionale: il perché della modifica, non il come.
Manda a capo le righe a ~72 caratteri.

Fixes #123
```

- **tipo**: `feat`, `fix`, `docs`, `i18n`, `perf`, `refactor`, `test`, `chore`.
- **ambito** (opzionale): `engine`, `parser`, `remote`, `voice`, `editor`, `android`, `linux`, `l10n`…

| ✅ Bene | ❌ Male |
|---|---|
| `fix(engine): stop exactly on pause markers at high WPM` | `arreglos` |
| `feat(remote): add follower role to the protocol` | `cambios varios en remote y engine y docs` |
| `docs(protocol): document cmd.goto payload` | `Update PROTOCOL.md` |

> **Nota:** i commit del tuo branch vengono combinati in uno solo (*squash*) al momento del merge, quindi la cosa più importante è il **titolo della PR**, che diventa il messaggio finale.

## Aprire una pull request

### 1. Aggiorna il tuo branch

```bash
git fetch upstream
git rebase upstream/develop
git push origin fix/pause-marker-skip
```

### 2. Crea la PR verso `develop`

Su GitHub, premi «Compare & pull request» e verifica:

- **base repository:** `GNUXDAR/PromptFlow`, **base:** `develop`
- **head repository:** il tuo fork, **compare:** il tuo branch

### 3. Titolo

Segui lo stesso formato dei commit: `tipo(ambito): riepilogo`. Sarà il messaggio del commit finale.

### 4. Descrizione

Il template della PR si compila da solo. Una buona PR risponde a quattro domande:

1. **Cosa cambia?** Un riepilogo in una o due frasi.
2. **Perché?** Il problema che risolve, con link alla issue: `Fixes #123` (la chiude al merge) o `Refs #123` (la menziona soltanto).
3. **Come lo provo?** Passaggi concreti perché chi revisiona possa riprodurre il risultato.
4. **Cosa hai verificato?** La checklist del template, spuntata con onestà. Se non hai potuto provare qualcosa (per esempio, non hai un dispositivo Android), dillo.

Se la modifica è visiva, aggiungi screenshot o un breve video **prima e dopo**.

> **Esempio di buona descrizione**
>
> Il motore saltava il marcatore `[PAUSE 2s]` quando due marcatori cadevano sulla stessa riga a più di 300 WPM, perché veniva elaborato un solo marcatore per frame.
>
> Fixes #42
>
> **Come provare:** apri `test/fixtures/double_pause.md` a 350 WPM; deve fermarsi due volte.
>
> - [x] Nuovo test `pausa doble en la misma línea` (fallisce senza la correzione)
> - [x] `flutter analyze` / `flutter test`
> - [ ] Provato su Android (non ho un dispositivo)

### 5. PR in bozza

Se vuoi un parere presto su un lavoro non finito, apri la PR come **Draft**. Segnala come «Ready for review» quando è pronta.

### 6. PR che dipendono da altre (impilate)

Se la tua PR ha bisogno di un'altra non ancora integrata, imposta come base il branch di quell'altra PR e indicalo nella descrizione: «Dipende da #12». Quando la prima verrà integrata, GitHub cambierà automaticamente la base in `develop`.

## Il processo di revisione

### Cosa aspettarsi

- Una prima risposta entro **circa 7 giorni**. Se passano più di due settimane senza notizie, commenta nella PR per ricordarlo: è gradito.
- Uno o più commenti con suggerimenti. È normale e non significa che la PR sia fatta male.
- I controlli automatici (analisi e test) devono passare.

### Rispondere ai commenti

- Apporta le modifiche in **nuovi commit** sullo stesso branch. Non riscrivere la cronologia (`push --force`) dopo che qualcuno ha già revisionato: così chi revisiona vede solo ciò che è cambiato.
- Rispondi a ogni commento: «Fatto in abc123», oppure spiega perché proponi qualcos'altro. Dissentire con argomenti fa parte di una buona revisione.
- Chi ha aperto una conversazione è chi la segna come risolta.

### Criteri di approvazione

Una PR viene integrata quando:

- [ ] Fa una sola cosa e la descrizione spiega il cosa e il perché.
- [ ] Rispetta l'architettura e le convenzioni di questa guida.
- [ ] Ha test per la nuova logica e tutti i controlli passano.
- [ ] I testi dell'interfaccia sono in `lib/l10n/`.
- [ ] La documentazione interessata è aggiornata.
- [ ] Almeno un maintainer l'ha approvata.

Il merge lo esegue un maintainer con **Squash and merge** su `develop`.

## Dopo il merge

- Elimina il tuo branch (GitHub offre un pulsante).
- Sincronizza il tuo fork:
  ```bash
  git switch develop
  git fetch upstream
  git merge --ff-only upstream/develop
  git push origin develop
  ```
- La tua modifica arriverà in `main` con la prossima versione pubblicata.

## Traduzioni

I testi dell'interfaccia si trovano in `lib/l10n/app_<lingua>.arb`. Il file di riferimento è `app_en.arb`.

- **Correggere una traduzione:** modifica il `.arb` di quella lingua e apri una PR `i18n/…`.
- **Aggiungere una lingua:** copia `app_en.arb` come `app_<codice>.arb`, traduci **solo i valori** (mai le chiavi né i `{placeholders}`) e verifica con `flutter gen-l10n`.
- **Documentazione tradotta:** si trova in `docs/i18n/<lingua>/`. L'originale in spagnolo prevale: se modifichi un documento, segnala nella PR che le traduzioni non sono più aggiornate, oppure aggiornale.

## Galateo e codice di condotta

Questo progetto segue il [Contributor Covenant 2.1](https://www.contributor-covenant.org/it/version/2/1/code_of_conduct/). In sintesi:

- Sii gentile e paziente: dietro ogni PR e ogni revisione c'è una persona che dedica il proprio tempo libero.
- Critica il codice, non le persone.
- Presumi la buona fede e chiedi prima di dare per scontato.
- Scrivi in spagnolo o in inglese, come preferisci.

I comportamenti inaccettabili possono essere segnalati in privato ai maintainer tramite una issue contrassegnata come riservata o con un messaggio diretto su GitHub.

## Ottenere aiuto

- **Dubbi su come fare qualcosa:** apri una issue con l'etichetta `question`.
- **Dubbi sulla tua PR:** chiedi nella PR stessa.
- **Riferimenti del progetto:** [`docs/ARCHITECTURE.md`](../en/ARCHITECTURE.md) e [`docs/PROTOCOL.md`](../en/PROTOCOL.md).

Grazie per il tuo contributo! 💛
