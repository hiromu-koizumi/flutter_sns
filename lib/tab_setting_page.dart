import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/tab_add_page.dart';

//タブ追加ページ作成途中。アプリ内には組み込まれていない
//上部タブを増やすコードがかけなかった
class TabSettingPage extends StatefulWidget {

  @override
  _TabSettingPageState createState() => _TabSettingPageState();
}

class _TabSettingPageState extends State<TabSettingPage> {
  Widget build(BuildContext context) {
    DocumentReference _tabsRef;
    _tabsRef = Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection("tabs")
        .document();

    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        actions: <Widget>[
          RaisedButton(
            child: Text("追加"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    settings: const RouteSettings(name: "/new"),
                    builder: (BuildContext context) =>
                        TabAddPage() //null 編集機能付けるのに必要っぽい
                    ),
              );
            },
          ),RaisedButton(
            child: Text("削除"),
            onPressed: () {
              _tabsRef.delete();
            },
          ),
        ],
      ),
      body: favoritePage(),
    );
  }

  //上タブの表示処理.ユーザーネームを表示させる
  Widget favoritePage() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: StreamBuilder<QuerySnapshot>(

          //followしている人の情報を_followingFollowersNameに送る。_followingFollowersNameでは、その情報からユーザーIDを取り出し、IDを使いユーザーネームを取り出し表示している
          stream: Firestore.instance
              .collection('users')
              .document(firebaseUser.uid)
              .collection("tabs")
              .orderBy("time", descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
  }
  _followingFollowersName(BuildContext context, DocumentSnapshot document) {
    return Container(
        margin: const EdgeInsets.all(15.0),
        padding: const EdgeInsets.all(3.0),
        decoration: new BoxDecoration(
            border: new Border.all(color: Colors.blueAccent)
        ),
        child: ListTile(
      title: Text(document['tab']),
    ));
  }
}
