import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter_base_project_mvvm/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'config/config.dart';
import 'config/languages/language_config.dart';
import 'core/constants/app_assets.dart';
import 'core/utils/device_orientation.dart';
import 'injection_container.dart';
import 'viewmodels/providers/language_provider.dart';
import 'viewmodels/providers/info_provider.dart';
import 'viewmodels/providers/theme_provider.dart';
import 'views/splash.dart';
import 'core/utils/helpers.dart';

final navigatorKey = GlobalKey<NavigatorState>();
late List<CameraDescription> cameras;

Future<bool> _loadEnv() async {
  try {
    await dotenv.load(fileName: ".env");
    return true;
  } catch (e) {
    printLog(e.toString());
    return false;
  }
}

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    if (Config.debug) return;

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    printLog('Firebase initialization failed: $e');
  }
}

void _loadCameras() async {
  try {
    cameras = await availableCameras();
  } catch (e) {
    printLog('Camera initialization failed: $e');
    cameras = [];
  }
}

void main() async {
  if (!await _loadEnv()) {
    throw Exception(
        "Failed to load environment variables, please create .env file at project level and add DEBUG=true");
  }

  WidgetsFlutterBinding.ensureInitialized();

  await initializeFirebase();
  await initializeDependencies();
  await switchToPortraitMode();

  _loadCameras();

  try {
    await EasyLocalization.ensureInitialized();
    runApp(EasyLocalization(
        assetLoader: CsvAssetLoader(),
        path: AppAssets.translations,
        fallbackLocale: LanguageConfig.defaultLanguage.locale,
        supportedLocales: LanguageConfig.locales,
        child: const MainApp()));
  } catch (e) {
    printLog(e.toString());
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<ThemeProvider>(create: (_) => sl()),
      ChangeNotifierProvider<LanguageProvider>(create: (_) => sl()),
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
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: Config.debug,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      color: themeProvider.baseTheme.primary,
      theme: themeProvider.baseTheme.themeData,
      home: const Splash(),
    );
  }
}
