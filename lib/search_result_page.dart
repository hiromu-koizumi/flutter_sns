import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/Image_url.dart';
import 'package:flutter_cos/post_details.dart';
import 'package:flutter_cos/user_page.dart';
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

  //上タブのインスタンス作成
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
    print(searchWords);
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
        return Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('posts')
                  .where('tag', arrayContains: searchWords)
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
                        return _tagSearchResult(context, documentSnapshot);
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
      case 'ユーザー':
        return Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: StreamBuilder<QuerySnapshot>(

              //followしている人の情報を_followingFollowersNameに送る。_followingFollowersNameでは、その情報からユーザーIDを取り出し、IDを使いユーザーネームを取り出し表示している
              stream: Firestore.instance
                  .collection('users')
                  .where('userName', isEqualTo: searchWords)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Text('Loading...');
                return ListView.builder(
                  //データをいくつ持ってくるかの処理
                  itemCount: snapshot.data.documents.length,
                  padding: const EdgeInsets.only(top: 10.0),

                  //投稿を表示する処理にデータを送っている
                  itemBuilder: (context, index) => _nameSearchResult(
                      context, snapshot.data.documents[index]),
                );
              }),
        );
        break;
    }
  }

  Widget _nameSearchResult(BuildContext context, DocumentSnapshot document) {
    return InkWell(
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
        ));
  }

  //投稿表示する処理
  Widget _tagSearchResult(BuildContext context, DocumentSnapshot document) {
    return InkWell(
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
        ));
  }
}
