import 'package:flutter/material.dart';

//編集時、以前投稿した画像を表示
class OldImage extends StatelessWidget {
  final String url;

  const OldImage({
    Key key,
    @required this.url,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Image.network(
        (url),
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      ),
      borderRadius: BorderRadius.all(Radius.circular(100.0)),
      clipBehavior: Clip.hardEdge,
    );
  }
}
