import 'package:flutter/material.dart';
import 'package:flutter_base_project_mvvm/core/resources/data_state.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/firebase_remote_config.dart';
import '../../data/managers/local/local_storage.dart';
import '../../data/repositories/remote/settings/country.dart';
import '../../injection_container.dart';
import '../../models/settings.dart';

class InfoProvider with ChangeNotifier {
  final LocalStorageManager _localStorageManager;
  DeviceInfo? deviceInfo;
  final CountryRepo _countryRepo;
  int rateAppCount = 0;

  InfoProvider(this._countryRepo, this._localStorageManager) {
    _fetchAndSetDeviceInfo();
    _fetchCountryInfo();
  }

  void _fetchAndSetDeviceInfo() {
    final deviceName = sl<DeviceData>().name;
    final osVersion = sl<DeviceData>().osVersion;
    final appVersion = sl<PackageInfo>().version;
    final buildNumber = sl<PackageInfo>().buildNumber;
    deviceInfo = DeviceInfo(deviceName, appVersion, buildNumber, osVersion);
  }

  Future<void> _fetchCountryInfo() async {
    final dataState = await _countryRepo.getCountry();
    if (dataState is DataFailed) return;
    deviceInfo?.country = dataState.data;
    notifyListeners();
  }

  String? get skippedVersion =>
      _localStorageManager.getString(key: AppConstants.skippedVersion) ??
      sl<PackageInfo>().version;

  Future<void> setSkippedVersion() async {
    final firebaseRemoteConfigService = sl<FirebaseRemoteConfigService>();
    await _localStorageManager.setString(
        key: AppConstants.skippedVersion,
        value: firebaseRemoteConfigService.getRecommendedMinimumVersion());
  }
}
