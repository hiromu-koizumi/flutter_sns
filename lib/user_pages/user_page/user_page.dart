import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/parts/Image_url.dart';
import 'package:flutter_cos/follow/user_follow_page.dart';
import 'package:flutter_cos/other_pages/login_page.dart';
import 'package:flutter_cos/parts/circular_progress_indicator.dart';
import 'package:flutter_cos/user_pages/following_followers_number.dart';
import 'package:flutter_cos/posts/post_details.dart';
import 'package:flutter_cos/user_pages/post.dart';
import 'package:flutter_cos/user_pages/row_user_info.dart';
import 'package:flutter_cos/user_pages/user_image.dart';
import 'package:flutter_cos/user_pages/user_page/follow_button.dart';
import 'package:flutter_cos/user_pages/user_profile.dart';

//格子状に表示する
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:uuid/uuid.dart';

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
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPages> {
  final _postList = [];
  bool _loading = false;
  var _loadCheckPost = 0;
  final _getPostNumber = 7;
  StreamController<List> _postsController = StreamController<List>.broadcast();

  @override
  void initState() {
    super.initState();

    Firestore.instance
        .collection('users')
        .document(widget.userId)
        .collection("posts")
        .orderBy("time", descending: true)
        .limit(_getPostNumber)
        .snapshots()
        .listen((data) => data.documents.forEach((doc) => _postList.add(doc)));

    //3秒遅くしないとpostListに投稿が代入できていない
    Future.delayed(new Duration(seconds: 4), () {
      _postsController.add(_postList);

      //まだ読み込んでいないpostがあるか判断するために必要。割ったあまりを代入している。代入される数字が0だったらまだ取得できる投稿がある可能性が高い
      _loadCheckPost = _postList.length % _getPostNumber;
    });
  }

  fetchPosts(document) async {
    if (_loading) {
      return null;
    }
    _loading = true;
    Firestore.instance
        .collection('users')
        .document(widget.userId)
        .collection('posts')
        .orderBy("time", descending: true)
        .startAfter([document['time']])
        .limit(_getPostNumber)
        .snapshots()
        .listen((data) => data.documents.forEach((doc) => _postList.add(doc)));

    Future.delayed(
      new Duration(seconds: 4),
      () {
        print('読み込み中');
        _postsController.sink.add(_postList);
        _loadCheckPost = _postList.length % _getPostNumber;
        _loading = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _postsController.stream,
      builder: (context, snapshot) {
        //画面底を感知する
        return Padding(
          padding: EdgeInsets.only(bottom: 50),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification value) {
              //まだ不完全な制約。保存されている投稿がちょうどあまりが出ない場合、もう投稿がないのに投稿を取得しようとしてしまう
              if (value.metrics.extentAfter == 0.0 && _loadCheckPost == 0) {
                //画面そこに到達したときの処理
                //一番最後に取得した投稿をfetchPostsに送っている。あちらでは、startAfterを使いその投稿より後の投稿を取得している
                fetchPosts(_postList[_postList.length - 1]);
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
                    DocumentSnapshot documentSnapshot = _postList[index];

                    return index == _postList.length - 1 && _loadCheckPost == 0
                        ? Indicator()
                        : Post(
                            document: documentSnapshot,
                            myPageOrUserPage: "userPage",
                          );
                  },
                  staggeredTileBuilder: (int index) =>
                      const StaggeredTile.fit(1),
                  itemCount: _postList.length,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  userProfileHeader() {
    return SliverAppBar(
      expandedHeight: 200.0,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          margin: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              RowUserInfo(
                userId: widget.userId,
                userPageOrMyPage: "userPage",
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
          .where('userId', isEqualTo: widget.userId)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');

        return UserProfile(document: snapshot.data.documents[0]);
      },
    );
  }
}
