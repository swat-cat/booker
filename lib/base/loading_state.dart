import 'package:flutter/material.dart';

abstract class LoadingBaseState<T extends StatefulWidget> extends State<T> {

  bool _isLoading = false;
  String _title = "";

  @override
  Widget build(BuildContext context) => new Scaffold(
    appBar: new AppBar(title: new Text(_title)),
    body: _isLoading?new Center(
      child: new CircularProgressIndicator(),
    ):content(),
  );

  Widget content();

  set isLoading(bool value) {
    _isLoading = value;
  }

  set title(String value) {
    _title = value;
  }

}