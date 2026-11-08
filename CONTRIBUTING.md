# Guía de contribución a PromptFlow

🌐 **Español** · [English](docs/i18n/en/CONTRIBUTING.md) · [Português](docs/i18n/pt/CONTRIBUTING.md) · [Français](docs/i18n/fr/CONTRIBUTING.md) · [Deutsch](docs/i18n/de/CONTRIBUTING.md) · [Italiano](docs/i18n/it/CONTRIBUTING.md) · [Русский](docs/i18n/ru/CONTRIBUTING.md) · [中文](docs/i18n/zh/CONTRIBUTING.md) · [日本語](docs/i18n/ja/CONTRIBUTING.md) · [한국어](docs/i18n/ko/CONTRIBUTING.md) · [हिन्दी](docs/i18n/hi/CONTRIBUTING.md) · [العربية](docs/i18n/ar/CONTRIBUTING.md)

¡Gracias por tu interés en PromptFlow! Esta guía explica cómo proponer cambios, desde arreglar una errata hasta añadir una función completa. Está pensada para leerse de arriba abajo la primera vez y para consultarse por secciones después.

> **Nota:** si es tu primera contribución a un proyecto de código abierto, no te preocupes por hacerlo todo perfecto. Un PR pequeño con buena intención es mejor que ninguno; en la revisión te ayudaremos con el resto.

## Índice

1. [Formas de contribuir](#formas-de-contribuir)
2. [Antes de empezar](#antes-de-empezar)
3. [Preparar el entorno](#preparar-el-entorno)
4. [Modelo de ramas](#modelo-de-ramas)
5. [Hacer tus cambios](#hacer-tus-cambios)
6. [Mensajes de commit](#mensajes-de-commit)
7. [Abrir un pull request](#abrir-un-pull-request)
8. [El proceso de revisión](#el-proceso-de-revisión)
9. [Después del merge](#después-del-merge)
10. [Traducciones](#traducciones)
11. [Etiqueta y código de conducta](#etiqueta-y-código-de-conducta)
12. [Obtener ayuda](#obtener-ayuda)

---

## Formas de contribuir

No todo es código. Todas estas aportaciones son valiosas:

| Tipo | Ejemplos |
|---|---|
| **Reportar errores** | Algo falla, se ve mal o el scroll no es fluido en tu equipo. |
| **Proponer ideas** | Una función nueva, un atajo, un formato de guion. |
| **Código** | Arreglos, funciones, rendimiento, tests. |
| **Documentación** | Erratas, aclaraciones, ejemplos, diagramas. |
| **Traducciones** | Nuevos idiomas o mejoras en los existentes ([ver abajo](#traducciones)). |
| **Pruebas en hardware** | Pedales Bluetooth, tablets, Raspberry Pi, redes Wi‑Fi con aislamiento. |
| **Revisar PRs** | Probar el PR de otra persona y comentar lo que viste. |

## Antes de empezar

### Busca si ya existe

Antes de abrir un issue o empezar a programar, busca en los [issues](https://github.com/GNUXDAR/PromptFlow/issues) y [pull requests](https://github.com/GNUXDAR/PromptFlow/pulls) abiertos. Si alguien ya trabaja en lo mismo, comenta allí en vez de duplicar el esfuerzo.

### Abre un issue para los cambios grandes

| Tamaño del cambio | ¿Hace falta un issue antes? |
|---|---|
| Errata, enlace roto, texto confuso | No: abre el PR directamente. |
| Arreglo de un bug pequeño y claro | Recomendado, no obligatorio. |
| Función nueva, cambio de comportamiento, cambio de protocolo o de arquitectura | **Sí.** Acordar el enfoque antes evita que tu trabajo se rechace por un desacuerdo de diseño. |

> **Consejo:** comenta en el issue «Me encargo yo» para que nadie más lo tome. Si después no puedes seguir, avisa: no pasa nada.

### Issues para empezar

Los issues con la etiqueta `good first issue` están acotados y explicados para quien llega por primera vez. Los de `help wanted` son importantes y buscan voluntarios.

## Preparar el entorno

### Requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) estable (Dart 3).
- Linux: dependencias de escritorio de Flutter (`clang`, `cmake`, `ninja-build`, `libgtk-3-dev`).
- Android (opcional): Android SDK y un dispositivo o emulador.

### Fork y clonado

```bash
# 1. Haz un fork desde GitHub (botón «Fork») y clónalo
git clone https://github.com/<tu-usuario>/PromptFlow.git
cd PromptFlow

# 2. Añade el repositorio original como «upstream»
git remote add upstream https://github.com/GNUXDAR/PromptFlow.git

# 3. Instala dependencias y comprueba que todo funciona
flutter pub get
flutter analyze
flutter test
```

### Voz (opcional)

```bash
tool/setup_vosk_linux.sh      # libvosk + modelo español para Linux
```

## Modelo de ramas

| Rama | Para qué sirve | ¿Quién escribe? |
|---|---|---|
| `main` | Versiones publicadas. Siempre estable. | Solo mantenedores, al publicar una versión. |
| `develop` | Integración de lo próximo que se publicará. **Destino de todos los PR.** | Nadie directamente: solo mediante PR. |
| `tipo/descripcion` | Tu trabajo. Una rama por tema. | Tú. |

> **Importante:** nunca hagas commits directos en `main` ni en `develop`, ni abras un PR contra `main`. Todo entra por un PR a `develop`.

### Nombres de rama

Usa `tipo/descripcion-corta` en minúsculas y con guiones:

| Prefijo | Uso | Ejemplo |
|---|---|---|
| `feat/` | Función nueva | `feat/follower-mode` |
| `fix/` | Corrección de un bug | `fix/pause-marker-skip` |
| `docs/` | Solo documentación | `docs/protocol-examples` |
| `i18n/` | Traducciones | `i18n/add-turkish` |
| `perf/` | Rendimiento | `perf/painter-culling` |
| `refactor/` | Reorganización sin cambio de comportamiento | `refactor/controller-commands` |
| `test/` | Solo tests | `test/remote-reconnect` |
| `chore/` | Build, dependencias, CI | `chore/bump-flutter` |

```bash
git fetch upstream
git switch -c fix/pause-marker-skip upstream/develop
```

## Hacer tus cambios

### Un PR, un tema

Un PR debe hacer **una sola cosa**. Si arreglas un bug y además descubres otro, abre dos PRs. Los PRs pequeños se revisan antes y con más cuidado.

| Tamaño | Recomendación |
|---|---|
| < 200 líneas | Ideal. |
| 200–600 líneas | Aceptable; explica bien la estructura en la descripción. |
| > 600 líneas | Divídelo en varios PRs, o abre un issue para planear las partes. |

### Respeta la arquitectura

Lee [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) antes de tocar código. Las reglas que más se revisan son:

- `domain/` no depende de widgets de Flutter, sockets ni ficheros.
- Toda acción de control es un `PrompterCommand` y pasa por `PrompterController.execute`, venga del teclado, del pedal, del mando remoto o de la voz.
- Nada dentro del bucle de animación reconstruye widgets por frame.
- Si cambias el protocolo, actualiza [`docs/PROTOCOL.md`](docs/PROTOCOL.md). Si el cambio rompe la compatibilidad, sube el campo `v`.
- Los textos visibles para el usuario van en `lib/l10n/`, nunca escritos directamente en el código (ver [Traducciones](#traducciones)).

### Tests

- Cada arreglo de bug debe llevar un test que falle sin el arreglo.
- Cada función nueva con lógica (motor, parser, protocolo, voz) debe llevar tests.
- Para el motor de scroll usa `ScrollEngine.manual()` y `advance()`: los tests son deterministas y no dependen del reloj.

### Antes de subir

```bash
dart format lib test integration_test
flutter analyze        # sin avisos
flutter test           # todo en verde
```

## Mensajes de commit

Usamos [Conventional Commits](https://www.conventionalcommits.org/es/v1.0.0/):

```
tipo(ámbito): resumen en imperativo, sin punto final

Cuerpo opcional: el porqué del cambio, no el cómo.
Ajusta las líneas a ~72 caracteres.

Fixes #123
```

- **tipo**: `feat`, `fix`, `docs`, `i18n`, `perf`, `refactor`, `test`, `chore`.
- **ámbito** (opcional): `engine`, `parser`, `remote`, `voice`, `editor`, `android`, `linux`, `l10n`…

| ✅ Bien | ❌ Mal |
|---|---|
| `fix(engine): stop exactly on pause markers at high WPM` | `arreglos` |
| `feat(remote): add follower role to the protocol` | `cambios varios en remote y engine y docs` |
| `docs(protocol): document cmd.goto payload` | `Update PROTOCOL.md` |

> **Nota:** los commits de tu rama se combinan en uno solo (*squash*) al hacer el merge, así que lo más importante es el **título del PR**, que pasa a ser el mensaje final.

## Abrir un pull request

### 1. Actualiza tu rama

```bash
git fetch upstream
git rebase upstream/develop
git push origin fix/pause-marker-skip
```

### 2. Crea el PR contra `develop`

En GitHub, pulsa «Compare & pull request» y comprueba:

- **base repository:** `GNUXDAR/PromptFlow`, **base:** `develop`
- **head repository:** tu fork, **compare:** tu rama

### 3. Título

Sigue el mismo formato que los commits: `tipo(ámbito): resumen`. Será el mensaje del commit final.

### 4. Descripción

La plantilla del PR se rellena sola. Un buen PR responde a cuatro preguntas:

1. **¿Qué cambia?** Un resumen en una o dos frases.
2. **¿Por qué?** El problema que resuelve, con enlace al issue: `Fixes #123` (lo cierra al hacer merge) o `Refs #123` (solo lo menciona).
3. **¿Cómo lo pruebo?** Pasos concretos para que quien revisa reproduzca el resultado.
4. **¿Qué verificaste?** La checklist de la plantilla, marcada con honestidad. Si algo no pudiste probar (por ejemplo, no tienes un dispositivo Android), dilo.

Si el cambio es visual, añade capturas o un vídeo corto **antes y después**.

> **Ejemplo de buena descripción**
>
> El motor saltaba la marca `[PAUSE 2s]` cuando dos marcas caían en la misma línea a más de 300 WPM, porque solo se procesaba una marca por frame.
>
> Fixes #42
>
> **Cómo probar:** abre `test/fixtures/double_pause.md` a 350 WPM; debe detenerse dos veces.
>
> - [x] Test nuevo `pausa doble en la misma línea` (falla sin el arreglo)
> - [x] `flutter analyze` / `flutter test`
> - [ ] Probado en Android (no tengo dispositivo)

### 5. PR en borrador

Si quieres opinión temprana sobre un trabajo sin terminar, abre el PR como **Draft**. Márcalo como «Ready for review» cuando esté listo.

### 6. PRs que dependen de otros (apilados)

Si tu PR necesita otro que aún no se ha integrado, pon como base la rama de ese otro PR e indícalo en la descripción: «Depende de #12». Cuando se integre el primero, GitHub cambiará la base a `develop` automáticamente.

## El proceso de revisión

### Qué esperar

- Una primera respuesta en **unos 7 días**. Si pasan más de dos semanas sin noticias, comenta en el PR para recordarlo: es bienvenido.
- Uno o varios comentarios con sugerencias. Es lo normal y no significa que el PR sea malo.
- Las comprobaciones automáticas (análisis y tests) tienen que pasar.

### Responder a los comentarios

- Haz los cambios en **commits nuevos** sobre la misma rama. No reescribas el historial (`push --force`) después de que alguien haya revisado: así quien revisa ve solo lo que cambió.
- Responde a cada comentario: «Hecho en abc123» o explica por qué propones otra cosa. Discrepar con argumentos es parte de una buena revisión.
- Quien abrió una conversación es quien la marca como resuelta.

### Criterios para aprobar

Un PR se integra cuando:

- [ ] Hace una sola cosa y la descripción explica el qué y el porqué.
- [ ] Respeta la arquitectura y las convenciones de esta guía.
- [ ] Tiene tests para la lógica nueva y todas las comprobaciones pasan.
- [ ] Los textos de interfaz están en `lib/l10n/`.
- [ ] La documentación afectada está actualizada.
- [ ] Al menos un mantenedor lo ha aprobado.

El merge lo hace un mantenedor con **Squash and merge** sobre `develop`.

## Después del merge

- Borra tu rama (GitHub ofrece un botón).
- Sincroniza tu fork:
  ```bash
  git switch develop
  git fetch upstream
  git merge --ff-only upstream/develop
  git push origin develop
  ```
- Tu cambio llegará a `main` en la próxima versión publicada.

## Traducciones

Los textos de la interfaz están en `lib/l10n/app_<idioma>.arb`. El archivo de referencia es `app_en.arb`.

- **Corregir una traducción:** edita el `.arb` de ese idioma y abre un PR `i18n/…`.
- **Añadir un idioma:** copia `app_en.arb` como `app_<código>.arb`, traduce **solo los valores** (nunca las claves ni los `{placeholders}`) y comprueba con `flutter gen-l10n`.
- **Documentación traducida:** está en `docs/i18n/<idioma>/`. El original en español manda: si cambias un documento, avisa en el PR de que las traducciones quedan desactualizadas, o actualízalas.

## Etiqueta y código de conducta

Este proyecto sigue el [Contributor Covenant 2.1](https://www.contributor-covenant.org/es/version/2/1/code_of_conduct/). En resumen:

- Sé amable y paciente: detrás de cada PR y cada revisión hay una persona dedicando su tiempo libre.
- Critica el código, no a las personas.
- Asume buena fe y pregunta antes de suponer.
- Escribe en español o en inglés, como prefieras.

Los comportamientos inaceptables se pueden comunicar en privado a los mantenedores mediante un issue marcado como confidencial o por mensaje directo en GitHub.

## Obtener ayuda

- **Dudas sobre cómo hacer algo:** abre un issue con la etiqueta `question`.
- **Dudas sobre tu PR:** pregunta en el propio PR.
- **Referencias del proyecto:** [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) y [`docs/PROTOCOL.md`](docs/PROTOCOL.md).

¡Gracias por contribuir! 💛
