import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/tab_add_page.dart';
import 'package:flutter_cos/user_page.dart';

class TabSettingPage extends StatefulWidget {
  // TabSettingPage(this.userInformation);
//
  // final DocumentSnapshot userInformation;

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
              print('aa');
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
//    return StreamBuilder<QuerySnapshot>(
//        stream: Firestore.instance
//            .collection('users')
//            .where('userId', isEqualTo: document['userId'])
//            .snapshots(),
//        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//          if (!snapshot.hasData) return const Text('Loading...');
//          // userInformation = snapshot.data.documents[0];
//
//          //ユーザー登録をしていない人としてる人で処理を分けている。エラーでないように
//          if (snapshot.data.documents.length == 0) {
//            return Text('未登録さんがいいねしました');
//          } else {
//            return InkWell(
//                onTap: () {
//                  Navigator.push(
//                    context,
//                    MaterialPageRoute(
//                        settings: const RouteSettings(name: "/userPage"),
//                        builder: (BuildContext context) =>
//                        //表示されている名前のユーザーIDをUserPageに渡している
//                        UserPage(document['userId'])),
//                  );
//                },
//                child: Row(
//                  children: <Widget>[
//                    Container(
//                        width: 40.0,
//                        height: 40.0,
//                        decoration: new BoxDecoration(
//                            shape: BoxShape.circle,
//                            image: new DecorationImage(
//                                fit: BoxFit.fill,
//                                image: new NetworkImage(
//                                    snapshot.data.documents[0]['photoUrl'])))),
//                    SizedBox(
//                      width: 20.0,
//                    ),
//                    Text(snapshot.data.documents[0]['userName']),
//                  ],
//                ));
//            //}
//            // Text(snapshot.data.documents[0]['userName']);
//          }
//        });
  }
}
