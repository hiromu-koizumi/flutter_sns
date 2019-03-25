import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/user_page.dart';

class MyFollowPage extends StatefulWidget {
  //MyHomePage({Key key, this.title}) : super(key: key);

  // final String title;

  @override
  _MyFollowPageState createState() => _MyFollowPageState();
}

class _MyFollowPageState extends State<MyFollowPage>
    with SingleTickerProviderStateMixin {
  final List<Tab> tabs = <Tab>[
    Tab(text: 'フォロー'),
    Tab(text: 'フォロワー'),
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
        //title: const Text(""),
        title: TabBar(
          controller: _tabController,
          tabs: tabs,
        ),
       // actions: <Widget>[],
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
                  .document(firebaseUser.uid)
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
                  itemBuilder: (context, index) => _followingFollowersName(
                      context, snapshot.data.documents[index]),
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
                  .document(firebaseUser.uid)
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
                  itemBuilder: (context, index) => _followingFollowersName(
                      context, snapshot.data.documents[index]),
                );
              }),
        );
        break;
    }
  }


  Widget _followingFollowersName(
      BuildContext context, DocumentSnapshot document) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .where('userId', isEqualTo:document['userId'])
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          userInformation = snapshot.data.documents[0];

          return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: const RouteSettings(name: "/userPage"),
                      builder: (BuildContext context) =>
                          //表示されている名前のユーザーIDをUserPageに渡している
                          UserPage(document['userId'])),
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
                                  snapshot.data.documents[0]['photoUrl'])))),
                  SizedBox(
                    width: 20.0,
                  ),
                  Text(snapshot.data.documents[0]['userName']),
                ],
              ));
          // Text(snapshot.data.documents[0]['userName']);
        });
  }
}
