import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/parts/Image_url.dart';
import 'package:flutter_cos/posts/post_details.dart';

class NewPost extends StatelessWidget {
  final DocumentSnapshot document;
  const NewPost({
    Key key,
    @required this.document,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    settings: const RouteSettings(name: "/postDetails"),

                    //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
                    builder: (BuildContext context) => PostDetails(document)),
              );
            },
            child: Card(
              //写真表示
              child: ImageUrl(imageUrl: document['url']),
            )),
      ],
    );
  }
}
