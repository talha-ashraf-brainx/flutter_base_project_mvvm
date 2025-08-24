import 'package:flutter/material.dart';
import '../utils/helpers.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../injection_container.dart';
import '../../main.dart';
import '../../viewmodels/providers/info_provider.dart';
import '../../widgets/popups/forced_update.dart';
import 'firebase_remote_config.dart';

bool isSecondVersionLatest(String version1, String version2) {
  List<String> v1Parts = version1.split('.');
  List<String> v2Parts = version2.split('.');

  while (v1Parts.length < v2Parts.length) {
    v1Parts.add('0');
  }
  while (v2Parts.length < v1Parts.length) {
    v2Parts.add('0');
  }

  for (int i = 0; i < v1Parts.length; i++) {
    int v1Part = int.parse(v1Parts[i]);
    int v2Part = int.parse(v2Parts[i]);

    if (v2Part > v1Part) {
      return true;
    } else if (v1Part > v2Part) {
      return false;
    }
  }

  return false;
}

void checkForcedUpdates() {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  final packageInfo = sl<PackageInfo>();
  final firebaseRemoteConfigService = sl<FirebaseRemoteConfigService>();

  final requiredVersion =
      firebaseRemoteConfigService.getRequiredMinimumVersion();
  final recommendedVersion =
      firebaseRemoteConfigService.getRecommendedMinimumVersion();

  printLog(
      'requiredVersion: $requiredVersion, recommendedVersion: $recommendedVersion, currentVersion: ${packageInfo.version}');

  final previousSkippedRecommendedVersion =
      context.read<InfoProvider>().skippedVersion;

  bool isRecommendedVersionChanged =
      (recommendedVersion != previousSkippedRecommendedVersion) &&
          isSecondVersionLatest(packageInfo.version, recommendedVersion);
  bool isRequiredVersionChanged =
      isSecondVersionLatest(packageInfo.version, requiredVersion);

  if (isRequiredVersionChanged || isRecommendedVersionChanged) {
    showDialog(
        context: context,
        builder: (context) => const ForcedUpdate(),
        barrierDismissible: false);
  }
}
