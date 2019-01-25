
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/main.dart';



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
      icon: Icon(Icons.exit_to_app),
      onPressed: () {
        //getGroupItem();



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
            stream: Firestore.instance.collection('posts').where("userId", isEqualTo: firebaseUser.uid).snapshots(),

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
            }),
      ),

    );
  }

  //投稿表示する処理
  Widget _MyPageList(BuildContext context, DocumentSnapshot document) {
    return Card(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        //写真表示
        ImageUrl(imageUrl: document['url']),

        ListTile(
            leading: const Icon(Icons.android),
            title: Text(document['comment']),

            //substringで表示する時刻を短縮している
            subtitle: Text(document['time'].toString().substring(0, 10))),

      ]),
    );
  }

}