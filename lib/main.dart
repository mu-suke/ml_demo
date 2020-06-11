import 'dart:io';
import 'dart:math';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Firebase ML kitで遊んでみた'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  bool _isChecked = false;
  bool _isFaceRecognition = false;
  int _numOfFaces;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _image == null
                ? Text("画像を撮影してください")
                : Image.file(_image),
            Visibility(
              visible: _image != null && !_isChecked,
              child: startVerificationButton(),
            ),
            Visibility(
              visible: _isChecked,
              child: _isFaceRecognition
                  ? Text("$_numOfFaces人の顔が認識されました")
                  : Text("顔が認識できませんでした"),
            )
          ]
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onPickImageSelected();
        },
        child: Icon(
          Icons.add_a_photo,
          color: Colors.white,
        ),
      ),
    );
  }
  Widget startVerificationButton() {
    return RaisedButton(
      child: Text("顔認証", style: TextStyle(color: Colors.white),),
      color: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      onPressed: () {
        _startVerification();
      },
    );
  }
  void _onPickImageSelected() async {
    try {
      final file = await ImagePicker().getImage(source: ImageSource.camera);
      setState(() {
        _image = File(file.path);
      });
      if(file == null) {
        throw Exception('ファイルを取得できませんでした');
      }
    } catch (e) {
    }
  }
  void _startVerification() async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(_image);
    final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
    final List<Face> faces = await faceDetector.processImage(visionImage);
    setState(() {
      _isChecked = !_isChecked;
      _numOfFaces = faces.length != null
          ? faces.length
          : 0;
      _isFaceRecognition = faces.length > 0
          ? true
          : false;
    });
//    for (Face face in faces) {
//      print('==============================face::${face.boundingBox}');
//      final Rect boundingBox = face.boundingBox;
//
//      final double rotY = face.headEulerAngleY; // Head is rotated to the right rotY degrees
//      final double rotZ = face.headEulerAngleZ; // Head is tilted sideways rotZ degrees
//
//      // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
//      // eyes, cheeks, and nose available):
//      final FaceLandmark leftEar = face.getLandmark(FaceLandmarkType.leftEar);
//      if (leftEar != null) {
//        final Offset leftEarPos = leftEar.position;
//      }
//
//      // If classification was enabled with FaceDetectorOptions:
//      if (face.smilingProbability != null) {
//        final double smileProb = face.smilingProbability;
//      }
//
//      // If face tracking was enabled with FaceDetectorOptions:
//      if (face.trackingId != null) {
//        final int id = face.trackingId;
//      }
//    }
    faceDetector.close();
  }
}
