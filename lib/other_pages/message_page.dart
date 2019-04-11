import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/other_pages/login_page.dart';
import 'package:flutter_cos/user_pages/user_page.dart';
import 'package:uuid/uuid.dart';

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

  //起動時にユーザー名取得している。
  @override
  void initState() {
    super.initState();
    userNameSubstitution();
  }

  @override
  Widget build(BuildContext context) {
    //scaffoldにしてキーボードを出すと入力欄が上に上がりすぎる
    return Card(
      child: Column(
        children: <Widget>[
          SizedBox(height: 10),
          //右隅に配置するためのRow
          Row(
            children: <Widget>[
              IconButton(
                iconSize: 35,
                icon: Icon(Icons.keyboard_arrow_left),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),

          Flexible(
            child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection('posts')
                    //imagePathとドキュメントIDは同じ
                    .document(widget.document["documentId"])
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
                      if (document['userId'] == firebaseUser.uid) {
                        isOwnMessage = true;
                      }

                      //メッセージを右左どちらに表示するかを決めている
                      return isOwnMessage
                          ? _ownMessage(document)
                          : _message(document);
                    },
                    itemCount: snapshot.data.documents.length,
                  );
                }),
          ),

          //線
          Divider(height: 1.0),

          Container(
            margin: EdgeInsets.only(bottom: 50.0, right: 10.0, left: 10.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: TextField(
                    controller: _controller,

                    //チェックマークを押したときも送信できるようにしている
                    onSubmitted: _handleSubmit,
                    decoration: InputDecoration.collapsed(hintText: "メッセージの送信"),
                  ),
                ),
                Container(
                  child: IconButton(
                      icon: Icon(
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
    );
  }

  Widget _ownMessage(DocumentSnapshot document) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          Text(document["message"]),
        ],
      )
    ]);
  }

  Widget _message(DocumentSnapshot document) {
    return Row(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            _messageName(document),
          ],
        ),
        Text(document["message"])
      ],
    );
  }

  _handleSubmit(String message) {
    if (message != "") {
      _controller.text = "";
      print(message);

      DocumentReference _messageRef;
      _messageRef = Firestore.instance
          .collection('posts')
          .document(widget.document.documentID);

      _messageRef.collection("chat_room").add({
        "message": message,
        "created_at": DateTime.now(),
        "userId": firebaseUser.uid,
        "userName": _userName
      }).then((val) {
        print("成功です");
        print("$_userName");
      }).catchError((err) {
        print(err);
      });

      if (firebaseUser.uid != widget.document['userId']) {
        DocumentReference _noticeMessageRef;
          //noticeに既読したことを保存するためにidが必要
      final String uuid = Uuid().v1();
      final _id = uuid;
        _noticeMessageRef = Firestore.instance
            .collection('users')
            .document(widget.document['userId'])
            .collection("notice")
            .document(_id);

        _noticeMessageRef.setData({
          "documentId": widget.document.documentID,
          "userId": firebaseUser.uid,
          "message": "mes",
          "url": widget.document["url"],
          "time": DateTime.now(),
          "id": _id,
          "read": false
        });
      }
    }
  }

  //_userNameという変数にfirebaseに保存されているユーザー名を代入
  userNameSubstitution() {
    Firestore.instance
        .collection('users')
        .where('userId', isEqualTo: firebaseUser.uid)
        .snapshots()
        .listen((data) =>
            data.documents.forEach((doc) => _userName = doc["userName"]));
  }

  Widget _messageName(DocumentSnapshot document) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .where('userId', isEqualTo: document['userId'])
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          // userInformation = snapshot.data.documents[0];

          //ユーザ登録していない人としている人で処理を分けている。
          if (snapshot.data.documents.length == 0) {
            return Container(
              //margin: EdgeInsets.only(),
              child: Text('未登録さん'),
            );
          } else {
            return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        settings: const RouteSettings(name: "/userPage"),
                        builder: (BuildContext context) =>
                            //表示されている名前のユーザーIDをUserPageに渡している
                            UserPage(document['userId'])),
                  );
                },
                child: Column(
                  children: <Widget>[
                    Material(
                      child: Image.network(
                        (snapshot.data.documents[0]['photoUrl']),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(snapshot.data.documents[0]['userName']),
                  ],
                ));
            // Text(snapshot.data.documents[0]['userName']);
          }
        });
  }
}