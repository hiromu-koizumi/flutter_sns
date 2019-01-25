




//splash画面処理
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/main.dart';
import 'package:fluttertoast/fluttertoast.dart';

FirebaseUser firebaseUser;
final FirebaseAuth _auth = FirebaseAuth.instance;

//スプラッシュ画面
class Splash extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    //ログインしているか確認
    _getUser(context);

    return Scaffold(
      backgroundColor: Colors.pinkAccent,
      body: Center(
          child:
          FractionallySizedBox(
            //スプラッシュ画面の画像
            child: Image.asset('res/image/splash.jpg'),
            heightFactor: 0.4,
            widthFactor: 0.4,
          ),
      ),
    );
  }
}


//ログインしているか確認する処理
void _getUser(BuildContext context) async {
  try{
    firebaseUser = await _auth.currentUser();
    if (firebaseUser == null) {
      await _auth.signInAnonymously();
      firebaseUser = await _auth.currentUser();
    }

    //タイムラインに画面遷移
    Navigator.pushReplacementNamed(context, "/timeline");
  }catch(e){
    //エラー時の処理
    Fluttertoast.showToast(msg: "Firebaseとの接続に失敗しました。");
  }
}

void showBasicDialog(BuildContext context) {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email, password;

  //匿名アカウントと永久アカウントの処理を分けてる
  if(firebaseUser.isAnonymous) {
    showDialog(
      context: context,
      builder: (BuildContext) => AlertDialog(
        title: Text("ログイン/登録ダイアログ"),
        content: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.mail),
                  labelText: 'Email',
                ),
                onSaved: (String value) {
                  email = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Emailは必須入力です';
                  }
                },
              ),

              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.vpn_key),
                  labelText: 'Password',
                ),
                onSaved: (String value) {
                  password = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Passwordは必須入力です';
                  }
                  if(value.length<6){
                    return 'Passwordは6桁以上です';
                  }
                },
              )
            ],
          )
        ),

        //ボタン
        actions: <Widget>[
          FlatButton(
            child: const Text('キャンセル'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          FlatButton(
            child: const Text('登録'),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                _createUser(context,email,password);
              }
            },
          ),

          FlatButton(
            child: const Text('ログイン'),
            onPressed: () {
              if (_formKey.currentState.validate()){
                _formKey.currentState.save();
                _signIn(context,email,password);
              }
            }
          ),
        ],
      ),
    );
  }else{
    showDialog(
      context: context,
      builder: (BuildContext) =>
          AlertDialog(
            title: const Text('確認ダイアログ'),
            content: Text(firebaseUser.email + "でログインしています"),
            actions: <Widget>[
              FlatButton(
                child: const Text('キャンセル'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: const Text('ログアウト'),
                onPressed: () {
                  _auth.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, "/",(_) => false);
                }
              ),
            ],
          ),
    );
  }
}


//メールアドレスとパスワードでログインする処理
void _signIn(BuildContext context,String email, String password) async {
  try {
    //ログインしている
    await _auth.signInWithEmailAndPassword(email: email, password: password);

    Navigator.pushNamedAndRemoveUntil(context,"/", (_) => false);
  }catch(e){
    Fluttertoast.showToast(msg: "Firebaseのログインに失敗しました");
  }
}

//メールアドレスとパスワードで新規ユーザー作瀬尾
void _createUser(BuildContext context, String email, String password) async {
  try {
    //作成している
    await _auth.createUserWithEmailAndPassword(email: email, password: password);

    Navigator.pushNamedAndRemoveUntil(context, "?", (_) => false);
  }catch(e){
    Fluttertoast.showToast(msg: "Firebaseの登録に失敗しました");
  }
}