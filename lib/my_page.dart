
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/main.dart';
import 'package:flutter_cos/post.dart';
import 'package:flutter_cos/setting.dart';



class MyPage extends StatefulWidget {

  @override
  _MyPageState createState() => _MyPageState();
}


class _MyPageState extends State<MyPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('MyPage'),
          actions: <Widget>[

      IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {

        //画面遷移
        Navigator.push(
          context,
          MaterialPageRoute(
              settings: const RouteSettings(name: "/setting"),
              builder: (BuildContext context) =>
                  SettingPage() //null 編集機能付けるのに必要っぽい
          ),
        );

      },
    ),]
      ),
      body:


Padding(
        padding: const EdgeInsets.all(8.0),

        child: StreamBuilder<QuerySnapshot>(

          //uidはユーザーの情報を取得する。firebaseUserにはログインしたユーザーが格納されている。だからここではログインしたユーザーの情報を取得している。
          //stream: Firestore.instance.collection('users').document(firebaseUser.uid).collection("transaction").snapshots(),
              //whereで自分のユーザーIDと同じユーザーIDを持った投稿を取り出している。
            stream: Firestore.instance.collection('posts').orderBy("time", descending: true).where("userId", isEqualTo: firebaseUser.uid).snapshots(),

            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return const Text('Loading...');
              return ListView.builder(

                //データをいくつ持ってくるかの処理
                itemCount: snapshot.data.documents.length,
                padding: const EdgeInsets.only(top: 10.0),

                //投稿を表示する処理にデータを送っている
                itemBuilder: (context, index) =>
                    _MyPageList(context, snapshot.data.documents[index]),
              );
            }
            )
        ),

           // ])
     // ])

   );
  }

  //投稿表示する処理
  Widget _MyPageList(BuildContext context, DocumentSnapshot document) {
    return Card(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        //写真表示

        //_aaa(),

        ImageUrl(imageUrl: document['url']),

        ListTile(
            leading: const Icon(Icons.android),
            title: Text(document['comment']),

            //substringで表示する時刻を短縮している
            subtitle: Text(document['time'].toString().substring(0, 10))),

        //編集ボタン
        ButtonTheme.bar(
          child: ButtonBar(
            children: <Widget>[
              FlatButton(
                child: const Text('編集'),
                onPressed: () {
                  print("編集ボタンを押しました");
                  //編集処理,画面遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        settings: const RouteSettings(name: "/edit"),

                        //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
                        builder: (BuildContext context) => PostPage(document)),
                  );
                },
              )
            ],
          ),
        )
      ]),
    );
  }

  //ユーザー名とプロフィールを表示する。ちゃんと取得、表示できる。
Widget _user(){
  StreamBuilder(
  stream: Firestore.instance.collection('users').document(firebaseUser.uid).collection("transaction").snapshots(),
  builder: (context, snapshot) {
  if (!snapshot.hasData) return Text('Loading');
  return Column(
  children: <Widget>[
  Text(snapshot.data.documents[0]['userName']),
  Text(snapshot.data.documents[0]['profile']),
 ]
  );
  }
  );
}




}

