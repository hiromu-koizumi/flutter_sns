import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FollowingOrFollowerNumber extends StatelessWidget {
  final String userId;
  final String followingOrFollowers;

  const FollowingOrFollowerNumber({
    Key key,
    @required this.userId,
    this.followingOrFollowers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(userId)
            .collection(followingOrFollowers)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');

          return Text('${snapshot.data.documents.length}');
        });
  }
}
