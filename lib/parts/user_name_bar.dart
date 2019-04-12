import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/user_pages/user_page.dart';

Widget UserNameRow(BuildContext context, DocumentSnapshot document) {
  return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('users')
          .where('userId', isEqualTo: document['userId'])
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        return ListTile(
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
          leading: Material(
            child: Image.network(
              (snapshot.data.documents[0]['photoUrl']),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            clipBehavior: Clip.hardEdge,
          ),
          title: Text(snapshot.data.documents[0]['userName']),
        );
      });
}
