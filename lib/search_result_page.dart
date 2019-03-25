import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/my_page.dart';

//ユーザー登録
import 'package:flutter_cos/post_details.dart';
import 'package:flutter_cos/search_page.dart';
import 'package:flutter_cos/user_page.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SearchResultPage extends StatefulWidget {

  SearchResultPage(this.searchWords);

  final searchWords;

  @override
  _SearchResultPageState createState() => _SearchResultPageState(searchWords);

}

class _SearchResultPageState extends State<SearchResultPage>
//上タブのために必要
    with SingleTickerProviderStateMixin {
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
    print(searchWords.text);
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

          padding: const EdgeInsets.only(top: 12.0),
          child: StreamBuilder<QuerySnapshot>(

            //uidはユーザーの情報を取得する。firebaseUserにはログインしたユーザーが格納されている。だからここではログインしたユーザーの情報を取得している。
            //stream: Firestore.instance.collection('users').document(firebaseUser.uid).collection("transaction").snapshots(),

            //orderByで新しく投稿したものを上位に表示させている。投稿に保存されているtimeを見て判断している.
              stream: Firestore.instance
              .collection('posts')
              .where('tag',arrayContains: searchWords.text)
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
                      staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
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
                  .where('userName',isEqualTo: searchWords.text)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Text('Loading...');
                return ListView.builder(
                  //データをいくつ持ってくるかの処理
                  itemCount: snapshot.data.documents.length,
                  padding: const EdgeInsets.only(top: 10.0),

                  //投稿を表示する処理にデータを送っている
                  itemBuilder: (context, index) =>
                      _nameSearchResult(context, snapshot.data.documents[index]),
                );

              }),
        );
        break;
    }
  }

  bool favorite;

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
          )
          );
        },
        child: Row(
          children: <Widget>[
            Container(
                width: 40.0,
                height: 40.0,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new NetworkImage(
                            document['photoUrl'])))),
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
        onTap : (){
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
          //写真表示
          child: ImageUrl(imageUrl: document['url']),
        )
    );
  }
}

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
