import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../shared/coozy_shared.dart' as shared;

class HomeScreenActions {
  static Future<bool> handleBackPress(
    BuildContext context,
    GlobalKey<ScaffoldState> scaffoldKey,
    TabController tabController,
    DateTime? currentBackPressTime,
    void Function(DateTime) onUpdateBackPressTime,
  ) async {
    // If drawer is open, close it
    if (scaffoldKey.currentState?.isDrawerOpen ?? false) {
      scaffoldKey.currentState?.closeDrawer();
      return false;
    }

    // If not on the first tab, go to first tab
    if (tabController.index != 1) {
      tabController.animateTo(1);
      return false;
    } else {
      if (kIsWeb) {
        return await onBackPressDialog(context) ?? false;
      }

      final DateTime now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
        onUpdateBackPressTime(now);
        Fluttertoast.showToast(
          msg:
              context.tr(shared.LocaleKeys.homepagePressBackAgainToExitMsg) ??
              'Press back again to exit.',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 3,
        );
        return false;
      } else {
        return await onBackPressDialog(context) ?? false;
      }
    }
  }

  static Future<bool?> onBackPressDialog(BuildContext context) {
    bool isMobile = !kIsWeb && (Platform.isIOS || Platform.isAndroid);
    if (!isMobile) {
      return showDialog<bool>(
        context: context,
        builder: (context) => Theme(
          data: Theme.of(context),
          child: AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            titlePadding: const EdgeInsets.all(10.0),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 10.0,
            ),
            buttonPadding: const EdgeInsets.symmetric(horizontal: 10.0),
            title: Text(
              context.tr(
                    shared.LocaleKeys.homePageAreYouSureExitTitle,
                    track: shared.TrackConstants.homePageTrack,
                  ) ??
                  'Are you sure?',
            ),
            content: Text(
              context.tr(
                    shared.LocaleKeys.homePageDoYouWantToExitTheApp,
                    track: shared.TrackConstants.homePageTrack,
                  ) ??
                  'Do you want to exit the app?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  context.tr(
                        shared.LocaleKeys.commonNo,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'No',
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  context.tr(
                        shared.LocaleKeys.commonYes,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'Yes',
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(35.0)),
          ),
          contentPadding: const EdgeInsets.only(top: 10.0),
          title: Text(
            context.tr(
                  shared.LocaleKeys.homePageAreYouSureExitTitle,
                  track: shared.TrackConstants.homePageTrack,
                ) ??
                'Are you sure?',
          ),
          content: Text(
            context.tr(
                  shared.LocaleKeys.homePageDoYouWantToExitTheApp,
                  track: shared.TrackConstants.homePageTrack,
                ) ??
                'Do you want to exit the app?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                context.tr(
                      shared.LocaleKeys.commonNo,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'No',
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                context.tr(
                      shared.LocaleKeys.commonYes,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Yes',
              ),
            ),
          ],
        ),
      );
    }
  }
}
