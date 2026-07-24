import 'package:platform_info/platform_info.dart' as plt_info;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

class PlatformUtils {
  static bool isMobileApp() {
    try {
      return plt_info.platform.mobile == true;
    } catch (e) {
      return false;
    }
  }

  static bool isAndroid() {
    try {
      return plt_info.platform.android == true;
    } catch (e) {
      return false;
    }
  }

  static bool isIOS() {
    try {
      return plt_info.platform.iOS == true;
    } catch (e) {
      return false;
    }
  }

  static bool isWindowsOS() {
    try {
      return plt_info.platform.windows == true;
    } catch (e) {
      return false;
    }
  }

  static bool isMacOS() {
    try {
      return plt_info.platform.macOS == true;
    } catch (e) {
      return false;
    }
  }

  static bool isLinuxOS() {
    try {
      return plt_info.platform.linux == true;
    } catch (e) {
      return false;
    }
  }

  static bool isFuchsia() {
    try {
      return plt_info.platform.fuchsia == true;
    } catch (e) {
      return false;
    }
  }

  static Future<String> getCurrentPlatform() async {
    try {
      if (plt_info.platform.type == const plt_info.HostPlatformType.js()) {
        return 'Web';
      }

      return switch (plt_info.platform) {
        _ when plt_info.platform.macOS => 'macOS',
        _ when plt_info.platform.linux => 'Linux',
        _ when plt_info.platform.windows => 'Windows',
        _ when plt_info.platform.android => 'Android',
        _ when plt_info.platform.iOS => 'iOS',
        _ when plt_info.platform.fuchsia => 'Fuchsia',
        _ => 'Unknown platform',
      };
    } catch (e) {
      return 'Unknown platform';
    }
  }

  static Future<String> getCurrentPlatformBuildMode() async {
    try {
      switch (plt_info.platform.buildMode) {
        case plt_info.BuildMode.debug:
          return 'debug';
        case plt_info.BuildMode.profile:
          return 'profile';
        case plt_info.BuildMode.release:
          return 'release';
        default:
          return 'debug';
      }
    } catch (e) {
      return 'Unknown build mode';
    }
  }

  static String? getCurrentPlatformVersion() {
    try {
      return plt_info.platform.version;
    } catch (e) {
      return '';
    }
  }

  static void debugLog(Type? classObject, String? message) {
    if (kDebugMode) {
      debugPrint('${classObject?.toString() ?? 'Global'}: $message');
    }
  }
}
