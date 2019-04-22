import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/parts/Image_url.dart';
import 'package:flutter_cos/favorites/favorite.dart';
import 'package:flutter_cos/other_pages/login_page.dart';
import 'package:flutter_cos/main.dart';
import 'package:flutter_cos/message/message_page.dart';
import 'package:flutter_cos/searches/search_result_page.dart';
import 'package:flutter_cos/parts/user_name_bar.dart';

//投稿をタッチすると表示される画面

class _FormData {
  String comment;

  //現在の時刻を代入
  DateTime time;

  String url;

  var tagList = [];
}

class PostDetails extends StatefulWidget {
  PostDetails(this.document);

  final DocumentSnapshot document;

  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  @override
  void initState() {
    super.initState();
  }

  final _FormData _data = _FormData();

  @override
  Widget build(BuildContext context) {
    _data.comment = widget.document['comment'];
    _data.url = widget.document['url'];
    _data.tagList = widget.document['tag'];
    _data.time = widget.document['time'];

    //こうした方がわかりやすい？
    final url = _data.url;
    final comment = _data.comment;
    final tagList = _data.tagList;
    final time = _data.time;

    final List<Widget> tag = tagList.map<Widget>((name) {
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

    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: SingleChildScrollView(
        child: buildPadding(context, url, comment, time, cardChildren),
      ),
    );
  }

  Widget buildPadding(BuildContext context, String url, String comment,
      DateTime time, cardChildren) {
    final documentSnapshot = widget.document;

    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Card(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          UserName(document: documentSnapshot),

          //写真表示
          ImageUrl(imageUrl: url),

          ListTile(
            title: Text(comment),

            //substringで表示する時刻を短縮している
            subtitle: Text(time.toString().substring(0, 10)),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: cardChildren,
          ),

          ButtonTheme.bar(
            child: ButtonBar(
              children: <Widget>[
                FavoriteButton(
                  document: documentSnapshot,
                ),
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
                              MessagePage(documentSnapshot)),
                    );
                  },
                )
              ],
            ),
          )
        ]),
      ),
    );
  }
}
