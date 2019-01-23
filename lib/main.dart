import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_cosco/image.dart';
//import 'package:flutter_cosco/timeline.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

//firebaseに保存されるテキスト。const再代入不可な変数。const変数が指す先のメモリ領域も変更不可

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cosco',
      //home: MyHomePage(),
      home: TimeLine(),
    );
  }
}


class TimeLine extends StatefulWidget {
  @override
  _TimeLineState createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("リスト画面"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
//              print("login");
//              showBasicDialog(context);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('posts').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return const Text('Loading...');
              return ListView.builder(

                //データをいくつ持ってくるかの処理
                itemCount: snapshot.data.documents.length,
                padding: const EdgeInsets.only(top: 10.0),

                //投稿を表示する処理にデータを送っている
                itemBuilder: (context, index) =>
                    _buildListItem(context, snapshot.data.documents[index]),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            print("新規作成ボタンを押しました");

            //画面遷移
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => MyHomePage()
              ),
            );
          }),
    );
  }

  //投稿表示する処理
  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return Card(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        ListTile(
          leading: const Icon(Icons.android),
          title: Text(document['comment']),
          //subtitle: Text(document['date'].toString().substring(0,10))
        ),
        //写真表示
        ImageUrl(imageUrl: document['url'])
      ]),
    );
  }
}
  class ImageUrl extends StatelessWidget {
  final String imageUrl;

  ImageUrl({this.imageUrl});

  @override
  Widget build(BuildContext context) {
  return Image.network(
  imageUrl,
  );
  }
  }















/////////////////////
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _FormData {
  String comment;
  DateTime date = DateTime.now();
  String url;
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _FormData _data = _FormData();

  @override
  Widget build(BuildContext context) {
//    DocumentReference _mainReference;
//    _mainReference = Firestore.instance.collection('posts').document();

    return Scaffold(
      appBar: AppBar(
        title: const Text('投稿'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                print('保存ボタンを押しました');
              }),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              print('削除ボタンを押しました');
            },
          )
        ],
      ),
      body: SafeArea(
          child: Form(
            //グローバルキー。紐づけするためにある。
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20.0),
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

                  //なんであるかわからないからコメントアウト
                  //initialValue: _data.comment,
                ),

                //投稿ボタン
                RaisedButton(
                    elevation: 7.0,
                    child: Text('投稿'),
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: () {
                      //validatorに処理を送っている
                      if (_formKey.currentState.validate()) {
                        //onSavedに処理を送っている
                        _formKey.currentState.save();

                        //firebaseに写真とテキストを保存する処理
                        uploadImageText();

                        Navigator.pop(context);
                      }

                      //画面遷移
                      //Navigator.of(context).pushNamed("/timeline");
                    })
              ],
            ),
          )),
    );

  }


  //選んだ写真が格納される場所
  File _imageFile;

  //写真を追加するボタンを押したときの処理
  void _getImage(BuildContext context, ImageSource source) {
    //写真の横幅を決めている
    ImagePicker.pickImage(source: source, maxWidth: 400.0).then((File image) {
      setState(() {

        //写真を代入
        _imageFile = image;
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
            height: 150.0,
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

        //写真をfirebaseに保存する処理
        _imageFile == null? Text('写真選択して'):enableUpload(),

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

  Future<String> uploadImageText() async{

    //保存する写真の名前を変更するためにUUIDを生成している
    final String uuid = Uuid().v1();

    DocumentReference _mainReference;
    _mainReference = Firestore.instance.collection('posts').document();

    //_imageFileに格納されている画像をfirebaseStorageに保存している。
    final StorageReference firebaseStorageRef =
    //imageフォルダの中に写真を保存している
    FirebaseStorage.instance.ref().child('image').child('$uuid.jpeg');
    final StorageUploadTask task = firebaseStorageRef.putFile(_imageFile);

    //写真のurlをダウンロードしている
    var downUrl = await (await task.onComplete).ref.getDownloadURL();

    //urlに写真のURLを格納
    _data.url = downUrl.toString();

    print("download url : $_data.url");

    //firebaseDatebaseに保存している
    _mainReference.setData({
      "url": _data.url,
      "comment": _data.comment,
    });




    return _data.url;

  }
}