import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/user_pages/user_page/user_page.dart';

class NameSearchResult extends StatelessWidget {
  final DocumentSnapshot document;
  const NameSearchResult({
    Key key,
    @required this.document,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: "/userPage"),
                  builder: (BuildContext context) =>
                      //表示されている名前のユーザーIDをUserPageに渡している
                      UserPage(document['userId']),
                ));
          },
          child: Row(
            children: <Widget>[
              Material(
                child: Image.network(
                  (document['photoUrl']),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                clipBehavior: Clip.hardEdge,
              ),
              SizedBox(
                width: 20.0,
              ),
              Text(document['userName']),
            ],
          ),
        ),
      ],
    );
  }
}
