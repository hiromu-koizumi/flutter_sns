//スプラッシュ画面

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/other_pages/login_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //ログインしているか確認
    _getUser(context);

    return Scaffold(
      //backgroundColor: Colors.pinkAccent,
      body: Center(
        child: FractionallySizedBox(
          //スプラッシュ画面の画像
          child: Image.asset('res/image/splash.jpg'),
          heightFactor: 0.4,
          widthFactor: 0.4,
        ),
      ),
    );
  }

  //ログインしているか確認する処理
  void _getUser(BuildContext context) async {
    try {
      firebaseUser = await _auth.currentUser();
      if (firebaseUser == null) {
        await _auth.signInAnonymously();
        firebaseUser = await _auth.currentUser();
      }

      //タイムラインに画面遷移
      Navigator.pushReplacementNamed(context, "/bottombar");
    } catch (e) {
      //エラー時の処理
      Fluttertoast.showToast(msg: "Firebaseとの接続に失敗しました。");
    }
  }
}
