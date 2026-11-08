# Guia de contribuição para o PromptFlow

> Traduzido do original em espanhol. Em caso de divergência, prevalece o [original](../../../CONTRIBUTING.md).

Obrigado pelo seu interesse no PromptFlow! Este guia explica como propor alterações, desde corrigir um erro de digitação até adicionar uma funcionalidade completa. Ele foi pensado para ser lido de cima a baixo na primeira vez e consultado por seções depois.

> **Nota:** se esta é sua primeira contribuição para um projeto de código aberto, não se preocupe em fazer tudo perfeito. Um PR pequeno e bem-intencionado é melhor do que nenhum; na revisão ajudaremos com o resto.

## Índice

1. [Formas de contribuir](#formas-de-contribuir)
2. [Antes de começar](#antes-de-começar)
3. [Preparar o ambiente](#preparar-o-ambiente)
4. [Modelo de branches](#modelo-de-branches)
5. [Fazer suas alterações](#fazer-suas-alterações)
6. [Mensagens de commit](#mensagens-de-commit)
7. [Abrir um pull request](#abrir-um-pull-request)
8. [O processo de revisão](#o-processo-de-revisão)
9. [Depois do merge](#depois-do-merge)
10. [Traduções](#traduções)
11. [Etiqueta e código de conduta](#etiqueta-e-código-de-conduta)
12. [Obter ajuda](#obter-ajuda)

---

## Formas de contribuir

Nem tudo é código. Todas estas contribuições são valiosas:

| Tipo | Exemplos |
|---|---|
| **Relatar erros** | Algo falha, aparece errado ou a rolagem não é fluida no seu equipamento. |
| **Propor ideias** | Uma funcionalidade nova, um atalho, um formato de roteiro. |
| **Código** | Correções, funcionalidades, desempenho, testes. |
| **Documentação** | Erros de digitação, esclarecimentos, exemplos, diagramas. |
| **Traduções** | Novos idiomas ou melhorias nos existentes ([veja abaixo](#traduções)). |
| **Testes em hardware** | Pedais Bluetooth, tablets, Raspberry Pi, redes Wi‑Fi com isolamento. |
| **Revisar PRs** | Testar o PR de outra pessoa e comentar o que você viu. |

## Antes de começar

### Verifique se já existe

Antes de abrir uma issue ou começar a programar, pesquise nas [issues](https://github.com/GNUXDAR/PromptFlow/issues) e nos [pull requests](https://github.com/GNUXDAR/PromptFlow/pulls) abertos. Se alguém já estiver trabalhando na mesma coisa, comente lá em vez de duplicar o esforço.

### Abra uma issue para alterações grandes

| Tamanho da alteração | É preciso uma issue antes? |
|---|---|
| Erro de digitação, link quebrado, texto confuso | Não: abra o PR diretamente. |
| Correção de um bug pequeno e claro | Recomendado, não obrigatório. |
| Funcionalidade nova, mudança de comportamento, mudança de protocolo ou de arquitetura | **Sim.** Combinar a abordagem antes evita que seu trabalho seja rejeitado por uma divergência de design. |

> **Dica:** comente na issue “Eu cuido disso” para que ninguém mais a pegue. Se depois não puder continuar, avise: não tem problema.

### Issues para começar

As issues com a etiqueta `good first issue` são delimitadas e explicadas para quem está chegando pela primeira vez. As de `help wanted` são importantes e procuram voluntários.

## Preparar o ambiente

### Requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) estável (Dart 3).
- Linux: dependências de desktop do Flutter (`clang`, `cmake`, `ninja-build`, `libgtk-3-dev`).
- Android (opcional): Android SDK e um dispositivo ou emulador.

### Fork e clone

```bash
# 1. Faça um fork no GitHub (botão “Fork”) e clone-o
git clone https://github.com/<seu-usuario>/PromptFlow.git
cd PromptFlow

# 2. Adicione o repositório original como “upstream”
git remote add upstream https://github.com/GNUXDAR/PromptFlow.git

# 3. Instale as dependências e verifique se tudo funciona
flutter pub get
flutter analyze
flutter test
```

### Voz (opcional)

```bash
tool/setup_vosk_linux.sh      # libvosk + modelo em espanhol para Linux
```

## Modelo de branches

| Branch | Para que serve | Quem escreve? |
|---|---|---|
| `main` | Versões publicadas. Sempre estável. | Só mantenedores, ao publicar uma versão. |
| `develop` | Integração do que será publicado a seguir. **Destino de todos os PRs.** | Ninguém diretamente: só por meio de PR. |
| `tipo/descricao` | Seu trabalho. Uma branch por tema. | Você. |

> **Importante:** nunca faça commits diretamente em `main` nem em `develop`, nem abra um PR contra `main`. Tudo entra por um PR para `develop`.

### Nomes de branch

Use `tipo/descricao-curta` em minúsculas e com hifens:

| Prefixo | Uso | Exemplo |
|---|---|---|
| `feat/` | Funcionalidade nova | `feat/follower-mode` |
| `fix/` | Correção de um bug | `fix/pause-marker-skip` |
| `docs/` | Só documentação | `docs/protocol-examples` |
| `i18n/` | Traduções | `i18n/add-turkish` |
| `perf/` | Desempenho | `perf/painter-culling` |
| `refactor/` | Reorganização sem mudança de comportamento | `refactor/controller-commands` |
| `test/` | Só testes | `test/remote-reconnect` |
| `chore/` | Build, dependências, CI | `chore/bump-flutter` |

```bash
git fetch upstream
git switch -c fix/pause-marker-skip upstream/develop
```

## Fazer suas alterações

### Um PR, um tema

Um PR deve fazer **uma única coisa**. Se você corrigir um bug e descobrir outro, abra dois PRs. PRs pequenos são revisados mais cedo e com mais cuidado.

| Tamanho | Recomendação |
|---|---|
| < 200 linhas | Ideal. |
| 200–600 linhas | Aceitável; explique bem a estrutura na descrição. |
| > 600 linhas | Divida em vários PRs, ou abra uma issue para planejar as partes. |

### Respeite a arquitetura

Leia [`docs/ARCHITECTURE.md`](../en/ARCHITECTURE.md) antes de mexer no código. As regras mais verificadas na revisão são:

- `domain/` não depende de widgets do Flutter, sockets nem arquivos.
- Toda ação de controle é um `PrompterCommand` e passa por `PrompterController.execute`, venha do teclado, do pedal, do controle remoto ou da voz.
- Nada dentro do loop de animação reconstrói widgets a cada frame.
- Se você alterar o protocolo, atualize [`docs/PROTOCOL.md`](../en/PROTOCOL.md). Se a alteração quebrar a compatibilidade, incremente o campo `v`.
- Os textos visíveis para o usuário ficam em `lib/l10n/`, nunca escritos diretamente no código (veja [Traduções](#traduções)).

### Testes

- Toda correção de bug deve vir com um teste que falhe sem a correção.
- Toda funcionalidade nova com lógica (motor, parser, protocolo, voz) deve vir com testes.
- Para o motor de rolagem, use `ScrollEngine.manual()` e `advance()`: os testes são determinísticos e não dependem do relógio.

### Antes de enviar

```bash
dart format lib test integration_test
flutter analyze        # sem avisos
flutter test           # tudo passando
```

## Mensagens de commit

Usamos [Conventional Commits](https://www.conventionalcommits.org/pt-br/v1.0.0/):

```
tipo(escopo): resumo no imperativo, sem ponto final

Corpo opcional: o porquê da alteração, não o como.
Quebre as linhas em ~72 caracteres.

Fixes #123
```

- **tipo**: `feat`, `fix`, `docs`, `i18n`, `perf`, `refactor`, `test`, `chore`.
- **escopo** (opcional): `engine`, `parser`, `remote`, `voice`, `editor`, `android`, `linux`, `l10n`…

| ✅ Bom | ❌ Ruim |
|---|---|
| `fix(engine): stop exactly on pause markers at high WPM` | `arreglos` |
| `feat(remote): add follower role to the protocol` | `cambios varios en remote y engine y docs` |
| `docs(protocol): document cmd.goto payload` | `Update PROTOCOL.md` |

> **Nota:** os commits da sua branch são combinados em um só (*squash*) no merge, então o mais importante é o **título do PR**, que se torna a mensagem final.

## Abrir um pull request

### 1. Atualize sua branch

```bash
git fetch upstream
git rebase upstream/develop
git push origin fix/pause-marker-skip
```

### 2. Crie o PR contra `develop`

No GitHub, clique em “Compare & pull request” e verifique:

- **base repository:** `GNUXDAR/PromptFlow`, **base:** `develop`
- **head repository:** seu fork, **compare:** sua branch

### 3. Título

Siga o mesmo formato dos commits: `tipo(escopo): resumo`. Ele será a mensagem do commit final.

### 4. Descrição

O template do PR é preenchido automaticamente. Um bom PR responde a quatro perguntas:

1. **O que muda?** Um resumo em uma ou duas frases.
2. **Por quê?** O problema que resolve, com link para a issue: `Fixes #123` (fecha a issue no merge) ou `Refs #123` (só a menciona).
3. **Como eu testo?** Passos concretos para que quem revisa reproduza o resultado.
4. **O que você verificou?** O checklist do template, marcado com honestidade. Se não conseguiu testar algo (por exemplo, não tem um dispositivo Android), diga.

Se a alteração for visual, adicione capturas de tela ou um vídeo curto de **antes e depois**.

> **Exemplo de boa descrição**
>
> O motor pulava a marca `[PAUSE 2s]` quando duas marcas caíam na mesma linha a mais de 300 WPM, porque só uma marca era processada por frame.
>
> Fixes #42
>
> **Como testar:** abra `test/fixtures/double_pause.md` a 350 WPM; deve parar duas vezes.
>
> - [x] Teste novo `pausa doble en la misma línea` (falha sem a correção)
> - [x] `flutter analyze` / `flutter test`
> - [ ] Testado no Android (não tenho dispositivo)

### 5. PR em rascunho

Se quiser uma opinião cedo sobre um trabalho inacabado, abra o PR como **Draft**. Marque-o como “Ready for review” quando estiver pronto.

### 6. PRs que dependem de outros (empilhados)

Se o seu PR precisa de outro que ainda não foi integrado, defina como base a branch desse outro PR e indique isso na descrição: “Depende de #12”. Quando o primeiro for integrado, o GitHub mudará a base para `develop` automaticamente.

## O processo de revisão

### O que esperar

- Uma primeira resposta em **cerca de 7 dias**. Se passarem mais de duas semanas sem notícias, comente no PR para lembrar: é bem-vindo.
- Um ou vários comentários com sugestões. É normal e não significa que o PR seja ruim.
- As verificações automáticas (análise e testes) precisam passar.

### Responder aos comentários

- Faça as alterações em **commits novos** na mesma branch. Não reescreva o histórico (`push --force`) depois que alguém já revisou: assim quem revisa vê só o que mudou.
- Responda a cada comentário: “Feito em abc123” ou explique por que você propõe outra coisa. Discordar com argumentos faz parte de uma boa revisão.
- Quem abriu uma conversa é quem a marca como resolvida.

### Critérios para aprovar

Um PR é integrado quando:

- [ ] Faz uma única coisa e a descrição explica o quê e o porquê.
- [ ] Respeita a arquitetura e as convenções deste guia.
- [ ] Tem testes para a lógica nova e todas as verificações passam.
- [ ] Os textos de interface estão em `lib/l10n/`.
- [ ] A documentação afetada está atualizada.
- [ ] Pelo menos um mantenedor o aprovou.

O merge é feito por um mantenedor com **Squash and merge** em `develop`.

## Depois do merge

- Apague sua branch (o GitHub oferece um botão).
- Sincronize seu fork:
  ```bash
  git switch develop
  git fetch upstream
  git merge --ff-only upstream/develop
  git push origin develop
  ```
- Sua alteração chegará a `main` na próxima versão publicada.

## Traduções

Os textos da interface estão em `lib/l10n/app_<idioma>.arb`. O arquivo de referência é `app_en.arb`.

- **Corrigir uma tradução:** edite o `.arb` desse idioma e abra um PR `i18n/…`.
- **Adicionar um idioma:** copie `app_en.arb` como `app_<código>.arb`, traduza **só os valores** (nunca as chaves nem os `{placeholders}`) e verifique com `flutter gen-l10n`.
- **Documentação traduzida:** fica em `docs/i18n/<idioma>/`. O original em espanhol prevalece: se você alterar um documento, avise no PR que as traduções ficaram desatualizadas, ou atualize-as.

## Etiqueta e código de conduta

Este projeto segue o [Contributor Covenant 2.1](https://www.contributor-covenant.org/pt-br/version/2/1/code_of_conduct/). Em resumo:

- Seja gentil e paciente: por trás de cada PR e de cada revisão há uma pessoa dedicando seu tempo livre.
- Critique o código, não as pessoas.
- Presuma boa-fé e pergunte antes de supor.
- Escreva em espanhol ou em inglês, como preferir.

Comportamentos inaceitáveis podem ser comunicados em privado aos mantenedores por meio de uma issue marcada como confidencial ou por mensagem direta no GitHub.

## Obter ajuda

- **Dúvidas sobre como fazer algo:** abra uma issue com a etiqueta `question`.
- **Dúvidas sobre o seu PR:** pergunte no próprio PR.
- **Referências do projeto:** [`docs/ARCHITECTURE.md`](../en/ARCHITECTURE.md) e [`docs/PROTOCOL.md`](../en/PROTOCOL.md).

Obrigado por contribuir! 💛
