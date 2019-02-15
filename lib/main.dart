import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/message_page.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/my_page.dart';
import 'package:flutter_cos/post.dart';

//ユーザー登録
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

//firebaseに保存されるテキスト。const再代入不可な変数。const変数が指す先のメモリ領域も変更不可
void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cosco',
      routes: <String, WidgetBuilder>{
        //はじめは自動的に'/'の画面に遷移する
        '/': (_) => Splash(),
        '/timeline': (_) => TimeLine(),
      },
      // home: TimeLine(),
    );
  }
}

class TimeLine extends StatefulWidget {
  @override
  _TimeLineState createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {

  var _savedDocumentID;

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("リスト画面"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              print("login");

              //ログイン画面表示
              showBasicDialog(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              print("mypage");
              //画面遷移
              Navigator.push(
                context,
                MaterialPageRoute(
                    settings: const RouteSettings(name: "/myPage"),
                    builder: (BuildContext context) => MyPage()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(

            //uidはユーザーの情報を取得する。firebaseUserにはログインしたユーザーが格納されている。だからここではログインしたユーザーの情報を取得している。
            //stream: Firestore.instance.collection('users').document(firebaseUser.uid).collection("transaction").snapshots(),

            //orderByで新しく投稿したものを上位に表示させている。投稿に保存されているtimeを見て判断している.
            stream: Firestore.instance
                .collection('posts')
                .orderBy("time", descending: true)
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
                    _buildListItem(context, snapshot.data.documents[index]),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            print("新規作成ボタンを押しました");

            //画面遷移
            Navigator.push(
              context,
              MaterialPageRoute(
                  settings: const RouteSettings(name: "/new"),
                  builder: (BuildContext context) =>
                      PostPage(null) //null 編集機能付けるのに必要っぽい
                  ),
            );
          }),
    );
  }

 bool favorite;
  //投稿表示する処理
  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {




    return Card(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        //写真表示
        ImageUrl(imageUrl: document['url']),

        ListTile(
          leading: const Icon(Icons.android),
          title: Text(document['comment']),

          //substringで表示する時刻を短縮している
          subtitle: Text(document['time'].toString().substring(0, 10)),
        ),
        //編集ボタン

    ButtonTheme.bar(
          child: ButtonBar(
            children: <Widget>[
              FlatButton(
                child: Icon(
                  favorite == true ? Icons.favorite : Icons.favorite_border,
                  color: favorite == true ? Colors.red : Colors.black38,
                ),
                onPressed: () {

                  print("いいねボタンを押しました");
                  print("${document.documentID}");

                  //お気に入りボタン押した投稿のdocumentIDと時間を保存する処理
                  uploadFavolite(document);

                  //ハートボタンが押されたことを伝えている。これがあることで更新できハートがすぐ赤くなる。
                  setState(() {
                    if (favorite != true) {
                      favorite = true;
                    } else {
                      favorite = false;
                    }
                  });
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

                        //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
                        builder: (BuildContext context) =>
                            MessagePage(document)),
                  );
                },
              )
            ],
          ),
        )
      ]),
    );
  }

   uploadFavolite(document) {

     savedDocumentIDSub(document);

     favSaveCheck(document);


  }

   savedDocumentIDSub(document) {
    Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection("favolite")
        .where("documentID", isEqualTo: document.documentID)
        .snapshots()
        .listen((data) =>
        data.documents.forEach((doc) =>

        //空の時nullに上書きされない
        _savedDocumentID = doc["documentID"]));
  }

  favSaveCheck(document){
    DocumentReference _favoliteReference;
    _favoliteReference = Firestore.instance.collection('users').document(firebaseUser.uid).collection("favolite").document();

    //処理を10秒遅らせている。遅らせないとsavedDocumentIDが更新される前にこちらの処理をしてしまう。
    Future.delayed(new Duration(seconds: 10), (){
      if (_savedDocumentID == document.documentID) {
       return print('saveなし${_savedDocumentID}');
      }else{
        print('saveした${_savedDocumentID}');
        _favoliteReference.setData({
          "documentID": document.documentID,
          "time": DateTime.now(),
        });
      }
    });
  }
}


//urlから画像を表示する処理
class ImageUrl extends StatelessWidget {
  final String imageUrl;

  ImageUrl({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
    );
  }
}
