import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/user_page.dart';

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
              itemBuilder: (context, index) => _followingFollowersName(
                  context, snapshot.data.documents[index]),
            );
          }),
    );
  }

  Widget _followingFollowersName(
      BuildContext context, DocumentSnapshot document) {
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
            return Text('未登録さんがいいねしました');
          } else {
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
                    Material(
                      child: Image.network(
                        ( snapshot.data.documents[0]['photoUrl']),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    Text(snapshot.data.documents[0]['userName']),
                  ],
                ));
            //}
            // Text(snapshot.data.documents[0]['userName']);
          }
        });
  }
}
