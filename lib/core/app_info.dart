/// Datos de la app y del autor para la pantalla «Acerca de».
library;

abstract final class AppInfo {
  /// Debe coincidir con `version:` de pubspec.yaml (lo comprueba un test).
  static const version = '1.0.0';
  static const author = 'Arturo Cabrera';
  static const repository = 'https://github.com/GNUXDAR/PromptFlow';
  static const contributing = 'https://github.com/GNUXDAR/PromptFlow/blob/develop/CONTRIBUTING.md';
  static const license = 'https://github.com/GNUXDAR/PromptFlow/blob/develop/LICENSE';
  static const vosk = 'https://alphacephei.com/vosk/';

  static const socials = <SocialLink>[
    SocialLink(SocialNetwork.github, 'GNUXDAR', 'https://github.com/GNUXDAR'),
    SocialLink(SocialNetwork.youtube, '@gnuxdar', 'https://www.youtube.com/@gnuxdar'),
    SocialLink(SocialNetwork.instagram, '@gnuxdar', 'https://www.instagram.com/gnuxdar/'),
    SocialLink(SocialNetwork.tiktok, '@gnuxdar', 'https://www.tiktok.com/@gnuxdar'),
    SocialLink(SocialNetwork.x, '@gnuxdar', 'https://x.com/gnuxdar'),
    SocialLink(SocialNetwork.linkedin, 'arturo-cabrera', 'https://www.linkedin.com/in/arturo-cabrera/'),
  ];
}

enum SocialNetwork {
  github('GitHub'),
  youtube('YouTube'),
  instagram('Instagram'),
  tiktok('TikTok'),
  x('X'),
  linkedin('LinkedIn');

  const SocialNetwork(this.label);

  /// Nombre de marca: no se traduce.
  final String label;
}

final class SocialLink {
  const SocialLink(this.network, this.handle, this.url);
  final SocialNetwork network;
  final String handle;
  final String url;
}
