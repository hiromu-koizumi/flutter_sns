import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/favorite.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/main.dart';
import 'package:flutter_cos/message_page.dart';
import 'package:flutter_cos/user_page.dart';

//投稿をタッチすると表示される画面

class _FormData {
  String comment;

  //現在の時刻を代入
  DateTime time;

  String url;

  String imagePath;

}

class PostDetails extends StatefulWidget {

  PostDetails(this.document);
  final DocumentSnapshot document;

  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails>{

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
          leading: const Icon(Icons.android),
          title: userName(),
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                  settings: const RouteSettings(name: "/userPage"),
                  builder: (BuildContext context) =>
                      UserPage(widget.document)
              ),
            );
          },
        ),

        //写真表示
        ImageUrl(imageUrl: _data.url),

        ListTile(
          //leading: const Icon(Icons.android),
          title: Text(_data.comment),

          //substringで表示する時刻を短縮している
          subtitle: Text(_data.time.toString().substring(0, 10)),

        ),
        //編集ボタン

        ButtonTheme.bar(
          child: ButtonBar(
            children: <Widget>[
              favoriteButton(),
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
              )
            ],
          ),
        )
      ]),
    ))));
  }

  favoriteButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('users')
              .document(firebaseUser.uid)
              .collection("favorite")
              .where("documentID", isEqualTo: widget.document.documentID)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
            if (snapshot.data.documents.length == 0)
              return FlatButton(
                child: Icon(
                    Icons.favorite_border,
                  color: Colors.pinkAccent,
                ),
                onPressed: () {
                  print("いいねボタンを押しました");

                  //お気に入りボタン押した投稿のdocumentIDと時間を保存する処理
                  uploadFavorite(widget.document);
                },
              );
            return FlatButton(
              child: Icon(
                  Icons.favorite,
                color: Colors.pinkAccent,
              ),
              onPressed: () {
                print("いいねボタンを押しました");

                //お気に入りボタン押した投稿のdocumentIDと時間を保存する処理
                uploadFavorite(widget.document);
              },
            );
          }),
    );
  }

  //usernameの処理まとめられるとおもう。でもまとめると他人のユーザー名を表示させるのが難しい
  Widget userName() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(widget.document['userId'])
            .collection("profiles")
            .snapshots(),

        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          userInformation = snapshot.data.documents[0];

          if (snapshot.data.documents[0]['profile'] != null) {
            return Column(children: <Widget>[
              Text(snapshot.data.documents[0]['userName']),
              //Text(snapshot.data.documents[0]['profile']),
            ]);
          }else{
            return Text(snapshot.data.documents[0]['userName']);
          }
        }
    );
  }
}