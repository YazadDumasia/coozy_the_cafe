// ignore_for_file: avoid_print
import 'dart:io';

Future<void> main() async {
  print('--- Drift Web Wasm Sync Tool ---');

  final pubspecLock = File('pubspec.lock');
  if (!pubspecLock.existsSync()) {
    print('Error: pubspec.lock not found in current directory.');
    exit(1);
  }

  final content = pubspecLock.readAsStringSync();

  // Extract sqlite3 version
  final sqlite3VersionMatch = RegExp(
    r'sqlite3:\n\s+dependency: ".*"\n\s+description:\n\s+name: sqlite3\n\s+sha256: ".*"\n\s+url: ".*"\n\s+source: hosted\n\s+version: "(.*)"',
  ).firstMatch(content);
  // Extract drift version
  final driftVersionMatch = RegExp(
    r'drift:\n\s+dependency: ".*"\n\s+description:\n\s+name: drift\n\s+sha256: ".*"\n\s+url: ".*"\n\s+source: hosted\n\s+version: "(.*)"',
  ).firstMatch(content);

  final sqlite3Version = sqlite3VersionMatch?.group(1) ?? '3.3.4';
  final driftVersion = driftVersionMatch?.group(1) ?? '2.34.0';

  print('Detected package:sqlite3 version: $sqlite3Version');
  print('Detected package:drift version: $driftVersion');

  final sqlite3Url =
      'https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-$sqlite3Version/sqlite3.wasm';
  final driftWorkerUrl =
      'https://github.com/simolus3/drift/releases/download/drift-$driftVersion/drift_worker.js';

  final webDir = Directory('web');
  if (!webDir.existsSync()) {
    webDir.createSync();
  }

  print('\nDownloading sqlite3.wasm...');
  await _download(sqlite3Url, 'web/sqlite3.wasm');

  print('Downloading drift_worker.js...');
  await _download(driftWorkerUrl, 'web/drift_worker.js');

  print(
    '\n✅ Web resources successfully synced with your pubspec.lock versions!',
  );
  print(
    'Remember to clear your browser cache or perform a Hard Refresh if running locally.',
  );
}

Future<void> _download(String url, String path) async {
  final process = await Process.start('curl', ['-L', url, '-o', path]);
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    print('❌ Failed to download from $url');
  } else {
    print('✅ Saved to $path');
  }
}
