import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'dashboard.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget{
  State<StatefulWidget> createState() {
    return new MyAppPage();
  }
}
class MyAppPage extends State<MyApp> {
  bool isLoading = true;
  bool isuser = false;

  getStorage() async{
    SharedPreferences st = await SharedPreferences.getInstance();
    print(st.getString('user'));
    if(st.getString('user') != null){
      setState(() {
        isLoading = false;
        isuser = false;
      });
    }
    else{
      setState(() {
        isuser = true;
        isLoading = false;
      });
    }
    
  }

  MyAppPage(){
    getStorage();
  }

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: isuser ? Home() : Dashboard(),
    );
  }
}
