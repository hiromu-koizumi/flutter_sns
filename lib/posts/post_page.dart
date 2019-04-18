import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/parts/Image_url.dart';
import 'package:flutter_cos/other_pages/login_page.dart';
import 'package:flutter_cos/main.dart';
import 'package:flutter_cos/posts/add_image_button.dart';
import 'package:flutter_cos/posts/new_image.dart';
import 'package:flutter_cos/posts/old_image.dart';
import 'package:flutter_cos/user_pages/my_page/my_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

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

  //写真を削除するときにurlとは別にimagePathが必要だと思う
  String imagePath;

  String documentId;

  var tagList = [];
}

class _PostPageState extends State<PostPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _FormData _data = _FormData();
  final String uuid = Uuid().v1();
  //一つにまとめられると思う。新着に投稿を乗せるため保存先を2つにしてある
  //新規投稿時のデータベース保存先作成
  DocumentReference _allPostsReference;
  DocumentReference _userPostsReference;
//textfieldの中に書き込まれた文字を取得するために必要
  TextEditingController myController = TextEditingController();
  bool deleteFlg = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //タイムラインから渡された引数があるか。ありの場合:編集の処理。なしの場合:新規投稿の処理。
    if (widget.document != null) {
      _data.comment = widget.document['comment'];
      _data.url = widget.document['url'];
      _data.imagePath = widget.document['imagePath'];
      _data.documentId = widget.document['documentId'];

      //widget.document['tag']をそのまま代入すると[[値]]というふうにカッコが二重になってしまうので取り出している
      widget.document['tag'].forEach((n) {
        _data.tagList.add(n);
      });

      print(tag);
      //編集ボタン押したときのデータベースの参照先
      _allPostsReference =
          Firestore.instance.collection('posts').document(_data.documentId);
      _userPostsReference = Firestore.instance
          .collection('users')
          .document(firebaseUser.uid)
          .collection("posts")
          .document(_data.documentId);

      deleteFlg = true;
    } else {
      //新規投稿のときのドキュメントIDを作成している
      _data.documentId = uuid;
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myController.dispose();
    super.dispose();
  }

  //tagListに代入された値を画面に表示するために必要
  StreamController<List> tag = StreamController<List>.broadcast();

  @override
  Widget build(BuildContext context) {
    if (firebaseUser.isAnonymous) {
      return Scaffold(
          appBar: AppBar(title: const Text('')),
          body: Center(
              child: Text(
            "投稿機能を使うには登録が必要です\t下の顔のマークから登録おねがいします!！",
            //textの折返しのために必要
            softWrap: true,
            maxLines: 2,

            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          )));
    } else {
      //streamBuildrtがreturnで返されたあとじゃないとtagに代入しても反応しない。だから一秒遅らせて、streambuilderが返されてから代入している
      Future.delayed(new Duration(seconds: 1), () {
        if (widget.document != null) {
          //widget.document['tag'].map((item) => _data.tagList = item);
          print("kokodaupppp${_data.tagList}");
          tag.add(_data.tagList);
        }
      });

      return Scaffold(
        appBar: AppBar(
          title: const Text('投稿'),
          actions: <Widget>[
            //削除ボタン処理
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: !deleteFlg
                  ? null
                  : () {
                      print('削除ボタンを押しました');

                      //firebaseStorageからデータを削除
                      final StorageReference firebaseStorageRef =
                          FirebaseStorage.instance
                              .ref()
                              .child('image')
                              .child('${_data.imagePath}');
                      firebaseStorageRef.delete();

                      myFollowersDelete();

                      //firebaseDatabaseからデータを削除
                      _allPostsReference.delete();
                      _userPostsReference.delete();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
            )
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SafeArea(
            child: Form(
              //グローバルキー。紐づけするためにある。
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.only(
                    top: 20.0, left: 20.0, right: 20.0, bottom: 50),
                children: <Widget>[
                  //image.dartファイルのクラス
                  AddImageButton(
                    onPressed: () {
                      _getImage(context, ImageSource.gallery);
                    },
                  ),
                  _imageFile == null && _data.url == null
                      ? Container()
                      : _imageFile == null && _data.url != null
                          ? OldImage(url: _data.url)
                          : NewImage(imageFile: _imageFile),
                  //ImageInput(),
                  TextFormField(
                    decoration: const InputDecoration(
                      //   hintText: 'comment',
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

                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: StreamBuilder(
                      stream: tag.stream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Text('');
                        // print(snapshot.data.length);
                        return Row(
                          children: _data.tagList
                              .map(
                                (item) => Container(
                                      decoration: ShapeDecoration(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                        ),
                                        color: Colors.black12,
                                      ),
                                      margin:
                                          EdgeInsets.only(right: 5, left: 5),
                                      padding: EdgeInsets.all(5),
                                      child: Text(item),
                                    ),
                              )
                              .toList(),
                        );
                        //Text(snapshot.data.toString());
                      },
                    ),
                  ),

                  Column(children: <Widget>[
                    TextField(
                      controller: myController,
                      decoration: const InputDecoration(
                        hintText: '入力したらタグ追加ボタンを押してね！',
                        labelText: 'タグ',
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                            elevation: 7.0,
                            child: Text('タグを追加'),
                            textColor: Colors.white,
                            color: Colors.blue,
                            onPressed: () {
                              _data.tagList.add(myController.text);
                              tag.add(_data.tagList);
                              print(_data.tagList);

                              myController.text = "";
                            }),
                        IconButton(
                          icon: Icon(Icons.highlight_off),
                          onPressed: () {
                            _data.tagList.removeLast();
                            tag.add(_data.tagList);
                          },
                        ),
                      ],
                    ),
                  ]),
                  SizedBox(height: 15),

                  //投稿ボタン
                  RaisedButton(
                    elevation: 7.0,
                    child: Text('投稿'),
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        if (_data.url == null && _imageFile == null) {
                          return Fluttertoast.showToast(msg: "写真を選択してね！");
                        }
                        //onSavedに処理を送っている。_formKeyがついているOnSavedに飛ぶ
                        _formKey.currentState.save();

                        //firebaseに写真とテキストを保存する処理._mainReferenceは投稿情報を渡している。これを渡さず関数側で投稿情報を作り編集投稿すると編集できず新規投稿をしてしまう。
                        uploadImageText(
                            _allPostsReference, _userPostsReference);

                        Navigator.pop(context);

                        //編集時の処理。編集を更新させるために二回戻らせている
                        if (widget.document != null) {
                          // Navigator.pop(context);
                          //投稿を編集した時にそれを反映させるためにpushAndRemoveUntilをしている
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyPages(),
                              ),
                              (_) => false);
                        }
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  //写真が追加、変更されたか
  bool photoEditAdd = false;

  //選んだ写真が格納される場所
  File _imageFile;

  //写真を追加するボタンを押したときの処理
  void _getImage(BuildContext context, ImageSource source) {
    //写真の横幅を決めている
    ImagePicker.pickImage(source: source, maxWidth: 400.0).then(
      (File image) {
        setState(
          () {
            //写真を代入
            _imageFile = image;
            photoEditAdd = true;
          },
        );

        //他でも使える形式に変更している。後々必要になるかも。
        // widget.setImage(image);
        // Navigator.pop(context);
      },
    );
  }

  //後々使うかもしれないから消さないでー
//写真を追加するボタンを押されたとき呼ばれる処理。
  //iphoneではカメラ起動できないためコメントアウト
//  void _openImagePicker(BuildContext context) {
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

  Future<String> uploadImageText(
      _allPostsReference, _userPostsReference) async {
    //保存する写真の名前を変更するためにUUIDを生成している

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

      // _data.documentId = uuid;

      //urlに写真のURLを格納
      _data.url = downUrl.toString();

      //保存するdcumentIDを全DBで統一するためにdocument(_data.imagePath)にimagePathを使用している。
      _allPostsReference =
          Firestore.instance.collection('posts').document(_data.documentId);
      _userPostsReference = Firestore.instance
          .collection('users')
          .document(firebaseUser.uid)
          .collection("posts")
          .document(_data.documentId);

      print("download url : $_data.url");
    }

    //フォロワーのDBに投稿を保存している
    myFollowersSave();

    //firebaseDatebaseに保存している
    _allPostsReference.setData({
      "url": _data.url,
      "comment": _data.comment,
      "time": _data.date,
      "imagePath": _data.imagePath,
      "userId": firebaseUser.uid,
      "tag": _data.tagList,
      "documentId": _data.documentId,
    });
    _userPostsReference.setData({
      "url": _data.url,
      "comment": _data.comment,
      "time": _data.date,
      "imagePath": _data.imagePath,
      "userId": firebaseUser.uid,
      "documentId": _data.documentId,
      "tag": _data.tagList
    });
  }

  myFollowersSave() {
    var _myFollowersId = [];

    Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection("followers")
        .snapshots()
        .listen(
          (data) => data.documents.forEach(
                (doc) =>

                    //空の時nullに上書きされない
                    _myFollowersId.add(
                      doc["userId"],
                    ),
              ),
        );

    //一秒遅く処理を開始しないと_myFollowersIdに値が代入されない。もっと良いコードあるはず
    Future.delayed(
      new Duration(seconds: 1),
      () {
        print("フォロワーリスト$_myFollowersId");
        print(_myFollowersId.length);
        int id = 0;
        DocumentReference _followerReference;

        //フォロワーの数と同じだけ処理をくりかえしている。
        while (_myFollowersId.length - 1 >= id) {
          _followerReference = Firestore.instance
              .collection('users')
              .document(_myFollowersId[id])
              .collection("followingPosts")
              .document(_data.documentId);

          _followerReference.setData(
            {
              "url": _data.url,
              "comment": _data.comment,
              "time": _data.date,
              "documentId": _data.documentId,
              "userId": firebaseUser.uid,
              "tag": _data.tagList
            },
          );
          id = id + 1;
        }
      },
    );
  }

  myFollowersDelete() {
    var _myFollowersId = [];

    Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection("followers")
        .snapshots()
        .listen((data) => data.documents.forEach((doc) =>

            //空の時nullに上書きされない
            _myFollowersId.add(doc["userId"])));

    //一秒遅く処理を開始しないと_myFollowersIdに値が代入されない。もっと良いコードあるはず
    Future.delayed(
      new Duration(seconds: 1),
      () {
        print("フォロワーリスト$_myFollowersId");
        print(_myFollowersId.length);
        int id = 0;
        DocumentReference _followerReference;

        //フォロワーの数と同じだけ処理をくりかえしている。
        while (_myFollowersId.length - 1 >= id) {
          _followerReference = Firestore.instance
              .collection('users')
              .document(_myFollowersId[id])
              .collection("followingPosts")
              .document(_data.documentId);

          _followerReference.delete();
          id = id + 1;
        }
      },
    );
  }
}
