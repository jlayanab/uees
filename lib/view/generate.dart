import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenerateScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GenerateScreenState();
}

class GenerateScreenState extends State<GenerateScreen> {
  static const double _topSectionTopPadding = 50.0;
  static const double _topSectionBottomPadding = 20.0;
  //static const double _topSectionHeight = 50.0;
  String _dataString; //variable donde se guarda el código QR generado
  SharedPreferences sharedPreferences;

  GlobalKey globalKey = new GlobalKey();
  //String _inputErrorText;

  //final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    mostrarDatos();
  }

  //Toma el valor de Identification por medio de SharedPreference
  Future guardarDatos() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var jsonResponse;
    sharedPreferences.setString(
        "Identification", jsonResponse['Identification']);
  }

  //Guarda el valor de Identification en una variable llamada _dataString
  Future mostrarDatos() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _dataString = sharedPreferences.getString("Identification");
    });
    print(_dataString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Código QR'),
        backgroundColor: Color.fromRGBO(62, 15, 31, 1),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _captureAndSharePng ?? "",
          )
        ],
      ),
      body: _contentWidget(),
    );
  }

  Future<void> _captureAndSharePng() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      final channel = const MethodChannel('channel:me.camellabs.share/share');
      channel.invokeMethod('shareFile', 'image.png');
    } catch (e) {
      print(e.toString());
    }
  }

  _contentWidget() {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: _topSectionTopPadding,
              left: 20.0,
              right: 10.0,
              bottom: _topSectionBottomPadding,
            ),
            //child: Container(
            //height: _topSectionHeight,
            //child: Row(
            //mainAxisSize: MainAxisSize.max,
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            //children: <Widget>[
            //Expanded(
            //child: TextField(
            //controller: _textController,
            //decoration: InputDecoration(
            //hintText: "Enter a custom message",
            //errorText: _inputErrorText,
            //),
            //),
            //),
            //Padding(
            //padding: const EdgeInsets.only(left: 10.0),
            //child: FlatButton(
            //child: Text("SUBMIT"),
            //onPressed: () {
            //setState(() {
            //dataString = _textController.text;
            //inputErrorText = null;
            //});
            //},
            //),
            //)
            //],
            //),
            //),
          ),
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: globalKey,
                child: QrImage(
                  data: _dataString ??
                      "", //Genera código QR mediante el valor de Identification
                  size: 0.5 * bodyHeight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
