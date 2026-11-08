// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'PromptFlow';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String commonError(String message) {
    return 'خطأ: $message';
  }

  @override
  String get homeImport => 'استيراد .txt / .md';

  @override
  String get homeRemote => 'التحكم عن بُعد';

  @override
  String get homeNewScript => 'نص جديد';

  @override
  String homeEditScript(String title) {
    return 'تعديل $title';
  }

  @override
  String get homeSampleFileName => 'mithal.md';

  @override
  String get homeSampleScript =>
      '# نص تجريبي\n\n## الافتتاح\n[CAM 1] مرحبًا، و**أهلًا بكم** في PromptFlow. يعرض هذا النص التجريبي\nالعلامات المتاحة. [PAUSE 2s]\n\nيمكنك كتابة الكلمات **بخط عريض** للتأكيد، أو ==تمييزها==\nعندما تكون مهمة.\n\n## عرض توضيحي\n[CAM 2] [CUE Demo] الآن ننتقل إلى كاميرا أخرى. يوقف الإيقاف المؤقت التلقائي النص\nلبضع ثوانٍ ثم يُستأنف تلقائيًا. [PAUSE 1.5s]\n\nالإيقاف المؤقت بدون مدة يوقف النص إلى أن تضغط على «تشغيل». [PAUSE]\n\n## الختام\n[CAM 1] شكرًا على المشاهدة. تحكّم في جهاز التلقين من هاتفك عبر\nوضع **التحكم عن بُعد**، أو باستخدام دواسة Bluetooth.\n';

  @override
  String get editorNameHint => 'name.md';

  @override
  String get editorSave => 'حفظ (Ctrl+S)';

  @override
  String get editorRehearse => 'التدرّب في جهاز التلقين';

  @override
  String editorSavedTo(String path) {
    return 'تم الحفظ في $path';
  }

  @override
  String get editorUnsavedTitle => 'تغييرات غير محفوظة';

  @override
  String get editorUnsavedBody => 'هل تريد المغادرة بدون حفظ؟';

  @override
  String get editorLeave => 'مغادرة';

  @override
  String get editorBodyHint =>
      '# العنوان\n\n## قسم\n[CAM 1] نص مع **تأكيد**. [PAUSE 2s]';

  @override
  String get editorBold => 'غامق';

  @override
  String get editorHighlight => 'تمييز';

  @override
  String get editorSection => '## قسم';

  @override
  String get editorPause2s => 'إيقاف مؤقت 2 ث';

  @override
  String get editorPauseManual => 'إيقاف مؤقت يدوي';

  @override
  String get editorCue => 'إشارة';

  @override
  String get editorCueSnippet => '[CUE اسم] ';

  @override
  String editorStats(int words, int markers) {
    return 'الكلمات: $words · العلامات: $markers';
  }

  @override
  String editorDurationAt(int wpm, String duration) {
    return 'المدة بسرعة $wpm WPM: $duration';
  }

  @override
  String get editorTargetHint => 'المدة المستهدفة';

  @override
  String get editorNoTarget => 'بلا هدف';

  @override
  String editorMinutes(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get editorPausesExceedTarget =>
      'فترات الإيقاف المؤقت تتجاوز المدة المستهدفة';

  @override
  String editorNeededWpm(int wpm) {
    return 'تحتاج إلى $wpm WPM';
  }

  @override
  String get prompterExit => 'خروج (Esc)';

  @override
  String prompterServerInfo(String address, int port, String pin, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جهاز تحكم',
      many: '$count جهاز تحكم',
      few: '$count أجهزة تحكم',
      two: 'جهازا تحكم',
      one: 'جهاز تحكم واحد',
      zero: 'لا توجد أجهزة تحكم',
    );
    return '$address:$port  PIN $pin  · $_temp0';
  }

  @override
  String get prompterServerStopped => 'تم إيقاف الخادم';

  @override
  String prompterServerPortError(int port, String message) {
    return 'تعذّر فتح المنفذ $port: $message';
  }

  @override
  String get prompterBack5 => 'رجوع 5 ث (Page Up)';

  @override
  String get prompterForward5 => 'تقديم 5 ث (Page Down)';

  @override
  String get prompterPlay => 'تشغيل (Space)';

  @override
  String get prompterPause => 'إيقاف مؤقت (Space)';

  @override
  String get prompterSlower => 'أبطأ (↓)';

  @override
  String get prompterFaster => 'أسرع (↑)';

  @override
  String prompterWpm(int wpm) {
    return '$wpm WPM';
  }

  @override
  String prompterStatusLine(String status, String remaining) {
    return '$status · المتبقي $remaining';
  }

  @override
  String get prompterVoiceOn => 'تتبّع صوتي';

  @override
  String get prompterVoiceOff => 'إيقاف تتبّع الصوت';

  @override
  String get prompterGoToSection => 'الانتقال إلى قسم';

  @override
  String get prompterSettings => 'الإعدادات (S)';

  @override
  String get statusPlaying => 'قيد التشغيل';

  @override
  String statusAutoPaused(String seconds) {
    return 'إيقاف مؤقت $seconds ث';
  }

  @override
  String get statusAutoPausedShort => 'إيقاف مؤقت تلقائي';

  @override
  String get statusHolding => 'متوقف مؤقتًا — اضغط «تشغيل»';

  @override
  String get statusHoldingShort => 'إيقاف مؤقت في النص';

  @override
  String get statusFinished => 'النهاية';

  @override
  String get statusStopped => 'متوقف';

  @override
  String get settingsFontSize => 'حجم الخط';

  @override
  String get settingsLineHeight => 'تباعد الأسطر';

  @override
  String get settingsMargin => 'الهامش الجانبي';

  @override
  String get settingsFocusLine => 'خط التركيز';

  @override
  String get settingsSpeed => 'السرعة';

  @override
  String get settingsTextColor => 'لون النص';

  @override
  String get settingsWhite => 'أبيض';

  @override
  String get settingsYellow => 'أصفر';

  @override
  String get settingsMirrorH => 'انعكاس أفقي (H)';

  @override
  String get settingsMirrorV => 'انعكاس رأسي (V)';

  @override
  String get settingsFocusGuide => 'دليل خط التركيز';

  @override
  String get voiceTitle => 'تتبّع الصوت';

  @override
  String get voiceLanguage => 'لغة الصوت';

  @override
  String voiceStatusDownloading(int percent) {
    return 'جارٍ التنزيل $percent%';
  }

  @override
  String get voiceStatusInstalling => 'جارٍ تثبيت النموذج…';

  @override
  String get voiceStatusReady =>
      'جاهز: اضغط على الميكروفون في HUD وسيتبع النص صوتك';

  @override
  String get voiceStatusNoEngine =>
      'تم تثبيت النموذج، لكن محرك Vosk غير موجود (على Linux: tool/setup_vosk_linux.sh)';

  @override
  String voiceStatusNoModel(int size) {
    return 'النموذج غير مثبّت ($size MB، يُنزَّل مرة واحدة فقط)';
  }

  @override
  String voiceDownload(int size) {
    return 'تنزيل النموذج ($size MB)';
  }

  @override
  String get voiceErrorNoModel => 'نزّل نموذج الصوت من الإعدادات ← الصوت';

  @override
  String get voiceErrorNoEngine => 'Vosk غير مثبّت (tool/setup_vosk_linux.sh)';

  @override
  String get voiceErrorPermission =>
      'تم رفض إذن الميكروفون. اسمح به من إعدادات النظام لاستخدام تتبّع الصوت.';

  @override
  String voiceErrorDownload(String message) {
    return 'تعذّر تنزيل النموذج: $message';
  }

  @override
  String voiceErrorEngine(String message) {
    return 'خطأ في التعرّف على الصوت: $message';
  }

  @override
  String get remoteTitle => 'التحكم عن بُعد';

  @override
  String get remoteConnectTitle => 'الاتصال بجهاز تلقين';

  @override
  String get remoteReconnecting => 'جارٍ إعادة الاتصال…';

  @override
  String remoteRtt(String ms) {
    return 'RTT $ms ms';
  }

  @override
  String get remoteDisconnect => 'قطع الاتصال';

  @override
  String get remotePinRequired =>
      'أدخل رمز PIN المكوّن من 4 أرقام الظاهر على جهاز التلقين';

  @override
  String get remoteBadPin => 'رمز PIN غير صحيح';

  @override
  String remoteConnectFailed(String message) {
    return 'تعذّر الاتصال: $message';
  }

  @override
  String get remotePinLabel => 'رمز PIN لجهاز التلقين';

  @override
  String get remoteOnLan => 'على الشبكة المحلية';

  @override
  String get remoteSearch => 'بحث';

  @override
  String get remoteNoneFound =>
      'لم يتم العثور على جهاز تلقين. افتحه على كمبيوتر Linux أو استخدم IP يدويًا.';

  @override
  String get remoteManualIp => 'IP يدوي (مثل 192.168.1.20)';

  @override
  String get remoteConnect => 'اتصال';

  @override
  String get remotePosition => 'الموضع في النص';

  @override
  String remoteRemaining(String remaining) {
    return 'المتبقي $remaining';
  }

  @override
  String get remoteBack5 => 'رجوع 5 ث';

  @override
  String get remoteForward5 => 'تقديم 5 ث';

  @override
  String get remotePlay => 'تشغيل';

  @override
  String get remotePause => 'إيقاف مؤقت';

  @override
  String get remoteSlower => 'أبطأ';

  @override
  String get remoteFaster => 'أسرع';

  @override
  String get remoteMirrorH => 'انعكاس أفقي';

  @override
  String get remoteMirrorV => 'انعكاس رأسي';

  @override
  String get remoteFollowVoice => 'تتبّع الصوت';

  @override
  String get remoteStart => 'البداية';

  @override
  String get remoteSections => 'الأقسام والإشارات';

  @override
  String get remoteChangeScript => 'تغيير النص';

  @override
  String get aboutTitle => 'حول التطبيق';

  @override
  String aboutVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get aboutTagline =>
      'جهاز تلقين لنظامي Linux وAndroid: تمرير سلس، وتحكم عن بُعد عبر الشبكة المحلية، وتتبّع صوتي دون اتصال.';

  @override
  String get aboutCreatedBy => 'من إنشاء';

  @override
  String get aboutFollow => 'تابعني';

  @override
  String get aboutProject => 'المشروع';

  @override
  String get aboutSourceCode => 'الشيفرة المصدرية';

  @override
  String get aboutContribute => 'ساهم';

  @override
  String get aboutLicense => 'رخصة MIT';

  @override
  String get aboutVoiceCredit =>
      'التعرّف على الكلام دون اتصال: Vosk (Apache 2.0)';

  @override
  String get aboutLicenses => 'تراخيص البرمجيات مفتوحة المصدر';

  @override
  String aboutOpenFailed(String url) {
    return 'تعذّر فتح $url';
  }
}
