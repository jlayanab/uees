import 'dart:convert';
//import 'dart:html';
import 'package:uees/view/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uees/Cotrollers/databasehelpers.dart';

import '../main.dart';

class Confirmation extends StatefulWidget {
  @override
  _ConfirmationState createState() => _ConfirmationState();
}

class _ConfirmationState extends State<Confirmation> {
  DataBaseHelper databasehelper = new DataBaseHelper();
  bool _isLoading = false;
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  SharedPreferences sharedPreferences;
  String emailnew, passnew;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    mostrarDatos();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("nombres") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
    }
    //Agrega nuevo usuario al iniciar la pantalla por medio de registrarUser y sharedPreference
    if (sharedPreferences.getString("nombres") != null) {
      print(sharedPreferences.getString("nombres"));
      databasehelper.registrarUser(
          sharedPreferences.getString("email"),
          sharedPreferences.getString("pass"),
          sharedPreferences.getString("cod_identificacion"),
          sharedPreferences.getString("nombres"),
          sharedPreferences.getString("apellidos"));
    }
  }

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

  //Función para iniciar sesion con rails
  signIn(String email, pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {'email': email, 'password': pass};
    var jsonResponse;

    var response = await http
        .post("http://181.39.198.36:3000/api/v1/authenticate", body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response
          .body); //guarda datos del usuario logueado por sharedPreferences
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
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => MainPage()),
            (Route<dynamic> route) => false);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print(response.body);
    }
  }

  //guarda email y password ingresados por medio de sharedpreferences
  Future mostrarDatos() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      emailnew = sharedPreferences.getString("email");
      passnew = sharedPreferences.getString("pass");
    });
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: RaisedButton(
        onPressed: emailnew == "" || passnew == ""
            ? null
            : () async {
                setState(() {
                  _isLoading = true;
                });
                signIn(emailnew, passnew);
                //guarda valores de email y password del inicio de sesion por sharedpreferences
                SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                sharedPreferences.setString("email", emailnew);
                sharedPreferences.setString("pass", passnew);
              },
        elevation: 0.0,
        color: Colors.pink[900],
        child: Text("Confirmar", style: TextStyle(color: Colors.white70)),
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
            controller: emailController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.email, color: Colors.white70),
              hintText: emailnew,
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.white,
            obscureText: true,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: Colors.white70),
              hintText: passnew,
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
      child: Icon(
        Icons.account_circle,
        color: Colors.white70,
        size: 70,
      ),
      margin: EdgeInsets.only(top: 50.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
    );
  }
}
