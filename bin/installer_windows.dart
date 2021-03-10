#!/usr/bin/env dart

library installer_windows;

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

const youDontHaveAProperPubspec = '''
Your app's pubspec.yaml doesn't have a Squirrel section, it is Highly Recommended 
to have one! Here's an example section with all of the available parameters, though
most are optional:

squirrel:
  windows:
    certificateFile: "foo"
    overrideSigningParameters: "bar"
    loadingGif: "baz"
    iconUrl: "blahhgh"
    appFriendlyName: "blaf"
    appDescription: "blaf"
    setupIcon: "bamf"
    releaseDirectory: "blaf"
    buildEnterpriseMsiPackage: false
    dontBuildDeltas: false
''';

String stringOrThrow(dynamic? d, String err) {
  if (d == null) {
    throw Exception(err);
  }

  return d.toString();
}

String parseVersion(dynamic? v) {
  final ver = stringOrThrow(v, 'Your app needs a version');
  return ver.replaceFirst(RegExp(r'[-+].*$'), '').trimLeft();
}

String parseAuthor(dynamic? a) {
  final author = stringOrThrow(a, 'Your pubspec needs an authors section');
  return author.replaceAll(RegExp(r' <.*?>'), '').trimLeft();
}

class PubspecParams {
  final String name;
  final String title;
  final String version;
  final String authors;
  final String description;
  final String? certificateFile;
  final String? overrideSigningParameters;
  final String? loadingGif;
  final String? appIconUrl;
  final String? setupIcon;
  final String releaseDirectory;
  final bool buildEnterpriseMsiPackage;
  final bool dontBuildDeltas;

  PubspecParams(
      this.name,
      this.title,
      this.version,
      this.authors,
      this.description,
      this.certificateFile,
      this.overrideSigningParameters,
      this.loadingGif,
      this.appIconUrl,
      this.setupIcon,
      this.releaseDirectory,
      this.buildEnterpriseMsiPackage,
      this.dontBuildDeltas);

  factory PubspecParams.fromYaml(dynamic appPubspec) {
    dynamic windowsSection = appPubspec['squirrel']['windows'];
    if (windowsSection == null) {
      stderr.writeln(youDontHaveAProperPubspec);
      windowsSection = {};
    }

    final name = appPubspec['name'].toString();
    final title = stringOrThrow(
        windowsSection['appFriendlyName'] ?? appPubspec['title'],
        'Your app needs a description!');
    final version = parseVersion(appPubspec['version']);
    final authors = parseAuthor(appPubspec['authors']);
    final description = stringOrThrow(windowsSection['appDescription'] ?? title,
        'Your app must have a description');
    final certificateFile = windowsSection['certificateFile']?.toString();
    final overrideSigningParameters =
        windowsSection['overrideSigningParameters']?.toString();
    final loadingGif = windowsSection['loadingGif']?.toString();
    final appIconUrl = windowsSection['appIconUrl']?.toString();
    final setupIcon = windowsSection['setupIcon']?.toString();
    final releaseDirectory = windowsSection['releaseDirectory']?.toString() ??
        path.join(appDir, 'build');
    final buildEnterpriseMsiPackage =
        windowsSection['buildEnterpriseMsiPackage'] == true ? true : false;
    final dontBuildDeltas =
        windowsSection['dontBuildDeltas'] == true ? true : false;

    return PubspecParams(
        name,
        title,
        version,
        authors,
        description,
        certificateFile,
        overrideSigningParameters,
        loadingGif,
        appIconUrl,
        setupIcon,
        releaseDirectory,
        buildEnterpriseMsiPackage,
        dontBuildDeltas);
  }
}

Future<int> main(List<String> args) async {
  final yaml = loadYaml(await File(pubspecYaml).readAsString());

  final template = Environment().fromString(
      await File(path.join(rootDir, 'nuspec.jinja')).readAsString());

  final pubspec = PubspecParams.fromYaml(yaml);

  print(template.render(
      name: pubspec.name,
      title: pubspec.title,
      description: pubspec.description,
      version: pubspec.version,
      authors: pubspec.authors,
      iconUrl: pubspec.appIconUrl,
      additionalFiles: <dynamic>[]));

  // Copy Squirrel.exe into the app dir and squish the setup icon in
  // Squish the icon into main exe too
  // ls -r to get our file tree and create a temp dir
  // nuget pack
  // Run syncReleases
  // Releasify!

  return 0;
}
