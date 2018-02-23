import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';


class UserData {
  String displayName;
  String email;
  String uid;
  String password;
  bool returnSecureToken;

  UserData({this.displayName, this.email, this.uid, this.password, this.returnSecureToken});


}

class UserAuth {

  //To create new User
  Future<FirebaseUser> createUser(UserData userData) async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return await firebaseAuth
        .createUserWithEmailAndPassword(
        email: userData.email, password: userData.password);;
  }

  //To verify new User
  Future<FirebaseUser> verifyUser(UserData userData) async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return await firebaseAuth
        .signInWithEmailAndPassword(
        email: userData.email, password: userData.password);
  }

  static Future<Null> logout()async{
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    Null n = await firebaseAuth.signOut();
    return n;
  }
}