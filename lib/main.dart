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
  bool _loading = false;
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
              visible: _image != null,
              child: verificationButton(),
            ),
            Visibility(
              visible: _isChecked,
              child: _isFaceRecognition
                  ? Text("$_numOfFaces人の顔が認識されました")
                  : Text("顔が認識できませんでした"),
            ),
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
  Widget verificationButton() {
    return RaisedButton(
      child: verificationButtonChild(),
      color: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      onPressed: () {
        !_isChecked
            ? _startVerification()
            : _resetVerification();
      },
    );
  }
  Widget verificationButtonChild() {
    if (!_isChecked && _loading) {
      return Container(
        height: 20,
        width: 20,
        margin: EdgeInsets.all(5),
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      );
    }else if (!_isChecked) {
      return Text("顔認識", style: TextStyle(color: Colors.white),);
    }else {
      return Text("リセット", style: TextStyle(color: Colors.white),);
    }
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
    setState(() {
      _loading = true;
    });
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(_image);
    final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
    final List<Face> faces = await faceDetector.processImage(visionImage);
    setState(() {
      _isChecked = !_isChecked;
      _loading = !_loading;
      _numOfFaces = faces.length != null
          ? faces.length
          : 0;
      _isFaceRecognition = faces.length > 0
          ? true
          : false;
    });
    faceDetector.close();
  }
  void _resetVerification() {
    setState(() {
      _image = null;
      _isChecked = false;
      _isFaceRecognition = false;
    });
  }
}
