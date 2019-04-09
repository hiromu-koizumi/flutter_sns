import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/favorites/favorite.dart';
import 'package:flutter_cos/other_pages/login_page.dart';
import 'package:flutter_cos/parts/Image_url.dart';
import 'package:flutter_cos/other_pages/message_page.dart';
import 'package:flutter_cos/posts/post_details.dart';
import 'package:flutter_cos/posts/post_page.dart';
import 'package:flutter_cos/parts/user_name_bar.dart';
import 'package:flutter_cos/searches/search_result_page.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class TimeLine extends StatefulWidget {
  @override
  _TimeLineState createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> //上タブのために必要
    with
        SingleTickerProviderStateMixin {
  final List<Tab> tabs = <Tab>[
    Tab(text: '新着'),
    Tab(text: 'フォロー'),
  ];
  TabController _tabController;

  final _postList = [];
  final _followPostList = [];
  bool _loading = false;
  bool _followPostLoading = false;
  var _loadCheckFollowPost = 0;
  final _getPostNumber = 5;

  StreamController<List> _newPostsController =
      StreamController<List>.broadcast();
  StreamController<List> _followPostsController =
      StreamController<List>.broadcast();

  //上タブのインスタンス作成
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);

    //初めに表示する投稿を取得している。fetchPostsと一緒にできない。あちらではstartAfterを使用しているので。
    Firestore.instance
        .collection('posts')
        .orderBy("time", descending: true)
        .limit(10)
        .snapshots()
        .listen((data) => data.documents.forEach((doc) => _postList.add(doc)));

    Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection("followingPosts")
        .orderBy("time", descending: true)
        .limit(_getPostNumber)
        .snapshots()
        .listen((data) =>
            data.documents.forEach((doc) => _followPostList.add(doc)));

    //3秒遅くしないとpostListに投稿が代入できていない
    Future.delayed(new Duration(seconds: 4), () {
      _newPostsController.add(_postList);
      _followPostsController.add(_followPostList);
      _loadCheckFollowPost = _followPostList.length - _getPostNumber;
    });
  }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: () {
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
        ],
        title: TabBar(
          controller: _tabController,
          tabs: tabs,
        ),
      ),

      //上タブ表示させる処理
      body: TabBarView(
        controller: _tabController,
        children: tabs.map((Tab tab) {
          return createTab(tab);
        }).toList(),
      ),
    );
  }

  fetchPosts(document) async {
    if (_loading) {
      return null;
    }
    _loading = true;
    Firestore.instance
        .collection('posts')
        .orderBy("time", descending: true)
        .startAfter([document['time']])
        .limit(10)
        .snapshots()
        .listen((data) => data.documents.forEach((doc) => _postList.add(doc)));

    Future.delayed(new Duration(seconds: 4), () {
      print('読み込み中');
      _newPostsController.sink.add(_postList);
      _loading = false;
    });
  }

  fetchFollowPosts(document) async {
    if (_followPostLoading) {
      return null;
    }
    _followPostLoading = true;
    Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection("followingPosts")
        .orderBy("time", descending: true)
        .startAfter([document['time']])
        .limit(_getPostNumber)
        .snapshots()
        .listen((data) =>
            data.documents.forEach((doc) => _followPostList.add(doc)));

    Future.delayed(new Duration(seconds: 4), () {
      print('読み込み中');
      _followPostsController.add(_followPostList);
      _loadCheckFollowPost = _followPostList.length - _getPostNumber;
      _followPostLoading = false;
    });
  }

  //上タブの表示処理
  Widget createTab(Tab tab) {
    switch (tab.text) {
      case '新着':
        return StreamBuilder(
          stream: _newPostsController.stream,
          builder: (context, snapshot) {
            //画面底を感知する
            return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification value) {
                  if (value.metrics.extentAfter == 0.0) {
                    //画面そこに到達したときの処理
                    //一番最後に取得した投稿をfetchPostsに送っている。あちらでは、startAfterを使いその投稿より後の投稿を取得している
                    fetchPosts(_postList[_postList.length - 1]);
                  }
                },
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverStaggeredGrid.countBuilder(
                      crossAxisCount: 2,
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                      itemBuilder: (context, index) {
                        DocumentSnapshot documentSnapshot = _postList[index];

                        return _newPost(context, documentSnapshot, index);
                      },
                      staggeredTileBuilder: (int index) =>
                          const StaggeredTile.fit(1),
                      itemCount: _postList.length,
                    ),
                  ],
                ));
          },
        );

      case 'フォロー':
        return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification value) {
              if (value.metrics.extentAfter == 0.0) {
                //画面そこに到達したときの処理
                //一番最後に取得した投稿をfetchPostsに送っている。あちらでは、startAfterを使いその投稿より後の投稿を取得している
                fetchFollowPosts(_followPostList[_followPostList.length - 1]);
              }
            },
            child: StreamBuilder(
                stream: _followPostsController.stream,
                builder: (BuildContext context, snapshot) {
                  //if (!snapshot.hasData) return const Text('Loading...');

                  return Padding(
                      padding: EdgeInsets.only(bottom: 50),
                      child: ListView.builder(
                        itemCount: _followPostList.length,
                        padding: const EdgeInsets.only(top: 10.0),

                        //投稿を表示する処理にデータを送っている
                        itemBuilder: (context, index) {
                          DocumentSnapshot documentSnapshot =
                              _followPostList[index];

                          return _followPost(context, documentSnapshot, index);
                        },
                      ));
                }));
        break;
    }
  }

  //投稿表示する処理
  Widget _newPost(BuildContext context, DocumentSnapshot document, index) {
    return Column(
      children: <Widget>[
        InkWell(
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
            )),
        index == _postList.length - 1
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

  Widget _followPost(BuildContext context, DocumentSnapshot document, index) {
    return Column(
      children: <Widget>[
        Card(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            userName(context, document),

            //写真表示
            ImageUrl(imageUrl: document["url"]),

            ListTile(
              title: Text(document["comment"]),

              //substringで表示する時刻を短縮している
              subtitle: Text(document["time"].toString().substring(0, 10)),
            ),

            ButtonTheme.bar(
              child: ButtonBar(
                children: <Widget>[
                  Row(
                      children: document["tag"]
                          .map<Widget>((item) => InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      settings: const RouteSettings(
                                          name: "/postDetails"),

                                      //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
                                      builder: (BuildContext context) =>
                                          SearchResultPage(item)),
                                );
                              },
                              child: Container(
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5.0),
                                      ),
                                    ),
                                    color: Colors.black12,
                                  ),
                                  margin: EdgeInsets.only(right: 5, left: 5),
                                  padding: EdgeInsets.all(5),
                                  child: Text(item))))
                          .toList()),
                  favoriteButton(document),
                  FlatButton(
                    child: const Icon(Icons.comment),
                    onPressed: () {
                      print("コメントボタンを押しました");

                      //コメントページに画面遷移
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            settings: const RouteSettings(name: "/comment"),
                            builder: (BuildContext context) =>
                                MessagePage(document)),
                      );
                    },
                  )
                ],
              ),
            )
          ]),
        ),
        index == _followPostList.length - 1 && _loadCheckFollowPost == 0
            ? Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8.0, bottom: 60),
                  width: 32.0,
                  height: 32.0,
                  child: const CircularProgressIndicator(),
                ),
              )
            : Container()
      ],
    );
  }
}
