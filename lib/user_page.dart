import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

class UserPage extends StatelessWidget{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email, password, name ;

  UserPage(this.document);
  final DocumentSnapshot document;


  @override
  Widget build(BuildContext context) {
//    DocumentReference _userReference;
//    _userReference = Firestore.instance.collection('users').document(firebaseUser.uid).collection("transaction").document();


      return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: Text('ユーザー'), leading:
              IconButton(
                   //なぜか戻るボタン付が生成されないので自分で実装。これなくても戻るボタン表示されるはず
                  icon: Icon(Icons.keyboard_backspace),
                  onPressed: () {
                    print('戻るボタンを押しました');
                    Navigator.pop(context);
                  }),

            ),
            body: UserPages(document)),
      );
    }}


class UserPages extends StatefulWidget {
  UserPages(this.document);
  final DocumentSnapshot document;

  //documentにはログインしているユーザーではなくてこのページのユーザーの情報が入っている
  @override
  _UserPageState createState() => _UserPageState();
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


class _UserPageState extends State<UserPages> {
//class CollapsingList extends StatelessWidget {
  SliverPersistentHeader makeHeader(_myFollowReference,_othersFollowReference) {
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
              Icon(
                Icons.android
              ),
              Expanded(
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 4.0),
                      child: userName()
                    ),
                    followButton(_myFollowReference,_othersFollowReference)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }



//   userNameSave(_followReference) async {
//        Firestore.instance
//            .collection('users')
//            .document(widget.document['userId'])
//            .collection("profiles")
//            .snapshots()
//            .listen((data) =>
//            data.documents.forEach((doc) => addUserName = (doc["userName"])));
//
//        //処理を遅らせないと変数に名前保存する前にfirebaseに保存の処理を行ってしまう。ホントはawait使えばできると思う。でもうまくできないから処理を遅らして対処している
//        Future.delayed(new Duration(seconds: 1), () {
//          //ホントはuserId保存しなくてもいいはず。でもドキュメントネームをwhere("userId", isEqualTo: firebaseUser.uid)で取り出す方法がわからないからこうしている
//            _followReference.setData({
//              "userName": addUserName,
//              "userId": widget.document['userId']
//            });
//        });
//  }
  //widget.documentにはこのページのユーザーの情報が格納されている.
  //_followReferenceは自分のDBの保存先
  //フォローとフォロー解除の処理をif文で書いている。firebaseのfollowに保存されていればdeleteの処理。なければ保存の処理。
  followCheck(_myFollowReference,_othersFollowReference) async {
        String checkFollow;
        String toFollowName;
        String isFollowedName;

        //このページのユーザーは自分はフォローしているか確認するために、自分のDBに保存されているuserIDの中からこのページのユーザーのユーザーIDと一致したユーザーの名前を変数checkFollowに格納して確認している。フォローしていなければcheckFollowにはnullが入る
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .collection("following")
            .where("userId", isEqualTo: widget.document['userId'])
            .snapshots()
            .listen((data) =>
            data.documents.forEach((doc) => checkFollow = (doc["userName"])));

        //stream使ってもっと簡潔な処理がかけると思う
        //処理を遅らせないと変数に名前保存する前にfirebaseに保存の処理を行ってしまう。ホントはawait使えばできると思う。でもうまくできないから処理を遅らして対処している
        Future.delayed(new Duration(seconds: 1), ()
        {
          if (checkFollow != null){
            _myFollowReference.delete();
            _othersFollowReference.delete();
            print('delete');
          }else{
            //followされた人の名前をisFollowedNameに代入している
            Firestore.instance
                .collection('users')
                .document(widget.document['userId'])
                .collection("profiles")
                .snapshots()
                .listen((data) =>
                data.documents.forEach((doc) => isFollowedName = (doc["userName"])));

            //followした人の名前をtoFollowNameに代入している
            Firestore.instance
                .collection('users')
                .document(firebaseUser.uid)
                .collection("profiles")
                .snapshots()
                .listen((data) =>
                data.documents.forEach((doc) => toFollowName = (doc["userName"])));

            //処理を遅らせないと変数に名前保存する前にfirebaseに保存の処理を行ってしまう。ホントはawait使えばできると思う。でもうまくできないから処理を遅らして対処している
            Future.delayed(new Duration(seconds: 1), () {
              //ホントはuserId保存しなくてもいいはず。でもドキュメントネームをwhere("userId", isEqualTo: firebaseUser.uid)で取り出す方法がわからないからこうしている
              //ログインユーザーのDBにこのページのユーザー情報を保存。
              _myFollowReference.setData({
                "userName": isFollowedName,
                "userId": widget.document['userId'],
                "time": DateTime.now()
              });

              //このページのユーザーのDBにログインユーザーの情報を保存
              _othersFollowReference.setData({
                "userName": toFollowName,
                "userId": firebaseUser.uid,
                "time": DateTime.now()
              });


            });
            print('followしたよ');




          }
//          _followReference.setData({
//            "userName": ('$addUserName'),
//          });
        });
  }

  //フォローボタンの表示の切り替え処理。
  followButton(_myFollowReference,_othersFollowReference){
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: StreamBuilder<QuerySnapshot>(

          stream: Firestore.instance
              .collection('users')
              .document(firebaseUser.uid)
              .collection("following")
              .where("userId", isEqualTo: widget.document['userId'])
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
            if (snapshot.data.documents.length == 0) return RaisedButton(child: Text('フォローする'),
              onPressed: () {
                print('${snapshot.data.documents.length}');
                followCheck(_myFollowReference,_othersFollowReference);
              },
            );
            return  RaisedButton(child: Text('フォロー中'),
              onPressed: () {
                followCheck(_myFollowReference,_othersFollowReference);
              },
            );
          }),
    );

  }

  @override
  Widget build(BuildContext context) {


    DocumentReference _myFollowReference;
    _myFollowReference = Firestore.instance.collection('users').document(firebaseUser.uid).collection("following").document(widget.document['userId']);

    DocumentReference _othersFollowReference;
    _othersFollowReference = Firestore.instance.collection('users').document(widget.document['userId']).collection("followers").document(firebaseUser.uid);



    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(widget.document['userId'])
            .collection('posts')
            .orderBy("time", descending: true)
        //.where("userId", isEqualTo: firebaseUser.uid)
            .snapshots(),


        //streamが更新されるたびに呼ばれる
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          return CustomScrollView(
            slivers: <Widget>[
              makeHeader(_myFollowReference,_othersFollowReference),
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
                            builder: (BuildContext context) => PostPage(document)),
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
            .document(widget.document['userId'])
            .collection("profiles")
            .snapshots(),

        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          userInformation = snapshot.data.documents[0];

          if (snapshot.data.documents[0]['profile'] != null) {
            return Column(children: <Widget>[
              Text(snapshot.data.documents[0]['userName']),
              Text(snapshot.data.documents[0]['profile']),
            ]);
          }else{
            return Text(snapshot.data.documents[0]['userName']);
          }
        }
    );
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
//void _createUser(BuildContext context, String email, String password,String name) async {
//
//
//  try {
//    //Authenticationにユーザーを作成している
//    await _auth.createUserWithEmailAndPassword(
//        email: email, password: password);
//
//    firebaseUser = await _auth.currentUser();
//
//    DocumentReference _userReference;
//    _userReference = Firestore.instance.collection('users').document(firebaseUser.uid).collection("transaction").document();
//
//
//    await _userReference.setData({
//      "userName": name
//    });
//
//
//    Navigator.push(context,
//        MaterialPageRoute(
//            settings: const RouteSettings(name: "/MyPage"),
//
//            //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
//            builder: (BuildContext context) =>
//                MyPage()));
//    //Navigator.pushNamedAndRemoveUntil(context, "/MyPage", (_) => false);
//  } catch (e) {
//    await _auth.createUserWithEmailAndPassword(
//        email: email, password: password);
//
//    firebaseUser = await _auth.currentUser();
//
//    DocumentReference _userReference;
//    _userReference = Firestore.instance.collection('users').document(firebaseUser.uid).collection("transaction").document();
//
//    await _userReference.setData({
//      "userName": name
//    });
//
//
//    Navigator.push(context,
//        MaterialPageRoute(
//            settings: const RouteSettings(name: "/MyPage"),
//
//            //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
//            builder: (BuildContext context) =>
//                MyPage()));
//    Fluttertoast.showToast(msg: "Firebaseの登録に失敗しました");
//    //Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
//
//  }
//}
//
//
