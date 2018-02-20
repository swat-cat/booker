import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:booker/base/constants.dart'  as Constants;
import 'dart:convert';
import 'package:logging/logging.dart';

class RestClient{

  final Logger log = new Logger('MyClassName');

  Future<http.Response> post(String url, var body){
    return http.post(url,body: body, headers: {
      'Content-Type':'application/json',
      'Accept': 'application/json'
    });
  }
  
  Future<String> signIn(String email, String password) async {
      String url = Uri.encodeFull('https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key='+Constants.KEY);
      http.Response response = await post(url, JSON.encode({"email":email,"password":password,"returnSecureToken":'true'}));
      print("Response: "+ response.toString());
      print("Response Body: "+ response.body);
      return response.body;
  }

  Future<String> signUp(String email, String password) async {
    String url = Uri.encodeFull('https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key='+Constants.KEY);
    http.Response response = await post(url, {"email":email,"password":password,"returnSecureToken":'true'});
    print("Response: "+ response.toString());
    print("Response Body: "+ response.body);
    return response.body;
  }
}