import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/notice/notice_name.dart';
import 'package:flutter_cos/other_pages/login_page.dart';
import 'package:flutter_cos/message/message_page.dart';
import 'package:flutter_cos/parts/circular_progress_indicator.dart';
import 'package:flutter_cos/user_pages/user_page/user_page.dart';

class NoticePage extends StatefulWidget {
  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  final _noticeList = [];
  bool _loading = false;
  var _loadCheckNotice = 0;
  final _getNoticeNumber = 12;
  DocumentReference _notReadNoticeRef;

  StreamController<List> _noticeController = StreamController<List>.broadcast();

  @override
  initState() {
    super.initState();
    Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection("notice")
        .orderBy("time", descending: true)
        .limit(_getNoticeNumber)
        .snapshots()
        .listen(
            (data) => data.documents.forEach((doc) => _noticeList.add(doc)));
    //3秒遅くしないとpostListに投稿が代入できていない
    Future.delayed(
      new Duration(seconds: 4),
      () {
        print(_noticeList);
        //表示された通知に既読したことを保存している
        for (var n in _noticeList) {
          _notReadNoticeRef = Firestore.instance
              .collection('users')
              .document(firebaseUser.uid)
              .collection("notice")
              .document(n['id']);
          _notReadNoticeRef.updateData(
            {
              "read": true,
            },
          );
        }
        _noticeController.add(_noticeList);
        _loadCheckNotice = _noticeList.length - _getNoticeNumber;
      },
    );

    print('initきてるよv');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: noticePage(),
    );
  }

  fetchNotice(document) async {
    if (_loading) {
      return null;
    }

    _loading = true;
    Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection("notice")
        .orderBy("time", descending: true)
        .startAfter([document['time']])
        .limit(_getNoticeNumber)
        .snapshots()
        .listen(
            (data) => data.documents.forEach((doc) => _noticeList.add(doc)));

    Future.delayed(new Duration(seconds: 4), () {
      print('読み込み中');
      _noticeController.add(_noticeList);
      _loadCheckNotice = _noticeList.length - _getNoticeNumber;
      _loading = false;
    });
  }

  Future<void> _updateNotice() async {
    Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection('notice')
        .where('read', isEqualTo: false)
        .orderBy("time", descending: false)
        .startAfter([_noticeList[0]['time']])
        .limit(_getNoticeNumber)
        .snapshots()
        .listen((data) =>
            data.documents.forEach((doc) => _noticeList.insert(0, doc)));
    Future.delayed(new Duration(seconds: 4), () {
      //表示された通知に既読したことを保存している
      for (var n in _noticeList) {
        _notReadNoticeRef = Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .collection("notice")
            .document(n['id']);
        _notReadNoticeRef.updateData({
          "read": true,
        });
      }
      print('読み込み中');
      _noticeController.sink.add(_noticeList);
    });
  }

  //上タブの表示処理.ユーザーネームを表示させる
  Widget noticePage() {
    return RefreshIndicator(
      //下に引っ張ると更新する処理
      onRefresh: _updateNotice,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification value) {
          if (value.metrics.extentAfter == 0.0) {
            //画面そこに到達したときの処理
            //一番最後に取得した投稿をfetchPostsに送っている。あちらでは、startAfterを使いその投稿より後の投稿を取得している
            fetchNotice(_noticeList[_noticeList.length - 1]);
          }
        },
        child: StreamBuilder(
          stream: _noticeController.stream,
          builder: (BuildContext context, snapshot) {
            //if (!snapshot.hasData) return const Text('Loading...');

            return Padding(
              padding: EdgeInsets.only(bottom: 50),
              child: ListView.builder(
                itemCount: _noticeList.length,
                padding: const EdgeInsets.only(top: 10.0),
                //投稿を表示する処理にデータを送っている
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot = _noticeList[index];

                  return index == _noticeList.length - 1 &&
                          _loadCheckNotice == 0
                      ? Indicator()
                      : NoticeName(
                          document: documentSnapshot,
                        );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
