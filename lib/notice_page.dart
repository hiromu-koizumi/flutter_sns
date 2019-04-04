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


  //1回しか呼び出されない
//  @override
//  initState(){
//    super.initState();
//    print('aaaaaoooooooooo');
//    DocumentReference _followerReference;
//
//    Firestore.instance
//        .collection('users')
//        .document(firebaseUser.uid)
//        .collection("notice")
//        .orderBy("time", descending: true)
//        .limit(10)
//        .snapshots()
//        .listen((data) => data.documents.forEach((doc) =>
//
//    //空の時nullに上書きされない
//   // _savedDocumentID = doc["documentId"]));
//    _followerReference = Firestore.instance
//        .collection('users')
//        .document(firebaseUser.uid)
//        .collection("notice")
//        .document(doc['id'])));
//
//    Future.delayed(new Duration(seconds: 1), () {
//    _followerReference.updateData({
//      "kk": "aa",
//    });
//  });}

  @override
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
              .limit(10)
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

          print('aapppppp');
          switch (snapshot.data.documents.length.toString()) {
            //未登録者の通知を表示する処理。ユーザー情報のdocumentが0であるからこちらに割り振られる
            case "0":
              {
                if (document['favorite'] == "fav") {
                  //ユーザー未登録の人がいいねしたのを表示するときの処理
                  return Container(

                      margin: EdgeInsets.only(left: 5, right: 5,top: 5),
                      child: Row(children: <Widget>[
                        Text("未登録さんがいいねしました"),
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
                      ]));
                } else if (document['message'] == "mes") {
                  //ユーザー未登録の人がコメントしたのを表示するときの処理
                  return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              settings:
                                  const RouteSettings(name: "/MessagePage"),
                              builder: (BuildContext context) =>
                                  //表示されている名前のユーザーIDをUserPageに渡している
                                  MessagePage(document)),
                        );
                      },
                      child: Container(
                          margin: EdgeInsets.only(left: 5, right: 5,top: 5),
                          child: Row(children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text("未登録さんがあなたの投稿にコメントしました"),
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
                              ],
                            )
                          ])));
                }
              }
              break;

            //ユーザー登録している人の通知を表示する処理
            case "1":
              {
                //何回も呼び出される
                if (document['favorite'] == "fav") {
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
                          margin: EdgeInsets.only(left: 5, right: 5,top: 5),
                          child: Row(children: <Widget>[
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
                            Text(
                                "${snapshot.data.documents[0]['userName']}さんがいいねしました"),
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

                } else if (document['follow'] == "fol") {
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
                          margin: EdgeInsets.only(left: 5, right: 5,top: 5),
                          child: Row(children: <Widget>[
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
                            Text(
                                "${snapshot.data.documents[0]['userName']}さんがあなたをフォローしました"),
                          ])));
                  // Text(snapshot.data.documents[0]['userName']);
                } else if (document['message'] == "mes") {
                  //登録済みの人がフォローしたのを表示する処理
                  return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              settings:
                                  const RouteSettings(name: "/MessagePage"),
                              builder: (BuildContext context) =>
                                  //表示されている名前のユーザーIDをUserPageに渡している
                                  MessagePage(document)),
                        );
                      },
                      child: Container(
                          margin: EdgeInsets.only(left: 5, right: 5,top: 5),
                          child: Row(children: <Widget>[
                            Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: NetworkImage(snapshot
                                            .data.documents[0]['photoUrl'])))),
                            SizedBox(
                              width: 20.0,
                            ),
                            Column(
                              children: <Widget>[
                                Text(
                                    "${snapshot.data.documents[0]['userName']}さんがあなたの投稿にコメントしました"),
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
                              ],
                            )
                          ])));
                }
              }
              break;

            default:
              {
                print("Invalid choice");
              }
              break;
          }


        });
  }
}
