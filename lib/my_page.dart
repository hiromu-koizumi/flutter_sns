import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/follow_page.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/main.dart';
import 'package:flutter_cos/post.dart';
import 'package:flutter_cos/setting.dart';
import 'dart:math' as math;

//格子状に表示する
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

DocumentSnapshot userInformation;
//FirebaseUser firebaseUser;
final FirebaseAuth _auth = FirebaseAuth.instance;

class MyPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email, password, name;

  @override
  Widget build(BuildContext context) {
//    DocumentReference _userReference;
//    _userReference = Firestore.instance.collection('users').document(firebaseUser.uid).collection("transaction").document();

    if (firebaseUser.isAnonymous) {
      //匿名ユーザーのときの処理
      print('登録してない');

      return AlertDialog(
        title: Text("ログイン/登録"),
        content: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.perm_identity),
                    labelText: 'Name',
                  ),
                  onSaved: (String value) {
                    name = value;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Nameは必須入力です';
                    }
                  },
                ),
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
                    if (value.length < 6) {
                      return 'Passwordは6桁以上です';
                    }
                  },
                )
              ],
            )),

        //ボタン
        actions: <Widget>[
//            FlatButton(
//              child: const Text('キャンセル'),
//              onPressed: () {
//                Navigator.pop(context);
//              },
//            ),
          FlatButton(
            child: const Text('登録'),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                _createUser(context, email, password, name);
              }
            },
          ),
          FlatButton(
              child: const Text('ログイン'),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  _signIn(context, email, password);
                }
              }),
        ],
      );
    } else {
      return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: Text('マイページ'), actions: <Widget>[
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  //画面遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        settings: const RouteSettings(name: "/setting"),
                        builder: (BuildContext context) =>
                            SettingPage(userInformation) //null 編集機能付けるのに必要っぽい
                        ),
                  );
                },
              ),
            ]),
            body: MyPages()),
      );
    }
  }
}

class MyPages extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

//名前を表示するためにつけた
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class _MyPageState extends State<MyPages> {
//class CollapsingList extends StatelessWidget {
  SliverPersistentHeader makeHeader() {
    return SliverPersistentHeader(
      //スクロールしたときにヘッダーが消える
      pinned: false,

      delegate: _SliverAppBarDelegate(
        minHeight: 60.0,
        maxHeight: 150.0,
        child: Container(
          margin: EdgeInsets.all(16.0),
          //color: Colors.white, child: Center(child: userName())
          child: Row(
            children: <Widget>[
              InkWell(
                onTap: () {
                  print('photoChange');
                },
                // child: Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[Icon(Icons.android), userName()]),
              ),
              Expanded(
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left:50, right: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      settings:
                                          const RouteSettings(name: "/FollowPage"),

                                      //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
                                      builder: (BuildContext context) =>
                                          MyFollowPage()));
                            },
                            child: Column(
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('フォロー'),
                                followingNumber()
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      settings:
                                      const RouteSettings(name: "/FollowPage"),

                                      //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
                                      builder: (BuildContext context) =>
                                          MyFollowPage()));
                            },
                            child: Column(
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('フォロワー'),
                                followersNumber()
                              ],
                            ),
                          ),
//                          Expanded(
//                            child: Column(
//                              children: <Widget>[],
//                            ),
//                          ),
                        ],
                      ),
                    ),
//                    Container(
//                        margin: const EdgeInsets.only(bottom: 4.0),
//                        child: userName()),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // getFollowing();

    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .collection('posts')
            .orderBy("time", descending: true)
            //.where("userId", isEqualTo: firebaseUser.uid)
            .snapshots(),

        //streamが更新されるたびに呼ばれる
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          return CustomScrollView(
            slivers: <Widget>[
              makeHeader(),
              SliverStaggeredGrid.countBuilder(
                crossAxisCount: 2,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot =
                      snapshot.data.documents[index];
                  return _MyPageList(context, documentSnapshot);
                },
                staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
                itemCount: snapshot.data.documents.length,
              ),
            ],
          );
        });
  }

  //投稿表示する処理
  Widget _MyPageList(BuildContext context, DocumentSnapshot document) {
    return Padding(
        padding: EdgeInsets.only(bottom: 30),
        child: Card(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            //写真表示

            ImageUrl(imageUrl: document['url']),

            ListTile(
                leading: const Icon(Icons.android),
                title: Text(document['comment']),

                //substringで表示する時刻を短縮している
                subtitle: Text(document['time'].toString().substring(0, 10))),

            //編集ボタン
            ButtonTheme.bar(
              child: ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: const Text('編集'),
                    onPressed: () {
                      print("編集ボタンを押しました");
                      //編集処理,画面遷移
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            settings: const RouteSettings(name: "/edit"),

                            //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
                            builder: (BuildContext context) =>
                                PostPage(document)),
                      );
                    },
                  )
                ],
              ),
            )
          ]),
        ));
  }

  Widget userName() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .collection("profiles")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          userInformation = snapshot.data.documents[0];

          if (snapshot.data.documents[0]['profile'] != null) {
            return Column(children: <Widget>[
              Text(snapshot.data.documents[0]['userName']),
              //Text(snapshot.data.documents[0]['profile']),
            ]);
          } else {
            return Text(snapshot.data.documents[0]['userName']);
          }
        });
  }

  //following数をDBから取得し表示
  Widget followingNumber() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .collection("following")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          //userInformation = snapshot.data.documents[0];

          return Text('${snapshot.data.documents.length}');
        });
  }

  Widget followersNumber() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .collection("followers")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          //userInformation = snapshot.data.documents[0];

          return Text('${snapshot.data.documents.length}');
        });
  }
}

//メールアドレスとパスワードでログインする処理
void _signIn(BuildContext context, String email, String password) async {
  try {
    //ログインしている
    await _auth.signInWithEmailAndPassword(email: email, password: password);

    Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
  } catch (e) {
    Fluttertoast.showToast(msg: "Firebaseのログインに失敗しました");
  }
}

//メールアドレスとパスワードで新規ユーザー作成
void _createUser(
    BuildContext context, String email, String password, String name) async {
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

    await _userReference.setData({"userName": name});

    Navigator.push(
        context,
        MaterialPageRoute(
            settings: const RouteSettings(name: "/MyPage"),

            //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
            builder: (BuildContext context) => MyPage()));
    //Navigator.pushNamedAndRemoveUntil(context, "/MyPage", (_) => false);
  } catch (e) {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    firebaseUser = await _auth.currentUser();

    DocumentReference _userReference;
    _userReference = Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection("profiles")
        .document();

    await _userReference.setData({"userName": name});

    Navigator.push(
        context,
        MaterialPageRoute(
            settings: const RouteSettings(name: "/MyPage"),

            //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
            builder: (BuildContext context) => MyPage()));
    Fluttertoast.showToast(msg: "Firebaseの登録に失敗しました");
    //Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);

  }
}
