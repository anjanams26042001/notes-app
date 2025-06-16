import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'addnote.dart';
import 'viewnote.dart';

final db = FirebaseDatabase.instance.reference();

class Dashboard extends StatefulWidget {
  State<StatefulWidget> createState() {
    return new DashboardPage();
  }
}

class NotesList {
  String key;
  String title;
  String desc;
  NotesList(key, title, desc) {
    this.key = key;
    this.title = title;
    this.desc = desc;
  }
  NotesList ret() {
    return this;
  }
}

class DashboardPage extends State<Dashboard> {
  var user;
  List<NotesList> notes = new List<NotesList>();
  bool isLoading = true;

  storeList() {
    db.child('Notes/users/$user/notes/').once().then((DataSnapshot snapshot) {
      print(snapshot.value);
      setState(() {
        isLoading = false;
      });
      var data = json.encode(snapshot.value);
      print(data);
      final value = snapshot.value as Map;
      for (final key in value.keys) {
        print(value[key]['title']);
        NotesList p = new NotesList(
            value[key]['key'], value[key]['title'], value[key]['desc']);
        notes.add(p.ret());
      }
      //notes = List<NotesList>.generate(value.length, (key in value.keys) => NotesList(value[key]['key'],value[key]['title'],value[key]['desc']) );
      print(notes[0].key);
    });
  }

  search(searchKey){
    db.child('Notes/users/$user/notes/').once().then((DataSnapshot snapshot) {
      print(snapshot.value);
      var data = json.encode(snapshot.value);
      print(data);
      int i = 0;
      if(snapshot.value != null){
        final value = snapshot.value as Map;
        for (final key in value.keys) {
          print(value[key]['title']);
          if(value[key]['title'].toString().contains(searchKey)){
            if(i==0){notes = [];i  =1;}
            NotesList p = new NotesList(
                value[key]['key'], value[key]['title'], value[key]['desc']);
            notes.add(p.ret());
          }
        }
      }
      //print(notes[0].key);
      setState(() {
        isLoading = false;
      });
      if(i==0){
        _showDialog('Oops...', 'No match found', context);
      }
      
      //notes = List<NotesList>.generate(value.length, (key in value.keys) => NotesList(value[key]['key'],value[key]['title'],value[key]['desc']) );
      
    });
  }

  getFromStorage() async {
    SharedPreferences st = await SharedPreferences.getInstance();
    print(st.getString('user'));
    setState(() {
      // = false;
      user = st.getString('user');
    });
    storeList();
  }

  setinstorage(notekey) async {
    SharedPreferences st = await SharedPreferences.getInstance();
    st.setString('key', notekey);
  }

  DashboardPage() {
    getFromStorage();
  }

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  TextEditingController searchKey = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchBar = TextField(
      controller: searchKey,
      textInputAction: TextInputAction.done,
      onSubmitted: (term){
        setState(() {
          isLoading = true;
        });
        search(searchKey.text);
      },
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          suffixIcon: Icon(Icons.search),
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Search your Notes ",
         // border:
            //  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
        ),
    );

    return Scaffold(
      appBar: AppBar(title: searchBar),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final item = notes[index];
                return 
                      Center(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                            SizedBox(height: 50.0),
                            ListTile(
                              onTap: () {
                                setinstorage(item.key);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ViewNote()));
                              },
                              title: Center(
                                child: Text(
                                  item.title,
                                  style: Theme.of(context).textTheme.headline,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0.0),
                              child: Container(
                                  height: 1.0, width: 300, color: Colors.black),
                            ),
                          ]));
              },
            ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Center(
                  child: CircleAvatar(
                backgroundColor: Colors.purpleAccent,
                radius: 50,
                child: Text(user[0], style: TextStyle(fontSize: 50)),
              )),
              decoration: BoxDecoration(
                color: Colors.purple,
              ),
            ),
            ListTile(
              title: Text('Add Note'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddNote()));
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () async {
                SharedPreferences st = await SharedPreferences.getInstance();
                st.remove('user');

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                  (Route<dynamic> route) => false,
                );
                // Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
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
}
