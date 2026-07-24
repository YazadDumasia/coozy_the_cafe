import 'package:coozy_the_cafe/packages/shared/config/app_extensions.dart';
import 'package:coozy_the_cafe/packages/shared/l10n/locale_keys.dart';
import 'package:coozy_the_cafe/packages/shared/l10n/track_constants.dart';
import 'package:coozy_the_cafe/packages/shared/utils/components/local_manager.dart';
import 'package:flutter/material.dart';

class HomeScreenPopupMenu extends StatelessWidget {
  const HomeScreenPopupMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: PopupMenuButton<String>(
        onSelected: (value) async {
          switch (value) {
            case 'backup_db':
              break;
            case 'export_db':
              break;
            case 'restore_db':
              break;
            case 'clear_data':
              await LocalManager.instance.clearAll();
              break;
            default:
              break;
          }
        },
        itemBuilder: (BuildContext bc) {
          return <PopupMenuItem<String>>[
            PopupMenuItem(
              value: 'backup_db',
              child: Text(
                context.tr(
                      LocaleKeys.homePageBackup,
                      track: TrackConstants.homePageTrack,
                    ) ??
                    'Backup',
              ),
            ),
            PopupMenuItem(
              value: 'export_db',
              child: Text(
                context.tr(
                      LocaleKeys.homePageExport,
                      track: TrackConstants.homePageTrack,
                    ) ??
                    'Export',
              ),
            ),
            PopupMenuItem(
              value: 'restore_db',
              child: Text(
                context.tr(
                      LocaleKeys.homePageRestore,
                      track: TrackConstants.homePageTrack,
                    ) ??
                    'Restore',
              ),
            ),
            PopupMenuItem(
              value: 'clear_data',
              child: Text(
                context.tr(
                      LocaleKeys.homePageClearData,
                      track: TrackConstants.homePageTrack,
                    ) ??
                    'Clear Data',
              ),
            ),
          ];
        },
        icon: Icon(
          Icons.more_vert_rounded,
          size: Theme.of(context).appBarTheme.iconTheme?.size,
          color: Theme.of(context).appBarTheme.iconTheme?.color,
        ),
      ),
    );
  }
}
