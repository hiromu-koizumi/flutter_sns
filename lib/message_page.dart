import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/login.dart';
import 'package:flutter_cos/my_page.dart';

class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();

  //タイムラインからのdocument引数を受け取るために記載
  MessagePage(this.document);

  final DocumentSnapshot document;


}

class _MessagePageState extends State<MessagePage> {
  final _controller = TextEditingController();

  var _userName = "";


  @override
  Widget build(BuildContext context) {

    //_userNameにfirebaseに保存されているユーザー名を代入する処理
    userNameSubstitution();

    return new Scaffold(
        appBar: new AppBar(
          title: Text('ChatRoom'),
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: <Widget>[
              Flexible(
                child: StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection('posts')
                        .document(widget.document.documentID)
                        .collection("chat_room")
                        .orderBy("created_at", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();
                      return ListView.builder(
                        padding: EdgeInsets.all(8.0),
                        reverse: true,
                        itemBuilder: (_, int index) {
                          DocumentSnapshot document =
                              snapshot.data.documents[index];

                          bool isOwnMessage = false;
                          if (document['user_name'] == _userName) {
                            isOwnMessage = true;
                          }

                          //メッセージを右左どちらに表示するかを決めている
                          return isOwnMessage
                              ? _ownMessage(document['message'], document['user_name'])
                              : _message(
                                  document['message'], document['user_name']);
                        },
                        itemCount: snapshot.data.documents.length,
                      );
                    }),
              ),
              new Divider(height: 1.0),
              Container(
                margin: EdgeInsets.only(bottom: 50.0, right: 10.0, left: 10.0),
                child: Row(
                  children: <Widget>[
                    new Flexible(
                      child: new TextField(
                        controller: _controller,
                        onSubmitted: _handleSubmit,
                        decoration:
                            new InputDecoration.collapsed(hintText: "メッセージの送信"),
                      ),
                    ),
                    new Container(
                      child: new IconButton(
                          icon: new Icon(
                            Icons.send,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            _handleSubmit(_controller.text);
                          }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _ownMessage(String message, String userName) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      Icon(Icons.person),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          Text(userName),
          Text(message),
        ],
      )
    ]);
  }

  Widget _message(String message, String userName) {
    return Row(
      children: <Widget>[
        Icon(Icons.person),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            Text(userName),
            Text(message),
          ],
        )
      ],
    );
  }

  _handleSubmit(String message) {
    _controller.text = "";
    print(message);

    DocumentReference _mainReference;
    _mainReference = Firestore.instance
        .collection('posts')
        .document(widget.document.documentID);

    _mainReference.collection("chat_room").add({
      "user_name": _userName,
      "message": message,
      "created_at": DateTime.now()
    }).then((val) {
      print("成功です");
      print("$_userName");
    }).catchError((err) {
      print(err);
    });
  }

  //_userNameという変数にfirebaseに保存されているユーザー名を代入
Widget userNameSubstitution() {
  Firestore.instance
      .collection('users')
      .document(firebaseUser.uid)
      .collection("transaction")
      .snapshots()
      .listen((data) =>
      data.documents.forEach((doc) => _userName = doc["userName"]));
}





//  Widget user() {
//    StreamBuilder(
//        stream: Firestore.instance
//            .collection('users')
//            .document(firebaseUser.uid)
//            .collection("transaction")
//            .snapshots(),
//        builder: (context, snapshot) {
//          if (!snapshot.hasData) return Text('Loading');
//          return Column(children: <Widget>[
//            Text(snapshot.data.documents[0]['userName']),
//           Text(snapshot.data.documents[0]['profile']),
//          ]);
//        });
//  }

}

//class _MessagePageState extends State<MessagePage> {

//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: const Text("コメント画面"),
//        actions: <Widget>[
//          IconButton(
//            icon: Icon(Icons.exit_to_app),
//            onPressed: () {
//              print("login");
//
//              //ログイン画面表示
//              showBasicDialog(context);
//            },
//          ),
//          IconButton(
//            icon: Icon(Icons.account_circle),
//            onPressed: () {
//              print("mypage");
//              //画面遷移
//              Navigator.push(
//                context,
//                MaterialPageRoute(
//                    settings: const RouteSettings(name: "/myPage"),
//                    builder: (BuildContext context) =>
//                        MyPage()
//                ),
//              );
//            },
//          )
//        ],
//      ),
//
//
//      body: Padding(
//        padding: const EdgeInsets.all(8.0),
//        child: StreamBuilder<QuerySnapshot>(
//
//          //uidはユーザーの情報を取得する。firebaseUserにはログインしたユーザーが格納されている。だからここではログインしたユーザーの情報を取得している。
//          //stream: Firestore.instance.collection('users').document(firebaseUser.uid).collection("transaction").snapshots(),
//
//
//          //orderByで新しく投稿したものを上位に表示させている。投稿に保存されているtimeを見て判断している.
//            stream: Firestore.instance.collection('posts').orderBy("time", descending: true).snapshots(),
//
//            builder:
//                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//              if (!snapshot.hasData) return const Text('Loading...');
//              return ListView.builder(
//                //データをいくつ持ってくるかの処理
//                itemCount: snapshot.data.documents.length,
//                padding: const EdgeInsets.only(top: 10.0),
//
//                //投稿を表示する処理にデータを送っている
//                itemBuilder: (context, index) =>
//                    _buildListItem(context, snapshot.data.documents[index]),
//              );
//            }),
//
//      ),
//
//    );
//  }
//
//  //投稿表示する処理
//  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
//    return Card(
//      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
//
//        ListTile(
//          leading: const Icon(Icons.android),
//          title: Text(document['comment']),
//
//          //substringで表示する時刻を短縮している
//          subtitle: Text(document['time'].toString().substring(0, 10)),
//
//
//        ),
//
//      ]),
//
//    );
//  }
//}
