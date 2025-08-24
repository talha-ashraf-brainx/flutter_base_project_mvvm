import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../utils/helpers.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../config/config.dart';
import '../../injection_container.dart';
import '../constants/app_constants.dart';

class FirebaseRemoteConfigService {
  static final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;

  Future<FirebaseRemoteConfigService?> init() async {
    if (!Config.firebaseEnabled) return null;

    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: Config.debug
              ? const Duration(seconds: 1)
              : const Duration(hours: 1),
        ),
      );

      final packageInfo = sl<PackageInfo>();
      await _remoteConfig.setDefaults(Config.debug
          ? {
              AppConstants.requiredMinimumVersionDebug: packageInfo.version,
              AppConstants.recommendedMinimumVersionDebug: packageInfo.version,
            }
          : Platform.isIOS
              ? {
                  AppConstants.requiredMinimumVersion: packageInfo.version,
                  AppConstants.recommendedMinimumVersion: packageInfo.version,
                }
              : {
                  AppConstants.requiredMinimumVersionAndroid:
                      packageInfo.version,
                  AppConstants.recommendedMinimumVersionAndroid:
                      packageInfo.version,
                });

      await _remoteConfig.fetchAndActivate();

      _remoteConfig.onConfigUpdated.listen((event) async {
        await _remoteConfig.activate();
      });
    } catch (e) {
      printLog("Error in FirebaseRemoteConfigService: $e");
    }

    return this;
  }

  String getRequiredMinimumVersion() => _remoteConfig.getString(Config.debug
      ? AppConstants.requiredMinimumVersionDebug
      : Platform.isIOS
          ? AppConstants.requiredMinimumVersion
          : AppConstants.requiredMinimumVersionAndroid);

  String getRecommendedMinimumVersion() => _remoteConfig.getString(Config.debug
      ? AppConstants.recommendedMinimumVersionDebug
      : Platform.isIOS
          ? AppConstants.recommendedMinimumVersion
          : AppConstants.recommendedMinimumVersionAndroid);
}
