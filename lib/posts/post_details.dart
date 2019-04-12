import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/parts/Image_url.dart';
import 'package:flutter_cos/favorites/favorite.dart';
import 'package:flutter_cos/other_pages/login_page.dart';
import 'package:flutter_cos/main.dart';
import 'package:flutter_cos/other_pages/message_page.dart';
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

    DocumentReference _mainReference;

    _mainReference = Firestore.instance
        .collection('posts')
        .document(widget.document.documentID);

    final url = _data.url;
    final comment = _data.comment;
    final tagList = _data.tagList;
    final time = _data.time;

    final documentSnapshot = widget.document;

    final userNameRow = UserNameRow(context, documentSnapshot);

    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: SingleChildScrollView(
        child: buildPadding(context, userNameRow, url, comment, tagList, time),
      ),
    );
  }

  Widget buildPadding(BuildContext context, Widget userNameRow, String url,
      String comment, List<dynamic> tagList, DateTime time) {
    final documentSnapshot = widget.document;

    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Card(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          userNameRow,
          //写真表示
          ImageUrl(imageUrl: url),

          ListTile(
            //leading: const Icon(Icons.android),
            title: Text(comment),

            //substringで表示する時刻を短縮している
            subtitle: Text(time.toString().substring(0, 10)),
            //trailing: Text(_data.tagList.toString()),
          ),

          ButtonTheme.bar(
            child: ButtonBar(
              children: <Widget>[
                Row(
                    children: tagList
                        .map((item) => InkWell(
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
