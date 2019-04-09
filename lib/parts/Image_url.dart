//urlから画像を表示する処理
import 'package:flutter/material.dart';

class ImageUrl extends StatelessWidget {
  final String imageUrl;

  ImageUrl({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.network(
            //横幅がが長くならない
            imageUrl, fit: BoxFit.cover,
          ),
        ));
  }
}