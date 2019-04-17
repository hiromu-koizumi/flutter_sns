import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/other_pages/login_page.dart';
import 'package:flutter_cos/user_pages/user_page/cosco_follow_button.dart';
import 'package:uuid/uuid.dart';

class FollowButton extends StatelessWidget {
  final String userId;

  const FollowButton({
    Key key,
    @required this.userId,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .collection("following")
            .where("userId", isEqualTo: userId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          final isFollow = snapshot.data.documents.isNotEmpty;
          //ユーザー登録していない人はフォローボタン表示しないようにしている
          if (firebaseUser.isAnonymous) return Text("");

          return CoscoFollowButton(
            isFollow: isFollow,
            onPressed: () {
              followCheck();
            },
          );
        },
      ),
    );
  }

  followCheck() async {
    DocumentReference _myFollowReference;
    _myFollowReference = Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection("following")
        .document(userId);

    DocumentReference _othersFollowReference;
    _othersFollowReference = Firestore.instance
        .collection('users')
        .document(userId)
        .collection("followers")
        .document(firebaseUser.uid);

    //noticeに既読したことを保存するためにidが必要
    final String uuid = Uuid().v1();
    final _id = uuid;
    DocumentReference _noticeFollowRef;
    _noticeFollowRef = Firestore.instance
        .collection('users')
        .document(userId)
        .collection("notice")
        .document(_id);
    String checkFollow;
    String toFollowName;
    String isFollowedName;

    //このページのユーザーは自分はフォローしているか確認するために、自分のDBに保存されているuserIDの中からこのページのユーザーのユーザーIDと一致したユーザーの名前を変数checkFollowに格納して確認している。フォローしていなければcheckFollowにはnullが入る
    Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection("following")
        .where("userId", isEqualTo: userId)
        .snapshots()
        .listen(
          (data) => data.documents.forEach(
                (doc) => checkFollow = (doc["userName"]),
              ),
        );

    //stream使ってもっと簡潔な処理がかけると思う
    //処理を遅らせないと変数に名前保存する前にfirebaseに保存の処理を行ってしまう。ホントはawait使えばできると思う。でもうまくできないから処理を遅らして対処している
    Future.delayed(
      new Duration(seconds: 1),
      () {
        if (checkFollow != null) {
          _myFollowReference.delete();
          _othersFollowReference.delete();
          print('delete');
        } else {
          //followされた人の名前をisFollowedNameに代入している
          Firestore.instance
              .collection('users')
              .where('userId', isEqualTo: userId)
              .snapshots()
              .listen(
                (data) => data.documents.forEach(
                      (doc) => isFollowedName = (doc["userName"]),
                    ),
              );

          //followした人の名前をtoFollowNameに代入している
          Firestore.instance
              .collection('users')
              .where('userId', isEqualTo: firebaseUser.uid)
              .snapshots()
              .listen(
                (data) => data.documents.forEach(
                      (doc) => toFollowName = (doc["userName"]),
                    ),
              );

          //処理を遅らせないと変数に名前保存する前にfirebaseに保存の処理を行ってしまう。ホントはawait使えばできると思う。でもうまくできないから処理を遅らして対処している
          Future.delayed(
            new Duration(seconds: 1),
            () {
              //ホントはuserId保存しなくてもいいはず。でもドキュメントネームをwhere("userId", isEqualTo: firebaseUser.uid)で取り出す方法がわからないからこうしている
              //ログインユーザーのDBにこのページのユーザー情報を保存。
              _myFollowReference.setData(
                {
                  "userName": isFollowedName,
                  "userId": userId,
                  "time": DateTime.now()
                },
              );

              //このページのユーザーのDBにログインユーザーの情報を保存
              _othersFollowReference.setData(
                {
                  "userName": toFollowName,
                  "userId": firebaseUser.uid,
                  "time": DateTime.now()
                },
              );
              _noticeFollowRef.setData(
                {
                  "userId": firebaseUser.uid,
                  "time": DateTime.now(),
                  "follow": "fol",
                  "id": _id,
                  "read": false
                },
              );
            },
          );
          print('followしたよ');
        }
      },
    );
  }
}
