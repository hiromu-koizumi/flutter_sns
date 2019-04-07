import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/Image_url.dart';
import 'package:flutter_cos/follow_page.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/mypost_details.dart';
import 'package:flutter_cos/post.dart';
import 'package:flutter_cos/setting.dart';

//格子状に表示する
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

DocumentSnapshot userInformation;

class MyPages extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPages> {
  bool _loading = false;
  final _myPostList = [];
  StreamController<List> _postsController = StreamController<List>.broadcast();

  //読み込む投稿がまだあるかチェックするために必要。
  var _postLoadCheck = 0;
  final _getPostNumber = 6;

  @override
  void initState() {
    super.initState();

    Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection('posts')
        .orderBy("time", descending: true)
        .limit(_getPostNumber)
        .snapshots()
        .listen(
            (data) => data.documents.forEach((doc) => _myPostList.add(doc)));

    //3秒遅くしないとpostListに投稿が代入できていない
    Future.delayed(new Duration(seconds: 4), () {
      _postsController.add(_myPostList);
      _postLoadCheck = _myPostList.length - _getPostNumber;
    });
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

  fetchMyPosts(document) async {
    if (_loading) {
      return null;
    }
    _loading = true;
    Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection('posts')
        .orderBy("time", descending: true)
        .startAfter([document['time']])
        .limit(_getPostNumber)
        .snapshots()
        .listen(
            (data) => data.documents.forEach((doc) => _myPostList.add(doc)));

    Future.delayed(new Duration(seconds: 4), () {
      print('読み込み中');
      _postsController.add(_myPostList);

      //postLoadCheckがマイナスになった場合もう読み込む投稿がない。
      _postLoadCheck = _myPostList.length - _getPostNumber;
      _loading = false;
    });
  }

  postStream() {
    return StreamBuilder(
        stream: _postsController.stream,
        //streamが更新されるたびに呼ばれる
        builder: (BuildContext context, snapshot) {
          return Padding(
              padding: EdgeInsets.only(bottom: 50),
              child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification value) {
                    if (value.metrics.extentAfter == 0.0) {
                      //画面そこに到達したときの処理
                      //一番最後に取得した投稿をfetchPostsに送っている。あちらでは、startAfterを使いその投稿より後の投稿を取得している
                      fetchMyPosts(_myPostList[_myPostList.length - 1]);
                    }
                  },
                  child: CustomScrollView(
                    slivers: <Widget>[
                      userProfileHeader(),
                      SliverStaggeredGrid.countBuilder(
                        crossAxisCount: 2,
                        mainAxisSpacing: 4.0,
                        crossAxisSpacing: 4.0,
                        itemBuilder: (context, index) {
                          DocumentSnapshot documentSnapshot =
                              _myPostList[index];

                          return _myPost(context, documentSnapshot, index);
                        },
                        staggeredTileBuilder: (int index) =>
                            const StaggeredTile.fit(1),
                        itemCount: _myPostList.length,
                      ),
                    ],
                  )));
        });
  }

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

  //投稿表示する処理
  Widget _myPost(BuildContext context, DocumentSnapshot document, index) {
//    return Padding(
//        padding: EdgeInsets.only(bottom: 1),
    return Column(
      children: <Widget>[
        InkWell(
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
            )),
        index == _myPostList.length - 1 && _postLoadCheck == 0
            ? Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8.0, bottom: 50),
                  width: 32.0,
                  height: 32.0,
                  child: const CircularProgressIndicator(),
                ),
              )
            : Container()
      ],
    );
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
