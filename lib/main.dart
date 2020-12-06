import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mldemo/my_model.dart';
import 'package:provider/provider.dart';

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
      home: MultiProvider(
        providers: [ChangeNotifierProvider(create: (context) => MyModel())],
        child: MyHomePage(title: 'Firebase ML kitで遊んでみた'),
      ),
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
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MyModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: _Body(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          model.selectImage();
        },
        child: Icon(
          Icons.add_a_photo,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: context.watch<MyModel>().selected
          ? const _SelectedContent()
          : const _WillSelectContent(),
    );
  }
}

class _SelectedContent extends StatelessWidget {
  const _SelectedContent({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MyModel>(context);
    return model.faceDetectionState == FaceDetectionState.detecting
        ? _loading()
        : Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(model.selectedImageFile),
                RaisedButton(
                  onPressed: () {
                    model.resetDetection();
                  },
                  child: const Text('リセット'),
                ),
                Text(model.faceDetectionState.toString())
              ],
            ),
          );
  }

  Widget _loading() {
    return Center(
      child: SpinKitThreeBounce(
        color: Colors.grey,
        size: 50.0,
      ),
    );
  }
}

class _WillSelectContent extends StatelessWidget {
  const _WillSelectContent({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MyModel>(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('画像を撮影してください'),
          Text(model.faceDetectionState.toString())
        ],
      ),
    );
  }
}
