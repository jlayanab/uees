import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:path/path.dart' as path;
//import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:uees/view/addUser.dart';
import 'package:uees/view/additems.dart';
import 'package:uees/view/listItems.dart';
import 'package:uees/view/login.dart';
import 'package:uees/view/generate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uees/Cotrollers/databasehelpers.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Registro UEES",
      debugShowCheckedModeBanner: false,
      home: MainPage(),
      theme: ThemeData(
          primaryColor: Color.fromRGBO(62, 15, 31, 1),
          accentColor: Colors.white70),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DataBaseHelper databasehelper = new DataBaseHelper();
  SharedPreferences sharedPreferences;
  ImagePicker imagePicker = ImagePicker();
  String firstButtonText = 'Tomar Foto';
  String albumName = 'Media';
  //String avatar = 'Almacenamiento interno/Media/prueba.jpg';
  //TextEditingController controllerAvatar;

  @override
  void initState() {
    //controllerAvatar = new TextEditingController();
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
    }
  }

  Future<Void> optionsDialog() {
    return (showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(child: Text('Tomar Foto'), onTap: openCamera),
                Padding(padding: EdgeInsets.all(10.0)),
                GestureDetector(
                    child: Text('Seleccionar de Galería'), onTap: openGallery),
              ],
            ),
          ));
        }));
  }

  void openCamera() async {
    ImagePicker.pickImage(source: ImageSource.camera).then((File picture) {
      if (picture != null && picture.path != null) {
        setState(() {
          firstButtonText = 'Guardando en proceso...';
        });
        GallerySaver.saveImage(picture.path, albumName: albumName)
            .then((bool success) {
          setState(() {
            firstButtonText = 'Imagen guardada!';
            String dir = path.dirname(picture.path);
            String newPath = path.join(dir, 'Shingekynokiojin.jpg');
            print('newPath: $newPath');
            picture.renameSync(newPath);
          });
        });
      }
    });
  }

  void openGallery() async {
    ImagePicker.pickImage(source: ImageSource.gallery).then((File picture) {
      String dir = path.dirname(picture.path);
      String newPath = path.join(dir, 'Shingekynokiojin.jpg');
      print('newPath : $newPath ');
      picture.renameSync(newPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Registro UEES 2020", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              sharedPreferences.clear();
              sharedPreferences.commit();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) => LoginPage()),
                  (Route<dynamic> route) => false);
            },
            child: Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromRGBO(62, 15, 31, 1),
            Color.fromRGBO(135, 22, 52, 1)
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new RaisedButton(
                    color: Colors.red[300],
                    textColor: Colors.white,
                    splashColor: Colors.blueGrey,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GenerateScreen()),
                      );
                    },
                    child: const Text('GENERAR CÓDIGO QR')),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new RaisedButton(
                    color: Colors.red[300],
                    textColor: Colors.white,
                    splashColor: Colors.blueGrey,
                    onPressed: optionsDialog,
                    child: const Text('SUBIR FOTO')),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new RaisedButton(
                    color: Colors.red[300],
                    textColor: Colors.white,
                    splashColor: Colors.blueGrey,
                    onPressed: () => databasehelper.loadImage(
                        '/data/user/0/com.example.uees/cache/prueba.jpg'),
                    child: const Text('FOTO')),
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text('IEE Proyectos'),
              accountEmail: new Text('jlayana@ieeproyectos.com'),
              // decoration: new BoxDecoration(
              //   image: new DecorationImage(
              //     fit: BoxFit.fill,
              //    // image: AssetImage('img/estiramiento.jpg'),
              //   )
              // ),
            ),
            new ListTile(
              title: new Text("Listar Items"),
              trailing: new Icon(Icons.help),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => ListItems(),
              )),
            ),
            new ListTile(
              title: new Text("Adicionar Items"),
              trailing: new Icon(Icons.help),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => AddDataItem(),
              )),
            ),
            new Divider(),
            new ListTile(
              title: new Text("Registro de Usuarios"),
              trailing: new Icon(Icons.help),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => AddUser(),
              )),
            ),
            // new Divider(),
            // new ListTile(
            //   title: new Text("Mostrar listado"),
            //   trailing: new Icon(Icons.help),
            //   onTap: () => Navigator.of(context).push(new MaterialPageRoute(
            //     builder: (BuildContext context) => ShowData(),
            //   )),
            // ),
          ],
        ),
      ),
    );
  }
}
