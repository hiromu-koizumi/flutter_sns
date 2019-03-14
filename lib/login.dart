//splash画面処理
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/main.dart';
import 'package:flutter_cos/my_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

//class LoginScreen extends StatelessWidget {
//  Widget build(context) {
//
//    //Provider.dartを呼び出している
//    final bloc = Provider.of(context);
//    return Container(
//      margin: EdgeInsets.all(20.0),
//      child: Column(
//        children: [
//          emailField(bloc),
//          passwordField(bloc),
//          Container(margin: EdgeInsets.only(top: 25.0)),
//          submitButton(bloc),
//        ],
//      ),
//    );
//  }
//
//  Widget emailField(Bloc bloc) {
//    return StreamBuilder(
//      stream: bloc.email,
//      builder: (context, snapshot) {
//        return TextField(
//          onChanged: bloc.changeEmail,
//          keyboardType: TextInputType.emailAddress,
//          decoration: InputDecoration(
//            hintText: 'you@example.com',
//            labelText: 'Email Address',
//            errorText: snapshot.error,
//          ),
//        );
//      },
//    );
//  }
//
//  Widget passwordField(Bloc bloc) {
//    return StreamBuilder(
//      stream: bloc.password,
//      builder: (context, snapshot) {
//        return TextField(
//          onChanged: bloc.changePassword,
//          decoration: InputDecoration(
//            hintText: 'password',
//            labelText: 'password',
//            errorText: snapshot.error,
//          ),
//        );
//      },
//    );
//  }
//
//  Widget submitButton(Bloc bloc)  {
//    return StreamBuilder(
//        stream: bloc.submitValid,
//        builder: (context, snapshot) {
//          return RaisedButton(
//            child: Text('Login'),
//            color: Colors.blue,
//            onPressed:() {
//              return bloc.submit().then(
//                  Future.delayed(new Duration(seconds: 2), () {
//                Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                      settings: const RouteSettings(name: "/MyPage"),
//
//                      //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
//                      builder: (BuildContext context) => MyPage()));
//                  })
//              );
//            });
//        });
//  }
//}

FirebaseUser firebaseUser;
final FirebaseAuth _auth = FirebaseAuth.instance;

//スプラッシュ画面
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


Widget loginScreen(BuildContext context) {
  String email, password;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  return new Center(
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
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              RaisedButton(
                child: const Text('ユーザー登録'),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    _createUser(context, email, password);
                  }

//                  var email = emailInputController.text;
//                  var password = passwordInputController.text;
                  // ここにログイン処理を書く
                  //_createUser(context, email, password);
                },
              ),
              const SizedBox(width: 24.0),
              RaisedButton(
                child: const Text('ログイン'),
                onPressed: () {
//                  var email = emailInputController.text;
//                  var password = passwordInputController.text;
//                  // ここにログイン処理を書く
//                  _signIn(context, email, password);
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
  );
}

//class LoginScreen extends StatelessWidget {
//
//  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//  String email, password;
//  Widget build(context) {
//
//    return Container(
//        margin: EdgeInsets.all(20.0),
//      child: Column(
//        children: [
//          emailField(),
//          passwordField(),
//          Container(margin: EdgeInsets.only(top: 10.0)),
//          submitButton(context),
//        ],
//      ),
//    );
//  }
//
//  Widget emailField() {
//    return TextFormField(
//              decoration: const InputDecoration(
//                icon: const Icon(Icons.mail),
//                labelText: 'Email',
//              ),
//              onSaved: (String value) {
//                email = value;
//              },
//              validator: (value) {
//                if (value.isEmpty) {
//                  return 'Emailは必須入力です';
//                }
//              },
//            );
//  }
//
//  Widget passwordField() {
//    return  TextFormField(
//              obscureText: true,
//              decoration: const InputDecoration(
//                icon: const Icon(Icons.vpn_key),
//                labelText: 'Password',
//              ),
//              onSaved: (String value) {
//                password = value;
//              },
//              validator: (value) {
//                if (value.isEmpty) {
//                  return 'Passwordは必須入力です';
//                }
//                if (value.length < 6) {
//                  return 'Passwordは6桁以上です';
//                }
//              },
//            );
//  }
//
//  Widget submitButton(BuildContext context) {
//    return FlatButton(
//        child: const Text('登録'),
//        onPressed: () {
//          if (_formKey.currentState.validate()) {
//            _formKey.currentState.save();
//            _createUser(context, email, password);
//          }
//        },
//      );
//  }

//  void _createUser(
//    BuildContext context, String email, String password) async {
//  try {
//    //Authenticationにユーザーを作成している
//    await _auth.createUserWithEmailAndPassword(
//        email: email, password: password);
//
//    firebaseUser = await _auth.currentUser();
//
//    DocumentReference _userReference;
//    _userReference = Firestore.instance
//        .collection('users')
//        .document(firebaseUser.uid)
//        .collection("profiles")
//        .document();
//
//    await _userReference.setData({"userName": "NONAME"});
//
//    Navigator.push(
//        context,
//        MaterialPageRoute(
//            settings: const RouteSettings(name: "/MyPage"),
//
//            //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
//            builder: (BuildContext context) => MyPage()));
//    //Navigator.pushNamedAndRemoveUntil(context, "/MyPage", (_) => false);
//  } catch (e) {
//    await _auth.createUserWithEmailAndPassword(
//        email: email, password: password);
//
//    firebaseUser = await _auth.currentUser();
//
//    DocumentReference _userReference;
//    _userReference = Firestore.instance
//        .collection('users')
//        .document(firebaseUser.uid)
//        .collection("profiles")
//        .document();
//
//    await _userReference.setData({"userName": "NONAME"});
//
//    Navigator.push(
//        context,
//        MaterialPageRoute(
//            settings: const RouteSettings(name: "/MyPage"),
//
//            //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
//            builder: (BuildContext context) => MyPage()));
//    Fluttertoast.showToast(msg: "Firebaseの登録に失敗しました");
//    //Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
//
//  }
//}
//}

//
// showBasicDialog(BuildContext context) {
//  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//  String email, password;
//  return AlertDialog(
//    title: Text("ログイン/登録"),
//    content: Form(
//        key: _formKey,
//        child: Column(
//          children: <Widget>[
////                TextFormField(
////                  decoration: const InputDecoration(
////                    icon: const Icon(Icons.perm_identity),
////                    labelText: 'Name',
////                  ),
////                  onSaved: (String value) {
////                    name = value;
////                  },
////                  validator: (value) {
////                    if (value.isEmpty) {
////                      return 'Nameは必須入力です';
////                    }
////                  },
////                ),
//            TextFormField(
//              decoration: const InputDecoration(
//                icon: const Icon(Icons.mail),
//                labelText: 'Email',
//              ),
//              onSaved: (String value) {
//                email = value;
//              },
//              validator: (value) {
//                if (value.isEmpty) {
//                  return 'Emailは必須入力です';
//                }
//              },
//            ),
//            TextFormField(
//              obscureText: true,
//              decoration: const InputDecoration(
//                icon: const Icon(Icons.vpn_key),
//                labelText: 'Password',
//              ),
//              onSaved: (String value) {
//                password = value;
//              },
//              validator: (value) {
//                if (value.isEmpty) {
//                  return 'Passwordは必須入力です';
//                }
//                if (value.length < 6) {
//                  return 'Passwordは6桁以上です';
//                }
//              },
//            )
//          ],
//        )),
//
//    //ボタン
//    actions: <Widget>[
////            FlatButton(
////              child: const Text('キャンセル'),
////              onPressed: () {
////                Navigator.pop(context);
////              },
////            ),
//      FlatButton(
//        child: const Text('登録'),
//        onPressed: () {
//          if (_formKey.currentState.validate()) {
//            _formKey.currentState.save();
//            _createUser(context, email, password);
//          }
//        },
//      ),
//      FlatButton(
//          child: const Text('ログイン'),
//          onPressed: () {
//            if (_formKey.currentState.validate()) {
//              _formKey.currentState.save();
//              _signIn(context, email, password);
//            }
//          }),
//    ],
//  );
//}
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
    _userReference = Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection("profiles")
        .document();

    await _userReference.setData({
      "userName": "NONAME",
      "photoUrl": "https://www.cosco-times.com/wp-content/uploads/2019/01/ponyoshida.png"
    });

    Navigator.push(
        context,
        MaterialPageRoute(
            settings: const RouteSettings(name: "/MyPage"),

            //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
            builder: (BuildContext context) => MyPages()));
    //Navigator.pushNamedAndRemoveUntil(context, "/MyPage", (_) => false);
  } catch (e) {

    Fluttertoast.showToast(msg: "登録に失敗しました。。");

  }
}
