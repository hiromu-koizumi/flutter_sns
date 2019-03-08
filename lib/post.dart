import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'login.dart';

//投稿作成、編集画面

class PostPage extends StatefulWidget {

  //編集機能のために追加。投稿情報をマイページから受け取っている
  PostPage(this.document);
  final DocumentSnapshot document;

  @override
  _PostPageState createState() => _PostPageState();
}

//投稿コメント、写真、時刻を格納する変数をまとめたクラス
class _FormData {
  String comment;

  //現在の時刻を代入
  DateTime date = DateTime.now();

  String url;

  String imagePath;
}



class _PostPageState extends State<PostPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _FormData _data = _FormData();

  @override
  Widget build(BuildContext context) {

    //一つにまとめられると思う。新着に投稿を乗せるため保存先を2つにしてある
    //新規投稿時のデータベース保存先作成
    DocumentReference _allPostsReference;
    DocumentReference _userPostsReference;
    _allPostsReference = Firestore.instance.collection('posts').document();
    _userPostsReference = Firestore.instance.collection('users').document(firebaseUser.uid).collection("posts").document();


    //削除機能のため
    bool deleteFlg = false;

    //タイムラインから渡された引数があるか。ありの場合:編集の処理。なしの場合:新規投稿の処理。
    if (widget.document != null) {
      if (_data.comment == null && _data.url == null) {
        _data.comment = widget.document['comment'];
        _data.url = widget.document['url'];
        _data.imagePath = widget.document['imagePath'];
      }

      //編集ボタン押したときのデータベースの参照先
      _allPostsReference = Firestore.instance.collection('posts').document(widget.document.documentID);
      _userPostsReference = Firestore.instance.collection('users').document(firebaseUser.uid).collection("posts").document(widget.document.documentID);

      deleteFlg = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('投稿'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                print('保存ボタンを押しました');
              }),

          //削除ボタン処理
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: !deleteFlg? null:() {
              print('削除ボタンを押しました');

              //firebaseStorageからデータを削除
              final StorageReference firebaseStorageRef =
              FirebaseStorage.instance.ref().child('image').child('${_data.imagePath}');
              firebaseStorageRef.delete();

              //firebaseDatabaseからデータを削除
              _allPostsReference.delete();
              _userPostsReference.delete();
              Navigator.pop(context);
            },
          )

        ],
      ),
      body: SafeArea(
          child: Form(
            //グローバルキー。紐づけするためにある。
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 50),
              children: <Widget>[
                //image.dartファイルのクラス
                addimageButton(),
                //ImageInput(),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'comment',
                    labelText: 'コメント',
                  ),

                  //投稿ボタンが押されたら処理が始まる
                  onSaved: (String value) {
                    //valueの中にテキストフィールドに書き込んだ文字が格納されている
                    _data.comment = value;
                  },

                  //投稿ボタンが押されたら処理が始まる
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'コメントは必須入力です';
                    }
                  },

                  //編集ボタン押した後のコメント欄に元あった文字を表示するのに必要。
                  initialValue: _data.comment,

                ),

                //投稿ボタン
                RaisedButton(
                    elevation: 7.0,
                    child: Text('投稿'),
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: () {
                      //validatorに処理を送っている。_formKeyがついているvalidatorに飛ぶ
                      if (_formKey.currentState.validate()) {
                        //onSavedに処理を送っている。_formKeyがついているOnSavedに飛ぶ
                        _formKey.currentState.save();

                        //firebaseに写真とテキストを保存する処理._mainReferenceは投稿情報を渡している。これを渡さず関数側で投稿情報を作り編集投稿すると編集できず新規投稿をしてしまう。
                        uploadImageText(_allPostsReference,_userPostsReference);

                       Navigator.pop(context);
                      }
                    })
              ],
            ),
          )
      ),
    );

  }

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
        imageExistingView(),
        //写真をfirebaseに保存する処理
        _imageFile == null? Text(''):enableUpload(),

      ],
    );
  }

  //画像表示する処理。
  Widget enableUpload(){
    return Container(
        child: Column(
            children: <Widget>[
              //写真を表示する場所
              Image.file(_imageFile, height: 300.0, width: 300.0),

        ]
        )
    );
  }

  //編集時以前投稿した写真表示
  Widget imageExistingView() {
    if (_data.url != null && _imageFile == null) {
      return Container(
          child: Column(
              children: <Widget>[
                ImageUrl(imageUrl: _data.url)
              ]
          )
      );
    }else{
      //写真を変更したときにもともと投稿してあった写真の表示をけす。
      return Container();
    }
  }

  Future<String> uploadImageText(_allPostsReference,_userPostsReference) async{

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
    _allPostsReference.setData({
      "url": _data.url,
      "comment": _data.comment,
      "time": _data.date,
      "imagePath" : _data.imagePath,
      "userId" : firebaseUser.uid
    });
    _userPostsReference.setData({
      "url": _data.url,
      "comment": _data.comment,
      "time": _data.date,
      "imagePath" : _data.imagePath,
      "userId" : firebaseUser.uid
    });
  }
}