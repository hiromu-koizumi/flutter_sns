import 'package:flutter/material.dart';
import 'package:flutter_cos/parts/Image_url.dart';

class OldImage extends StatelessWidget {
  final String url;

  const OldImage({
    Key key,
    @required this.url,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: <Widget>[ImageUrl(imageUrl: url)]));
  }
  //写真を変更したときにもともと投稿してあった写真の表示をけす。

}
