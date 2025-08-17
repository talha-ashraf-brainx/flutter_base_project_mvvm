import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'languages/language.dart';
import 'languages/language_config.dart';

class Config {
  static final bool debug = dotenv.env['DEBUG'] == 'true';

// Languages
  static const String english = 'english';

// Themes
  static const String light = 'light';
  static const String dark = 'dark';

  // Config
  static const String fontFamily = 'Inter';
  static const String defaultTheme = light;
  static final Language defaultLanguage =
      LanguageConfig.defaultLanguage(english);
  static const double designScreenHeight = 812.0;
  static const double designScreenWidth = 375.0;
  // TODO: Add your own bundle id and apple id
  // Example: bundleId = 'com.example.app';
  // Example: appleId = '1234567890';
  static const String bundleId = '';
  static const String appleId = '';
  static const String appPlaystoreUrl =
      'https://play.google.com/store/apps/details?id=$bundleId';
  static const String appAppstoreUrl = 'https://apps.apple.com/app/id$appleId';
  // TODO: Add your own privacy policy url and terms of use url and contact us email
  static const String privacyPolicyUrl = '';
  static const String termsOfUseUrl = '';
  static const String contactUsEmail = '';
  // TODO: Update this flag after firebase setup
  // TODO: Use flutterfire cli for firebase setup and override current implementations
  static const bool firebaseEnabled = false;
}
