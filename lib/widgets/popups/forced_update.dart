import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/view_constants.dart';
import '../../core/services/firebase_remote_config.dart';
import '../../core/services/force_update.dart';
import '../../injection_container.dart';
import '../../viewmodels/providers/info_provider.dart';
import '../../viewmodels/theme_provider.dart';
import '../translated_text.dart';

class ForcedUpdate extends StatefulWidget {
  const ForcedUpdate({super.key});

  @override
  State<ForcedUpdate> createState() => _ForcedUpdateState();
}

class _ForcedUpdateState extends State<ForcedUpdate> {
  final packageInfo = sl<PackageInfo>();
  final firebaseRemoteConfigService = sl<FirebaseRemoteConfigService>();
  final ValueNotifier showSkipButton = ValueNotifier<bool>(false);
  late final deviceInfoProvider = context.read<InfoProvider>();

  @override
  void initState() {
    super.initState();
    checkForSkipButtonVisibility();
  }

  checkForSkipButtonVisibility() {
    showSkipButton.value = isSecondVersionLatest(
            firebaseRemoteConfigService.getRequiredMinimumVersion(),
            firebaseRemoteConfigService.getRecommendedMinimumVersion()) &&
        !isSecondVersionLatest(packageInfo.version,
            firebaseRemoteConfigService.getRequiredMinimumVersion());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 332,
          padding: const EdgeInsets.only(
            left: AppConstants.gap24Px,
            right: AppConstants.gap24Px,
            top: AppConstants.gap20Px * 2,
            bottom: AppConstants.gap20Px * 1.5,
          ),
          decoration: BoxDecoration(
              color: themeProvider.baseTheme.surface,
              borderRadius: const BorderRadius.all(Radius.circular(8))),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TranslatedText(
                  ViewConstants.newVersionTitle,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: AppConstants.font24Px,
                      fontWeight: FontWeight.w500,
                      color: themeProvider.baseTheme.primaryText),
                ),
                const Gap(AppConstants.gap10Px),
                TranslatedText(
                  ViewConstants.newVersionDescription,
                  style: TextStyle(
                      fontSize: AppConstants.font16Px,
                      color: themeProvider.baseTheme.primaryText),
                ),
                const Gap(AppConstants.gap24Px + 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    skipButton(themeProvider),
                    actionButton(themeProvider, ViewConstants.update,
                        action: onUpdate),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  ValueListenableBuilder<dynamic> skipButton(ThemeProvider themeProvider) {
    return ValueListenableBuilder(
        valueListenable: showSkipButton,
        builder: (context, value, _) {
          return value
              ? actionButton(themeProvider, ViewConstants.skip,
                  action: () => onSkip(context))
              : const SizedBox();
        });
  }

  TextButton actionButton(ThemeProvider themeProvider, title,
      {Function()? action}) {
    return TextButton(
        onPressed: action,
        child: TranslatedText(
          title,
          style: TextStyle(
              fontSize: AppConstants.font16Px,
              color: themeProvider.baseTheme.primary,
              fontWeight: FontWeight.w600),
        ));
  }

  void onSkip(BuildContext context) {
    Navigator.pop(context);
    deviceInfoProvider.setSkippedVersion();
  }

  void onUpdate() async {
    final url =
        Platform.isAndroid ? Config.appPlaystoreUrl : Config.appAppstoreUrl;
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
