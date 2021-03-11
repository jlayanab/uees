import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:path/path.dart' as path;
import 'package:gallery_saver/gallery_saver.dart';
import 'package:uees/view/login.dart';
import 'package:uees/view/generate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uees/Cotrollers/databasehelpers.dart';
import 'package:image_cropper/image_cropper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Registro UEES",
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
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
  String usuario, newPath, albumName = 'Media';
  SharedPreferences sharedPreferences;
  File imagepicture, image;
  final picketFile = ImagePicker();
  bool visibilityController = false; //booleano para visualizar button

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    mostrarUsuario();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getInt("id") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
    }
    //condición para visualizacion del button
    if (sharedPreferences.getBool("avatar") == false) {
      visibilityController = true;
    }
    //condición para agregar las imagenes a la nueva tabla
    if (sharedPreferences.getString("file") != null) {
      databasehelper.saveImage(
          sharedPreferences.getInt("id"), sharedPreferences.getString("file"));
    }
  }

  //cuadro de selección para uso de cámara o galería
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

  //toma el email por medio de sharedpreferences
  Future guardarUsuario() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var jsonResponse;
    sharedPreferences.setString("email", jsonResponse['email']);
  }

  //guarda el email obtendido por sharedpreferences
  Future mostrarUsuario() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      usuario = sharedPreferences.getString("email");
    });
    print(usuario);
  }

  //funcion para usar camara del dispositivo y tomar foto
  void openCamera() async {
    final picture = await picketFile.getImage(
        source: ImageSource.camera,
        imageQuality: 100, //calidad de imagen
        maxWidth: 1450, //ancho de imagen
        maxHeight: 1275); //alto de imagen
    image = File(picture.path); //si existe una ruta abrir editor de imagen
    if (image != null) {
      //condición para abrir el editor de imagen
      cropImage(image);
    }
    Navigator.pop(context);
  }

  //funcion para usar galeria del dispositivo y seleccionar imagen
  void openGallery() async {
    final picture = await picketFile.getImage(
        source: ImageSource.gallery,
        imageQuality: 100, //calidad e imagen
        maxWidth: 1450, //ancho de imagen
        maxHeight: 1275); //alto de imagen
    image = File(picture.path); //si existe una ruta abrir editor de imagen
    if (image != null) {
      //condición para abrir el editor de imagen
      cropImage(image);
    }
    Navigator.pop(context);
  }

  //funcion para editar imagen seleccionada de camara y galeria
  cropImage(File picture) async {
    File cropped = await ImageCropper.cropImage(
      androidUiSettings: AndroidUiSettings(
        statusBarColor: Colors.pink[900],
        toolbarColor: Colors.pink[900],
        cropGridColor: Colors.pink[900],
        activeControlsWidgetColor: Colors.pink[900],
        toolbarTitle: "Editor de Foto",
        toolbarWidgetColor: Colors.white,
      ),
      sourcePath: picture.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2, //dimensiones para la imagen
        CropAspectRatioPreset.original, //dimensiones para la imagen
        CropAspectRatioPreset.ratio16x9, //dimensiones para la imagen
        CropAspectRatioPreset.ratio4x3, //dimensiones para la imagen
      ],
      maxWidth: 700,
    );
    if (cropped != null) {
      setState(() {
        imagepicture = cropped;
        GallerySaver.saveImage(imagepicture.path,
                albumName:
                    albumName) //guarda imagen en la galería de dispositivo
            .then((bool success) {
          setState(() {
            String dir =
                path.dirname(imagepicture.path); //guarda ruta de imagen
            newPath = path.join(dir, 'avatar.jpg'); //cambia nombre de imagen
            print('newPath: $newPath');
            imagepicture.renameSync(newPath); //renombra la ruta de la imagen
            databasehelper.loadImage(newPath); //guarda la imagen en la base
          });
        });
      });
    }
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
                    color: Colors.pink[900],
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
                //se muestra el button mediante una condicion
                Visibility(
                    visible: visibilityController,
                    child: new RaisedButton(
                        color: Colors.pink[900],
                        textColor: Colors.white,
                        splashColor: Colors.blueGrey,
                        onPressed: optionsDialog,
                        child: const Text('SUBIR FOTO')))
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              //muestra email de usuario actual en la pantalla de inicio
              accountName: new Text('UEES'),
              accountEmail: Text(usuario ?? ""),
              currentAccountPicture: GestureDetector(
                child: CircleAvatar(
                  //muestra imagen en la pantalla de inicio
                  backgroundColor: Colors.black,
                  backgroundImage: NetworkImage(
                      'https://pbs.twimg.com/profile_images/1212815999470358534/2eqDVz0n.jpg'),
                ),
              ),
            ),
            //new ListTile(
            //title: new Text(""),
            //trailing: new Icon(Icons.help),
            //onTap: () => Navigator.of(context).push(new MaterialPageRoute(
            //  builder: (BuildContext context) => ListItems(),
            //)),
            //    ),
            new Divider(),
            new ListTile(
                title: new Text("Log Out"),
                trailing: new Icon(Icons.logout),
                onTap: () {
                  sharedPreferences.clear();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => LoginPage()),
                      (Route<dynamic> route) => false);
                }),
          ],
        ),
      ),
    );
  }
}
