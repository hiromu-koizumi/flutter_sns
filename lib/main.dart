import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/Image_url.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/my_page.dart';
import 'package:flutter_cos/notice_page.dart';
import 'package:flutter_cos/post.dart';

//ユーザー登録
import 'package:flutter_cos/post_details.dart';
import 'package:flutter_cos/search_page.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
            icon: new Icon(Icons.search),
            //title: new Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.notifications),
            //title: new Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.face),
            //title: new Text('MyPage'),
          )
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        assert(index >= 0 && index <= 3);
        print(index);
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
                  builder: (BuildContext context) => SearchPage(),
                  //defaultTitle: 'Colors',
                );
                break;
              case 2:
                return CupertinoTabView(
                  builder: (BuildContext context) => NoticePage(),
                  // print('aaa');
                  //defaultTitle: 'Colors',
                );
                break;
              case 3:
                return CupertinoTabView(
                  builder: (BuildContext context) => MyPages(),
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

class _TimeLineState extends State<TimeLine> //上タブのために必要
    with
        SingleTickerProviderStateMixin {
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
//    Firestore.instance
//        .collection('users')
//        .document(firebaseUser.uid)
//        .collection("tabs")
//        .snapshots()
//        .listen((data) =>
//        data.documents.forEach((doc) => tabs.add(Tab(text: doc["tab"]))));
//    print("早い法$tabs");
////
//    Future.delayed(new Duration(seconds: 1), () {
//      _tabController = TabController(vsync: this, length: tabs.length);
//      print('遅い法$tabs');
//    });
  }

  //List<DocumentSnapshot> posts = [];

  Widget build(BuildContext context) {


//    Firestore.instance
//        .collection('posts')
//        .orderBy("documentId")
//        .startAfter(['00418ca0-3260-11e9-f140-b5d27a76ae0f'])
//        .limit(10)
//        .snapshots()
//        .listen((data) => data.documents.forEach((doc) =>
//
//            print("iiiiiiiiiiiiuuuuu${doc["comment"]}")));
//

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
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

  dodo(document){

    Firestore.instance
        .collection('posts')
        .orderBy("documentId")
        .startAfter([document['documentId']])
        .limit(3)
        .snapshots();
//        .listen((data) => data.documents.forEach((doc) =>
//
//    //空の時nullに上書きされない
//    // print("${doc["comment"]}")
//    print("iiiiiiiiiiiiuuuuu${doc["comment"]}")));

  }

  //上タブの表示処理
  Widget createTab(Tab tab) {
    switch (tab.text) {
      case '新着':
        return Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: StreamBuilder<QuerySnapshot>(
              stream: dodo(null) ,

//              Firestore.instance
//                  .collection('posts')
//                  //.orderBy("time", descending: true)
//                  .orderBy("documentId")
//                  .limit(3)
//                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Text('Loading...');
                return CustomScrollView(
                  slivers: <Widget>[
                    SliverStaggeredGrid.countBuilder(
                      crossAxisCount: 2,
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                      itemBuilder: (context, index) {

                        if(index == 2){
                          dodo(snapshot.data.documents[2]);
                        }

                        DocumentSnapshot documentSnapshot =
                            snapshot.data.documents[index];
                        print(index);
                        return _buildListItem(context, documentSnapshot, index);
                      },
                      staggeredTileBuilder: (int index) =>
                          const StaggeredTile.fit(1),
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
                  .collection('users')
                  .document(firebaseUser.uid)
                  .collection("followingPosts")
                  .orderBy("time", descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Text('Loading...');

                return CustomScrollView(
                  slivers: <Widget>[
                    SliverStaggeredGrid.countBuilder(
                      crossAxisCount: 2,
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                      itemBuilder: (context, index) {
                        DocumentSnapshot documentSnapshot =
                            snapshot.data.documents[index];
                        return _buildListItem(context, documentSnapshot, index);
                      },
                      staggeredTileBuilder: (int index) =>
                          const StaggeredTile.fit(1),
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
  Widget _buildListItem(
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
        index == 2 ? Center(
          child: new Container(
            margin: const EdgeInsets.only(top: 8.0,bottom: 50),
            width: 32.0,
            height: 32.0,
            child: const CircularProgressIndicator(),
          ),
        ): Text('')
      ],
    );
  }
}
