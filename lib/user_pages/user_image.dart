import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserImage extends StatelessWidget {
  final String userId;

  const UserImage({
    Key key,
    @required this.userId,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');

          return Material(
            child: Image.network(
              (snapshot.data.documents[0]['photoUrl']),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(40.0),
            ),
            clipBehavior: Clip.hardEdge,
          );
        });
  }
}
