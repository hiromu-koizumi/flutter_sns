//import 'dart:io';
//
//import 'package:flutter/material.dart';
//import 'package:flutter_cos/setting/image_exist.dart';
//import 'package:flutter_cos/setting/new_image.dart';
//import 'package:image_picker/image_picker.dart';
//
//class AddImageButton extends StatefulWidget {
//  AddImageButton(this.url);
//
//  final String url;
//  @override
//  _AddImageButtonState createState() => _AddImageButtonState();
//}
//
//class _AddImageButtonState extends State<AddImageButton> {
//  //写真が追加、変更されたか
//  bool photoEditAdd = false;
//  //選んだ写真が格納される場所
//  File _imageFile;
//  @override
//  Widget build(BuildContext context) {
//    void _getImage(BuildContext context, ImageSource source) {
//      //写真の横幅を決めている
//      ImagePicker.pickImage(source: source, maxWidth: 400.0).then((File image) {
//        setState(() {
//          //写真を代入
//          _imageFile = image;
//          photoEditAdd = true;
//        });
//
//        //他でも使える形式に変更している。
//        // widget.setImage(image);
//        // Navigator.pop(context);
//      });
//    }
//
//    final buttonColor = Theme.of(context).accentColor;
//
//    return Column(
//      children: <Widget>[
//        OutlineButton(
//          //枠線
//          borderSide: BorderSide(
//            color: buttonColor,
//            width: 2.0,
//          ),
//          onPressed: () {
//            //写真をギャラリーから選ぶかカメラで今とるかの選択画面を表示
//            _getImage(context, ImageSource.gallery);
//          },
//          child: Row(
//            //中心に配置
//            mainAxisAlignment: MainAxisAlignment.center,
//
//            children: <Widget>[
//              Icon(
//                Icons.camera_alt,
//                color: buttonColor,
//              ),
//              SizedBox(
//                width: 5.0,
//              ),
//              Text(
//                'Add Image',
//                style: TextStyle(color: buttonColor),
//              )
//            ],
//          ),
//        ),
//        //写真をfirebaseに保存する処理
//        _imageFile == null
//            ? OldImage(url: widget.url)
//            : NewImage(imageFile: _imageFile),
//        // _imageFile != null ? NewImage(imageFile: _imageFile) : Container(),
//      ],
//    );
//  }
//}
