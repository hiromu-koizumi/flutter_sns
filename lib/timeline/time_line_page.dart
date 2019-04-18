import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/other_pages/login_page.dart';
import 'package:flutter_cos/parts/circular_progress_indicator.dart';
import 'package:flutter_cos/posts/post_page.dart';
import 'package:flutter_cos/timeline/follow_post.dart';
import 'package:flutter_cos/timeline/new_post.dart';
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
      _loadCheckFollowPost = _followPostList.length % _getPostNumber;
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
      _loadCheckFollowPost = _followPostList.length % _getPostNumber;
      _followPostLoading = false;
    });
  }

  Future<void> _updateNewPost() async {
    Firestore.instance
        .collection('posts')
        .orderBy("time", descending: false)
        .startAfter([_postList[0]['time']])
        .limit(10)
        .snapshots()
        //startAfterを使っているが更新時に同じ投稿を取得してしまうので以下の制約を追加
        .listen((data) => data.documents.isNotEmpty &&
                data.documents[0]["documentId"] != _postList[0]["documentId"]
            ? data.documents.forEach((doc) => _postList.insert(0, doc))
            : print("新規投稿無し"));
    Future.delayed(new Duration(seconds: 4), () {
      print('読み込み中');
      _newPostsController.sink.add(_postList);
    });
  }

  Future<void> _updateFollowPost() async {
    Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection("followingPosts")
        .orderBy("time", descending: false)
        .startAfter([_followPostList[0]['time']])
        .limit(10)
        .snapshots()
        .listen(
          (data) => data.documents.isNotEmpty &&
                  data.documents[0]["documentId"] !=
                      _followPostList[0]["documentId"]
              ? data.documents.forEach((doc) => _followPostList.insert(0, doc))
              : print('新規投稿無し'),
        );
    Future.delayed(new Duration(seconds: 4), () {
      print('読み込み中');
      _followPostsController.sink.add(_followPostList);
    });
  }

  //上タブの表示処理
  Widget createTab(Tab tab) {
    switch (tab.text) {
      case '新着':
        return RefreshIndicator(
            //下に引っ張ると更新する処理
            onRefresh: _updateNewPost,
            child: StreamBuilder(
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
                            DocumentSnapshot documentSnapshot =
                                _postList[index];

                            return index == _postList.length - 1
                                ? Indicator()
                                : NewPost(
                                    document: documentSnapshot,
                                  );
                          },
                          staggeredTileBuilder: (int index) =>
                              const StaggeredTile.fit(1),
                          itemCount: _postList.length,
                        ),
                      ],
                    ));
              },
            ));
      case 'フォロー':
        return RefreshIndicator(
          //下に引っ張ると更新する処理
          onRefresh: _updateFollowPost,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification value) {
              if (value.metrics.extentAfter == 0.0 &&
                  _loadCheckFollowPost == 0) {
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

                      return index == _followPostList.length - 1 &&
                              _loadCheckFollowPost == 0
                          ? Indicator()
                          : FollowPost(
                              document: documentSnapshot,
                            );
                    },
                  ),
                );
              },
            ),
          ),
        );
        break;
    }
  }
}
