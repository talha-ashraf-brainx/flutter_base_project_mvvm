import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import '../../core/utils/helpers.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

import '../../core/constants/view_constants.dart';
import '../../main.dart';
import '../../viewmodels/theme_provider.dart';

mixin ImageEditorMixin {
  Future<String?> cropImage(XFile image) async {
    final context = navigatorKey.currentContext;
    if (context == null) return null;

    final themeProvider = context.read<ThemeProvider>();
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: ViewConstants.cropImage.tr(),
            toolbarColor: themeProvider.baseTheme.primary,
            toolbarWidgetColor: themeProvider.baseTheme.onPrimary,
            activeControlsWidgetColor: themeProvider.baseTheme.primary,
          ),
          IOSUiSettings(
            title: ViewConstants.cropImage.tr(),
          ),
        ],
      );

      return croppedFile?.path;
    } catch (e) {
      printLog('Error cropping image: $e');
    }
    return null;
  }

  Future<File> compressImage(File file) async {
    try {
      final extension = path.extension(file.path);
      final targetPath = path.join(
        path.dirname(file.path),
        '${path.basenameWithoutExtension(file.path)}_compressed$extension',
      );
      final compressedXFile = await _compressImage(file, targetPath);
      if (compressedXFile != null) {
        return File(compressedXFile.path);
      }
    } catch (e) {
      printLog('Error compressing image: $e');
    }
    return file;
  }

  Future<XFile?> _compressImage(File file, String targetPath) async {
    final imageBytes = await file.readAsBytes();
    final originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) {
      printLog('Failed to decode image.');
      return null;
    }

    final originalWidth = originalImage.width;
    final originalHeight = originalImage.height;
    final longerSide =
        originalWidth > originalHeight ? originalWidth : originalHeight;
    printLog('Original width: $originalWidth, height: $originalHeight');

    double scaleFactor;
    if (longerSide >= 4000) {
      scaleFactor = 5.0;
    } else if (longerSide >= 3000) {
      scaleFactor = 4.0;
    } else if (longerSide >= 2000) {
      scaleFactor = 3.0;
    } else if (longerSide >= 1000) {
      scaleFactor = 2.0;
    } else {
      scaleFactor = 1.5;
    }

    final scaledWidth = (originalWidth / scaleFactor).round();
    final scaledHeight = (originalHeight / scaleFactor).round();
    printLog('Scaled width: $scaledWidth, height: $scaledHeight');

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 90,
      minWidth: scaledWidth,
      minHeight: scaledHeight,
    );

    final originalSize = file.lengthSync();
    final compressedSize = await result?.length() ?? 0;

    printLog(
        'Original size: ${(originalSize / (1024 * 1024)).toStringAsFixed(2)}MB');
    printLog(
        'Compressed size: ${(compressedSize / (1024 * 1024)).toStringAsFixed(2)}MB');

    if (compressedSize >= originalSize) {
      printLog('Compression equal or greater than original size');
      return XFile(file.path);
    }

    return result;
  }
}
