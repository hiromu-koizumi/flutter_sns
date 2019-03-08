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
      .where("documentID", isEqualTo: document.documentID)
      .snapshots()
      .listen((data) =>
      data.documents.forEach((doc) =>

      //空の時nullに上書きされない
      _savedDocumentID = doc["documentID"]));

 DocumentReference _favoriteReference;
 _favoriteReference =
      Firestore.instance.collection('users').document(firebaseUser.uid)
         .collection("favorite")
         .document(document.documentID);

 //処理を1秒遅らせている。遅らせないとsavedDocumentIDが更新される前にこちらの処理をしてしまう。
 Future.delayed(new Duration(seconds: 1), () {
 if (_savedDocumentID == document.documentID) {
   print('消去した');
   _favoriteReference.delete();
 } else {
   print('saveした${_savedDocumentID}');
   _favoriteReference.setData({
     "documentID": document.documentID,
     "time": DateTime.now(),
   });
 }

  });
}