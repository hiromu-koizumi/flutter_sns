import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/favorite.dart';
import 'package:flutter_cos/message_page.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/my_page.dart';
import 'package:flutter_cos/post.dart';

//ユーザー登録
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_cos/post_details.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

//firebaseに保存されるテキスト。const再代入不可な変数。const変数が指す先のメモリ領域も変更不可
void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cosco',
      routes: <String, WidgetBuilder>{
        //はじめは自動的に'/'の画面に遷移する
        '/': (_) => Splash(),
        '/bottombar': (_) => BottomBar(),
      },
      // home: TimeLine(),
    );
  }
}

//下タブはStatefulWidgetじゃないと呼び出しができなかった
class BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() => _BottomBarState();
}

//下タブ
class _BottomBarState extends State<BottomBar> {
  @override
  build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            //title: new Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.face),
            //title: new Text('MyPage'),
          )
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        assert(index >= 0 && index <= 1);
        return CupertinoTabView(
          builder: (BuildContext context) {
            switch (index) {
              case 0:
                return CupertinoTabView(
                  builder: (BuildContext context) => TimeLine(),
                  //defaultTitle: 'Colors',
                );
                break;
              case 1:
                return CupertinoTabView(
                  builder: (BuildContext context) => MyPage(),
                  //defaultTitle: 'Support Chat',
                );
                break;
            }
            return null;
          },
        );
      },
    );
  }
}

class TimeLine extends StatefulWidget {
  @override
  _TimeLineState createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine>
//上タブのために必要
  with SingleTickerProviderStateMixin {
  final List<Tab> tabs = <Tab>[
    Tab(text: '新着'),
    Tab(text: 'フォロー'),
  ];
  TabController _tabController;

  //上タブのインスタンス作成
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
  }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
        ),
        actions: <Widget>[
//          IconButton(
//            icon: Icon(Icons.exit_to_app),
//            onPressed: () {
//              print("login");
//
//              //ログイン画面表示
//              showBasicDialog(context);
//            },
//          ),
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

//          IconButton(
//            icon: Icon(Icons.account_circle),
//            onPressed: () {
//              print("mypage");
//              //画面遷移
//              Navigator.push(
//                context,
//                MaterialPageRoute(
//                    settings: const RouteSettings(name: "/myPage"),
//                    builder: (BuildContext context) => MyPage()),
//              );
//            },
//          )
        ],
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
      case '新着':
        return Padding(

          padding: const EdgeInsets.only(top: 12.0),
          child: StreamBuilder<QuerySnapshot>(

              //uidはユーザーの情報を取得する。firebaseUserにはログインしたユーザーが格納されている。だからここではログインしたユーザーの情報を取得している。
              //stream: Firestore.instance.collection('users').document(firebaseUser.uid).collection("transaction").snapshots(),

              //orderByで新しく投稿したものを上位に表示させている。投稿に保存されているtimeを見て判断している.
              stream: Firestore.instance
                  .collection('posts')
                  .orderBy("time", descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Text('Loading...');
//                return ListView.builder(
//                  //データをいくつ持ってくるかの処理
//                  itemCount: snapshot.data.documents.length,
//                  padding: const EdgeInsets.only(top: 10.0),
//
//                  //投稿を表示する処理にデータを送っている
//                  itemBuilder: (context, index) =>
//                      _buildListItem(context, snapshot.data.documents[index]),
//                );

              return CustomScrollView(
                slivers: <Widget>[
                  SliverStaggeredGrid.countBuilder(
                    crossAxisCount: 2,
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                    itemBuilder: (context, index) {
                      DocumentSnapshot documentSnapshot =
                      snapshot.data.documents[index];
                      return _buildListItem(context, documentSnapshot);
                    },
                    staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
                    itemCount: snapshot.data.documents.length,
                  ),

                ],
              );
              }),
        );
        break;
      case 'フォロー':
        return Padding(

          padding: const EdgeInsets.only(top: 12.0),
          child: StreamBuilder<QuerySnapshot>(

            //uidはユーザーの情報を取得する。firebaseUserにはログインしたユーザーが格納されている。だからここではログインしたユーザーの情報を取得している。
            //stream: Firestore.instance.collection('users').document(firebaseUser.uid).collection("transaction").snapshots(),

            //orderByで新しく投稿したものを上位に表示させている。投稿に保存されているtimeを見て判断している.
              stream: Firestore.instance
                  .collection('posts')
                  .orderBy("time", descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Text('Loading...');
//                return ListView.builder(
//                  //データをいくつ持ってくるかの処理
//                  itemCount: snapshot.data.documents.length,
//                  padding: const EdgeInsets.only(top: 10.0),
//
//                  //投稿を表示する処理にデータを送っている
//                  itemBuilder: (context, index) =>
//                      _buildListItem(context, snapshot.data.documents[index]),
//                );

                return CustomScrollView(
                  slivers: <Widget>[
                    SliverStaggeredGrid.countBuilder(
                      crossAxisCount: 2,
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                      itemBuilder: (context, index) {
                        DocumentSnapshot documentSnapshot =
                        snapshot.data.documents[index];
                        return _buildListItem(context, documentSnapshot);
                      },
                      staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
                      itemCount: snapshot.data.documents.length,
                    ),

                  ],
                );
              }),
        );
        break;
    }
  }

  bool favorite;

  //投稿表示する処理
  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
//    savedDocumentIDSuba(document,favorite);
//   if (savedUserID == firebaseUser.uid) {
//     favorite = true;
//     print('aaaaa');
//   }





    //Card(
//    color: const Color(0x00000000),
//    elevation: 3.0,
//    child: new GestureDetector(
//      onTap: () {
//        print("hello");
//      },
//      child: new Container(
//          decoration: new BoxDecoration(
//            image: new DecorationImage(
//              image: new NetworkImage(document['url']),
//              fit: BoxFit.cover,
//            ),
//            borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
//          )
//      ),
//    ),
//  );





    return InkWell(
        onTap : (){
          print('aaadd');
          Navigator.push(
            context,
            MaterialPageRoute(
                settings: const RouteSettings(name: "/postDetails"),

                //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
                builder: (BuildContext context) =>
                    PostDetails(document)),
          );
        },
        child: Card(

          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            //写真表示
            ImageUrl(imageUrl: document['url']),

//            ListTile(
//              leading: const Icon(Icons.android),
//              title: Text(document['comment']),
//
//              //substringで表示する時刻を短縮している
//              subtitle: Text(document['time'].toString().substring(0, 10)),
//            ),
            //編集ボタン

//            ButtonTheme.bar(
//              child: ButtonBar(
//                children: <Widget>[
//                  FlatButton(
//                    child: Icon(
//                      //savedDocumentIDSuba(document,favorite)
//                      favorite == true ? Icons.favorite : Icons.favorite_border,
//                      color: favorite == true ? Colors.red : Colors.black38,
//                    ),
//                    onPressed: () {
//                      print("いいねボタンを押しました");
//                      print("${document.documentID}");
//
//                      //お気に入りボタン押した投稿のdocumentIDと時間を保存する処理
//                      uploadFavorite(document);
//
//                      //ハートボタンが押されたことを伝えている。これがあることで更新できハートがすぐ赤くなる。
//                      setState(() {
//                        if (favorite != true) {
//                          favorite = true;
//                        } else {
//                          favorite = false;
//                        }
//                      });
//                    },
//                  ),
//                  FlatButton(
//                    child: const Icon(Icons.comment),
//                    onPressed: () {
//                      print("コメントボタンを押しました");
//
//                      //コメントページに画面遷移
//                      Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                            settings: const RouteSettings(name: "/comment"),
//
//                            //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
//                            builder: (BuildContext context) =>
//                                MessagePage(document)),
//                      );
//                    },
//                  )
//                ],
//              ),
//            )
          ]),
        )
    );






//      Card(
//      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
//        //写真表示
//        ImageUrl(imageUrl: document['url']),
//
//        ListTile(
//          leading: const Icon(Icons.android),
//          title: Text(document['comment']),
//
//          //substringで表示する時刻を短縮している
//          subtitle: Text(document['time'].toString().substring(0, 10)),
//        ),
//        //編集ボタン
//
//        ButtonTheme.bar(
//          child: ButtonBar(
//            children: <Widget>[
//              FlatButton(
//                child: Icon(
//                  //savedDocumentIDSuba(document,favorite)
//                  favorite == true ? Icons.favorite : Icons.favorite_border,
//                  color: favorite == true ? Colors.red : Colors.black38,
//                ),
//                onPressed: () {
//                  print("いいねボタンを押しました");
//                  print("${document.documentID}");
//
//                  //お気に入りボタン押した投稿のdocumentIDと時間を保存する処理
//                  uploadFavorite(document);
//
//                  //ハートボタンが押されたことを伝えている。これがあることで更新できハートがすぐ赤くなる。
//                  setState(() {
//                    if (favorite != true) {
//                      favorite = true;
//                    } else {
//                      favorite = false;
//                    }
//                  });
//                },
//              ),
//              FlatButton(
//                child: const Icon(Icons.comment),
//                onPressed: () {
//                  print("コメントボタンを押しました");
//
//                  //コメントページに画面遷移
//                  Navigator.push(
//                    context,
//                    MaterialPageRoute(
//                        settings: const RouteSettings(name: "/comment"),
//
//                        //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
//                        builder: (BuildContext context) =>
//                            MessagePage(document)),
//                  );
//                },
//              )
//            ],
//          ),
//        )
//      ]),
//    );
  }
}
//class Favorite{
//  final bool isFavorite;
//  Favorite({
//    this.isFavorite = false
//  });
//}
//
//class fav {
//  final String documentId;
//  fav(this.documentId);
//  bool isFavorite;
//  String id;
//  List<Favorite> favlis = [];
//  void fa(){
//     favlis[]
//  }
//}

//urlから画像を表示する処理
class ImageUrl extends StatelessWidget {
  final String imageUrl;

  ImageUrl({this.imageUrl});

  @override
  Widget build(BuildContext context) {
//            return Image.network(
//      //横幅がが長くならない
//      imageUrl, width: 600, height: 300,
//    );
  return Container(
      child: ClipRRect(
    borderRadius: BorderRadius.circular(12.0),
   child: Image.network(
  //横幅がが長くならない
  imageUrl,fit: BoxFit.cover,
  ),
      )
  );
  }
}
