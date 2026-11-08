// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'PromptFlow';

  @override
  String get commonCancel => 'Отмена';

  @override
  String commonError(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get homeImport => 'Импорт .txt / .md';

  @override
  String get homeRemote => 'Пульт';

  @override
  String get homeNewScript => 'Новый сценарий';

  @override
  String homeEditScript(String title) {
    return 'Изменить «$title»';
  }

  @override
  String get homeSampleFileName => 'primer.md';

  @override
  String get homeSampleScript =>
      '# Пример сценария\n\n## Вступление\n[CAM 1] Здравствуйте и **добро пожаловать** в PromptFlow. Этот пример сценария показывает\nдоступные метки. [PAUSE 2s]\n\nСлова можно выделить **жирным** для акцента или ==подсветить==,\nесли они важны.\n\n## Демонстрация\n[CAM 2] [CUE Demo] Теперь переключаем камеру. Автоматические паузы останавливают текст\nна несколько секунд, а затем он продолжается сам. [PAUSE 1.5s]\n\nПауза без длительности останавливает текст, пока вы не нажмёте «Пуск». [PAUSE]\n\n## Завершение\n[CAM 1] Спасибо за просмотр. Управляйте суфлёром с телефона в режиме\n**Пульт** или с помощью Bluetooth-педали.\n';

  @override
  String get editorNameHint => 'imya.md';

  @override
  String get editorSave => 'Сохранить (Ctrl+S)';

  @override
  String get editorRehearse => 'Репетиция в суфлёре';

  @override
  String editorSavedTo(String path) {
    return 'Сохранено: $path';
  }

  @override
  String get editorUnsavedTitle => 'Несохранённые изменения';

  @override
  String get editorUnsavedBody => 'Выйти без сохранения?';

  @override
  String get editorLeave => 'Выйти';

  @override
  String get editorBodyHint =>
      '# Заголовок\n\n## Раздел\n[CAM 1] Текст сценария с **акцентом**. [PAUSE 2s]';

  @override
  String get editorBold => 'Жирный';

  @override
  String get editorHighlight => 'Подсветка';

  @override
  String get editorSection => '## Раздел';

  @override
  String get editorPause2s => 'Пауза 2 с';

  @override
  String get editorPauseManual => 'Ручная пауза';

  @override
  String get editorCue => 'Cue';

  @override
  String get editorCueSnippet => '[CUE имя] ';

  @override
  String editorStats(int words, int markers) {
    return 'Слов: $words · меток: $markers';
  }

  @override
  String editorDurationAt(int wpm, String duration) {
    return 'Длительность при $wpm WPM: $duration';
  }

  @override
  String get editorTargetHint => 'Целевая длительность';

  @override
  String get editorNoTarget => 'Без цели';

  @override
  String editorMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String get editorPausesExceedTarget => 'Паузы превышают цель';

  @override
  String editorNeededWpm(int wpm) {
    return 'Нужно $wpm WPM';
  }

  @override
  String get prompterExit => 'Выход (Esc)';

  @override
  String prompterServerInfo(String address, int port, String pin, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count пульта',
      many: '$count пультов',
      few: '$count пульта',
      one: '$count пульт',
      zero: 'нет пультов',
    );
    return '$address:$port  PIN $pin  · $_temp0';
  }

  @override
  String get prompterServerStopped => 'Сервер остановлен';

  @override
  String prompterServerPortError(int port, String message) {
    return 'Не удалось открыть порт $port: $message';
  }

  @override
  String get prompterBack5 => 'Назад на 5 с (Page Up)';

  @override
  String get prompterForward5 => 'Вперёд на 5 с (Page Down)';

  @override
  String get prompterPlay => 'Пуск (Пробел)';

  @override
  String get prompterPause => 'Пауза (Пробел)';

  @override
  String get prompterSlower => 'Медленнее (↓)';

  @override
  String get prompterFaster => 'Быстрее (↑)';

  @override
  String prompterWpm(int wpm) {
    return '$wpm WPM';
  }

  @override
  String prompterStatusLine(String status, String remaining) {
    return '$status · осталось $remaining';
  }

  @override
  String get prompterVoiceOn => 'Следовать за голосом';

  @override
  String get prompterVoiceOff => 'Отключить слежение за голосом';

  @override
  String get prompterGoToSection => 'Перейти к разделу';

  @override
  String get prompterSettings => 'Настройки (S)';

  @override
  String get statusPlaying => 'Воспроизведение';

  @override
  String statusAutoPaused(String seconds) {
    return 'Пауза $seconds с';
  }

  @override
  String get statusAutoPausedShort => 'Автопауза';

  @override
  String get statusHolding => 'Пауза — нажмите «Пуск»';

  @override
  String get statusHoldingShort => 'Пауза сценария';

  @override
  String get statusFinished => 'Конец';

  @override
  String get statusStopped => 'Остановлено';

  @override
  String get settingsFontSize => 'Размер шрифта';

  @override
  String get settingsLineHeight => 'Межстрочный интервал';

  @override
  String get settingsMargin => 'Боковое поле';

  @override
  String get settingsFocusLine => 'Линия чтения';

  @override
  String get settingsSpeed => 'Скорость';

  @override
  String get settingsTextColor => 'Цвет текста';

  @override
  String get settingsWhite => 'Белый';

  @override
  String get settingsYellow => 'Жёлтый';

  @override
  String get settingsMirrorH => 'Зеркально по горизонтали (H)';

  @override
  String get settingsMirrorV => 'Зеркально по вертикали (V)';

  @override
  String get settingsFocusGuide => 'Направляющая линии чтения';

  @override
  String get voiceTitle => 'Слежение за голосом';

  @override
  String get voiceLanguage => 'Язык речи';

  @override
  String voiceStatusDownloading(int percent) {
    return 'Загрузка $percent %';
  }

  @override
  String get voiceStatusInstalling => 'Установка модели…';

  @override
  String get voiceStatusReady =>
      'Готово: нажмите микрофон на HUD, и текст будет следовать за голосом';

  @override
  String get voiceStatusNoEngine =>
      'Модель установлена, но нет движка Vosk (в Linux: tool/setup_vosk_linux.sh)';

  @override
  String voiceStatusNoModel(int size) {
    return 'Модель не установлена ($size МБ, загружается один раз)';
  }

  @override
  String voiceDownload(int size) {
    return 'Скачать модель ($size МБ)';
  }

  @override
  String get voiceErrorNoModel =>
      'Скачайте голосовую модель в разделе Настройки → Голос';

  @override
  String get voiceErrorNoEngine =>
      'Vosk не установлен (tool/setup_vosk_linux.sh)';

  @override
  String get voiceErrorPermission =>
      'Нет доступа к микрофону. Разрешите его в настройках системы, чтобы использовать слежение за голосом.';

  @override
  String voiceErrorDownload(String message) {
    return 'Не удалось скачать модель: $message';
  }

  @override
  String voiceErrorEngine(String message) {
    return 'Ошибка распознавания речи: $message';
  }

  @override
  String get remoteTitle => 'Пульт';

  @override
  String get remoteConnectTitle => 'Подключиться к суфлёру';

  @override
  String get remoteReconnecting => 'Переподключение…';

  @override
  String remoteRtt(String ms) {
    return 'RTT $ms мс';
  }

  @override
  String get remoteDisconnect => 'Отключиться';

  @override
  String get remotePinRequired =>
      'Введите 4-значный PIN, показанный на суфлёре';

  @override
  String get remoteBadPin => 'Неверный PIN';

  @override
  String remoteConnectFailed(String message) {
    return 'Не удалось подключиться: $message';
  }

  @override
  String get remotePinLabel => 'PIN суфлёра';

  @override
  String get remoteOnLan => 'В локальной сети';

  @override
  String get remoteSearch => 'Поиск';

  @override
  String get remoteNoneFound =>
      'Суфлёр не найден. Откройте его на компьютере с Linux или введите IP вручную.';

  @override
  String get remoteManualIp => 'IP вручную (напр. 192.168.1.20)';

  @override
  String get remoteConnect => 'Подключиться';

  @override
  String get remotePosition => 'Позиция в сценарии';

  @override
  String remoteRemaining(String remaining) {
    return 'Осталось $remaining';
  }

  @override
  String get remoteBack5 => 'Назад 5 с';

  @override
  String get remoteForward5 => 'Вперёд 5 с';

  @override
  String get remotePlay => 'Пуск';

  @override
  String get remotePause => 'Пауза';

  @override
  String get remoteSlower => 'Медленнее';

  @override
  String get remoteFaster => 'Быстрее';

  @override
  String get remoteMirrorH => 'Зеркало H';

  @override
  String get remoteMirrorV => 'Зеркало V';

  @override
  String get remoteFollowVoice => 'Следовать за голосом';

  @override
  String get remoteStart => 'В начало';

  @override
  String get remoteSections => 'Разделы и метки CUE';

  @override
  String get remoteChangeScript => 'Сменить сценарий';

  @override
  String get aboutTitle => 'О приложении';

  @override
  String aboutVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get aboutTagline =>
      'Суфлёр для Linux и Android: плавная прокрутка, пульт по локальной сети и слежение за голосом без интернета.';

  @override
  String get aboutCreatedBy => 'Автор';

  @override
  String get aboutFollow => 'Подписаться';

  @override
  String get aboutProject => 'Проект';

  @override
  String get aboutSourceCode => 'Исходный код';

  @override
  String get aboutContribute => 'Участвовать';

  @override
  String get aboutLicense => 'Лицензия MIT';

  @override
  String get aboutVoiceCredit =>
      'Распознавание речи без интернета: Vosk (Apache 2.0)';

  @override
  String get aboutLicenses => 'Лицензии открытого ПО';

  @override
  String aboutOpenFailed(String url) {
    return 'Не удалось открыть $url';
  }
}
