import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/user_pages/user_page/user_page.dart';

class MessageName extends StatelessWidget {
  final DocumentSnapshot document;
  const MessageName({
    Key key,
    @required this.document,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
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
