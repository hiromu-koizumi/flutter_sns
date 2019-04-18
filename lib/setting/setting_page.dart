import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/setting/image_exist.dart';
import 'package:flutter_cos/setting/new_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_cos/other_pages/login_page.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SettingPage extends StatefulWidget {
//mypageから渡されたユーザー情報を受け取っている
  SettingPage(this.userInformation);

  final DocumentSnapshot userInformation;

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _UserData {
  String userName;
  String profile;
  String url;

  //写真を削除するときにurlとは別にimagePathが必要だと思う
  String imagePath;

  String searchKey;
  String userId;
//String makeUserID;
}

class _SettingPageState extends State<SettingPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _UserData _data = _UserData();

  @override
  Widget build(BuildContext context) {
    DocumentReference _userReference;
    _userReference =
        Firestore.instance.collection('users').document(firebaseUser.uid);

    _data.userName = widget.userInformation['userName'];
    _data.profile = widget.userInformation['profile'];
    _data.url = widget.userInformation['photoUrl'];
    _data.imagePath = widget.userInformation['imagePath'];
    _data.searchKey = widget.userInformation['searchKey'];
    _data.userId = widget.userInformation['userId'];

    return Scaffold(
      appBar: AppBar(title: Text('設定'), actions: <Widget>[
        IconButton(
          icon: Icon(Icons.directions_run),
          onPressed: () {
            logoutDialog(context);
          },
        ),
      ]),
      body: SafeArea(
        child: Form(
          //グローバルキー。紐づけするためにある。
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: <Widget>[
              Column(
                children: <Widget>[
                  //addimageButton(),
                  addImageButton(),
                  _imageFile == null
                      ? OldImage(url: _data.url)
                      : NewImage(imageFile: _imageFile),
                ],
              ),

              //ユーザー名テキストフィールド
              TextFormField(
                decoration: const InputDecoration(
                  // hintText: 'name',
                  labelText: 'ユーザー名',
                ),

                //投稿ボタンが押されたら処理が始まる
                onSaved: (String value) {
                  //valueの中にテキストフィールドに書き込んだ文字が格納されている
                  _data.userName = value;
                },

                //編集ボタン押した後のコメント欄に元あった文字を表示するのに必要。
                initialValue: _data.userName,
              ),

              //プロフィールテキストフィールド
              TextFormField(
                decoration: const InputDecoration(
                  //hintText: 'comment',
                  labelText: '自己紹介',
                ),

                //投稿ボタンが押されたら処理が始まる
                onSaved: (String value) {
                  //valueの中にテキストフィールドに書き込んだ文字が格納されている
                  _data.profile = value;
                },

                //編集ボタン押した後のコメント欄に元あった文字を表示するのに必要。
                initialValue: _data.profile,
              ),

              //投稿ボタン
              RaisedButton(
                  elevation: 7.0,
                  child: Text('保存'),
                  textColor: Colors.white,
                  color: Colors.blue,
                  onPressed: () {
//                        //onSavedに処理を送っている。_formKeyがついているOnSavedに飛ぶ
                    _formKey.currentState.save();
                    uploadText(_userReference);
                    Navigator.pop(context);
                  })
            ],
          ),
        ),
      ),
    );
  }

  void logoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: const Text('確認ダイアログ'),
            content: Text(firebaseUser.email + "でログインしています"),
            actions: <Widget>[
              FlatButton(
                child: const Text('キャンセル'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                  child: const Text('ログアウト'),
                  onPressed: () {
                    _auth.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, "/", (_) => false);
                  }),
            ],
          ),
    );
  }

  Future<String> uploadText(_userReference) async {
    //保存する写真の名前を変更するためにUUIDを生成している
    final String uuid = Uuid().v1();

    //写真に変更を加えたときの処理
    if (photoEditAdd == true) {
      //写真を編集した時以前の写真をFirebabseStorageから削除
      if (_data.imagePath != null) {
        //firebaseStorageからデータを削除
        final StorageReference firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child('image')
            .child('${_data.imagePath}');
        firebaseStorageRef.delete();
      }

      //_imageFileに格納されている画像をfirebaseStorageに保存している。
      final StorageReference firebaseStorageRef =
          //imageフォルダの中に写真を保存している
          FirebaseStorage.instance.ref().child('image').child('$uuid.jpeg');
      final StorageUploadTask task = firebaseStorageRef.putFile(_imageFile);

      _data.imagePath = uuid + '.jpeg';

      //写真のurlをダウンロードしている
      var downUrl = await (await task.onComplete).ref.getDownloadURL();

      //urlに写真のURLを格納
      _data.url = downUrl.toString();

      print("download url : $_data.url");
    }

    //firebaseDatebaseに保存している
    _userReference.setData({
      "userName": _data.userName,
      "profile": _data.profile,
      "photoUrl": _data.url,
      "imagePath": _data.imagePath,
      "userId": _data.userId,
      //ユーザー名の位置文字目を取り出している
      "searchKey": _data.userName.substring(0, 1),
    });
  }

  ///////////////画像処理

  //写真が追加、変更されたか
  bool photoEditAdd = false;

  //選んだ写真が格納される場所
  File _imageFile;

  //写真を追加するボタンを押したときの処理
  void _getImage(BuildContext context, ImageSource source) {
    //写真の横幅を決めている
    ImagePicker.pickImage(source: source, maxWidth: 400.0).then((File image) {
      setState(() {
        //写真を代入
        _imageFile = image;
        photoEditAdd = true;
      });

      //他でも使える形式に変更している。
      // widget.setImage(image);
      // Navigator.pop(context);
    });
  }

  //これをクラスにすると保存の処理ができない。getImageがあるので
  Widget addImageButton() {
    //枠線、アイコン、テキストの色
    final buttonColor = Theme.of(context).accentColor;

    return Column(
      children: <Widget>[
        OutlineButton(
          //枠線
          borderSide: BorderSide(
            color: buttonColor,
            width: 2.0,
          ),
          onPressed: () {
            //写真をギャラリーから選ぶかカメラで今とるかの選択画面を表示
            _getImage(context, ImageSource.gallery);
          },
          child: Row(
            //中心に配置
            mainAxisAlignment: MainAxisAlignment.center,

            children: <Widget>[
              Icon(
                Icons.camera_alt,
                color: buttonColor,
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                'Add Image',
                style: TextStyle(color: buttonColor),
              )
            ],
          ),
        ),
      ],
    );
  }

//後々使うかもしれないから消さないで！写真を追加するボタンを押されたとき呼ばれる処理。使う写真を
//  Widget _openImagePicker(BuildContext context) {
//    showModalBottomSheet(
//        context: context,
//        builder: (BuildContext context) {
//          return Container(
//            height: 200.0,
//            padding: EdgeInsets.all(10.0),
//            child: Column(children: [
//              Text(
//                'Pick an Image',
//                style: TextStyle(fontWeight: FontWeight.bold),
//              ),
//              SizedBox(
//                height: 10.0,
//              ),
//              FlatButton(
//                textColor: Theme.of(context).primaryColor,
//                child: Text('Use Camera'),
//                onPressed: () {
//                  //カメラが起動する
//                  _getImage(context, ImageSource.camera);
//                },
//              ),
//              FlatButton(
//                textColor: Theme.of(context).primaryColor,
//                child: Text('Use Gallery'),
//                onPressed: () {
//                  //ギャラリーが表示される
//                  _getImage(context, ImageSource.gallery);
//                },
//              )
//            ]),
//          );
//        });
//  }
}
