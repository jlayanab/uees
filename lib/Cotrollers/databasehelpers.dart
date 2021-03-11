//import 'dart:io';
//import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DataBaseHelper {
  String serverUrl = "http://181.39.198.36:3000/api/v1";
  String serverUrlitems = "http://181.39.198.36:3000/api/items";

  var status;
  var token;

  // Crear funcion para el Login
  loginData(String email, String password) async {
    String myUrl = "$serverUrl/authenticate";
    final respose = await http.post(myUrl,
        headers: {'Accept': 'application/json'},
        body: {"email": "$email", "password": "$password"});
    status = respose.body.contains('error');

    var data = json.decode(respose.body);

    if (status) {
      print('data : ${data["error"]}');
    } else {
      print('data : ${data["token"]}');
      _save(data["token"]);
    }
  }

  //Funcion para registro de Items
  addDataItem(String _nameController, String _descriptionController) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = prefs.get(key) ?? 0;

    String myUrl = "$serverUrl/items";
    final respose = await http.post(myUrl, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $value'
    }, body: {
      "item[name]": "$_nameController",
      "item[description]": "$_descriptionController"
    });

    status = respose.body.contains('error');

    var data = json.decode(respose.body);
    //Resolver problema de token
    if (status) {
      print('data : ${data["error"]}');
    } else {
      print('data : ${data["token"]}');
      //_save(data["token"]);
    }
  }

  //function for update or put Items
  void editarData(String id, String nombre, String descripcion) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = prefs.get(key) ?? 0;

    String myUrl = "http://181.39.198.36:3000/api/v1/items/$id";

    http.put(myUrl, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $value'
    }, body: {
      "item[name]": "$nombre",
      "item[description]": "$descripcion"
    }).then((respose) {
      print('Respose status : ${respose.statusCode}');
      print('Respose body : ${respose.body}');
    });
  }

  //Crear funcion para registro de usuarios
  registerUserData(String email, String password) async {
    String myUrl = "$serverUrl/users";
    final respose = await http.post(myUrl,
        headers: {'Accept': 'application/json'},
        body: {"email": "$email", "password": "$password"});
    status = respose.body.contains('error');

    var data = json.decode(respose.body);

    if (status) {
      print('data : ${data["error"]}');
    } else {
      print('data : ${data["token"]}');
      _save(data["token"]);
    }
  }

//function for delete
  void removeRegister(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = prefs.get(key) ?? 0;

    String myUrl = "http://181.39.198.36:3000/api/v1/items/$id";

    http.Response response = await http.delete(myUrl, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $value'
    });
    print('Respose status : ${response.statusCode}');
    print('Respose body : ${response.body}');
  }

//fuction get data
  Future<List> getData() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = prefs.get(key) ?? 0;

    String myUrl = "$serverUrlitems";

    http.Response response = await http.get(myUrl, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $value'
    });
    return json.decode(response.body);
  }

//Función guardar
  _save(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = token;
    prefs.setString(key, value);
  }

//Función leer
  read() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = prefs.get(key) ?? 0;
    print('read : $value');
  }

//Función update y agregar avatar al usuario
  loadImage(String avatar) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = prefs.get(key) ?? 0;
    final id =
        sharedPreferences.getInt("id"); //Toma valor de id por sharedPreference

    String myUser = "http://181.39.198.36:3000/api/v1/users/$id";

    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $value'
    };
    var request = http.MultipartRequest('PUT', Uri.parse(myUser));
    request.files
        .add(await http.MultipartFile.fromPath('user[avatar]', '$avatar'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  //Funcion para agregar Usuarios o registrarse
  registrarUser(dynamic usuario, dynamic clave, String identification,
      String nombres, String apellidos) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('http://181.39.198.36:3000/api/v1/users'));
    request.body =
        '''{\n    "user":{\n        "email":"$usuario",\n        "password":"$clave",\n        "Identification":"$identification",\n        "Nombres":"$nombres",\n        "Apellidos":"$apellidos"\n    }\n}''';
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

//Función para guardar las rutas de las imágenes de los usuarios y los ids
  saveImage(id, String ruta) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = prefs.get(key) ?? 0;
    var headers = {
      'Authorization': 'Bearer Bearer $value',
      'Content-Type': 'application/json'
    };
    var request = http.Request(
        'POST', Uri.parse('http://181.39.198.36:3000/api/v1/images'));
    request.body =
        '''{\n    "image": {\n        "users_id":$id,\n        "ruta": "$ruta",\n        "status": "Created"\n    }\n}''';
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }
}
