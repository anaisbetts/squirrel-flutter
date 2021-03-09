#!/usr/bin/env dart

library installer_windows;

import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:jinja/jinja.dart';

final rootDir = path
    .canonicalize(path.join(path.dirname(path.fromUri(Platform.script)), '..'));

// NB: there has got to be a better way to do this
final appDir = path.canonicalize(
    path.join(path.dirname(path.fromUri(Platform.packageConfig!)), '..'));

final pubspecYaml = path.join(appDir, 'pubspec.yaml');

Future<int> main(List<String> args) async {
  final pubspec = loadYaml(await File(pubspecYaml).readAsString());

  final template = Environment().fromString(
      await File(path.join(rootDir, 'nuspec.jinja')).readAsString());

  print(template.render(
      name: pubspec['name'],
      title: pubspec['title'],
      version: pubspec['version'],
      authors: pubspec['authors'] ?? 'FILL IN THE AUTHORS',
      iconUrl: 'FILL THIS IN',
      description: 'FILL THIS IN',
      copyright: 'FILL THIS IN',
      exe: 'FILL THIS IN',
      additionalFiles: <dynamic>[]));

  return 0;
}
