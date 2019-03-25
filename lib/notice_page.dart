import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/message_page.dart';
import 'package:flutter_cos/user_page.dart';

class NoticePage extends StatefulWidget {
  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: noticePage(),
    );
  }

  //上タブの表示処理.ユーザーネームを表示させる
  Widget noticePage() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: StreamBuilder<QuerySnapshot>(

          //followしている人の情報を_followingFollowersNameに送る。_followingFollowersNameでは、その情報からユーザーIDを取り出し、IDを使いユーザーネームを取り出し表示している
          stream: Firestore.instance
              .collection('users')
              .document(firebaseUser.uid)
              .collection("notice")
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
                  _noticeName(context, snapshot.data.documents[index]),
            );
          }),
    );
  }

  Widget _noticeName(BuildContext context, DocumentSnapshot document) {
    return StreamBuilder<QuerySnapshot>(
      //フォローした人などのユーザー名を取得している。ログインユーザーのnoticeDBに保存されているuserIdを利用して
        stream: Firestore.instance
            .collection('users')
            .where('userId', isEqualTo: document['userId'])
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
         // userInformation = snapshot.data.documents[0];
    if (snapshot.data.documents.length == 0) {
      //ユーザー未登録の人がいいねしたのを表示するときの処理
    return Text('未登録さんがいいねしました');
    } else if (document['favorite'] == "fav") {
      //登録済みの人がいいねしたのを表示する処理
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
              child: Container(
              margin: EdgeInsets.only(left: 10, right:10 ),
              child:Row(children: <Widget>[
                Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(
                                snapshot.data.documents[0]['photoUrl'])))),
                SizedBox(
                  width: 20.0,
                ),
                Text("${snapshot.data.documents[0]['userName']}さんがいいねしました"),
                SizedBox(
                  width: 15.0,
                ),
                Container(
                  width: 40.0,
                  height: 40.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2.0),
                    child: Image.network(
                      //横幅がが長くならない
                      document['url'], fit: BoxFit.cover,
                    ),
                  ),
                ),

              ])));
          // Text(snapshot.data.documents[0]['userName']);

        }else if (document['follow'] == "fol") {
      //登録済みの人がフォローしたのを表示する処理
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
              child: Container(
              margin: EdgeInsets.only(left: 10, right:10 ),
              child:Row(children: <Widget>[
                Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(
                                snapshot.data.documents[0]['photoUrl'])))),
                SizedBox(
                  width: 20.0,
                ),
                Text("${snapshot.data.documents[0]['userName']}さんがあなたをフォローしました"),


              ])));
          // Text(snapshot.data.documents[0]['userName']);
          }else if (document['message'] == "mes") {
      //登録済みの人がフォローしたのを表示する処理
      return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: const RouteSettings(name: "/MessagePage"),
                      builder: (BuildContext context) =>
                          //表示されている名前のユーザーIDをUserPageに渡している
                      MessagePage(document)),
                );
              },
              child: Container(
              margin: EdgeInsets.only(left: 10, right:10 ),
              child:Row(children: <Widget>[
                Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(
                                snapshot.data.documents[0]['photoUrl'])))),
                SizedBox(
                  width: 20.0,
                ),
                Column(children: <Widget>[
                  Text("${snapshot.data.documents[0]['userName']}さんがあなたの投稿にコメントしました"),


                  Container(
                    width: 40.0,
                    height: 40.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2.0),
                      child: Image.network(
                        //横幅がが長くならない
                        document['url'], fit: BoxFit.cover,
                      ),
                    ),
                  ),

                ],)

              ])));
          // Text(snapshot.data.documents[0]['userName']);
          }
        }


        );
  }
}
