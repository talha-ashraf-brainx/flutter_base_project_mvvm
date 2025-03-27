import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

dynamic showModalSheet({
  required BuildContext context,
  required Widget content,
  Color? backgroundColor,
  bool showDragHandle = false,
  bool useSafeArea = true,
  bool isScrollControlled = false,
}) async {
  final result = await showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      useSafeArea: useSafeArea,
      showDragHandle: showDragHandle,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      clipBehavior: Clip.hardEdge,
      builder: (context) => content);
  return result;
}

void showToast(String message) {
  Fluttertoast.showToast(msg: message.tr());
}
