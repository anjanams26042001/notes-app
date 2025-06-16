import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

final db = FirebaseDatabase.instance.reference();

class Login extends StatefulWidget {
  State<StatefulWidget> createState() {
    return new LoginPage();
  }
}

class LoginPage extends State<Login> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  bool isLoading = false;
  SharedPreferences st;

  getstorage() async {
    st = await SharedPreferences.getInstance();
  }

  TextEditingController uname = new TextEditingController();
  TextEditingController pass = new TextEditingController();

  LoginPage() {
    getstorage();
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextField(
      controller: uname,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Username",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final passwordField = TextField(
      controller: pass,
      obscureText: true,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    return Scaffold(
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
                CircleAvatar(
                  backgroundColor: Colors.purple,
                  radius: 50,
                  child: Text('L', style: TextStyle(fontSize: 50)),
                ),
                SizedBox(height: 50.0),
                emailField,
                SizedBox(height: 50.0),
                passwordField,
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
                            login(uname.text, pass.text, context);
                          },
                          child: Text("Login",
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

  login(uname, pass, context) {
    if (uname.isEmpty || pass.isEmpty) {
      print('Fields cannot be empty');
      _showDialog("Oops...", 'Fields cannot be empty', context);
      setState(() {
        isLoading = false;
      });
    } else {
      db
          .child('Notes/users/' + '$uname' + '/')
          .once()
          .then((DataSnapshot snapshot) {
        print(snapshot.value);
        if (snapshot.value == null) {
          print('Invalid user');
          _showDialog('Oops...', 'Username does not exists', context);
          setState(() {
            isLoading = false;
          });
        } else {
          print(snapshot.value);
          var data = json.encode(snapshot.value);
          print(data);
          var res = json.decode(data);
          print(res['name']);
          if (res['pass'] != pass) {
            print('Invalid password');
            _showDialog('Oops...', 'Incorrect password', context);
            setState(() {
              isLoading = false;
            });
          } else {
            print(res);
            _showDialog('Hurrah', 'Login Success', context);
            st.setString('user', uname);
            //Navigator.push(
           //     context, MaterialPageRoute(builder: (context) => Dashboard()));
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
              (Route<dynamic> route) => false,
            );
            setState(() {
              isLoading = false;
            });
          }
        }
      });
    }
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
}
