import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/main.dart';
import 'package:flutter_cos/post.dart';
import 'package:flutter_cos/setting.dart';
import 'dart:math' as math;

//格子状に表示する
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

DocumentSnapshot userInformation;

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          body: MyPages()),
    );
  }
}

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
        maxHeight: 200.0,
        child: Container(
            color: Colors.lightBlue, child: Center(child: userName())),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('posts')
            .orderBy("time", descending: true)
            .where("userId", isEqualTo: firebaseUser.uid)
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
                  return _MyPageList(context, documentSnapshot);
                },
                staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
                itemCount: snapshot.data.documents.length,
              ),
            ],
          );
        });
  }

  //投稿表示する処理
  Widget _MyPageList(BuildContext context, DocumentSnapshot document) {
    return Card(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        //写真表示

        ImageUrl(imageUrl: document['url']),

        ListTile(
            leading: const Icon(Icons.android),
            title: Text(document['comment']),

            //substringで表示する時刻を短縮している
            subtitle: Text(document['time'].toString().substring(0, 10))),

        //編集ボタン
        ButtonTheme.bar(
          child: ButtonBar(
            children: <Widget>[
              FlatButton(
                child: const Text('編集'),
                onPressed: () {
                  print("編集ボタンを押しました");
                  //編集処理,画面遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        settings: const RouteSettings(name: "/edit"),

                        //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
                        builder: (BuildContext context) => PostPage(document)),
                  );
                },
              )
            ],
          ),
        )
      ]),
    );
  }

  Widget userName() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .collection("transaction")
            .snapshots(),

        //streamが更新されるたびに呼ばれる
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');

          userInformation = snapshot.data.documents[0];

          return Column(children: <Widget>[
            Text(snapshot.data.documents[0]['userName']),
            Text(snapshot.data.documents[0]['profile']),
          ]);
        });
  }
}