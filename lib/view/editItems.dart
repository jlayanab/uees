import 'package:flutter/material.dart';
import 'package:uees/Cotrollers/databasehelpers.dart';
import 'package:uees/view/listItems.dart';

class EditItem extends StatefulWidget {
  final List list;
  final int index;

  EditItem({this.list, this.index});

  @override
  _EditItemState createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  DataBaseHelper databasehelper = new DataBaseHelper();

  TextEditingController controllerId;
  TextEditingController controllerName;
  TextEditingController controllerDescription;

  @override
  void initState() {
    controllerId = new TextEditingController(
        text: widget.list[widget.index]['id'].toString());
    controllerName = new TextEditingController(
        text: widget.list[widget.index]['name'].toString());
    controllerDescription = new TextEditingController(
        text: widget.list[widget.index]['description'].toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Editar"),
      ),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.all(10.0),
          children: <Widget>[
            new Column(
              children: <Widget>[
                new ListTile(
                  leading: const Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  title: new TextFormField(
                    controller: controllerName,
                    validator: (value){
                      if (value.isEmpty){
                        return 'Ingrese nombre';
                      }else {
                        return null;
                      }
                    },
                    decoration: new InputDecoration(
                      hintText: "Name",
                      labelText: "Name",
                    ),
                  ),
                ),
                const Divider(
                  height: 1.0,
                ),
                new ListTile(
                  leading: const Icon(
                    Icons.location_on,
                    color: Colors.black,
                  ),
                  title: new TextFormField(
                    controller: controllerDescription,
                    validator: (value) {
                      if (value.isEmpty){
                        return "Ingresa una Descripcion";
                      }
                      return null;
                    },
                    decoration: new InputDecoration(
                      hintText: "Description",
                      labelText: "Description",
                    ),
                  ),
                ),
                const Divider(
                  height: 1.0,
                ),
                new Padding(
                  padding: const EdgeInsets.all(10.0),
                ),
                new RaisedButton(
                    child: new Text("Editar"),
                    color: Colors.blueAccent,
                    onPressed: () {
                      databasehelper.editarData(
                          controllerId.text.trimRight(),
                          controllerName.text.trim(),
                          controllerDescription.text.trim());
                      Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) => new ListItems(),
                      ));
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}
