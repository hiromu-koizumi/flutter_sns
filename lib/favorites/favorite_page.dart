import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/other_pages/login_page.dart';
import 'package:flutter_cos/parts/user_name_bar.dart';

class MyFavoritePage extends StatefulWidget {
  MyFavoritePage(this.document);

  final DocumentSnapshot document;

  @override
  _MyFavoritePageState createState() => _MyFavoritePageState();
}

class _MyFavoritePageState extends State<MyFavoritePage> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: _favoritePage(),
    );
  }

  //上タブの表示処理.ユーザーネームを表示させる
  Widget _favoritePage() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: StreamBuilder<QuerySnapshot>(

          //followしている人の情報を_followingFollowersNameに送る。_followingFollowersNameでは、その情報からユーザーIDを取り出し、IDを使いユーザーネームを取り出し表示している
          stream: Firestore.instance
              .collection('users')
              .document(firebaseUser.uid)
              .collection("posts")
              .document(widget.document["documentId"])
              .collection("beFavorited")
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
              itemBuilder: (context, index) =>
                  _favoriteName(context, snapshot.data.documents[index]),
            );
          }),
    );
  }

  Widget _favoriteName(BuildContext context, DocumentSnapshot document) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .where('userId', isEqualTo: document['userId'])
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          // userInformation = snapshot.data.documents[0];

          //ユーザー登録をしていない人としてる人で処理を分けている。エラーでないように
          if (snapshot.data.documents.length == 0) {
            return Padding(
                padding: EdgeInsets.only(top: 5, left: 5), child: Text('未登録'));
          } else {
            //
            return UserName(document: document);
          }
        });
  }
}
