//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter_cos/my_page.dart';
//import 'package:flutter_cos/user_page.dart';
//
//class UserName {
//  userName(document) {
////    return StreamBuilder<QuerySnapshot>(
////        stream: Firestore.instance
////            .collection('users')
////            .where('userId', isEqualTo: document['userId'])
////            .snapshots(),
////
////        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
////          if (!snapshot.hasData) return const Text('Loading...');
////
////          return Row(
////            children: <Widget>[
////              Container(
////                  width: 40.0,
////                  height: 40.0,
////                  decoration: new BoxDecoration(
////                      shape: BoxShape.circle,
////                      image: new DecorationImage(
////                          fit: BoxFit.fill,
////                          image: new NetworkImage(
////                              snapshot.data.documents[0]['photoUrl'])))),
////              SizedBox(
////                width: 20.0,
////
////              ),
////
////              Text(snapshot.data.documents[0]['userName']),
////
////            ],
////          );
////          // Text(snapshot.data.documents[0]['userName']);
////
////        }
////    );
//
//
//    return StreamBuilder<QuerySnapshot>(
//        stream: Firestore.instance
//            .collection('users')
//            .where('userId', isEqualTo:document['userId'])
//            .snapshots(),
//        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//          if (!snapshot.hasData) return const Text('Loading...');
//
//          return InkWell(
//              onTap: () {
//                Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                      settings: const RouteSettings(name: "/userPage"),
//                      builder: (BuildContext context) =>
//                      //表示されている名前のユーザーIDをUserPageに渡している
//                      UserPage(document['userId'])),
//                );
//              },
//              child: Row(
//                children: <Widget>[
//                  Container(
//                      width: 40.0,
//                      height: 40.0,
//                      decoration: new BoxDecoration(
//                          shape: BoxShape.circle,
//                          image: new DecorationImage(
//                              fit: BoxFit.fill,
//                              image: new NetworkImage(
//                                  snapshot.data.documents[0]['photoUrl'])))),
//                  SizedBox(
//                    width: 20.0,
//                  ),
//                  Text(snapshot.data.documents[0]['userName']),
//                ],
//              ));
//          // Text(snapshot.data.documents[0]['userName']);
//        });
//  }
//}