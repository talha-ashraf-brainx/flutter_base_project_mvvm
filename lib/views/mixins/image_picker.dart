import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../core/utils/helpers.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/view_constants.dart';
import '../../core/utils/ui.dart';
import '../../main.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

mixin ImagePickerMixin {
  late CameraController cameraController;

  void loadCamera({Function()? onCameraLoaded}) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    if (cameras.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showToast(ViewConstants.errorOpeningCamera);
        Navigator.pop(context);
      });
      return;
    }

    try {
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
            printLog(e);
            showToast(errorMessage);
            Navigator.pop(context);
          });
        }
      });
    } catch (e) {
      printLog('Camera controller initialization failed: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showToast(ViewConstants.errorOpeningCamera);
        Navigator.pop(context);
      });
    }
  }

  Future<void> captureImage(
      {FutureOr<dynamic> Function(XFile)? onImageCaptured,
      bool crop = true}) async {
    if (!cameraController.value.isInitialized ||
        cameraController.value.isTakingPicture) {
      return;
    }

    try {
      final XFile file = await cameraController.takePicture();
      await onImageCaptured?.call(file);
    } on CameraException catch (e) {
      printLog('Error capturing image: $e');
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
      printLog('Error picking image: $e');
    }
  }

  // Returns image according to the preview aspect ratio
  Future<XFile?> correctCapturedImage({
    required XFile capturedFile,
    required double previewAspectRatio,
  }) async {
    final bytes = await capturedFile.readAsBytes();
    final originalImage = img.decodeImage(bytes);
    if (originalImage == null) null;

    final context = navigatorKey.currentContext;
    if (context == null) return null;

    final mediaQuery = MediaQuery.of(context);
    double originalWidth = originalImage!.width.toDouble();
    double originalHeight = originalImage.height.toDouble();
    if (Platform.isIOS) {
      originalWidth -= mediaQuery.padding.horizontal;
      originalHeight -= mediaQuery.padding.vertical;
    }

    double originalAspectRatio = originalWidth / originalHeight;

    int cropX = 0,
        cropY = 0,
        cropWidth = originalWidth.toInt(),
        cropHeight = originalHeight.toInt();

    if (originalAspectRatio > previewAspectRatio) {
      cropWidth = (previewAspectRatio * originalHeight).toInt();
      cropX = ((originalWidth - cropWidth) / 2).round();
    } else if (originalAspectRatio < previewAspectRatio) {
      cropHeight = (originalWidth / previewAspectRatio).toInt();
      cropY = ((originalHeight - cropHeight) / 2).round();
    }

    final cropped = img.copyCrop(
      originalImage,
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );

    final correctedBytes = img.encodeJpg(cropped);

    final tempDir = await getTemporaryDirectory();
    final correctedPath = path.join(
      tempDir.path,
      'corrected_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final correctedFile = File(correctedPath)..writeAsBytesSync(correctedBytes);

    return XFile(correctedFile.path);
  }
}
