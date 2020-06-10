import 'dart:io';
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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: _image == null
            ? Text("画像を撮影してください")
            : Image.file(_image),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onPickImageSelected();
        },
        child: Icon(
          Icons.camera_alt,
          color: Colors.white,
        ),
      ),
    );
  }

  void _onPickImageSelected() async {
    var imageSource = ImageSource.camera;

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
}
