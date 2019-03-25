import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/login.dart';
import 'dart:async';

uploadFavorite(document) async {
  var _savedDocumentID;

  //ここの処理もっと良い方法あるはず。
  Firestore.instance
      .collection('users')
      .document(firebaseUser.uid)
      .collection("favorite")
      .where("documentId", isEqualTo: document.documentID)
      .snapshots()
      .listen((data) => data.documents.forEach((doc) =>

          //空の時nullに上書きされない
          _savedDocumentID = doc["documentId"]));

  print("saveの$_savedDocumentID");

  DocumentReference _favoritedUserRef;
  DocumentReference _beFavoritedUserRef;
  DocumentReference _noticeFavoriteRef;

//document.documentIDはいいねした投稿のドキュメントID

  //いいねした人のDBにいいねした投稿のドキュメントIDを保存
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

  _noticeFavoriteRef = Firestore.instance
      .collection('users')
      .document(document['userId'])
      .collection("notice")
      .document();


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
        "userId" : firebaseUser.uid,
        "time": DateTime.now(),
      });
      _noticeFavoriteRef.setData({
        "documentId": document.documentID,
        "userId" : firebaseUser.uid,
        "time": DateTime.now(),

        //favoriteとフォローを識別するためにつけている
        "favorite": "fav",

        "url":  document["url"]
      });
    }
  });
}
