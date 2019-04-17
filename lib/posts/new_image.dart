import 'dart:io';

import 'package:flutter/material.dart';

class NewImage extends StatelessWidget {
  final File imageFile;

  const NewImage({
    Key key,
    @required this.imageFile,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: <Widget>[
      //写真を表示する場所
      Image.file(imageFile, height: 300.0, width: 300.0),
    ]));
  }
}
