import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base_project_mvvm/config/app_router.dart';
import 'package:flutter_base_project_mvvm/views/camera.dart';
import 'package:flutter_base_project_mvvm/views/mixins/image_editor.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with ImageEditorMixin {
  File? image;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: body()),
    );
  }

  Widget body() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SizedBox(
      width: double.maxFinite,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image != null) Image.file(image!),
          Align(
              child: ElevatedButton(
                  onPressed: onCameraTapped, child: Text('Pick Image')))
        ],
      ),
    );
  }

  void onCameraTapped() {
    AppRouter.push(context,
        CameraView(onImageCaptured: (XFile selectedImage) async {
      setState(() {
        isLoading = true;
      });
      final croppedFilePath = await cropImage(selectedImage);
      final compressedImage =
          await compressImage(File(croppedFilePath ?? selectedImage.path));
      setState(() {
        image = compressedImage;
        isLoading = false;
      });
    }));
  }
}
