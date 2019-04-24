import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/parts/user_name_bar.dart';

//follow_pageだけでこのファイルなくせると思う。
class UserFollowPage extends StatefulWidget {
  //MyHomePage({Key key, this.title}) : super(key: key);

  // final String title;
  //userIdにはこのページのユーザーIDが入っている
  UserFollowPage(this.userId, this.followOrFollower);
  final userId;
  final followOrFollower;

  @override
  _UserFollowPageState createState() => _UserFollowPageState();
}

class _UserFollowPageState extends State<UserFollowPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<Tab> tabs;

  //上タブのインスタンス作成
  @override
  void initState() {
    super.initState();
    //フォロワーボタンを押した時はタブの左をフォロワータブに変更している
    if (widget.followOrFollower == "follow") {
      tabs = <Tab>[
        Tab(text: 'フォロー'),
        Tab(text: 'フォロワー'),
      ];
    } else {
      tabs = <Tab>[
        Tab(text: 'フォロワー'),
        Tab(text: 'フォロー'),
      ];
    }

    _tabController = TabController(vsync: this, length: tabs.length);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //  title: const Text(""),
        title: TabBar(
          controller: _tabController,
          tabs: tabs,
        ),
        actions: <Widget>[],
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

  //上タブの表示処理.ユーザーネームを表示させる
  Widget createTab(Tab tab) {
    switch (tab.text) {
      case 'フォロー':
        return Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: StreamBuilder<QuerySnapshot>(

              //followしている人の情報を_followingFollowersNameに送る。_followingFollowersNameでは、その情報からユーザーIDを取り出し、IDを使いユーザーネームを取り出し表示している
              stream: Firestore.instance
                  .collection('users')
                  .document(widget.userId)
                  .collection("following")
                  .orderBy("time", descending: true)
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
                      UserName(document: snapshot.data.documents[index]),
                );
              }),
        );
        break;
      case 'フォロワー':
        return Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: StreamBuilder<QuerySnapshot>(

              //orderByで新しく投稿したものを上位に表示させている。投稿に保存されているtimeを見て判断している.
              stream: Firestore.instance
                  .collection('users')
                  .document(widget.userId)
                  .collection("followers")
                  .orderBy("time", descending: true)
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
                      UserName(document: snapshot.data.documents[index]),
                );
              }),
        );
        break;
    }
  }
}
