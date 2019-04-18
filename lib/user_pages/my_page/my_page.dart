import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/parts/Image_url.dart';
import 'package:flutter_cos/follow/follow_page.dart';
import 'package:flutter_cos/other_pages/login_page.dart';
import 'package:flutter_cos/parts/circular_progress_indicator.dart';
import 'package:flutter_cos/user_pages/following_followers_number.dart';
import 'package:flutter_cos/posts/my_post_details.dart';
import 'package:flutter_cos/posts/post_page.dart';
import 'package:flutter_cos/setting/setting_page.dart';
import 'package:flutter_cos/user_pages/post.dart';
import 'package:flutter_cos/user_pages/row_user_info.dart';
import 'package:flutter_cos/user_pages/user_image.dart';
import 'package:flutter_cos/user_pages/user_profile.dart';

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
  final _getPostNumber = 7;

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
      _postLoadCheck = _myPostList.length % _getPostNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: postStream(),
    );
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
      _postLoadCheck = _myPostList.length % _getPostNumber;
      _loading = false;
    });
  }

  Future<void> _updatePost() async {
    Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection('posts')
        .orderBy("time", descending: false)
        .startAfter([_myPostList[0]['time']])
        .limit(_getPostNumber)
        .snapshots()
        .listen((data) => data.documents.isNotEmpty &&
                data.documents[0]["documentId"] != _myPostList[0]["documentId"]
            ? data.documents.forEach((doc) => _myPostList.insert(0, doc))
            : print("新規投稿無し"));
    //  data.documents.forEach((doc) => _myPostList.insert(0, doc)));
    Future.delayed(new Duration(seconds: 4), () {
      print('読み込み中');
      _postsController.sink.add(_myPostList);
    });
  }

  postStream() {
    return RefreshIndicator(
        //下に引っ張ると更新する処理
        onRefresh: _updatePost,
        child: StreamBuilder(
            stream: _postsController.stream,
            //streamが更新されるたびに呼ばれる
            builder: (BuildContext context, snapshot) {
              return Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification value) {
                        if (value.metrics.extentAfter == 0.0 &&
                            _postLoadCheck == 0) {
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

                              return index == _myPostList.length - 1 &&
                                      _postLoadCheck == 0
                                  ? Indicator()
                                  : Post(
                                      document: documentSnapshot,
                                      myPageOrUserPage: "myPage",
                                    );
                            },
                            staggeredTileBuilder: (int index) =>
                                const StaggeredTile.fit(1),
                            itemCount: _myPostList.length,
                          ),
                        ],
                      )));
            }));
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
              RowUserInfo(
                userId: firebaseUser.uid,
                userPageOrMyPage: "myPage",
              ),
              userProfile(),
            ],
          ),
        ),
      ),
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
        //値を受け渡す処理があるのでクラスにしなかった
        userInformation = snapshot.data.documents[0];

        return UserProfile(document: snapshot.data.documents[0]);
      },
    );
  }
}
