import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum FaceDetectionState {
  willDetect,
  detecting,
  detected,
  notFound,
  error,
}

class MyModel with ChangeNotifier {

  File selectedImageFile;

  bool get selected => selectedImageFile != null;

  FaceDetectionState faceDetectionState = FaceDetectionState.willDetect;

  FaceDetector _faceDetector;

  void selectImage() async {
    try {
      final file =  await ImagePicker().getImage(source: ImageSource.gallery);
      selectedImageFile = File(file.path);
      if (selectedImageFile != null) {
        faceDetectionState = FaceDetectionState.detecting;
        notifyListeners();
        _detectFace();
      } else {
        notifyListeners();
      }
    } catch(e) {
      print(e);
    }
  }

  void _detectFace() async {
    try {
      const options = FaceDetectorOptions();
      final visionImage = FirebaseVisionImage.fromFile(selectedImageFile);
      _faceDetector = FirebaseVision.instance.faceDetector(options);
      final faces = await _faceDetector.processImage(visionImage);
      if (faces.isEmpty) {
        faceDetectionState = FaceDetectionState.notFound;
      } else {
        faceDetectionState = FaceDetectionState.detected;
      }
      notifyListeners();
    } catch (e) {
      faceDetectionState = FaceDetectionState.error;
      notifyListeners();
    } finally {
      await _faceDetector.close();
    }
  }

  void resetDetection() {
    faceDetectionState = FaceDetectionState.willDetect;
    selectedImageFile = null;
    notifyListeners();
  }
}
