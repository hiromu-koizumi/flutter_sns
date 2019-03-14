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

  _favoritedUserRef = Firestore.instance
      .collection('users')
      .document(firebaseUser.uid)
      .collection("favorite")
      .document(document.documentID);

  _beFavoritedUserRef = Firestore.instance
      .collection('users')
      .document(document['userId'])
      .collection("posts")
      .document(document.documentID)
      .collection('beFavorited')
  //削除できるようにdocumentIDを指定している
      .document(document.documentID);


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
        "userId" : document["userId"],
        "time": DateTime.now(),
      });
    }
  });
}
