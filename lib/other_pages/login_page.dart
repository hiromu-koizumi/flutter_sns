//splash画面処理
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/main.dart';
import 'package:flutter_cos/user_pages/my_page/my_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

//いろんなページで使うから外出しといたほうが便利
FirebaseUser firebaseUser;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email, password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Center(
      child: new Form(
        key: _formKey,
        child: new SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 24.0),
              new TextFormField(
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
              const SizedBox(height: 24.0),
              new TextFormField(
                //  controller: passwordInputController,
                decoration: new InputDecoration(
                  icon: const Icon(Icons.vpn_key),
                  border: const UnderlineInputBorder(),
                  labelText: 'Password',
                ),
                onSaved: (String value) {
                  password = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Passwordは必須入力です';
                  }
                  if (value.length < 6) {
                    return 'Passwordは6桁以上です';
                  }
                },
                obscureText: true,
              ),
              const SizedBox(height: 24.0),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      child: const Text('ユーザー登録'),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          _createUser(context, email, password);
                        }
                      },
                    ),
                    const SizedBox(width: 24.0),
                    RaisedButton(
                      child: const Text('ログイン'),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          _signIn(context, email, password);
                        }
                      },
                    ),
                  ]),
            ],
          ),
        ),
      ),
    ));
  }

  ////メールアドレスとパスワードでログインする処理
  void _signIn(BuildContext context, String email, String password) async {
    try {
      //ログインしている
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      firebaseUser = await _auth.currentUser();

      Navigator.push(
          context,
          MaterialPageRoute(
              settings: const RouteSettings(name: "/MyPage"),

              //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
              builder: (BuildContext context) => MyPages()));

      //Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
    } catch (e) {
      Fluttertoast.showToast(msg: "Firebaseのログインに失敗しました");
    }
  }

//メールアドレスとパスワードで新規ユーザー作成
  void _createUser(BuildContext context, String email, String password) async {
    try {
      //Authenticationにユーザーを作成している
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      firebaseUser = await _auth.currentUser();

      DocumentReference _userReference;
      _userReference =
          Firestore.instance.collection('users').document(firebaseUser.uid);

      await _userReference.setData({
        "userName": "NONAME",
        "photoUrl":
            "https://www.cosco-times.com/wp-content/uploads/2019/01/ponyoshida.png",
        "userId": firebaseUser.uid,
        "profile": ""
      });

      Navigator.push(
          context,
          MaterialPageRoute(
              settings: const RouteSettings(name: "/MyPage"),

              //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
              builder: (BuildContext context) => MyPages()));
      //Navigator.pushNamedAndRemoveUntil(context, "/MyPage", (_) => false);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "ごめんなさい。。このベールアドレス、パスワードは登録されています。もう一度別のもので試してみてください！！");
    }
  }
}
