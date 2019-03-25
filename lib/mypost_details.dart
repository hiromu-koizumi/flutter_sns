import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/favorite_page.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/main.dart';
import 'package:flutter_cos/message_page.dart';
import 'package:flutter_cos/post.dart';
import 'package:flutter_cos/user_page.dart';

//投稿をタッチすると表示される画面

class _FormData {
  String comment;

  //現在の時刻を代入
  DateTime time;

  String url;

  String imagePath;

}

class MyPostDetails extends StatefulWidget {

  MyPostDetails(this.document);
  final DocumentSnapshot document;

  @override
  _MyPostDetailsState createState() => _MyPostDetailsState();
}

class _MyPostDetailsState extends State<MyPostDetails>{

  final _FormData _data = _FormData();

  @override
  Widget build(BuildContext context) {

    _data.comment = widget.document['comment'];
    _data.url = widget.document['url'];
    _data.imagePath = widget.document['imagePath'];
    _data.time = widget.document['time'];

    DocumentReference _mainReference;

    _mainReference = Firestore.instance.collection('posts').document(widget.document.documentID);

    return Scaffold (
        appBar: AppBar(
            title: const Text('')
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Card(
                  child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[

                    ListTile(
                      title: userName(),
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              settings: const RouteSettings(name: "/userPage"),
                              builder: (BuildContext context) =>
                                  UserPage(widget.document['userId'])
                          ),
                        );
                      },
                    ),

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
                                    settings: const RouteSettings(name: "/comment"),

                                    builder: (BuildContext context) =>
                                        MyFavoritePage(widget.document)),
                              );
                            },
                          ),FlatButton(
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

                    ),
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
            .document(_data.imagePath)
            .collection("beFavorited")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          //userInformation = snapshot.data.documents[0];

          return Text('${snapshot.data.documents.length}人がいいねしたよ！！');
        });
  }

  //usernameの処理まとめられるとおもう。でもまとめると他人のユーザー名を表示させるのが難しい
  Widget userName() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .where('userId', isEqualTo:widget.document['userId'])
            .snapshots(),

        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          userInformation = snapshot.data.documents[0];


          return Row(
            children: <Widget>[
              Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new NetworkImage(
                              snapshot.data.documents[0]['photoUrl'])))),
              SizedBox(
                width: 20.0,

              ),

              Text(snapshot.data.documents[0]['userName']),

            ],
          );
        }
    );
  }
}