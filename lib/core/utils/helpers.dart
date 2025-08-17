import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/config.dart';
import '../../main.dart';
import '../../viewmodels/providers/info_provider.dart';
import '../constants/app_constants.dart';
import '../constants/view_constants.dart';
import 'ui.dart';

KeyboardActionsConfig keyboardActionbuildConfig(
    BuildContext context, List<FocusNode> nodes) {
  return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: nodes
          .map((node) => KeyboardActionsItem(
              focusNode: node, displayDoneButton: true, displayArrows: false))
          .toList());
}

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

void contactUs() async {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  final deviceInfo = context.read<InfoProvider>().deviceInfo;
  final Uri emailLaunchUri = Uri(
      query: deviceInfo == null
          ? null
          : encodeQueryParameters({
              'body':
                  'Device: ${deviceInfo.deviceName}\n App Version: ${deviceInfo.appVersion}\n Build Number: ${deviceInfo.buildNumber}\n OS Version: ${deviceInfo.osVersion}\n Country: ${deviceInfo.country}\n\n',
            }),
      scheme: AppConstants.emailScheme,
      path: Config.contactUsEmail);

  try {
    await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
  } catch (e) {
    showToast(ViewConstants.noEmailAppAvailable);
    debugPrint('contactUs error: $e');
  }
}
