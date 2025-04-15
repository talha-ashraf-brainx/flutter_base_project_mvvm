import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter_base_project_mvvm/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'config/config.dart';
import 'config/languages/language_config.dart';
import 'core/constants/app_assets.dart';
import 'core/utils/device_orientation.dart';
import 'injection_container.dart';
import 'viewmodels/language_provider.dart';
import 'viewmodels/providers/custom_modal_progress_hud.dart';
import 'viewmodels/providers/info_provider.dart';
import 'viewmodels/theme_provider.dart';
import 'views/splash.dart';

final navigatorKey = GlobalKey<NavigatorState>();
late List<CameraDescription> cameras;
final logger = Logger();

Future<bool> _loadEnv() async {
  try {
    await dotenv.load(fileName: ".env");
    return true;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

void initializeCrashlytics() {
  if (!Config.debug) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
}

void main() async {
  if (!await _loadEnv()) {
    throw Exception(
        "Failed to load environment variables, please create .env file at project level and add DEBUG=true");
  }

  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Use flutterfire cli for firebase setup and override current implementations
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  initializeCrashlytics();

  await initializeDependencies();
  await switchToPortraitMode();
  cameras = await availableCameras();
  try {
    if (Config.debug) {
      FlavorConfig(name: "DEBUG", location: BannerLocation.topEnd);
    }
    await EasyLocalization.ensureInitialized();
    runApp(EasyLocalization(
        assetLoader: CsvAssetLoader(),
        path: AppAssets.translations,
        fallbackLocale: Config.defaultLanguage.locale,
        supportedLocales: LanguageConfig.locales,
        child: const MainApp()));
  } catch (e) {
    debugPrint(e.toString());
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<ThemeProvider>(create: (_) => sl()),
      ChangeNotifierProvider<LanguageProvider>(create: (_) => sl()),
      ChangeNotifierProvider<CustomModalProgressHudProvider>(
          create: (_) => sl()),
      ChangeNotifierProvider<InfoProvider>(create: (_) => sl(), lazy: false),
    ], child: const BaseApp());
  }
}

class BaseApp extends StatefulWidget {
  const BaseApp({
    super.key,
  });

  @override
  State<BaseApp> createState() => _BaseAppState();
}

class _BaseAppState extends State<BaseApp> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return FlavorBanner(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        color: themeProvider.baseTheme.primary,
        theme: themeProvider.baseTheme.themeData,
        home: const Splash(),
      ),
    );
  }
}
