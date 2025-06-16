import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

final db = FirebaseDatabase.instance.reference();

class AddNote extends StatefulWidget {
  State<StatefulWidget> createState() {
    return new AddNotePage();
  }
}

class AddNotePage extends State<AddNote> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  var user;
  bool isLoading = false;

  getFromStorage() async {
    SharedPreferences st = await SharedPreferences.getInstance();
    print(st.getString('user'));
    setState(() {
      isLoading = false;
      user = st.getString('user');
      print(user);
    });
  }

  AddNotePage() {
    getFromStorage();
  }

  TextEditingController title = new TextEditingController();
  TextEditingController desc = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final titleField = TextField(
      controller: title,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Title",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final descriptionField = TextField(
      keyboardType: TextInputType.multiline,
      maxLines: null,
      controller: desc,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Add your Note",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Add Note')) 
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 50.0),
                titleField,
                SizedBox(height: 50.0),
                descriptionField,
                SizedBox(
                  height: 50.0,
                ),
                isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.purple,
                        child: MaterialButton(
                          minWidth: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                            });
                            login(title.text, desc.text, context);
                          },
                          child: Text("Add Note",
                              textAlign: TextAlign.center,
                              style: style.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                SizedBox(
                  height: 50.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  login(title, desc, context) {
    if (title.isEmpty || desc.isEmpty) {
      print('Fields cannot be empty');
      _showDialog("Oops...", 'Fields cannot be empty', context);
      setState(() {
        isLoading = false;
      });
    } else {
      print('$title\n$desc\n$user');
      var push = db.child('Notes/users/$user/notes').push();
      push.set({
        'key' : push.key,
        'title': title,
        'desc' : desc,
      });
      setState(() {
        isLoading = false;
      });

      Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
              (Route<dynamic> route) => false,
            );
      _showDialog('Hurrah', 'Note Added', context);
  }
}

void _showDialog(msg, text, context) {
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: new Text(msg),
        content: new Text(text),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new FlatButton(
            child: new Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}}
