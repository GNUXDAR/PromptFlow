import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:promptflow/core/app_info.dart';

void main() {
  test('AppInfo.version coincide con pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final v = RegExp(r'^version:\s*([0-9.]+)', multiLine: true).firstMatch(pubspec)!.group(1);
    expect(AppInfo.version, v);
  });

  test('redes del autor: https y una por red', () {
    expect(AppInfo.socials.map((s) => s.network).toSet(), hasLength(AppInfo.socials.length));
    for (final s in AppInfo.socials) {
      expect(Uri.parse(s.url).scheme, 'https');
    }
    expect(AppInfo.socials.firstWhere((s) => s.network == SocialNetwork.linkedin).url,
        'https://www.linkedin.com/in/arturo-cabrera/');
  });
}
