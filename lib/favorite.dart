import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/login.dart';
import 'dart:async';

  var _savedDocumentID;
  var savedUserID;

uploadFavorite(document) async {
//    savedDocumentIDSub(document);
//    favSaveCheck(document);

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
         .document();

 //処理を1秒遅らせている。遅らせないとsavedDocumentIDが更新される前にこちらの処理をしてしまう。
 Future.delayed(new Duration(seconds: 1), () {
 if (_savedDocumentID == document.documentID) {
   return print('saveなし${_savedDocumentID}');
 } else {
   print('saveした${_savedDocumentID}');
   _favoriteReference.setData({
     "documentID": document.documentID,
     "time": DateTime.now(),
   });
 }

  });
}



//  savedDocumentIDSub(document) {
//     Firestore.instance
//        .collection('users')
//        .document(firebaseUser.uid)
//        .collection("favorite")
//        .where("documentID", isEqualTo: document.documentID)
//        .snapshots()
//        .listen((data) =>
//        data.documents.forEach((doc) =>
//
//        //空の時nullに上書きされない
//        _savedDocumentID = doc["documentID"]));
//  }
//
//  favSaveCheck(document) {
//    DocumentReference _favoriteReference;
//    _favoriteReference =
//        Firestore.instance.collection('users').document(firebaseUser.uid)
//            .collection("favorite")
//            .document();
//
//    //処理を10秒遅らせている。遅らせないとsavedDocumentIDが更新される前にこちらの処理をしてしまう。
//    //Future.delayed(new Duration(seconds: 10), () {
//      if (_savedDocumentID == document.documentID) {
//        return print('saveなし${_savedDocumentID}');
//      } else {
//        print('saveした${_savedDocumentID}');
//        _favoriteReference.setData({
//          "documentID": document.documentID,
//          "time": DateTime.now(),
//        });
//
//        DocumentReference _favPostReference;
//        _favPostReference =
//            Firestore.instance.collection('posts').document(document.documentID)
//                .collection("favorite")
//                .document();
//        print('postにfav登録');
//
//        _favPostReference.setData({
//          "userId": firebaseUser.uid,
//          "time": DateTime.now(),
//        });      }
//    //});
//  }
//
//
//  //投稿情報にお気に入りした人のユーザーIDを登録
//  favSavePost(document){
//    DocumentReference _favPostReference;
//    _favPostReference =
//        Firestore.instance.collection('posts').document(document.documentID)
//            .collection("favorite")
//            .document();
//    print('postにfav登録');
//
//    _favPostReference.setData({
//      "userId": firebaseUser.uid,
//      "time": DateTime.now(),
//    });
//  }
//
//  //async付けるとiconをリターンできない
 savedDocumentIDSuba(document,favorite)  {
   Firestore.instance
       .collection('posts')
       .document(document.documentID)
       .collection("favorite")
       .where("userId", isEqualTo: firebaseUser.uid)
       .snapshots()
       .listen((data) =>
       data.documents.forEach((doc) =>

       //空の時nullに上書きされない
       savedUserID = doc["userId"]));


  Future.delayed(new Duration(seconds: 1), ()
  {

      if (savedUserID == firebaseUser.uid) {

        print('saveなし${savedUserID}');
        favorite = true;
        //return Icons.favorite;

      } else {
        print('saveした${savedUserID}');
        //return Icons.favorite_border;
      }

  });
}

//aaad(document){
//  Firestore.instance
//      .collection('posts')
//      .document(document.documentID)
//      .collection("favorite")
//      .where("userId", isEqualTo: firebaseUser.uid)
//      .snapshots()
//      .listen((data) =>
//      data.documents.forEach((doc) =>
//
//      //空の時nullに上書きされない
//      savedUserID = doc["userId"]));
//}