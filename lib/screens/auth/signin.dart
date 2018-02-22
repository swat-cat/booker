import 'package:flutter/material.dart';
import 'package:flutter/src/services/message_codec.dart';
import 'dart:async';
import '../../base/loading_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:booker/services/rest_client.dart';
import 'package:booker/base/constants.dart'  as Constants;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignIn extends StatefulWidget {
  @override
  State createState() => new SignInState();
}

class SignInState extends LoadingBaseState<SignIn> {
  String _signin = "Sign In";
  String _signup = "Sign up";
  String _alreadyHaveAccount = "Already have account?";
  String _haveNoAccount = "Have no account?";
  bool needAddProfile = true;
  SignState signState = SignState.SIGNIN;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passController = new TextEditingController();
  final TextEditingController _confirmPassController = new TextEditingController();


  @override
  void initState() {
    super.initState();
    title = getLabel();
  }

  @override
  Widget content(){
    setState(()=>title = getLabel());
    return new Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildEmailTextField(),
          buildPasswordTextField(context),
          signState == SignState.SIGNUP?buildConfirmPassTextField():new Container(),
          confirmButton(),
          messageLabel(),
          toggleSignState()
        ],
      ),
    );
  }

  Widget buildEmailTextField() => new Container(
    alignment: new Alignment(0.5, 0.5),
    height: 36.0,
    margin: const EdgeInsets.only(left: 16.0,right: 16.0,bottom: 16.0),
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration:
            new BoxDecoration(
                borderRadius: new BorderRadius.all(const Radius.circular(4.0)),
                border: new Border.all(color: Colors.grey)),
        child: new TextField(
          controller: _emailController,
          decoration: new InputDecoration.collapsed(hintText: "Email"),
          keyboardType: TextInputType.emailAddress,
        ),
      );

  Widget buildPasswordTextField(BuildContext context) => new Container(
        alignment: new Alignment(0.5, 0.5),
        height: 36.0,
        margin: const EdgeInsets.only(left: 16.0,right: 16.0,bottom: 16.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration:
            new BoxDecoration(
                borderRadius: new BorderRadius.all(const Radius.circular(4.0)),
                border: new Border.all(color: Colors.grey)),
        child: new TextField(
          obscureText: true,
          controller: _passController,
          decoration: new InputDecoration.collapsed(hintText: "Password"),
        ),
      );

  Widget buildConfirmPassTextField() => new Container(
    alignment: new Alignment(0.5, 0.5),
    height: 36.0,
    margin: const EdgeInsets.only(left: 16.0,right: 16.0,bottom: 16.0),
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    decoration:
    new BoxDecoration(
        borderRadius: new BorderRadius.all(const Radius.circular(4.0)),
        border: new Border.all(color: Colors.grey)),
    child: new TextField(
      obscureText: true,
      controller: _confirmPassController,
      decoration: new InputDecoration.collapsed(hintText: "Confirm password"),
    ),
  );

  Widget confirmButton() => new Padding(padding: new EdgeInsets.all(8.0),
      child: new RaisedButton(
      color: new Color(0xff64B5F6),
      onPressed: _confirmPressed,
      child: new Text(
        getLabel(),
        style: new TextStyle(
          color: new Color(0xffffffff)
        ),
      )));

  Widget messageLabel() => new Text(message());

  Widget toggleSignState() => new FlatButton(
      onPressed: _toggleSignState,
      child: new Text(
         getReverseLabel(),
        style: new TextStyle(color: new Color(0xff64B5F6)),
      ));

  void _confirmPressed() {
    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    var email = _emailController.text.trim();
    RegExp exp = new RegExp(p);
    if(!exp.hasMatch(email)){
      AlertDialog dialog = new AlertDialog(
        title: new Text("Email is not valid"),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      );
      showDialog(context: context, child: dialog);
      return;
    }
    var pass = _passController.text;
    if(pass.length<6){
      AlertDialog dialog = new AlertDialog(
        title: new Text("Password is too short"),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      );
      showDialog(context: context, child: dialog);
      return;
    }
    var confirmPass = _confirmPassController.text;
    if(signState == SignState.SIGNUP){
      if(confirmPass != pass){
        AlertDialog dialog = new AlertDialog(
          title: new Text("Passwords didn't match"),
          actions: <Widget>[
            new FlatButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
          ],
        );
        showDialog(context: context, child: dialog);
        return;
      }
    }
    _emailController.clear();
    _passController.clear();
    _confirmPassController.clear();
    setState(()=>isLoading = true);
    auth(email, pass).then((user) {
      if (signState == SignState.SIGNUP) {
        Firestore.instance.collection('users').document(user.email)
            .setData({ 'email': user.email });
      }
      if(user.displayName == null || user.displayName.length==0){
        Navigator.of(context).pushReplacementNamed("/personal_data");
      }
      else{
        Navigator.of(context).pushReplacementNamed("/activities");
      }
      setState(()=>isLoading = false);
    }).catchError((PlatformException e) {
      AlertDialog dialog = new AlertDialog(
        title: new Text("Auth error!"),
        actions: <Widget>[
          new FlatButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      );
      showDialog(context: context, child: dialog);
      setState(()=>isLoading = false);
    });
  }

  Future<bool> checkAndSaveToken(String body) async{
    Map data = JSON.decode(body);
    if(data["error"]!=null){
      String message = data["error"]["message"];
      AlertDialog dialog = new AlertDialog(
        title: new Text(message!=null?message:"Error"),
        actions: <Widget>[
          new FlatButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      );
      showDialog(context: context, child: dialog);
      return false;
    }
    print(data["idToken"]);
    String dispName =  data["displayName"];
    setState(()=>needAddProfile = dispName!=null && dispName.length>0);
    String token = data["idToken"];
    var sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(Constants.TOKEN, token);
    return true;
  }

  void _toggleSignState() {
    setState((){
      signState = signState == SignState.SIGNIN?SignState.SIGNUP:SignState.SIGNIN;
      title = getLabel();
    });
  }

  String getLabel(){
    return signState == SignState.SIGNIN?_signin:_signup;
  }

  String getReverseLabel(){
    return signState == SignState.SIGNIN?_signup:_signin;
  }

  String message(){
    return signState == SignState.SIGNIN?_haveNoAccount:_alreadyHaveAccount;
  }

  Future<FirebaseUser> auth(String email, String password){
    if(signState == SignState.SIGNIN){
      return _auth.signInWithEmailAndPassword(email: email, password: password);
    }
    else{
      return _auth.createUserWithEmailAndPassword(email: email, password: password);
    }
  }
}

enum SignState{
  SIGNIN,SIGNUP
}