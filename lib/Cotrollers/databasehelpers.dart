import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DataBaseHelper {
  String serverUrl = "http://192.168.100.26:3000/api/v1";
  String serverUrlitems = "http://192.168.100.26:3000/api/items";

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
    TODO: //Resolver problema de token
    if (status) {
      print('data : ${data["error"]}');
    } else {
      print('data : ${data["token"]}');
      //_save(data["token"]);
    }
  }

  //function for update or put
  void editarData(String id, String nombre, String descripcion) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = prefs.get(key) ?? 0;

    String myUrl = "http://192.168.100.26:3000/api/v1/items/$id";

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

    String myUrl = "http://192.168.100.26:3000/api/v1/items/$id";

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

//Funcion guardar
  _save(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = token;
    prefs.setString(key, value);
  }

  read() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = prefs.get(key) ?? 0;
    print('read : $value');
  }

//Funcion guardar imagen
  loadImage(String avatar) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = prefs.get(key) ?? 0;

    String myUser = "http://192.168.100.26:3000/api/v1/users/7";

    http.Response response = await http.patch(myUser, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $value'
    }, body: {
      "avatar": "$avatar"
    });

    return (response.body);
  }
}
