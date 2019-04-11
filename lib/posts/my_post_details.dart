import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/parts/Image_url.dart';
import 'package:flutter_cos/favorites/favorite_page.dart';
import 'package:flutter_cos/other_pages/login_page.dart';
import 'package:flutter_cos/other_pages/message_page.dart';
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

    DocumentReference _mainReference;

    _mainReference = Firestore.instance
        .collection('posts')
        .document(widget.document.documentID);

    return Scaffold(
        appBar: AppBar(title: const Text('')),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Card(
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    userName(context, widget.document),

                    //写真表示
                    ImageUrl(imageUrl: _data.url),

                    //編集ボタン
                    ButtonTheme.bar(
                      child: ButtonBar(
                        alignment: MainAxisAlignment.start,
                        children: <Widget>[
//                          favoriteButton(),
                          FlatButton(
                            child: loveNumber(),
                            onPressed: () {
                              //コメントページに画面遷移
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    settings:
                                        const RouteSettings(name: "/comment"),
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
                                    settings:
                                        const RouteSettings(name: "/comment"),
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
                                    settings:
                                        const RouteSettings(name: "/PostPage"),
                                    builder: (BuildContext context) =>
                                        PostPage(widget.document)),
                              );
                            },
                          )
                        ],
                      ),
                    ),

                    Row(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              _data.comment,
                              style: TextStyle(fontSize: 17),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            //substringで表示する時刻を短縮している
                            Text(
                                _data.time.toString().substring(
                                      0,
                                      10,
                                    ),
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black26)),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                        SizedBox(
                          width: 25,
                        ),
                        Row(
                            children: _data.tagList
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
                                        margin:
                                            EdgeInsets.only(right: 5, left: 5),
                                        padding: EdgeInsets.all(5),
                                        child: Text(item))))
                                .toList()),
                      ],
                    )
                  ]),
                ))));
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
