import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base_project_mvvm/viewmodels/theme_provider.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../translated_text.dart';

Future<void> showNativePopup(
  BuildContext context, {
  required String title,
  required String description,
  required String secondaryActionTitle,
  required String primaryActionTitle,
  required VoidCallback secondaryAction,
  required VoidCallback primaryAction,
}) async {
  final themeProvider = context.read<ThemeProvider>();
  await showAdaptiveDialog(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: TranslatedText(title),
      content: TranslatedText(description),
      backgroundColor: themeProvider.baseTheme.background,
      actions: [
        adaptiveAction(
            context, secondaryActionTitle, secondaryAction, themeProvider),
        adaptiveAction(
            context, primaryActionTitle, primaryAction, themeProvider,
            buttonColor: themeProvider.baseTheme.primary,
            isDefaultAction: true,
            fontWeight: FontWeight.w600),
      ],
    ),
  );
}

Widget adaptiveAction(
  BuildContext context,
  String buttonTitle,
  VoidCallback action,
  ThemeProvider themeProvider, {
  bool isDefaultAction = false,
  Color? buttonColor,
  FontWeight? fontWeight,
}) {
  if (Platform.isIOS) {
    return CupertinoDialogAction(
      isDefaultAction: isDefaultAction,
      onPressed: () {
        Navigator.pop(context);
        action();
      },
      child: TranslatedText(buttonTitle),
    );
  }

  return TextButton(
    onPressed: () {
      Navigator.pop(context);
      action();
    },
    child: TranslatedText(
      buttonTitle,
      style: TextStyle(
        fontSize: AppConstants.font16Px,
        color: buttonColor ?? themeProvider.baseTheme.primary,
        fontWeight: fontWeight,
      ),
    ),
  );
}
