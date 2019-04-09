import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/parts/Image_url.dart';
import 'package:flutter_cos/posts/post_details.dart';
import 'package:flutter_cos/user_pages/user_page.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SearchResultPage extends StatefulWidget {
  SearchResultPage(this.searchWords);

  final searchWords;

  @override
  _SearchResultPageState createState() => _SearchResultPageState(searchWords);
}

class _SearchResultPageState extends State<SearchResultPage> //上タブのために必要
    with
        SingleTickerProviderStateMixin {
  final List<Tab> tabs = <Tab>[
    Tab(text: '投稿'),
    Tab(text: 'ユーザー'),
  ];

  _SearchResultPageState(this.searchWords);

  final searchWords;
  TabController _tabController;

  final _postList = [];
  final _nameList = [];
  bool _postLoading = false;
  bool _nameLoading = false;
  var _loadCheckPost = 0;
  var _loadCheckName = 0;
  final _getPostNumber = 6;
  final _getNameNumber = 12;

  StreamController<List> _postsController = StreamController<List>.broadcast();
  StreamController<List> _nameController = StreamController<List>.broadcast();

  //上タブのインスタンス作成
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
    print(searchWords);

    Firestore.instance
        .collection('posts')
        .where('tag', arrayContains: searchWords)
        .orderBy("time", descending: true)
        .limit(_getPostNumber)
        .snapshots()
        .listen((data) => data.documents.forEach((doc) => _postList.add(doc)));


    Firestore.instance
        .collection('users')
        .where('userName', isEqualTo: searchWords)
        .orderBy("userId")
        .limit(_getNameNumber)
        .snapshots()
        .listen((data) => data.documents.forEach((doc) => _nameList.add(doc)));

    //3秒遅くしないとpostListに投稿が代入できていない
    Future.delayed(new Duration(seconds: 4), () {
      _postsController.add(_postList);
      _nameController.add(_nameList);
      _loadCheckPost = _postList.length - _getPostNumber;
      _loadCheckName = _nameList.length - _getNameNumber;
    });
  }
  fetchPosts(document) async {
    if (_postLoading) {
      return null;
    }
    _postLoading = true;
    Firestore.instance
        .collection('posts')
        .where('tag', arrayContains: searchWords)
        .orderBy("time", descending: true)
        .startAfter([document['time']])
        .limit(_getPostNumber)
        .snapshots()
        .listen((data) => data.documents.forEach((doc) => _postList.add(doc)));

    Future.delayed(new Duration(seconds: 4), () {
      print('読み込み中');
      _postsController.add(_postList);
      _loadCheckPost = _postList.length - _getPostNumber;
      _postLoading = false;
    });
  }

  fetchName(document) async {
    if (_nameLoading) {
      return null;
    }
    _nameLoading = true;
    Firestore.instance
        .collection('users')
        .where('userName', arrayContains: searchWords)
        .orderBy("userId")
        .startAfter([document['userId']])
        .limit(_getNameNumber)
        .snapshots()
        .listen((data) => data.documents.forEach((doc) => _nameList.add(doc)));

    Future.delayed(new Duration(seconds: 4), () {
      print('読み込み中');
      _nameController.add(_nameList);
      _loadCheckName = _nameList.length - _getNameNumber;
      _nameLoading = false;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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

  //上タブの表示処理
  Widget createTab(Tab tab) {
    switch (tab.text) {
      case '投稿':
        return StreamBuilder(
          stream: _postsController.stream,
          builder: (context, snapshot) {
            //画面底を感知する
            return Padding(
                padding: EdgeInsets.only(bottom: 50),
            child:NotificationListener<ScrollNotification>(
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

                        return _tagSearchResult(
                            context, documentSnapshot, index);
                      },
                      staggeredTileBuilder: (int index) =>
                          const StaggeredTile.fit(1),
                      itemCount: _postList.length,
                    ),
                  ],
                ))
            );},
        );
      case 'ユーザー':
        return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification value) {
              if (value.metrics.extentAfter == 0.0) {
                //画面そこに到達したときの処理
                //一番最後に取得した投稿をfetchPostsに送っている。あちらでは、startAfterを使いその投稿より後の投稿を取得している
                fetchPosts(_nameList[_nameList.length - 1]);
              }
            },
            child: StreamBuilder(
                stream: _nameController.stream,
                builder: (BuildContext context, snapshot) {
                  //if (!snapshot.hasData) return const Text('Loading...');

                  return Padding(
                      padding: EdgeInsets.only(bottom: 50),
                      child: ListView.builder(
                        itemCount: _nameList.length,
                        padding: const EdgeInsets.only(top: 10.0),

                        //投稿を表示する処理にデータを送っている
                        itemBuilder: (context, index) {
                          DocumentSnapshot documentSnapshot = _nameList[index];

                          return _nameSearchResult(
                              context, documentSnapshot, index);
                        },
                      ));
                }));
        break;
    }
  }

  Widget _nameSearchResult(
      BuildContext context, DocumentSnapshot document, index) {
    return Column(
      children: <Widget>[
        InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: "/userPage"),
                    builder: (BuildContext context) =>
                        //表示されている名前のユーザーIDをUserPageに渡している
                        UserPage(document['userId']),
                  ));
            },
            child: Row(
              children: <Widget>[
                Material(
                  child: Image.network(
                    (document['photoUrl']),
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  clipBehavior: Clip.hardEdge,
                ),
                SizedBox(
                  width: 20.0,
                ),
                Text(document['userName']),
              ],
            )),

        index == _nameList.length - 1 && _loadCheckName == 0
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

  //投稿表示する処理
  Widget _tagSearchResult(
      BuildContext context, DocumentSnapshot document, index) {
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
        index == _postList.length - 1 && _loadCheckPost == 0
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
}
