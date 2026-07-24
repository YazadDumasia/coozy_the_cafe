import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

QueryExecutor openConnection(String dbName) {
  return driftDatabase(
    name: dbName,
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
      onResult: (result) {
        if (result.missingFeatures.isNotEmpty) {
          debugPrint(
            '⚠️ Drift Web Warning: Missing features: ${result.missingFeatures}',
          );
        }
      },
    ),
    native: DriftNativeOptions(
      databasePath: () async {
        final dbFolder = await getApplicationDocumentsDirectory();
        return p.join(dbFolder.path, dbName);
      },
      setup: (rawDb) {
        rawDb.execute('PRAGMA foreign_keys = ON;');
      },
    ),
  );
}
