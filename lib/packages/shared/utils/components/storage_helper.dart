import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import '../../../core/coozy_core.dart' as core;

class StorageHelper {
  // Get the local path for storing files
  Future<String> get _localPath async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Get a reference to a local file
  Future<File> _getLocalFile(String fileName) async {
    final String localPath = await _localPath;
    return File('$localPath${Platform.pathSeparator}$fileName');
  }

  // Write text to a file (entire content at once)
  Future<File> writeTextToFile(String fileName, String? text) async {
    final File file = await _getLocalFile(fileName);
    return file.writeAsString(text ?? '', mode: FileMode.write);
  }

  // Write bytes to a file (entire content at once)
  Future<File> writeBytesToFile(String fileName, Uint8List? data) async {
    final File file = await _getLocalFile(fileName);
    return file.writeAsBytes(data!, mode: FileMode.write);
  }

  // Read text from a file (entire content at once)
  Future<String?> readFromFile(String fileName) async {
    try {
      final File file = await _getLocalFile(fileName);
      return await file.readAsString();
    } catch (e) {
      core.PlatformUtils.debugLog(StorageHelper, 'Error reading file: $e');
      return null;
    }
  }

  // Stream read from a file (for large files)
  Stream<List<int>> readFileAsStream(String fileName) async* {
    final File file = await _getLocalFile(fileName);
    final Stream<List<int>> stream = file.openRead();
    yield* stream;
  }

  // Stream write to a file (for large files)
  Future<void> writeStreamToFile(
    String fileName,
    Stream<List<int>> dataStream,
  ) async {
    final File file = await _getLocalFile(fileName);
    final IOSink sink = file.openWrite();
    await for (List<int> chunk in dataStream) {
      sink.add(chunk);
    }
    await sink.flush();
    await sink.close();
  }
}
// To read a large file using the stream method:
/*
  void readLargeFile(String fileName) async {
  final storageHelper = StorageHelper();
  await for (var chunk in storageHelper.readFileAsStream(fileName)) {
    // Process each chunk of data
    print(String.fromCharCodes(chunk));
  }
}*/

//To write a large file using the stream method:

/*
void writeLargeFile(String fileName, Stream<List<int>> dataStream) async {
  final storageHelper = StorageHelper();
  await storageHelper.writeStreamToFile(fileName, dataStream);
}
*/

// To read an entire file at once:
/*
void readWholeFile(String fileName) async {
  final storageHelper = StorageHelper();
  String? content = await storageHelper.readFromFile(fileName);
  print(content);
}
*/

// To write an entire text file at once:
/*
void writeWholeFile(String fileName, String content) async {
  final storageHelper = StorageHelper();
  await storageHelper.writeTextToFile(fileName, content);
}
*/

//To write an entire file with bytes at once:
/*
void writeWholeFileBytes(String fileName, Uint8List data) async {
  final storageHelper = StorageHelper();
  await storageHelper.writeBytesToFile(fileName, data);
}
*/
