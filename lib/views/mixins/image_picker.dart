import 'dart:async';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/app_router.dart';
import '../../core/constants/view_constants.dart';
import '../../core/utils/ui.dart';
import '../../main.dart';

mixin ImagePickerMixin {
  late CameraController cameraController;

  void loadCamera({Function()? onCameraLoaded}) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    if (cameras.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showToast(ViewConstants.errorOpeningCamera);
        AppRouter.pop(context);
      });
      return;
    }

    cameraController = CameraController(cameras[0], ResolutionPreset.max);
    cameraController.initialize().then((_) {
      onCameraLoaded?.call();
    }).catchError((Object e) {
      if (e is CameraException) {
        String errorMessage;
        switch (e.code) {
          case 'CameraAccessDenied':
            errorMessage = ViewConstants.cameraAccessDenied.tr();
            break;
          default:
            errorMessage = ViewConstants.errorOpeningCamera.tr();
            break;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          logger.e(e);
          showToast(errorMessage);
          AppRouter.pop(context);
        });
      }
    });
  }

  Future<void> captureImage(
      {FutureOr<dynamic> Function(XFile)? onImageCaptured,
      bool crop = true}) async {
    if (cameraController.value.isTakingPicture) {
      return;
    }

    try {
      final XFile file = await cameraController.takePicture();
      await onImageCaptured?.call(file);
    } on CameraException catch (e) {
      logger.e('Error capturing image: $e');
    }
  }

  Future<void> pickImageFromGallery(
      {FutureOr<dynamic> Function(XFile)? onImagePicked,
      bool crop = true}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await onImagePicked?.call(image);
      }
    } catch (e) {
      logger.e('Error picking image: $e');
    }
  }
}
