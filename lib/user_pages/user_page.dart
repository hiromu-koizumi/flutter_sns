import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/parts/Image_url.dart';
import 'package:flutter_cos/follow/user_follow_page.dart';
import 'package:flutter_cos/other_pages/login_page.dart';
import 'package:flutter_cos/posts/post_details.dart';

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
  _UserPageState createState() => _UserPageState(userId);
}

class _UserPageState extends State<UserPages> {
  _UserPageState(this.userId);

  final _postList = [];
  bool _loading = false;
  var _loadCheckPost = 0;
  final _getPostNumber = 6;
  StreamController<List> _postsController =
  StreamController<List>.broadcast();

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
        .listen((data) =>
        data.documents.forEach((doc) => _postList.add(doc)));

    //3秒遅くしないとpostListに投稿が代入できていない
    Future.delayed(new Duration(seconds: 4), () {
      _postsController.add(_postList);

      //まだ読み込んでいないpostがあるか判断するために必要
      _loadCheckPost = _postList.length - _getPostNumber;
    });
  }

  final userId;

  //widget.documentにはこのページのユーザーの情報が格納されている.
  //_followReferenceは自分のDBの保存先
  //フォローとフォロー解除の処理をif文で書いている。firebaseのfollowに保存されていればdeleteの処理。なければ保存の処理。
  followCheck(
      _myFollowReference, _othersFollowReference, _noticeFollowRef,_id) async {
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
            "id": _id,
            "read": false
          });
        });
        print('followしたよ');
      }
    });
  }

  //フォローボタンの表示の切り替え処理。
  followButton(_myFollowReference, _othersFollowReference, _noticeFollowRef,_id) {
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
                  followCheck(_myFollowReference, _othersFollowReference,
                      _noticeFollowRef,_id);
                },
              );
            } else {
              //フォローしているときの処理
              return RaisedButton(
                child: Text('フォロー中'),
                onPressed: () {
                  followCheck(_myFollowReference, _othersFollowReference,
                      _noticeFollowRef,_id);
                },
              );
            }
          }),
    );
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

    Future.delayed(new Duration(seconds: 4), () {
      print('読み込み中');
      _postsController.sink.add(_postList);
      _loadCheckPost = _postList.length - _getPostNumber;
      _loading = false;
    });
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

      //noticeに既読したことを保存するためにidが必要
  final String uuid = Uuid().v1();
  final _id = uuid;
    DocumentReference _noticeFollowRef;
    _noticeFollowRef = Firestore.instance
        .collection('users')
        .document(widget.userId)
        .collection("notice")
        .document(_id);

    return StreamBuilder(
      stream: _postsController.stream,
      builder: (context, snapshot) {
        //画面底を感知する
        return Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification value) {
                  if (value.metrics.extentAfter == 0.0) {
                    //画面そこに到達したときの処理
                    //一番最後に取得した投稿をfetchPostsに送っている。あちらでは、startAfterを使いその投稿より後の投稿を取得している
                    fetchPosts(_postList[_postList.length - 1]);
                  }
                },
                child: CustomScrollView(
                  slivers: <Widget>[
                    userProfileHeader(_myFollowReference, _othersFollowReference, _noticeFollowRef,_id),
                    SliverStaggeredGrid.countBuilder(
                      crossAxisCount: 2,
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                      itemBuilder: (context, index) {
                        DocumentSnapshot documentSnapshot =
                        _postList[index];

                        return _userPageList(context, documentSnapshot, index);
                      },
                      staggeredTileBuilder: (int index) =>
                      const StaggeredTile.fit(1),
                      itemCount: _postList.length,
                    ),
                  ],
                )));
      },
    );
  }

  userProfileHeader(
      _myFollowReference, _othersFollowReference, _noticeFollowRef,_id) {
    return SliverAppBar(
        expandedHeight: 200.0,
        backgroundColor: Colors.white,
        flexibleSpace: FlexibleSpaceBar(
            background: Container(
          margin: EdgeInsets.all(16.0),
          //color: Colors.white, child: Center(child: userName())

          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  userImage(),

                  //中央に配置するために付けている
                  Expanded(
                      child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 15,
                      ),
                      Row(
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
                                          UserFollowPage(widget.userId)));
                            },
                            child: Column(
                              children: <Widget>[
                                Text('フォロー'),
                                _followingNumber()
                              ],
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
                                          UserFollowPage(widget.userId)));
                            },
                            child: Column(
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('フォロワー'),
                                _followersNumber()
                              ],
                            ),
                          ),
                        ],
                      ),
                      followButton(_myFollowReference, _othersFollowReference,
                          _noticeFollowRef,_id)
                    ],
                  )),
                ],
              ),
              userProfile(),
            ],
          ),
        )));
  }

  //投稿表示する処理
  Widget _userPageList(BuildContext context, DocumentSnapshot document,index) {
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

  Widget userProfile() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .where('userId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');

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
            .where('userId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');

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

  Widget _followingNumber() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(widget.userId)
            .collection("following")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');

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

          return Text('${snapshot.data.documents.length}');
        });
  }
}
