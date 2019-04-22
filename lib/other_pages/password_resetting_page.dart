import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordResettingPage extends StatefulWidget {
  @override
  _PasswordResettingPageState createState() => _PasswordResettingPageState();
}

class _PasswordResettingPageState extends State<PasswordResettingPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String email;
  var auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              iconSize: 35,
              icon: Icon(Icons.keyboard_arrow_left),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        SizedBox(
          height: 250,
        ),
        Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 24.0),
                  TextFormField(
                    // controller: emailInputController,
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.mail),
                      border: const UnderlineInputBorder(),
                      labelText: 'Email',
                    ),
                    onSaved: (String value) {
                      email = value;
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'メールアドレスは必須入力です';
                      }
                      Pattern pattern =
                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                      RegExp regex = new RegExp(pattern);
                      if (!regex.hasMatch(value))
                        return '無効なメールアドレスです';
                      else
                        return null;
                    },
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  RaisedButton(
                    child: const Text('パスワードを再設定する'),
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        auth.sendPasswordResetEmail(email: email);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    ));
  }
}
