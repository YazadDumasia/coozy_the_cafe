import 'dart:async';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/coozy_core.dart' as core;

class ImageProcessor {
  final List<Map<String, dynamic>> data = <Map<String, dynamic>>[];

  /// Process image data with batching and concurrency control
  Future<void> processImageData(
    List<dynamic> jsonData, {
    int batchSize = 100,
    int maxConcurrentTasks = 5,
  }) async {
    for (int i = 0; i < jsonData.length; i += batchSize) {
      // Split data into batches
      final List batch = jsonData.sublist(
        i,
        i + batchSize > jsonData.length ? jsonData.length : i + batchSize,
      );

      await _processBatch(batch, maxConcurrentTasks);
    }
  }

  /// Process a single batch of image data with limited concurrency
  Future<void> _processBatch(
    List<dynamic> batch,
    int maxConcurrentTasks,
  ) async {
    final Semaphore semaphore = Semaphore(maxConcurrentTasks);
    final List<Future<void>> tasks = <Future<void>>[];

    for (var imageData in batch) {
      tasks.add(
        semaphore.withPermits(() async {
          final String? downloadUrl = Uri.tryParse(
            imageData['download_url'],
          )?.toString();
          if (downloadUrl == null) return;

          try {
            // Use CachedNetworkImageProvider for caching
            final CachedNetworkImageProvider imageProvider =
                CachedNetworkImageProvider(downloadUrl);

            final Completer<void> completer = Completer<void>();
            final ImageStream imageStream = imageProvider.resolve(
              const ImageConfiguration(),
            );

            imageStream.addListener(
              ImageStreamListener(
                (ImageInfo info, _) {
                  data.add(<String, dynamic>{
                    'id': imageData['id'],
                    'author': imageData['author'],
                    'url': Uri.tryParse(imageData['url'])?.toString(),
                    'download_url': downloadUrl,
                    'image_width': info.image.width.toDouble(),
                    'image_height': info.image.height.toDouble(),
                  });
                  completer.complete();
                },
                onError: (dynamic error, StackTrace? stackTrace) {
                  core.PlatformUtils.debugLog(
                    ImageProcessor,
                    'Error loading image: $error',
                  );
                  completer.complete();
                },
              ),
            );

            await completer.future;
          } catch (e) {
            core.PlatformUtils.debugLog(ImageProcessor, 'Unexpected error: $e');
          }
        }),
      );
    }

    await Future.wait(tasks); // Wait for all tasks in the batch to complete
  }
}

/// A simple Semaphore implementation
class Semaphore {
  Semaphore(int maxPermits) : _currentPermits = maxPermits;
  int _currentPermits;
  final List<Completer<void>> _queue = <Completer<void>>[];

  Future<void> withPermits(Future<void> Function() action) async {
    await _acquire();
    try {
      await action();
    } finally {
      _release();
    }
  }

  Future<void> _acquire() {
    if (_currentPermits > 0) {
      _currentPermits--;
      return Future.value();
    } else {
      final Completer<void> completer = Completer<void>();
      _queue.add(completer);
      return completer.future;
    }
  }

  void _release() {
    if (_queue.isNotEmpty) {
      final Completer<void> completer = _queue.removeAt(0);
      completer.complete();
    } else {
      _currentPermits++;
    }
  }
}
