import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'login.dart';

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
}

class _SettingPageState extends State<SettingPage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _UserData _data = _UserData();

  @override
  Widget build(BuildContext context) {

    DocumentReference _userReference;
    _userReference = Firestore.instance.collection('users').document(firebaseUser.uid).collection("profiles").document();

    if (widget.userInformation != null) {
      if (_data.userName == null && _data.profile == null) {
        _data.userName = widget.userInformation['userName'];
        _data.profile = widget.userInformation['profile'];
        _data.url = widget.userInformation['photoUrl'];
        _data.imagePath = widget.userInformation['imagePath'];
        print('${_data.userName}');
      }

      //編集ボタン押したときのデータベースの参照先
      _userReference = Firestore.instance.collection('users').document(firebaseUser.uid).collection("profiles").document(widget.userInformation.documentID);
    }



    return Scaffold(
        appBar: AppBar(
          title: Text('設定'),actions: <Widget>[
          IconButton(
            icon: Icon(Icons.directions_run),
            onPressed: () {
              logoutDialog(context);
            },
          ),]
        ),
        body: SafeArea(
            child: Form(
                //グローバルキー。紐づけするためにある。
                key: _formKey,
                child: ListView(
                    padding: const EdgeInsets.all(20.0),
                    children: <Widget>[
                      addimageButton(),

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

                //投稿ボタンが押されたら処理が始まる
//                validator: (value) {
//                  if (value.isEmpty) {
//                    return 'コメントは必須入力です';
//                  }
//                },

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
                    //validatorに処理を送っている。_formKeyがついているvalidatorに飛ぶ
//                      if (_formKey.currentState.validate()) {
//                        //onSavedに処理を送っている。_formKeyがついているOnSavedに飛ぶ
                        _formKey.currentState.save();
                        uploadText(_userReference);
//
//                        //firebaseに写真とテキストを保存する処理._mainReferenceは投稿情報を渡している。これを渡さず関数側で投稿情報を作り編集投稿すると編集できず新規投稿をしてしまう。
//                        uploadImageText(_mainReference);

                    Navigator.pop(context);
                  }

                  //画面遷移

                  )
            ]))));
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

  Future<String> uploadText(_userReference) async{


    //保存する写真の名前を変更するためにUUIDを生成している
    final String uuid = Uuid().v1();

    //DocumentReference _mainReference;
    //_mainReference = Firestore.instance.collection('users').document(firebaseUser.uid).collection("transaction").document();

    //写真に変更を加えたときの処理
    if (photoEditAdd == true) {

      //写真を編集した時以前の写真をFirebabseStorageから削除
      if ( _data.imagePath != null) {
        //firebaseStorageからデータを削除
        final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('image').child(
            '${_data.imagePath}');
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
      "imagePath": _data.imagePath
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
      Navigator.pop(context);
    });
  }

  Widget addimageButton() {
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
            _openImagePicker(context);
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
        //編集時以前投稿した写真を表示
       // imageExistingView(),
        //写真をfirebaseに保存する処理
        imageExistingView(),
        _imageFile == null? Text(''):enableUpload(),

      ],
    );
  }

  //画像表示する処理。
  Widget enableUpload(){
    return Container(
        width: 190.0,
        height: 190.0,
        decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: new DecorationImage(
                fit: BoxFit.fill,
                image: FileImage(_imageFile)
            )
        ));
  }


  //写真を追加するボタンを押されたとき呼ばれる処理。使う写真を
  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 200.0,
            padding: EdgeInsets.all(10.0),
            child: Column(children: [
              Text(
                'Pick an Image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10.0,
              ),
              FlatButton(
                textColor: Theme.of(context).primaryColor,
                child: Text('Use Camera'),
                onPressed: () {
                  //カメラが起動する
                  _getImage(context, ImageSource.camera);
                },
              ),
              FlatButton(
                textColor: Theme.of(context).primaryColor,
                child: Text('Use Gallery'),
                onPressed: () {

                  //ギャラリーが表示される
                  _getImage(context, ImageSource.gallery);
                },
              )
            ]),
          );
        });
  }

  //編集時以前投稿した写真表示
  Widget imageExistingView() {
    if (_data.url != null && _imageFile == null) {
      return Container(
          width: 190.0,
          height: 190.0,
          decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(_data.url)
              )
          ));
    }else{
      //写真を変更したときにもともと投稿してあった写真の表示をけす。
      return Container();
    }
  }
}
