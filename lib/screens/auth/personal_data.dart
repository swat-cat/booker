import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../base/loading_state.dart';
import 'package:flutter/material.dart';
import 'package:booker/base/dialog_shower.dart' as DialogShower;

class PersonalData extends StatefulWidget {
  @override
  _PersonalDataState createState() => new _PersonalDataState();
}

class _PersonalDataState extends LoadingBaseState<PersonalData> {

  final TextEditingController _firstNameController = new TextEditingController();
  final TextEditingController _lastNameController = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  void initState() {
    hasUser = true;
  }

  @override
  Widget content() {
    setState(()=>title = "Profile");
    return new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildFirstNameTextField(),
          buildLastNameTextField(),
          confirmButton(),
          skip()
        ],
      ),
    );
  }

  Widget buildFirstNameTextField() => new Container(
    alignment: new Alignment(0.5, 0.5),
    height: 36.0,
    margin: const EdgeInsets.only(left: 16.0,right: 16.0,bottom: 16.0),
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    decoration:
    new BoxDecoration(
        borderRadius: new BorderRadius.all(const Radius.circular(4.0)),
        border: new Border.all(color: Colors.grey)),
    child: new TextField(
      controller: _firstNameController,
      decoration: new InputDecoration.collapsed(hintText: "First Name"),
      keyboardType: TextInputType.text,
    ),
  );

  Widget buildLastNameTextField() => new Container(
    alignment: new Alignment(0.5, 0.5),
    height: 36.0,
    margin: const EdgeInsets.only(left: 16.0,right: 16.0,bottom: 16.0),
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    decoration:
    new BoxDecoration(
        borderRadius: new BorderRadius.all(const Radius.circular(4.0)),
        border: new Border.all(color: Colors.grey)),
    child: new TextField(
      controller: _lastNameController,
      decoration: new InputDecoration.collapsed(hintText: "Last Name"),
      keyboardType: TextInputType.text,
    ),
  );

  Widget confirmButton() => new Padding(padding: new EdgeInsets.all(8.0),
      child: new RaisedButton(
          color: new Color(0xff64B5F6),
          onPressed: _save,
          child: new Text(
            "Save",
            style: new TextStyle(
                color: new Color(0xffffffff)
            ),
          )));

  Widget skip() => new FlatButton(
      onPressed: _skip,
      child: new Text(
        "Skip",
        style: new TextStyle(color: new Color(0xff64B5F6)),
      ));

  void _save() {
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    if (firstName.length>0 && firstName.length<2){
      AlertDialog d = DialogShower.buildDialog(message: "First Name is too short",confirm: "Ok", confirmFn: ()=>Navigator.pop(context));
      showDialog(context: context, child: d);
      return;
    }
    if(lastName.length>0 && lastName.length<2){
      AlertDialog d = DialogShower.buildDialog(message: "Last Name is too short",confirm: "Ok", confirmFn: ()=>Navigator.pop(context));
      showDialog(context: context, child: d);
      return;
    }
    if(lastName.length == 0 && firstName.length == 0) {
      showDialog(context: context,
          child: DialogShower.buildDialog(message: "No content for saving",confirm: "Ok", confirmFn: ()=>Navigator.pop(context)));
      return;
    }
    String displayName="";
    if(firstName.length>0){
      displayName+=firstName;
    }
    if(lastName.length>0){
      displayName+=" "+lastName;
    }

    _auth.currentUser().then((user){
      DocumentReference docRef = Firestore.instance.collection("users").document(user.email);
      if(docRef == null){
        Firestore.instance.collection("users").document(user.email).setData({"email":user.email, "displayName":displayName});
      }
      else{
        docRef.updateData({"displayName":displayName});
      }
      UserUpdateInfo updateInfo = new UserUpdateInfo();
      updateInfo.displayName = displayName;

      _auth.updateProfile(updateInfo).then((value){
        Navigator.pushReplacementNamed(context, "/activities");
      });
    });
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, "/activities");
  }
}
