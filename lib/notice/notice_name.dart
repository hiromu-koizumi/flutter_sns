import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/message/message_page.dart';
import 'package:flutter_cos/user_pages/user_page/user_page.dart';

class NoticeName extends StatelessWidget {
  final DocumentSnapshot document;

  const NoticeName({
    Key key,
    @required this.document,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      //フォローした人などのユーザー名を取得している。ログインユーザーのnoticeDBに保存されているuserIdを利用して
      stream: Firestore.instance
          .collection('users')
          .where('userId', isEqualTo: document['userId'])
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');

        switch (snapshot.data.documents.length.toString()) {
          //未登録者の通知を表示する処理。ユーザー情報のdocumentが0であるからこちらに割り振られる
          case "0":
            {
              if (document['favorite'] == "fav") {
                //ユーザー未登録の人がいいねしたのを表示するときの処理
                return Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 5, right: 5, top: 5),
                      child: Row(
                        children: <Widget>[
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
                        ],
                      ),
                    ),
                  ],
                );
              } else if (document['message'] == "mes") {
                //ユーザー未登録の人がコメントしたのを表示するときの処理
                return Column(
                  children: <Widget>[
                    InkWell(
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
                        margin: EdgeInsets.only(left: 5, right: 5, top: 5),
                        child: Row(
                          children: <Widget>[
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
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            }
            break;

          //ユーザー登録している人の通知を表示する処理
          case "1":
            {
              //何回も呼び出される
              if (document['favorite'] == "fav") {
                //登録済みの人がいいねしたのを表示する処理

                return Column(
                  children: <Widget>[
                    InkWell(
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
                        margin: EdgeInsets.only(left: 5, right: 5, top: 5),
                        child: Row(
                          children: <Widget>[
                            Material(
                              child: Image.network(
                                (snapshot.data.documents[0]['photoUrl']),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
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
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else if (document['follow'] == "fol") {
                //登録済みの人がフォローしたのを表示する処理

                return Column(
                  children: <Widget>[
                    InkWell(
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
                        margin: EdgeInsets.only(left: 5, right: 5, top: 5),
                        child: Row(
                          children: <Widget>[
                            Material(
                              child: Image.network(
                                (snapshot.data.documents[0]['photoUrl']),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            Text(
                                "${snapshot.data.documents[0]['userName']}さんがあなたをフォローしました"),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else if (document['message'] == "mes") {
                //登録済みの人がコメントしたのを表示する処理

                return Column(
                  children: <Widget>[
                    InkWell(
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
                        margin: EdgeInsets.only(left: 5, right: 5, top: 5),
                        child: Row(
                          children: <Widget>[
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
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            }
            break;

          default:
            {
              print("Invalid choice");
            }
            break;
        }
      },
    );
  }
}
