# Guide de contribution à PromptFlow

> Traduit de l'original en espagnol. En cas de divergence, l'[original](../../../CONTRIBUTING.md) fait foi.

Merci de votre intérêt pour PromptFlow ! Ce guide explique comment proposer des modifications, de la correction d'une coquille à l'ajout d'une fonctionnalité complète. Il est conçu pour être lu de haut en bas la première fois, puis consulté section par section.

> **Remarque :** si c'est votre première contribution à un projet open source, ne cherchez pas à tout faire parfaitement. Une petite PR bien intentionnée vaut mieux que rien ; lors de la revue, nous vous aiderons pour le reste.

## Sommaire

1. [Façons de contribuer](#façons-de-contribuer)
2. [Avant de commencer](#avant-de-commencer)
3. [Préparer l'environnement](#préparer-lenvironnement)
4. [Modèle de branches](#modèle-de-branches)
5. [Faire vos modifications](#faire-vos-modifications)
6. [Messages de commit](#messages-de-commit)
7. [Ouvrir une pull request](#ouvrir-une-pull-request)
8. [Le processus de revue](#le-processus-de-revue)
9. [Après le merge](#après-le-merge)
10. [Traductions](#traductions)
11. [Étiquette et code de conduite](#étiquette-et-code-de-conduite)
12. [Obtenir de l'aide](#obtenir-de-laide)

---

## Façons de contribuer

Tout n'est pas du code. Toutes ces contributions ont de la valeur :

| Type | Exemples |
|---|---|
| **Signaler des bugs** | Quelque chose plante, s'affiche mal ou le défilement n'est pas fluide sur votre machine. |
| **Proposer des idées** | Une nouvelle fonctionnalité, un raccourci, un format de script. |
| **Code** | Corrections, fonctionnalités, performances, tests. |
| **Documentation** | Coquilles, clarifications, exemples, diagrammes. |
| **Traductions** | Nouvelles langues ou améliorations des langues existantes ([voir plus bas](#traductions)). |
| **Tests sur matériel** | Pédales Bluetooth, tablettes, Raspberry Pi, réseaux Wi‑Fi avec isolation. |
| **Relire des PR** | Tester la PR de quelqu'un d'autre et commenter ce que vous avez constaté. |

## Avant de commencer

### Vérifiez si cela existe déjà

Avant d'ouvrir une issue ou de commencer à coder, cherchez parmi les [issues](https://github.com/GNUXDAR/PromptFlow/issues) et les [pull requests](https://github.com/GNUXDAR/PromptFlow/pulls) ouvertes. Si quelqu'un travaille déjà sur le même sujet, commentez là-bas au lieu de dupliquer l'effort.

### Ouvrez une issue pour les changements importants

| Taille du changement | Faut-il une issue au préalable ? |
|---|---|
| Coquille, lien cassé, texte confus | Non : ouvrez directement la PR. |
| Correction d'un bug petit et clair | Recommandé, pas obligatoire. |
| Nouvelle fonctionnalité, changement de comportement, changement de protocole ou d'architecture | **Oui.** Se mettre d'accord sur l'approche au préalable évite que votre travail soit refusé pour un désaccord de conception. |

> **Conseil :** commentez « Je m'en occupe » dans l'issue pour que personne d'autre ne la prenne. Si vous ne pouvez finalement pas continuer, prévenez : ce n'est pas grave.

### Issues pour débuter

Les issues portant le label `good first issue` sont bien délimitées et expliquées pour les nouveaux venus. Celles marquées `help wanted` sont importantes et recherchent des volontaires.

## Préparer l'environnement

### Prérequis

- [Flutter](https://docs.flutter.dev/get-started/install) stable (Dart 3).
- Linux : dépendances desktop de Flutter (`clang`, `cmake`, `ninja-build`, `libgtk-3-dev`).
- Android (facultatif) : Android SDK et un appareil ou un émulateur.

### Fork et clonage

```bash
# 1. Créez un fork depuis GitHub (bouton « Fork ») et clonez-le
git clone https://github.com/<votre-utilisateur>/PromptFlow.git
cd PromptFlow

# 2. Ajoutez le dépôt d'origine comme « upstream »
git remote add upstream https://github.com/GNUXDAR/PromptFlow.git

# 3. Installez les dépendances et vérifiez que tout fonctionne
flutter pub get
flutter analyze
flutter test
```

### Voix (facultatif)

```bash
tool/setup_vosk_linux.sh      # libvosk + modèle espagnol pour Linux
```

## Modèle de branches

| Branche | À quoi elle sert | Qui y écrit ? |
|---|---|---|
| `main` | Versions publiées. Toujours stable. | Uniquement les mainteneurs, lors de la publication d'une version. |
| `develop` | Intégration de ce qui sera publié prochainement. **Cible de toutes les PR.** | Personne directement : uniquement via PR. |
| `type/description` | Votre travail. Une branche par sujet. | Vous. |

> **Important :** ne faites jamais de commits directement sur `main` ni sur `develop`, et n'ouvrez jamais de PR vers `main`. Tout passe par une PR vers `develop`.

### Noms de branche

Utilisez `type/description-courte` en minuscules, avec des tirets :

| Préfixe | Usage | Exemple |
|---|---|---|
| `feat/` | Nouvelle fonctionnalité | `feat/follower-mode` |
| `fix/` | Correction d'un bug | `fix/pause-marker-skip` |
| `docs/` | Documentation uniquement | `docs/protocol-examples` |
| `i18n/` | Traductions | `i18n/add-turkish` |
| `perf/` | Performances | `perf/painter-culling` |
| `refactor/` | Réorganisation sans changement de comportement | `refactor/controller-commands` |
| `test/` | Tests uniquement | `test/remote-reconnect` |
| `chore/` | Build, dépendances, CI | `chore/bump-flutter` |

```bash
git fetch upstream
git switch -c fix/pause-marker-skip upstream/develop
```

## Faire vos modifications

### Une PR, un sujet

Une PR doit faire **une seule chose**. Si vous corrigez un bug et en découvrez un autre, ouvrez deux PR. Les petites PR sont relues plus vite et avec plus de soin.

| Taille | Recommandation |
|---|---|
| < 200 lignes | Idéal. |
| 200–600 lignes | Acceptable ; expliquez bien la structure dans la description. |
| > 600 lignes | Découpez-la en plusieurs PR, ou ouvrez une issue pour planifier les parties. |

### Respectez l'architecture

Lisez [`docs/ARCHITECTURE.md`](../en/ARCHITECTURE.md) avant de toucher au code. Les règles les plus vérifiées en revue sont :

- `domain/` ne dépend ni des widgets Flutter, ni des sockets, ni des fichiers.
- Toute action de contrôle est un `PrompterCommand` et passe par `PrompterController.execute`, qu'elle vienne du clavier, de la pédale, de la télécommande ou de la voix.
- Rien dans la boucle d'animation ne reconstruit de widgets à chaque frame.
- Si vous modifiez le protocole, mettez à jour [`docs/PROTOCOL.md`](../en/PROTOCOL.md). Si le changement casse la compatibilité, incrémentez le champ `v`.
- Les textes visibles par l'utilisateur vont dans `lib/l10n/`, jamais écrits en dur dans le code (voir [Traductions](#traductions)).

### Tests

- Chaque correction de bug doit être accompagnée d'un test qui échoue sans la correction.
- Chaque nouvelle fonctionnalité contenant de la logique (moteur, parser, protocole, voix) doit être accompagnée de tests.
- Pour le moteur de défilement, utilisez `ScrollEngine.manual()` et `advance()` : les tests sont déterministes et ne dépendent pas de l'horloge.

### Avant de pousser

```bash
dart format lib test integration_test
flutter analyze        # sans avertissement
flutter test           # tout au vert
```

## Messages de commit

Nous utilisons [Conventional Commits](https://www.conventionalcommits.org/fr/v1.0.0/) :

```
type(portée): résumé à l'impératif, sans point final

Corps facultatif : le pourquoi du changement, pas le comment.
Coupez les lignes à ~72 caractères.

Fixes #123
```

- **type** : `feat`, `fix`, `docs`, `i18n`, `perf`, `refactor`, `test`, `chore`.
- **portée** (facultative) : `engine`, `parser`, `remote`, `voice`, `editor`, `android`, `linux`, `l10n`…

| ✅ Bien | ❌ Mal |
|---|---|
| `fix(engine): stop exactly on pause markers at high WPM` | `arreglos` |
| `feat(remote): add follower role to the protocol` | `cambios varios en remote y engine y docs` |
| `docs(protocol): document cmd.goto payload` | `Update PROTOCOL.md` |

> **Remarque :** les commits de votre branche sont fusionnés en un seul (*squash*) lors du merge ; le plus important est donc le **titre de la PR**, qui devient le message final.

## Ouvrir une pull request

### 1. Mettez votre branche à jour

```bash
git fetch upstream
git rebase upstream/develop
git push origin fix/pause-marker-skip
```

### 2. Créez la PR vers `develop`

Sur GitHub, cliquez sur « Compare & pull request » et vérifiez :

- **base repository :** `GNUXDAR/PromptFlow`, **base :** `develop`
- **head repository :** votre fork, **compare :** votre branche

### 3. Titre

Suivez le même format que pour les commits : `type(portée): résumé`. Ce sera le message du commit final.

### 4. Description

Le modèle de PR se remplit automatiquement. Une bonne PR répond à quatre questions :

1. **Qu'est-ce qui change ?** Un résumé en une ou deux phrases.
2. **Pourquoi ?** Le problème résolu, avec un lien vers l'issue : `Fixes #123` (la ferme lors du merge) ou `Refs #123` (la mentionne seulement).
3. **Comment le tester ?** Des étapes concrètes pour que la personne qui relit puisse reproduire le résultat.
4. **Qu'avez-vous vérifié ?** La checklist du modèle, cochée honnêtement. Si vous n'avez pas pu tester quelque chose (par exemple, vous n'avez pas d'appareil Android), dites-le.

Si le changement est visuel, ajoutez des captures d'écran ou une courte vidéo **avant et après**.

> **Exemple de bonne description**
>
> Le moteur sautait le marqueur `[PAUSE 2s]` quand deux marqueurs tombaient sur la même ligne au-delà de 300 WPM, car un seul marqueur était traité par frame.
>
> Fixes #42
>
> **Comment tester :** ouvrez `test/fixtures/double_pause.md` à 350 WPM ; il doit s'arrêter deux fois.
>
> - [x] Nouveau test `pausa doble en la misma línea` (échoue sans la correction)
> - [x] `flutter analyze` / `flutter test`
> - [ ] Testé sur Android (je n'ai pas d'appareil)

### 5. PR en brouillon

Si vous voulez un avis précoce sur un travail inachevé, ouvrez la PR en tant que **Draft**. Marquez-la comme « Ready for review » quand elle est prête.

### 6. PR qui dépendent d'autres PR (empilées)

Si votre PR a besoin d'une autre qui n'a pas encore été intégrée, prenez comme base la branche de cette autre PR et indiquez-le dans la description : « Dépend de #12 ». Quand la première sera intégrée, GitHub changera automatiquement la base en `develop`.

## Le processus de revue

### À quoi s'attendre

- Une première réponse sous **environ 7 jours**. Si plus de deux semaines passent sans nouvelles, commentez la PR pour la relancer : c'est bienvenu.
- Un ou plusieurs commentaires avec des suggestions. C'est normal et cela ne signifie pas que la PR est mauvaise.
- Les vérifications automatiques (analyse et tests) doivent passer.

### Répondre aux commentaires

- Faites les modifications dans de **nouveaux commits** sur la même branche. Ne réécrivez pas l'historique (`push --force`) après qu'une revue a eu lieu : ainsi, la personne qui relit ne voit que ce qui a changé.
- Répondez à chaque commentaire : « Fait dans abc123 », ou expliquez pourquoi vous proposez autre chose. Exprimer un désaccord argumenté fait partie d'une bonne revue.
- C'est la personne qui a ouvert une conversation qui la marque comme résolue.

### Critères d'approbation

Une PR est intégrée lorsque :

- [ ] Elle fait une seule chose et la description explique le quoi et le pourquoi.
- [ ] Elle respecte l'architecture et les conventions de ce guide.
- [ ] Elle a des tests pour la nouvelle logique et toutes les vérifications passent.
- [ ] Les textes d'interface sont dans `lib/l10n/`.
- [ ] La documentation concernée est à jour.
- [ ] Au moins un mainteneur l'a approuvée.

Le merge est effectué par un mainteneur avec **Squash and merge** sur `develop`.

## Après le merge

- Supprimez votre branche (GitHub propose un bouton).
- Synchronisez votre fork :
  ```bash
  git switch develop
  git fetch upstream
  git merge --ff-only upstream/develop
  git push origin develop
  ```
- Votre changement arrivera dans `main` lors de la prochaine version publiée.

## Traductions

Les textes de l'interface se trouvent dans `lib/l10n/app_<langue>.arb`. Le fichier de référence est `app_en.arb`.

- **Corriger une traduction :** modifiez le `.arb` de cette langue et ouvrez une PR `i18n/…`.
- **Ajouter une langue :** copiez `app_en.arb` sous le nom `app_<code>.arb`, traduisez **uniquement les valeurs** (jamais les clés ni les `{placeholders}`) et vérifiez avec `flutter gen-l10n`.
- **Documentation traduite :** elle se trouve dans `docs/i18n/<langue>/`. L'original en espagnol fait foi : si vous modifiez un document, signalez dans la PR que les traductions sont désormais obsolètes, ou mettez-les à jour.

## Étiquette et code de conduite

Ce projet suit le [Contributor Covenant 2.1](https://www.contributor-covenant.org/fr/version/2/1/code_of_conduct/). En résumé :

- Soyez aimable et patient : derrière chaque PR et chaque revue, il y a une personne qui donne de son temps libre.
- Critiquez le code, pas les personnes.
- Présumez la bonne foi et posez des questions avant de tirer des conclusions.
- Écrivez en espagnol ou en anglais, comme vous préférez.

Les comportements inacceptables peuvent être signalés en privé aux mainteneurs au moyen d'une issue marquée comme confidentielle ou par message direct sur GitHub.

## Obtenir de l'aide

- **Questions sur la façon de faire quelque chose :** ouvrez une issue avec le label `question`.
- **Questions sur votre PR :** posez-les dans la PR elle-même.
- **Références du projet :** [`docs/ARCHITECTURE.md`](../en/ARCHITECTURE.md) et [`docs/PROTOCOL.md`](../en/PROTOCOL.md).

Merci de votre contribution ! 💛
