import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

Future<XFile?> pickImage() async {
  final ImagePicker _picker = ImagePicker();
  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  return pickedFile;
}

// Crop the picked image (constraint to a circular area)
Future<File?> cropImage(String imagePath) async {
  final croppedFile = await ImageCropper().cropImage(
    sourcePath: imagePath,
    aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
    ],
    androidUiSettings: AndroidUiSettings(
      toolbarTitle: 'Crop Image',
      toolbarColor: Colors.deepOrange,
      toolbarWidgetColor: Colors.white,
      initAspectRatio: CropAspectRatioPreset.square,
      lockAspectRatio: true,
    ),
    iosUiSettings: IOSUiSettings(
      minimumAspectRatio: 1.0,
      aspectRatioLockEnabled: true
    ),
  );

  return croppedFile != null ? File(croppedFile.path) : null;
}