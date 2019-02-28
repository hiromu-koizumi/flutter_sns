import 'package:flutter/material.dart';

class User {
  final String id;
  final String email;
  final String password;

  //@requiredをつけると必須パラメーターになる
  User({@required this.id, @required this.email, @required this.password});
}