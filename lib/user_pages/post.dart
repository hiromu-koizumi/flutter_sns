import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/parts/Image_url.dart';
import 'package:flutter_cos/posts/my_post_details.dart';
import 'package:flutter_cos/posts/post_details.dart';

class Post extends StatelessWidget {
  final DocumentSnapshot document;
  final String myPageOrUserPage;

  const Post({
    Key key,
    @required this.document,
    this.myPageOrUserPage,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (myPageOrUserPage == "myPage") {
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: const RouteSettings(name: "/postDetails"),

              //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
              builder: (BuildContext context) => MyPostDetails(document),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                settings: const RouteSettings(name: "/postDetails"),

                //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
                builder: (BuildContext context) => PostDetails(document)),
          );
        }
      },
      child: Card(
        //写真表示
        child: ImageUrl(imageUrl: document['url']),
      ),
    );
  }
}
