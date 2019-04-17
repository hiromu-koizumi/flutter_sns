import 'dart:io';

import 'package:flutter/material.dart';

class NewImage extends StatelessWidget {
  final File imageFile;

  const NewImage({
    Key key,
    this.imageFile,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Image.file(
        (imageFile),
        width: 190,
        height: 190,
        fit: BoxFit.cover,
      ),
      borderRadius: BorderRadius.all(Radius.circular(100.0)),
      clipBehavior: Clip.hardEdge,
    );
  }
}
