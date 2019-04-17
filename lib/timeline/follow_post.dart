import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/favorites/favorite.dart';
import 'package:flutter_cos/message/message_page.dart';
import 'package:flutter_cos/parts/Image_url.dart';
import 'package:flutter_cos/parts/user_name_bar.dart';
import 'package:flutter_cos/searches/search_result_page.dart';

class FollowPost extends StatelessWidget {
  final DocumentSnapshot document;
  const FollowPost({
    Key key,
    @required this.document,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            UserName(document: document),

            //写真表示
            ImageUrl(imageUrl: document["url"]),

            ListTile(
              title: Text(document["comment"]),

              //substringで表示する時刻を短縮している
              subtitle: Text(document["time"].toString().substring(0, 10)),
            ),

            ButtonTheme.bar(
              child: ButtonBar(
                children: <Widget>[
                  Row(
                      children: document["tag"]
                          .map<Widget>((item) => InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      settings: const RouteSettings(
                                          name: "/postDetails"),

                                      //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
                                      builder: (BuildContext context) =>
                                          SearchResultPage(item)),
                                );
                              },
                              child: Container(
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5.0),
                                      ),
                                    ),
                                    color: Colors.black12,
                                  ),
                                  margin: EdgeInsets.only(right: 5, left: 5),
                                  padding: EdgeInsets.all(5),
                                  child: Text(item))))
                          .toList()),
                  FavoriteButton(document: document),
                  FlatButton(
                    child: const Icon(Icons.comment),
                    onPressed: () {
                      print("コメントボタンを押しました");

                      //コメントページに画面遷移
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            settings: const RouteSettings(name: "/comment"),
                            builder: (BuildContext context) =>
                                MessagePage(document)),
                      );
                    },
                  )
                ],
              ),
            )
          ]),
        ),
      ],
    );
  }
}
