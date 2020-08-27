import 'package:flutter/material.dart';
import 'package:uees/Cotrollers/databasehelpers.dart';
import 'package:uees/main.dart';

class AddDataItem extends StatefulWidget {
  AddDataItem({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _AddDataItemState createState() => _AddDataItemState();
}

class _AddDataItemState extends State<AddDataItem> {
  DataBaseHelper databasehelper = new DataBaseHelper();

  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _descriptionController =
      new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Add Item',
        home: Scaffold(
          appBar: AppBar(
            title: Text('Add Item'),
          ),
          body: Container(
            child: ListView(
              padding: const EdgeInsets.only(
                  top: 62.0, left: 12.0, right: 12.0, bottom: 12.0),
              children: <Widget>[
                Container(
                  height: 50,
                  child: new TextField(
                    controller: _nameController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: 'name',
                        hintText: 'Item name',
                        icon: new Icon(Icons.email)),
                  ),
                ),
                Container(
                  height: 50,
                  child: new TextField(
                    controller: _descriptionController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        labelText: 'description',
                        hintText: 'Item descrition',
                        icon: new Icon(Icons.vpn_key)),
                  ),
                ),
                new Padding(
                  padding: new EdgeInsets.only(top: 44.0),
                ),
                Container(
                  height: 50,
                  child: new RaisedButton(
                    onPressed: () {
                      databasehelper.addDataItem(_nameController.text.trim(),
                          _descriptionController.text.trim());
                      Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) => new MainPage(),
                      ));
                    },
                    color: Colors.blue,
                    child: new Text(
                      'Add',
                      style: new TextStyle(
                          color: Colors.white, backgroundColor: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
