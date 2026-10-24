import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class DatabaseBackupHelper {
  DatabaseBackupHelper._();

  static Future<void> showBackupDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDesktop = shared.ResponsiveLayout.isDesktop(context);
    final isTablet = shared.ResponsiveLayout.isTablet(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        double progress = 0.0;
        String status = 'Initializing backup...';
        bool isDone = false;
        String? error;
        String? generatedPath;

        return StatefulBuilder(
          builder: (context, setState) {
            void runBackup() async {
              try {
                final db = sl<CoozyDatabase>();
                final path = await db.backupDatabase(
                  encryptBackup: true,
                  onProgress: (p, s) {
                    if (context.mounted) {
                      setState(() {
                        progress = p;
                        status = s;
                      });
                    }
                  },
                );

                if (context.mounted) {
                  setState(() {
                    isDone = true;
                    generatedPath = path;
                    status = 'Database backup created successfully!';
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  setState(() {
                    error = e.toString();
                    status = 'Backup failed';
                  });
                }
              }
            }

            // Start immediately once
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (progress == 0.0 && error == null && !isDone) {
                runBackup();
              }
            });

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 500 : (isTablet ? 450 : 360),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            error != null
                                ? Icons.error_outline_rounded
                                : (isDone
                                      ? Icons.check_circle_rounded
                                      : Icons.backup_rounded),
                            color: error != null
                                ? scheme.error
                                : (isDone ? Colors.green : scheme.primary),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Database Backup',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (error != null)
                        Text(
                          error!,
                          style: TextStyle(color: scheme.error, fontSize: 13),
                        )
                      else ...[
                        LinearProgressIndicator(
                          value: isDone ? 1.0 : progress,
                          borderRadius: BorderRadius.circular(8),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          status,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isDone && generatedPath != null)
                            ElevatedButton.icon(
                              icon: Icon(
                                kIsWeb
                                    ? Icons.download_rounded
                                    : Icons.share_rounded,
                                size: 18,
                              ),
                              label: Text(
                                kIsWeb ? 'Download Backup' : 'Share File',
                              ),
                              onPressed: () async {
                                if (kIsWeb) {
                                  try {
                                    final db = sl<CoozyDatabase>();
                                    final exportService =
                                        DatabaseJsonExportService(db);
                                    final data = await exportService
                                        .exportAllTablesToJson();
                                    final jsonBytes = Uint8List.fromList(
                                      utf8.encode(
                                        const JsonEncoder.withIndent('  ')
                                            .convert(data),
                                      ),
                                    );
                                    await Printing.sharePdf(
                                      bytes: jsonBytes,
                                      filename: generatedPath!,
                                    );
                                  } catch (e) {
                                    PlatformUtils.debugLog(
                                      DatabaseBackupHelper,
                                      'Error downloading backup on Web: $e',
                                    );
                                  }
                                } else {
                                  final xFile = XFile(generatedPath!);
                                  await SharePlus.instance.share(
                                    ShareParams(
                                      files: [xFile],
                                      subject:
                                          'Coozy Cafe Encrypted Database Backup',
                                    ),
                                  );
                                }
                              },
                            ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: (isDone || error != null)
                                ? () => Navigator.of(dialogContext).pop()
                                : null,
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> showExportDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDesktop = shared.ResponsiveLayout.isDesktop(context);
    final isTablet = shared.ResponsiveLayout.isTablet(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        double progress = 0.0;
        String status = 'Preparing JSON export...';
        bool isDone = false;
        String? error;
        String? exportedPath;

        return StatefulBuilder(
          builder: (context, setState) {
            void runExport() async {
              try {
                final db = sl<CoozyDatabase>();
                final exportService = DatabaseJsonExportService(db);
                final path = await exportService.exportToFile(
                  onProgress: (p, s) {
                    if (context.mounted) {
                      setState(() {
                        progress = p;
                        status = s;
                      });
                    }
                  },
                );

                if (context.mounted) {
                  setState(() {
                    isDone = true;
                    exportedPath = path;
                    status = 'JSON Export ready for download/sharing!';
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  setState(() {
                    error = e.toString();
                    status = 'Export failed';
                  });
                }
              }
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (progress == 0.0 && error == null && !isDone) {
                runExport();
              }
            });

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 500 : (isTablet ? 450 : 360),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            error != null
                                ? Icons.error_outline_rounded
                                : (isDone
                                      ? Icons.check_circle_rounded
                                      : Icons.file_upload_outlined),
                            color: error != null
                                ? scheme.error
                                : (isDone ? Colors.green : scheme.primary),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'JSON Database Export',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (error != null)
                        Text(
                          error!,
                          style: TextStyle(color: scheme.error, fontSize: 13),
                        )
                      else ...[
                        LinearProgressIndicator(
                          value: isDone ? 1.0 : progress,
                          borderRadius: BorderRadius.circular(8),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          status,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isDone && exportedPath != null)
                            ElevatedButton.icon(
                              icon: Icon(
                                kIsWeb
                                    ? Icons.download_rounded
                                    : Icons.share_rounded,
                                size: 18,
                              ),
                              label: Text(
                                kIsWeb ? 'Download JSON' : 'Export & Share',
                              ),
                              onPressed: () async {
                                if (kIsWeb) {
                                  try {
                                    final db = sl<CoozyDatabase>();
                                    final exportService =
                                        DatabaseJsonExportService(db);
                                    final data = await exportService
                                        .exportAllTablesToJson();
                                    final jsonBytes = Uint8List.fromList(
                                      utf8.encode(
                                        const JsonEncoder.withIndent('  ')
                                            .convert(data),
                                      ),
                                    );
                                    await Printing.sharePdf(
                                      bytes: jsonBytes,
                                      filename: exportedPath!,
                                    );
                                  } catch (e) {
                                    PlatformUtils.debugLog(
                                      DatabaseBackupHelper,
                                      'Error downloading JSON export on Web: $e',
                                    );
                                  }
                                } else {
                                  final xFile = XFile(exportedPath!);
                                  await SharePlus.instance.share(
                                    ShareParams(
                                      files: [xFile],
                                      subject: 'Coozy Cafe JSON Export',
                                    ),
                                  );
                                }
                              },
                            ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: (isDone || error != null)
                                ? () => Navigator.of(dialogContext).pop()
                                : null,
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> showRestoreOptionsDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDesktop = shared.ResponsiveLayout.isDesktop(context);
    final isTablet = shared.ResponsiveLayout.isTablet(context);

    // List recent backups from backup directory
    List<FileSystemEntity> backupFiles = [];
    if (!kIsWeb) {
      try {
        final db = sl<CoozyDatabase>();
        final dbPath = await db.getDbPath();
        final parentDir = File(dbPath).parent;
        if (await parentDir.exists()) {
          backupFiles = parentDir
              .listSync()
              .where((f) => f.path.endsWith('.db') || f.path.endsWith('.enc'))
              .toList();
        }
      } catch (_) {}
    }

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool isDragging = false;

        Future<void> handleSelectedFile(dynamic fileItem) async {
          try {
            String? contentToRestore;
            String? filePath;

            if (fileItem is PlatformFile) {
              if (kIsWeb) {
                final bytes = await fileItem.readAsBytes();
                contentToRestore = utf8.decode(bytes);
              } else {
                filePath = fileItem.path;
              }
            } else if (fileItem is XFile) {
              if (kIsWeb) {
                final bytes = await fileItem.readAsBytes();
                contentToRestore = utf8.decode(bytes);
              } else {
                filePath = fileItem.path;
              }
            }

            final target = contentToRestore ?? filePath;
            if (target != null && dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
              await _executeRestore(context, target);
            }
          } catch (e) {
            PlatformUtils.debugLog(
              DatabaseBackupHelper,
              'Error preparing file for restore: $e',
            );
          }
        }

        Future<void> pickFile() async {
          try {
            if (kIsWeb) {
              // Ensure FilePickerWeb is active on Web if hot-reloaded
              try {
                FilePickerPlatform.instance;
              } catch (_) {}
            }
            final picked = await FilePicker.pickFile(
              type: FileType.custom,
              allowedExtensions: kIsWeb ? ['json'] : ['db', 'enc', 'json'],
            );
            if (picked != null) {
              await handleSelectedFile(picked);
            }
          } catch (e) {
            PlatformUtils.debugLog(
              DatabaseBackupHelper,
              'FilePicker error: $e',
            );
          }
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 600 : (isTablet ? 500 : double.infinity),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.settings_backup_restore_rounded,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Restore Database',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Upload or select a database backup file to restore application state. CAUTION: Restoring will overwrite existing data.',
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Drag and Drop Zone with tap support
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: pickFile,
                          borderRadius: BorderRadius.circular(12),
                          child: DropTarget(
                            onDragEntered: (_) =>
                                setDialogState(() => isDragging = true),
                            onDragExited: (_) =>
                                setDialogState(() => isDragging = false),
                            onDragDone: (detail) async {
                              setDialogState(() => isDragging = false);
                              if (detail.files.isNotEmpty) {
                                await handleSelectedFile(detail.files.first);
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 24,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isDragging
                                    ? scheme.primary.withValues(alpha: 0.12)
                                    : scheme.surfaceContainerHighest
                                        .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDragging
                                      ? scheme.primary
                                      : scheme.outlineVariant,
                                  width: isDragging ? 2 : 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 44,
                                    color: isDragging
                                        ? scheme.primary
                                        : scheme.primary,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Drag & drop backup file here',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    kIsWeb
                                        ? 'Supports (.json) backup files'
                                        : 'Supports (.db, .enc, .json) backup files',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: pickFile,
                                    icon: const Icon(Icons.folder_open_rounded, size: 18),
                                    label: const Text('Browse File'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (backupFiles.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Recent Local Backups:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: backupFiles.length,
                            separatorBuilder: (_, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final file = backupFiles[index];
                              final name = file.path
                                  .split(Platform.pathSeparator)
                                  .last;
                              return ListTile(
                                leading: const Icon(Icons.storage_rounded),
                                title: Text(
                                  name,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                trailing: ElevatedButton(
                                  child: const Text('Restore'),
                                  onPressed: () async {
                                    Navigator.of(dialogContext).pop();
                                    await _executeRestore(context, file.path);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> _executeRestore(
    BuildContext context,
    String backupFilePath,
  ) async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        double progress = 0.0;
        String status = 'Starting restore...';
        bool isDone = false;
        String? error;

        return StatefulBuilder(
          builder: (context, setState) {
            void runRestore() async {
              try {
                final db = sl<CoozyDatabase>();
                await db.restoreDatabase(
                  backupFilePath,
                  onProgress: (p, s) {
                    if (context.mounted) {
                      setState(() {
                        progress = p;
                        status = s;
                      });
                    }
                  },
                );

                if (context.mounted) {
                  setState(() {
                    isDone = true;
                    status = 'Database restored successfully! Please restart or reload.';
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  setState(() {
                    error = e.toString();
                    status = 'Restore failed';
                  });
                }
              }
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (progress == 0.0 && error == null && !isDone) {
                runRestore();
              }
            });

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Restoring Database',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (error != null)
                      Text(error!, style: TextStyle(color: scheme.error))
                    else ...[
                      LinearProgressIndicator(value: isDone ? 1.0 : progress),
                      const SizedBox(height: 12),
                      Text(status, textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 20),
                    if (isDone || error != null)
                      ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('OK'),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
