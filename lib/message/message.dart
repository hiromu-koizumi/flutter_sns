import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/message/message_name.dart';

class Message extends StatelessWidget {
  final DocumentSnapshot document;
  const Message({
    Key key,
    @required this.document,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            MessageName(document: document),
          ],
        ),
        Text(document["message"])
      ],
    );
  }
}
