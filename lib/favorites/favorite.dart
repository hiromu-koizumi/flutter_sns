import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/other_pages/login_page.dart';
import 'dart:async';

import 'package:uuid/uuid.dart';

class FavoriteButton extends StatelessWidget {
  final DocumentSnapshot document;

  const FavoriteButton({
    Key key,
    @required this.document,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('users')
              .document(firebaseUser.uid)
              .collection("favorite")
              .where("documentId", isEqualTo: document.documentID)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
            final isFavorite = snapshot.data.documents.isNotEmpty;

            return _buildBorderFlatButton(isFavorite, () {
              print("いいねボタンを押しました");

              //お気に入りボタン押した投稿のdocumentIDと時間を保存する処理
              uploadFavorite(document);
            });
          }),
    );
  }

  Widget _buildBorderFlatButton(bool isFavorite, VoidCallback onPressed) {
    final favoriteIcon = isFavorite ? Icons.favorite : Icons.favorite_border;
    return FlatButton(
      child: Icon(
        favoriteIcon,
        color: Colors.pinkAccent,
      ),
      onPressed: onPressed,
    );
  }
}

uploadFavorite(document) async {
  var _savedDocumentID;

  //ここの処理もっと良い方法あるはず。
  Firestore.instance
      .collection('users')
      .document(firebaseUser.uid)
      .collection("favorite")
      .where("documentId", isEqualTo: document.documentID)
      .snapshots()
      //上のコードで十分なはずだがエラー出る。上も一応動く。forEach使う必要ない
      .listen((data) => data.documents.forEach((doc) =>

          //空の時nullに上書きされない
          _savedDocumentID = doc["documentId"]));

  print("saveの$_savedDocumentID");

  DocumentReference _favoritedUserRef;
  DocumentReference _beFavoritedUserRef;
  DocumentReference _noticeFavoriteRef;

  //document.documentIDはいいねした投稿のドキュメントID

  //いいねした人のDBにいいねした投稿のドキュメントIDを保存。いいね押したことあるか判定するために必要
  _favoritedUserRef = Firestore.instance
      .collection('users')
      .document(firebaseUser.uid)
      .collection("favorite")
      .document(document.documentID);

  //いいねされた人のDBにいいねした人のユーザーIdなどを保存
  _beFavoritedUserRef = Firestore.instance
      .collection('users')
      .document(document['userId'])
      .collection("posts")
      .document(document.documentID)
      .collection('beFavorited')
      //削除できるようにユーザーIdを指定している
      .document(firebaseUser.uid);

  //noticeに既読したことを保存するためにidが必要
  final String uuid = Uuid().v1();
  final _id = uuid;

  _noticeFavoriteRef = Firestore.instance
      .collection('users')
      .document(document['userId'])
      .collection("notice")
      .document(_id);

  //処理を1秒遅らせている。遅らせないとsavedDocumentIDが更新される前にこちらの処理をしてしまう。
  Future.delayed(new Duration(seconds: 1), () {
    if (_savedDocumentID == document.documentID) {
      print("saveの$_savedDocumentID");
      print('消去した');
      _favoritedUserRef.delete();
      _beFavoritedUserRef.delete();
    } else {
      print('saveした${_savedDocumentID}');
      _favoritedUserRef.setData({
        "documentId": document.documentID,
        "time": DateTime.now(),
      });
      _beFavoritedUserRef.setData({
        "documentId": document.documentID,
        "userId": firebaseUser.uid,
        "time": DateTime.now(),
      });
      _noticeFavoriteRef.setData({
        "documentId": document.documentID,
        "userId": firebaseUser.uid,
        "time": DateTime.now(),
        "id": _id,

        //favoriteとフォローを識別するためにつけている
        "favorite": "fav",

        "url": document["url"],
        "read": false
      });
    }
  });
}
