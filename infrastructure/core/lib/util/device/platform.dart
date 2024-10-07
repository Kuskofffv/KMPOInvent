import 'dart:io';
import 'dart:ui';

import 'package:core/util/extension/extensions.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../../core_dependencies.dart';

class TPlatform {
  TPlatform._();

  static bool _preloaded = false;
  static String? webPackageName;
  static String? webVersionName;
  static int? webVersionCode;

  static Future preload() async {
    if (_preloaded) {
      return;
    }
    _preloaded = true;
    _packageInfo = await PackageInfo.fromPlatform();
    _versionCode = _packageInfo.buildNumber.toInt();

    final deviceInfoPlugin = DeviceInfoPlugin();

    if (!kIsWeb) {
      if (Platform.isAndroid) {
        _androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      } else if (Platform.isIOS) {
        _iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      } else if (Platform.isMacOS) {
        _macOsDeviceInfo = await deviceInfoPlugin.macOsInfo;
      }
    }

    await _prepareDeviceId();
  }

  static late PackageInfo _packageInfo;

  static PackageInfo get packageInfo => _packageInfo;

  static late AndroidDeviceInfo _androidDeviceInfo;

  static AndroidDeviceInfo get androidDeviceInfo => _androidDeviceInfo;

  static late MacOsDeviceInfo _macOsDeviceInfo;

  static MacOsDeviceInfo get macOsDeviceInfo => _macOsDeviceInfo;

  static late IosDeviceInfo _iosDeviceInfo;

  static IosDeviceInfo get iosDeviceInfo => _iosDeviceInfo;

  static String get packageName =>
      (kIsWeb ? webPackageName : null) ?? _packageInfo.packageName;

  static String get versionName => webVersionName ?? _packageInfo.version;

  static late int _versionCode;

  static int get versionCode => webVersionCode ?? _versionCode;

  static late MediaQueryData _mediaQueryData;

  static MediaQueryData get mediaQueryData => _mediaQueryData;

  static double get screenWidth =>
      useScreenWidthDP ?? mediaQueryData.size.width;

  static double get screenHeight =>
      mediaQueryData.size.height * kUserScreenWidthDP;

  // ignore: deprecated_member_use
  static double get screenPixelWidth => window.physicalSize.width;

  // ignore: deprecated_member_use
  static double get screenPixelHeight => window.physicalSize.height;

  static void preloadMediaQuery(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
  }

  static bool get isIos => defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isDroid => defaultTargetPlatform == TargetPlatform.android;

  static bool get isMacos => defaultTargetPlatform == TargetPlatform.macOS;

  static bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;

  static bool get isLinux => defaultTargetPlatform == TargetPlatform.linux;

  static bool get isFuchsia => defaultTargetPlatform == TargetPlatform.fuchsia;

  static bool get isMobile => isIos || isDroid;

  static double recommendedScreenWidthDP = 380;

  static double? useScreenWidthDP =
      !kIsWeb && isMobile ? recommendedScreenWidthDP : null;

  static void setDefaultUseScreenWidthDP() {
    useScreenWidthDP = !kIsWeb && isMobile ? recommendedScreenWidthDP : null;
  }

  static double get kUserScreenWidthDP =>
      (useScreenWidthDP ?? mediaQueryData.size.width) /
      mediaQueryData.size.width;

  static final _storageDeviceId =
      StorageString.create("solid_storageDeviceId", isEternalCache: true);

  static String? get _platformDeviceId {
    if (kIsWeb) {
      return null;
    } else if (Platform.isIOS) {
      return _iosDeviceInfo.identifierForVendor;
    } else if (Platform.isAndroid) {
      return _androidDeviceInfo.id;
    }
    return null;
  }

  static Future _prepareDeviceId() async {
    var id = await _storageDeviceId.read();
    if (id == null) {
      id = (_platformDeviceId ?? const Uuid().v4())
          .replaceAll(RegExp(r"_|-|\s"), "");
      await _storageDeviceId.write(id);
    }
  }

  static String get deviceId => _storageDeviceId.memoryCache ?? "";

  static Future<String> userAgent() async {
    final packageName = packageInfo.packageName;
    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;

    String device = "";

    if (kIsWeb) {
      device = "(web)";
    } else if (Platform.isAndroid) {
      final info = androidDeviceInfo;
      final String manufacturer = info.manufacturer;
      final String model = info.model;
      String manufacturerModel = "";
      if (model.startsWith(manufacturer)) {
        manufacturerModel = model;
      } else {
        manufacturerModel = "$manufacturer $model";
      }
      device = "(android; ${info.version.release}; $manufacturerModel)";
    } else if (Platform.isIOS) {
      final info = iosDeviceInfo;
      device = "(ios; ${info.systemVersion}; ${info.model})";
    } else if (Platform.isMacOS) {
      final info = _macOsDeviceInfo;
      device =
          // ignore: lines_longer_than_80_chars
          "(macos; ${info.majorVersion}.${info.minorVersion}.${info.patchVersion}; ${info.model})";
    }

    return "$packageName/$version/$buildNumber $device $deviceId";
  }
}
