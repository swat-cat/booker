import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:booker/base/constants.dart';


class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => new _WelcomeState();
}

class _WelcomeState extends State<Welcome> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body:new Center(
            child: new Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                child: new Image(
                    image: new AssetImage('images/booking.png')))));
  }

  checkForToken()async{
    FirebaseAuth.instance.currentUser().then((user){
      if(user!=null){
        if(user.displayName == null || user.displayName.length==0){
          Navigator.of(context).pushReplacementNamed("/personal_data");
        }
        else{
          Navigator.pushReplacementNamed(context, "/activities");
        }
      }
      else{
        Navigator.of(context).pushReplacementNamed("/signin");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkForToken();
  }
}
