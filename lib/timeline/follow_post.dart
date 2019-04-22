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
    final List<Widget> tag = document["tag"].map<Widget>((name) {
      return InputChip(
        label: Text(name),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                settings: const RouteSettings(name: "/postSearch"),
                builder: (BuildContext context) => SearchResultPage(name)),
          );
        },
      );
    }).toList();

    final List<Widget> cardChildren = <Widget>[
      Container(
        padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
        alignment: Alignment.center,
        //child: Text("タグ", textAlign: TextAlign.start),
      ),
    ];
    if (tag.isNotEmpty)
      cardChildren.add(
        Wrap(
          children: tag.map<Widget>(
            (Widget chip) {
              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: chip,
              );
            },
          ).toList(),
        ),
      );

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

            Column(
              mainAxisSize: MainAxisSize.min,
              children: cardChildren,
            ),

            ButtonTheme.bar(
              child: ButtonBar(
                children: <Widget>[
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
