import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

var btntext = 'Register';

final db = FirebaseDatabase.instance.reference();

class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new RegisterPage();
  }
}

class RegisterPage extends State<Register> {
  bool isLoading = false;
  var btnText = 'Register';

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  TextEditingController name = new TextEditingController();
  TextEditingController uname = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController pass = new TextEditingController();
  TextEditingController conpass = new TextEditingController();

  RegisterPage();

  @override
  Widget build(BuildContext context) {
    final nameField = TextField(
      controller: name,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Name",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final unameField = TextField(
      controller: uname,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Username",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final emailField = TextField(
      controller: email,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
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
    final conpasswordField = TextField(
      controller: conpass,
      obscureText: true,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Confirm Password",
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
                  child: Text('R', style: TextStyle(fontSize: 50)),
                ),
                SizedBox(height: 50.0),
                nameField,
                SizedBox(height: 50.0),
                unameField,
                SizedBox(height: 50.0),
                emailField,
                SizedBox(height: 50.0),
                passwordField,
                SizedBox(height: 50.0),
                conpasswordField,
                SizedBox(
                  height: 50.0,
                ),
                //registerButton,
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
                            register(name.text, uname.text, email.text,
                                pass.text, conpass.text, context);
                          },
                          child: Text("$btnText",
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

  register(name, uname, email, pass, conpass, context) {
    if (name.isEmpty || uname.isEmpty || email.isEmpty || pass.isEmpty) {
      print('Fields are Empty');
      setState(() {
        isLoading = false;
      });
      _showDialog("Oops...",'Fields cannot be empty', context);
    } else if (!(RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email))) {
      print('Invalid Email');
      setState(() {
        isLoading = false;
      });
      _showDialog("Oops...","Enter a valid Email", context);
    } else if (!(RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
        .hasMatch(pass))) {
      print('Invalid password');
      setState(() {
        isLoading = false;
      });
      _showDialog("Oops...","Password must have atleast 8 characters including a uppercase letter,a lowercase letter,a special character and a number", context);
           
    } else if (pass != conpass) {
      print('Password mismatch');
      setState(() {
        isLoading = false;
      });
      _showDialog("Oops...","Passwords did not match", context);
      
    } else {
      print('good to go');

      db.child('Notes/users/' + '$uname').once().then((DataSnapshot snapshot) {
        print(snapshot.value);
        if (snapshot.value != null) {
          print('User already Exists');
          setState(() {
            isLoading = false;
          });
         _showDialog("Oops...","Username Already Exists", context);
        } else {
          db.child('Notes/users/' + '$uname').set({
            'name': name,
            'uname': uname,
            'email': email,
            'pass': pass,
            'notes': ''
          });
          setState(() {
            isLoading = false;
          });
          _showDialog("Hurrah","Registration success\nHead to LOGIN", context);

                    
          
        }
      });
    }
  }
}

void _showDialog(msg,text,context) {
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