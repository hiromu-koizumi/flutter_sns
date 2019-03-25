import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/main.dart';
import 'package:flutter_cos/post_details.dart';
import 'package:flutter_cos/user_follow_page.dart';
import 'dart:math' as math;

//格子状に表示する
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

DocumentSnapshot userInformation;
//FirebaseUser firebaseUser;
final FirebaseAuth _auth = FirebaseAuth.instance;

class UserPage extends StatelessWidget {
  UserPage(this.userId);

  final userId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('ユーザー'),
            leading: IconButton(
                //なぜか戻るボタン付が生成されないので自分で実装。これなくても戻るボタン表示されるはず
                icon: Icon(Icons.keyboard_backspace),
                onPressed: () {
                  print('戻るボタンを押しました');
                  Navigator.pop(context);
                }),
          ),
          body: UserPages(userId)),
    );
  }
}

class UserPages extends StatefulWidget {
  UserPages(this.userId);

  final userId;

  //documentにはログインしているユーザーではなくてこのページのユーザーの情報が入っている
  @override
  _UserPageState createState() => _UserPageState(userId);
}

class _UserPageState extends State<UserPages> {
  _UserPageState(this.userId);

  final userId;

  //widget.documentにはこのページのユーザーの情報が格納されている.
  //_followReferenceは自分のDBの保存先
  //フォローとフォロー解除の処理をif文で書いている。firebaseのfollowに保存されていればdeleteの処理。なければ保存の処理。
  followCheck(_myFollowReference, _othersFollowReference,_noticeFollowRef) async {
    String checkFollow;
    String toFollowName;
    String isFollowedName;

    //このページのユーザーは自分はフォローしているか確認するために、自分のDBに保存されているuserIDの中からこのページのユーザーのユーザーIDと一致したユーザーの名前を変数checkFollowに格納して確認している。フォローしていなければcheckFollowにはnullが入る
    Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection("following")
        .where("userId", isEqualTo: widget.userId)
        .snapshots()
        .listen((data) =>
            data.documents.forEach((doc) => checkFollow = (doc["userName"])));

    //stream使ってもっと簡潔な処理がかけると思う
    //処理を遅らせないと変数に名前保存する前にfirebaseに保存の処理を行ってしまう。ホントはawait使えばできると思う。でもうまくできないから処理を遅らして対処している
    Future.delayed(new Duration(seconds: 1), () {
      if (checkFollow != null) {
        _myFollowReference.delete();
        _othersFollowReference.delete();
        print('delete');
      } else {
        //followされた人の名前をisFollowedNameに代入している
        Firestore.instance
            .collection('users')
            .where('userId', isEqualTo: userId)
            .snapshots()
            .listen((data) => data.documents
                .forEach((doc) => isFollowedName = (doc["userName"])));

        //followした人の名前をtoFollowNameに代入している
        Firestore.instance
            .collection('users')
            .where('userId', isEqualTo: firebaseUser.uid)
            .snapshots()
            .listen((data) => data.documents
                .forEach((doc) => toFollowName = (doc["userName"])));

        //処理を遅らせないと変数に名前保存する前にfirebaseに保存の処理を行ってしまう。ホントはawait使えばできると思う。でもうまくできないから処理を遅らして対処している
        Future.delayed(new Duration(seconds: 1), () {
          //ホントはuserId保存しなくてもいいはず。でもドキュメントネームをwhere("userId", isEqualTo: firebaseUser.uid)で取り出す方法がわからないからこうしている
          //ログインユーザーのDBにこのページのユーザー情報を保存。
          _myFollowReference.setData({
            "userName": isFollowedName,
            "userId": widget.userId,
            "time": DateTime.now()
          });

          //このページのユーザーのDBにログインユーザーの情報を保存
          _othersFollowReference.setData({
            "userName": toFollowName,
            "userId": firebaseUser.uid,
            "time": DateTime.now()
          });
          _noticeFollowRef.setData({
            "userId": firebaseUser.uid,
            "time": DateTime.now(),
            "follow": "fol",
          });
        });
        print('followしたよ');
      }
    });
  }

  //フォローボタンの表示の切り替え処理。
  followButton(_myFollowReference, _othersFollowReference,_noticeFollowRef) {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('users')
              .document(firebaseUser.uid)
              .collection("following")
              .where("userId", isEqualTo: widget.userId)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');

            //ユーザー登録していない人はフォローボタン表示しないようにしている
            if (firebaseUser.isAnonymous) {
              return Text("");
            } else if (snapshot.data.documents.length == 0) {
              //フォローしていないときの処理
              return RaisedButton(
                child: Text('フォローする'),
                onPressed: () {
                  print('${snapshot.data.documents.length}');
                  followCheck(_myFollowReference, _othersFollowReference,_noticeFollowRef);
                },
              );
            } else {
              //フォローしているときの処理
              return RaisedButton(
                child: Text('フォロー中'),
                onPressed: () {
                  followCheck(_myFollowReference, _othersFollowReference,_noticeFollowRef);
                },
              );
            }
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    DocumentReference _myFollowReference;
    _myFollowReference = Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection("following")
        .document(userId);

    DocumentReference _othersFollowReference;
    _othersFollowReference = Firestore.instance
        .collection('users')
        .document(widget.userId)
        .collection("followers")
        .document(firebaseUser.uid);

    DocumentReference _noticeFollowRef;
    _noticeFollowRef = Firestore.instance
        .collection('users')
        .document(widget.userId)
        .collection("notice")
        .document();

    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(widget.userId)
            .collection('posts')
            .orderBy("time", descending: true)
            //.where("userId", isEqualTo: firebaseUser.uid)
            .snapshots(),

        //streamが更新されるたびに呼ばれる
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          return CustomScrollView(
            slivers: <Widget>[
              // makeHeader(_myFollowReference, _othersFollowReference),
              userProfileHeader(_myFollowReference, _othersFollowReference,_noticeFollowRef),
              SliverStaggeredGrid.countBuilder(
                crossAxisCount: 2,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot =
                      snapshot.data.documents[index];
                  return _userPageList(context, documentSnapshot);
                },
                staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
                itemCount: snapshot.data.documents.length,
              ),
            ],
          );
        });
  }

  userProfileHeader(_myFollowReference, _othersFollowReference,_noticeFollowRef) {
    return SliverAppBar(
        expandedHeight: 150.0,
        backgroundColor: Colors.white,
        flexibleSpace: FlexibleSpaceBar(
            background: Container(
          margin: EdgeInsets.all(16.0),
          //color: Colors.white, child: Center(child: userName())
          child: Row(
            children: <Widget>[
              InkWell(
                  onTap: () {
                    print('photoChange');
                  },
                  // child: Expanded(
                  child: userProfile()),
              Expanded(
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(left: 50, right: 50),
                        child: Column(children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          settings: const RouteSettings(
                                              name: "/FollowPage"),

                                          //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
                                          builder: (BuildContext context) =>
                                              UserFollowPage(widget.userId)));
                                },
                                child: Column(
                                  children: <Widget>[
                                    Text('フォロー'),
                                    _followingNumber()
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          settings: const RouteSettings(
                                              name: "/FollowPage"),

                                          //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
                                          builder: (BuildContext context) =>
                                              UserFollowPage(widget.userId)));
                                },
                                child: Column(
                                  children: <Widget>[
                                    Text('フォロワー'),
                                    _followersNumber()
                                  ],
                                ),
                              ),
                            ],
                          ),
                          followButton(
                              _myFollowReference, _othersFollowReference,_noticeFollowRef)
                        ])),
                  ],
                ),
              ),
            ],
          ),
        )));
  }

  //投稿表示する処理
  Widget _userPageList(BuildContext context, DocumentSnapshot document) {
    return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                settings: const RouteSettings(name: "/postDetails"),

                //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
                builder: (BuildContext context) => PostDetails(document)),
          );
        },
        child: Card(
          //写真表示
          child: ImageUrl(imageUrl: document['url']),
        ));
  }

  Widget userProfile() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .where('userId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          if (snapshot.data.documents.length == 0) return Text('NONAME');
          userInformation = snapshot.data.documents[0];

          return Column(
            children: <Widget>[
              Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new NetworkImage(
                              snapshot.data.documents[0]['photoUrl'])))),
              Text(snapshot.data.documents[0]['userName']),
            ],
          );
        });
  }

  Widget _followingNumber() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(widget.userId)
            .collection("following")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          //userInformation = snapshot.data.documents[0];

          return Text('${snapshot.data.documents.length}');
        });
  }

  Widget _followersNumber() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(widget.userId)
            .collection("followers")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          //userInformation = snapshot.data.documents[0];

          return Text('${snapshot.data.documents.length}');
        });
  }
}
