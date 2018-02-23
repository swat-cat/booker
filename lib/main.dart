import 'package:booker/screens/auth/personal_data.dart';
import 'package:booker/screens/auth/signin.dart';
import 'package:booker/screens/main/activity.dart';
import 'package:booker/screens/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


void main(){
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Welcome(),
      routes:  <String, WidgetBuilder> {
        "/welcome":(BuildContext context) => new Welcome(),
        "/signin": (BuildContext context) => new SignIn(),
        "/personal_data": (BuildContext context) => new PersonalData(),
        "/activities": (BuildContext context) => new Activities(),
      },
    );
  }
}