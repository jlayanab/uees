import 'dart:convert';
//import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uees/main.dart';
//import 'package:uees/view/confirmation.dart';
//import 'package:uees/view/confirmation.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final TextEditingController rolController =
      new TextEditingController(); //Guarda valor de email ingresado por el usuario por pantalla
  final TextEditingController codigoController =
      new TextEditingController(); //Guarda valor de password ingresado por el usuario por pantalla

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromRGBO(62, 15, 31, 1),
            Color.fromRGBO(135, 22, 52, 1)
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: <Widget>[
                  headerSection(),
                  textSection(),
                  buttonSection(),
                ],
              ),
      ),
    );
  }

  //Función para iniciar sesión por el web service Uees
  signInUees(String rol, String codigo) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var jsonResponse;
    String mUrl = "http://app.uees.edu.ec:3000/datosEmpleados";
    Map<String, String> queryParams = {'rol': '$rol', 'codigo': '$codigo'};
    String queryString = Uri(queryParameters: queryParams).query;
    var requestUrl = mUrl + '?' + queryString;

    http.Response response = await http.get(requestUrl);

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body.toString());
      print(response.statusCode);
      print(json.decode(response.body));
      if (jsonResponse != null) {
        //setState(() {
        //  _isLoading = false;
        //});
        //guarda datos del usuario logueado por sharedPreferences
        sharedPreferences.setString("codigo", jsonResponse['codigo']);
        sharedPreferences.setString("apellido", jsonResponse['apellido']);
        sharedPreferences.setString("nombres", jsonResponse['nombres']);
        sharedPreferences.setString("facultad", jsonResponse['facultad']);
        sharedPreferences.setString("rolDesc", jsonResponse['rolDesc']);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => MainPage()),
            (Route<dynamic> route) => false);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print(response.body.toString());
    }
  }

  //Función para iniciar sesión desde servidor rails
  signIn(String email, pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {'email': email, 'password': pass};
    var jsonResponse;

    var response = await http
        .post("http://181.39.198.36:3000/api/v1/authenticate", body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        //guarda datos del usuario logueado por sharedPreferences
        sharedPreferences.setString("token", jsonResponse['token']);
        sharedPreferences.setInt("id", jsonResponse['id']);
        sharedPreferences.setString(
            "Identification", jsonResponse['Identification']);
        sharedPreferences.setBool("avatar", jsonResponse['avatar']);
        sharedPreferences.setString("file", jsonResponse['file']);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => MainPage()),
            (Route<dynamic> route) => false);
      }
    } //condicion para verificar si el usuario existe o inicia sesion desde web service
    else if (response.statusCode == 401) {
      //signInUees(emailController.text, passwordController.text);
    }
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: RaisedButton(
        onPressed: rolController.text == "" || codigoController.text == ""
            ? null
            : () async {
                setState(() {
                  _isLoading = true;
                });
                signInUees(rolController.text, codigoController.text);
                //guarda valores de email y password del inicio de sesion por sharedpreferences
                SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                sharedPreferences.setString("rol", rolController.text);
                sharedPreferences.setString("codigo", codigoController.text);
              },
        elevation: 0.0,
        color: Colors.pink[900],
        child: Text("Sign In", style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: rolController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.group, color: Colors.white70),
              hintText: "Rol",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: codigoController,
            cursorColor: Colors.white,
            //obscureText: true,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.perm_contact_cal, color: Colors.white70),
              hintText: "Cédula",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: EdgeInsets.only(top: 50.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Center(
        child: Text("UEES",
            style: TextStyle(
                color: Colors.white70,
                fontSize: 70.0,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
