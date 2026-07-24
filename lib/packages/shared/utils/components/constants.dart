import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' as toast;
import 'package:shared_preferences/shared_preferences.dart' as shared;
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/coozy_core.dart' as core;
import '../../coozy_shared.dart' as shared;

class Constants {
  static Map<String, String> hashMap = <String, String>{};
  static String kValidHexPattern = r'^#?[0-9a-fA-F]{1,8}';

  bool isFutureDate(String dateString) {
    try {
      final DateTime? bookingDate = DateTime.tryParse(dateString)?.toUtc();
      final DateTime today = DateTime.now().toUtc();
      return (bookingDate?.isAfter(today) ?? false) ||
          (bookingDate?.isAtSameMomentAs(today) ?? false);
    } catch (e) {
      core.PlatformUtils.debugLog(Constants, e.toString());
      return false;
    }
  }

  bool isPastDate(String dateString) {
    try {
      final DateTime? bookingDate = DateTime.tryParse(dateString)?.toUtc();
      final DateTime today = DateTime.now().toUtc();
      return (bookingDate?.isAfter(today) ?? false);
    } catch (e) {
      core.PlatformUtils.debugLog(Constants, e.toString());
      return false;
    }
  }

  static String? getValueFromKey(
    String? internetString,
    String? startInternetString,
    String? appendInternetString,
    String? defaultString,
  ) {
    if (internetString == null || internetString.isEmpty) {
      return defaultString.toString();
    } else {
      if (Constants.hashMap.isEmpty) {
        return defaultString.toString();
      } else {
        if (Constants.hashMap.containsKey(
          internetString.toString().trim().toLowerCase(),
        )) {
          final String str =
              (startInternetString ?? '') +
              Constants.hashMap[internetString.toLowerCase()]!.toString() +
              (appendInternetString ?? '');
          return str;
        } else {
          core.PlatformUtils.debugLog(
            Constants,
            'String Not Found:$internetString',
          );
          return defaultString.toString().trim();
        }
      }
    }
    /*
    if (internetString != null && internetString.isNotEmpty) {

      if (Constants.hashMap.isNotEmpty) {
        if (Constants.hashMap
            .containsKey(internetString.toString().trim().toLowerCase())) {
          String? str = (startInternetString ?? "") +
              Constants.hashMap[internetString.toLowerCase()]!.toString() +
              (appendInternetString ?? "");
          return str;
        } else {
          Constants.debugLog(Constants, "String Not Found:$internetString");
          return defaultString.toString().trim();
        }
      } else {
        return defaultString.toString();
      }
    } else {

      return defaultString.toString();
    }*/
  }

  static String getTextTimeAgo({
    required String? localizedCode,
    String? dateStr,
    DateTime? dateTime,
    bool? allowFromNow,
  }) {
    core.PlatformUtils.debugLog(Constants, 'date:$dateStr');
    core.PlatformUtils.debugLog(Constants, 'dateTime:$dateTime');
    if (dateStr != null && dateStr.isNotEmpty) {
      final DateTime? passingDate = DateTime.tryParse(dateStr)?.toLocal();
      final DateTime now = DateTime.now().toLocal();
      final Duration duration = now.difference(passingDate!);
      final DateTime result = now.subtract(duration).toLocal();
      return timeago.format(
        result,
        locale: localizedCode,
        allowFromNow: allowFromNow ?? true,
        clock: now,
      );
    } else if (dateTime != null) {
      final DateTime now = DateTime.now().toLocal();
      final Duration duration = now.difference(dateTime);
      final DateTime result = now.subtract(duration).toLocal();
      return timeago.format(
        result,
        locale: localizedCode,
        allowFromNow: allowFromNow ?? true,
        clock: now,
      );
    } else {
      return '';
    }
  }

  static Future<bool> isFirstTime(String? str) async {
    final shared.SharedPreferences prefs =
        await shared.SharedPreferences.getInstance();
    final bool firstTime =
        prefs.getBool(
          str ?? shared.PreferencesKeys.commonFirstTime.toString(),
        ) ??
        true;
    if (firstTime) {
      // first time
      await prefs.setBool(
        str ?? shared.PreferencesKeys.commonFirstTime.toString(),
        false,
      );
      return true;
    } else {
      return false;
    }
  }

  static String convertSecondsToHMS(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int remainingSeconds = totalSeconds % 3600;
    final int minutes = remainingSeconds ~/ 60;
    final int seconds = remainingSeconds % 60;
    final StringBuffer buffer = StringBuffer('');
    if (hours == 0) {
      buffer.write('');
    } else {
      buffer.write("${hours.toString().padLeft(2, '0')} Hours, ");
    }
    if (minutes == 0) {
      buffer.write('');
    } else {
      buffer.write("${minutes.toString().padLeft(2, '0')} Minutes, ");
    }

    if (seconds == 0) {
      buffer.write('0 Second');
    } else {
      buffer.write("${seconds.toString().padLeft(2, '0')} Second");
    }

    return buffer.toString();
  }

  static void showToastMsg({required String? msg, bool? isForShortDuration}) {
    toast.Fluttertoast.showToast(
      msg: '$msg',
      timeInSecForIosWeb:
          isForShortDuration == null || isForShortDuration == true ? 3 : 5,
      toastLength: isForShortDuration == null || isForShortDuration == true
          ? toast.Toast.LENGTH_SHORT
          : toast.Toast.LENGTH_LONG,
      fontSize: 16,
      textColor: Colors.white,
    );
  }
}
