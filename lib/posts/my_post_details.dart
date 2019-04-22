import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/parts/Image_url.dart';
import 'package:flutter_cos/favorites/favorite_page.dart';
import 'package:flutter_cos/other_pages/login_page.dart';
import 'package:flutter_cos/message/message_page.dart';
import 'package:flutter_cos/posts/post_page.dart';
import 'package:flutter_cos/searches/search_result_page.dart';
import 'package:flutter_cos/parts/user_name_bar.dart';

//投稿をタッチすると表示される画面

class _FormData {
  String comment;

  //現在の時刻を代入
  DateTime time;

  String url;

  String documentId;

  var tagList = [];
}

class MyPostDetails extends StatefulWidget {
  MyPostDetails(this.document);

  final DocumentSnapshot document;

  @override
  _MyPostDetailsState createState() => _MyPostDetailsState();
}

class _MyPostDetailsState extends State<MyPostDetails> {
  final _FormData _data = _FormData();

  @override
  Widget build(BuildContext context) {
    _data.comment = widget.document['comment'];
    _data.url = widget.document['url'];
    _data.time = widget.document['time'];
    _data.documentId = widget.document['documentId'];
    _data.tagList = widget.document['tag'];

    final List<Widget> tag = _data.tagList.map<Widget>((name) {
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
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: Card(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              UserName(document: widget.document),

              //写真表示
              ImageUrl(imageUrl: _data.url),

              //編集ボタン
              ButtonTheme.bar(
                child: ButtonBar(
                  alignment: MainAxisAlignment.start,
                  children: <Widget>[
                    FlatButton(
                      child: loveNumber(),
                      onPressed: () {
                        //コメントページに画面遷移
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              settings: const RouteSettings(name: "/comment"),
                              builder: (BuildContext context) =>
                                  MyFavoritePage(widget.document)),
                        );
                      },
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
                                  MessagePage(widget.document)),
                        );
                      },
                    ),
                    FlatButton(
                      child: const Icon(Icons.more_horiz),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              settings: const RouteSettings(name: "/PostPage"),
                              builder: (BuildContext context) =>
                                  PostPage(widget.document)),
                        );
                      },
                    )
                  ],
                ),
              ),

              ListTile(
                //leading: const Icon(Icons.android),
                title: Text(_data.comment),

                //substringで表示する時刻を短縮している
                subtitle: Text(_data.time.toString().substring(0, 10)),
                //trailing: Text(_data.tagList.toString()),
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: cardChildren,
              ),
            ]),
          ),
        ),
      ),
    );
  }

  //love数をDBから取得し表示
  Widget loveNumber() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .collection("posts")
            .document(_data.documentId)
            .collection("beFavorited")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          //userInformation = snapshot.data.documents[0];

          return Text('${snapshot.data.documents.length}人がいいねしたよ！！');
        });
  }
}
