import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base_project_mvvm/core/extensions/double.dart';
import 'package:flutter_base_project_mvvm/core/extensions/int.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_constants.dart';
import '../viewmodels/theme_provider.dart';
import 'mixins/image_picker.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key, this.onImageCaptured});

  final FutureOr<dynamic> Function(XFile)? onImageCaptured;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with ImagePickerMixin {
  @override
  void initState() {
    super.initState();
    loadCamera(onCameraLoaded: () {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (cameraController.value.isInitialized) {
      cameraController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();

    if (!cameraController.value.isInitialized) {
      return loader(themeProvider);
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          cameraWidgetFullScreen(),
          cameraOptions(themeProvider),
        ],
      ),
    );
  }

  Widget cameraWidgetFullScreen() {
    return OverflowBox(
      alignment: Alignment.center,
      maxWidth: double.infinity,
      child: AspectRatio(
        aspectRatio: 1 / cameraController.value.aspectRatio,
        child: cameraPreview(),
      ),
    );
  }

  Widget cameraPreview() => Platform.isIOS
      ? CameraPreview(cameraController)
      : RotatedBox(
          quarterTurns: 1,
          child: CameraPreview(cameraController),
        );

  SafeArea cameraOptions(ThemeProvider themeProvider) {
    return SafeArea(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.gap24Px.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(top: AppConstants.gap12Px.h),
              child: GestureDetector(
                onTap: goBack,
                child: SvgPicture.asset(
                  AppAssets.backButton,
                  height: 44.h,
                  width: 44.w,
                ),
              ),
            ),
          ),
          Icon(Icons.add, color: themeProvider.baseTheme.onPrimary, size: 44.h),
          Padding(
            padding: EdgeInsets.only(bottom: AppConstants.gap12Px.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onGalleryButtonPressed,
                  child: SvgPicture.asset(AppAssets.galleryButton),
                ),
                GestureDetector(
                  onTap: onCaptureButtonPressed,
                  child: SvgPicture.asset(AppAssets.captureButton),
                ),
                Opacity(
                  opacity: 0.0,
                  child: SvgPicture.asset(AppAssets.galleryButton),
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }

  Widget loader(ThemeProvider themeProvider) => Container(
      color: themeProvider.baseTheme.background,
      child: const Center(child: CircularProgressIndicator()));

  void onGalleryButtonPressed() async {
    await pickImageFromGallery(
        onImagePicked: (XFile image) => widget.onImageCaptured?.call(image));
    goBack();
  }

  void onCaptureButtonPressed() async {
    await captureImage(onImageCaptured: (XFile image) async {
      final correctedImage = await correctCapturedImage(
        capturedFile: image,
        previewAspectRatio: MediaQuery.of(context).size.aspectRatio,
      );
      if (correctedImage == null) return;

      widget.onImageCaptured?.call(correctedImage);
    });
    goBack();
  }

  void goBack() {
    Navigator.pop(context);
  }
}
