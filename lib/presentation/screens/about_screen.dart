import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_info.dart';
import '../../domain/entities/prompter_settings.dart';
import '../l10n.dart';

/// Pantalla «Acerca de»: versión, autor, redes, código fuente y licencias.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static IconData _icon(SocialNetwork n) => switch (n) {
        SocialNetwork.github => Icons.code,
        SocialNetwork.youtube => Icons.smart_display_outlined,
        SocialNetwork.instagram => Icons.photo_camera_outlined,
        SocialNetwork.tiktok => Icons.music_note_outlined,
        SocialNetwork.x => Icons.alternate_email,
        SocialNetwork.linkedin => Icons.work_outline,
      };

  Future<void> _open(BuildContext context, String url) async {
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.aboutOpenFailed(url))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          Center(
            child: Column(children: [
              const Icon(Icons.subtitles_outlined, size: 64, color: PrompterPalette.yellow),
              const SizedBox(height: 12),
              Text(l10n.appTitle, style: t.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(l10n.aboutVersion(AppInfo.version), style: t.bodyMedium?.copyWith(color: PrompterPalette.dim)),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Text(l10n.aboutTagline, textAlign: TextAlign.center, style: t.bodyLarge),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          _Header(l10n.aboutCreatedBy),
          const ListTile(
            leading: CircleAvatar(child: Text('AC')),
            title: Text(AppInfo.author),
          ),
          _Header(l10n.aboutFollow),
          for (final s in AppInfo.socials)
            ListTile(
              leading: Icon(_icon(s.network)),
              title: Text(s.network.label),
              subtitle: Text(s.handle),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => _open(context, s.url),
            ),
          _Header(l10n.aboutProject),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(l10n.aboutSourceCode),
            subtitle: const Text('github.com/GNUXDAR/PromptFlow'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _open(context, AppInfo.repository),
          ),
          ListTile(
            leading: const Icon(Icons.volunteer_activism_outlined),
            title: Text(l10n.aboutContribute),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _open(context, AppInfo.contributing),
          ),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: Text(l10n.aboutLicense),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _open(context, AppInfo.license),
          ),
          ListTile(
            leading: const Icon(Icons.mic_none),
            title: Text(l10n.aboutVoiceCredit),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _open(context, AppInfo.vosk),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.aboutLicenses),
            onTap: () => showLicensePage(
              context: context,
              applicationName: l10n.appTitle,
              applicationVersion: AppInfo.version,
              applicationLegalese: '© 2026 ${AppInfo.author} · MIT',
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(text,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}
