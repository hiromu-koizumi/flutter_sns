import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/follow_page.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/main.dart';
import 'package:flutter_cos/mypost_details.dart';
import 'package:flutter_cos/setting.dart';
import 'dart:math' as math;

//格子状に表示する
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

DocumentSnapshot userInformation;
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
                child: userProfile()
              ),
              Expanded(
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 50, right: 50),
                      child: Row(
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

    if (firebaseUser.isAnonymous) {

      return Card(
        child: loginScreen(context),
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
            body: postStream()),
      );
    }

  }

  postStream(){
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
              makeHeader(),
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
        onTap : (){
          Navigator.push(
            context,
            MaterialPageRoute(
                settings: const RouteSettings(name: "/postDetails"),

                //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
                builder: (BuildContext context) =>
                    MyPostDetails(document)),
          );
        },
        child: Card(
          //写真表示
          child: ImageUrl(imageUrl: document['url']),
        )
    );
  }

  Widget userProfile() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .collection("profiles")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          if (snapshot.data.documents.length == 0) return Text('NONAME');
          userInformation = snapshot.data.documents[0];

          if (snapshot.data.documents[0]['profile'] != null) {
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
                Text(snapshot.data.documents[0]['profile']),
              ],
            );
          } else {
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