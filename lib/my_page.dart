import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/follow_page.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/main.dart';
import 'package:flutter_cos/mypost_details.dart';
import 'package:flutter_cos/post.dart';
import 'package:flutter_cos/setting.dart';
import 'package:flutter_cos/tab_setting_page.dart';
import 'package:flutter_cos/user_profire.dart';
import 'dart:math' as math;

//格子状に表示する
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

DocumentSnapshot userInformation;

class MyPages extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPages> {
  userProfileHeader() {
    return SliverAppBar(
        expandedHeight: 180.0,
        backgroundColor: Colors.white,
        flexibleSpace: FlexibleSpaceBar(
            background: Container(
          margin: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  userImage(),

                  //中央に配置するために付けている
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                                        MyFollowPage()));
                          },
                          child: Column(
                            children: <Widget>[Text('フォロー'), followingNumber()],
                          ),
                        ),
                        SizedBox(
                          width: 40,
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
                      ],
                    ),
                  ),
                ],
              ),
              userProfile(),
            ],
          ),
        )));
  }

  @override
  Widget build(BuildContext context) {
    if (firebaseUser.isAnonymous) {
      return loginPage(context);
    } else {
      return Scaffold(
          appBar: AppBar(title: Text('マイページ'), actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add_a_photo),
              onPressed: () {
                print("mypage");

                //画面遷移
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: const RouteSettings(name: "/new"),
                      builder: (BuildContext context) =>
                          PostPage(null) //null 編集機能付けるのに必要っぽい
                      ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                //画面遷移
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: const RouteSettings(name: "/setting"),
                      builder: (BuildContext context) =>
                          SettingPage(userInformation) //
                      ),
                );
              },
            ),
          ]),
          body: postStream());
    }
  }

  postStream() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .collection('posts')
            .orderBy("time", descending: true)
            .snapshots(),

        //streamが更新されるたびに呼ばれる
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          return CustomScrollView(
            slivers: <Widget>[
              userProfileHeader(),
              SliverStaggeredGrid.countBuilder(
                crossAxisCount: 2,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot =
                      snapshot.data.documents[index];
                  return _myPageList(context, documentSnapshot);
                },
                staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
                itemCount: snapshot.data.documents.length,
              ),
            ],
          );
        });
  }

  //投稿表示する処理
  Widget _myPageList(BuildContext context, DocumentSnapshot document) {
//    return Padding(
//        padding: EdgeInsets.only(bottom: 1),
    return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                settings: const RouteSettings(name: "/postDetails"),

                //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
                builder: (BuildContext context) => MyPostDetails(document)),
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
            .where('userId', isEqualTo: firebaseUser.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          userInformation = snapshot.data.documents[0];

          return Flexible(
              child: Column(
            children: <Widget>[
              //左端に寄せるためにRow使用している。もっと良いコードあるはず。
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    snapshot.data.documents[0]['userName'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  //テキストを折り返すためにFlexible、softWrap: trueをつけている
                  //上でFlexible使用しているがこちらでもつけないと折り返せなかった。
                  Flexible(
                    child: Container(
                      child: Text(
                        snapshot.data.documents[0]['profile'],
                        softWrap: true,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ));
        });
  }

  Widget userImage() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .where('userId', isEqualTo: firebaseUser.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          userInformation = snapshot.data.documents[0];

          return Material(
            child: Image.network(
              (snapshot.data.documents[0]['photoUrl']),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(40.0),
            ),
            clipBehavior: Clip.hardEdge,
          );
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

          return Text('${snapshot.data.documents.length}');
        });
  }
}
