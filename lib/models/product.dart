import 'package:flutter/material.dart';

class Product {
//  final String id;
//  final String title;
//  final String description;
//  final double price;
//  final String image;
//  final bool isFavorite;
//  final String userEmail;
//  final String userId;
  final String comment;

  //現在の時刻を代入.finalつけるとエラー起こる
   DateTime date = DateTime.now();

  final String url;

  final String imagePath;

  final bool isFavorite;

  //userIdは直接定義している

  Product(
      {
//        @required this.id,
//        @required this.title,
//        @required this.description,
//        @required this.price,
//        @required this.image,
//        @required this.userEmail,
//        @required this.userId,
//
//        this.isFavorite = false

        @required this.comment,
        @required this.date,
        @required this.url,
        @required this.imagePath,

        this.isFavorite = false,
      });
}
