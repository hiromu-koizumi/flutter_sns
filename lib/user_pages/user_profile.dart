import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  final DocumentSnapshot document;

  const UserProfile({
    Key key,
    @required this.document,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        children: <Widget>[
          //左端に寄せるためにRow使用している。もっと良いコードあるはず。
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                document['userName'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              //テキストを折り返すためにFlexible、softWrap: trueをつけている
              //上でFlexible使用しているがこちらでもつけないと折り返せなかった。
              Flexible(
                child: Container(
                  child: Text(
                    document['profile'],
                    softWrap: true,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
