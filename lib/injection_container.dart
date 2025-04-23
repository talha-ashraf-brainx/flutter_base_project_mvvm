import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/services/firebase_remote_config.dart';
import 'data/managers/local/custom_cache_manager.dart';
import 'data/managers/local/local_storage.dart';
import 'data/managers/local/shared_preference.dart';
import 'data/managers/remote/api_manager.dart';
import 'data/managers/remote/dio_api_manager.dart';
import 'data/repositories/local/language.dart';
import 'data/repositories/local/theme.dart';
import 'data/repositories/remote/settings/country.dart';
import 'models/settings.dart';
import 'viewmodels/language_provider.dart';
import 'viewmodels/providers/custom_modal_progress_hud.dart';
import 'viewmodels/providers/info_provider.dart';
import 'viewmodels/theme_provider.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Initialize
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  final packageInfo = await PackageInfo.fromPlatform();
  sl.registerSingleton<PackageInfo>(packageInfo);

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final DeviceData deviceName = DeviceData(
      Platform.isAndroid
          ? (await deviceInfo.androidInfo).model
          : (await deviceInfo.iosInfo).utsname.machine,
      Platform.isAndroid
          ? (await deviceInfo.androidInfo).version.release
          : (await deviceInfo.iosInfo).systemVersion);
  sl.registerSingleton<DeviceData>(deviceName);

  final firebaseRemoteConfigService =
      await FirebaseRemoteConfigService().init();
  sl.registerSingleton<FirebaseRemoteConfigService>(
      firebaseRemoteConfigService);

  // Managers
  sl.registerSingleton<LocalStorageManager>(
      SharedPreferenceManager(sl<SharedPreferences>()));
  sl.registerSingleton<CustomCacheManager>(
      CustomCacheManager(sl<LocalStorageManager>()));
  sl.registerSingleton<ApiManager>(
      DioApiManager(AppConstants.countryUrl, sl<CustomCacheManager>()),
      instanceName: AppConstants.countryUrl);

  // Repositories
  sl.registerSingleton<ThemeRepo>(ThemeRepo(sl<LocalStorageManager>()));
  sl.registerSingleton<LanguageRepo>(LanguageRepo(sl<LocalStorageManager>()));
  sl.registerSingleton<CountryRepo>(
      CountryRepo(sl<ApiManager>(instanceName: AppConstants.countryUrl)));

  // Providers
  sl.registerFactory<ThemeProvider>(() => ThemeProvider(sl<ThemeRepo>()));
  sl.registerFactory<LanguageProvider>(
      () => LanguageProvider(sl<LanguageRepo>()));
  sl.registerFactory<CustomModalProgressHudProvider>(
      () => CustomModalProgressHudProvider());
  sl.registerFactory<InfoProvider>(
      () => InfoProvider(sl<CountryRepo>(), sl<LocalStorageManager>()));
}
