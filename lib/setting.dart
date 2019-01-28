import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'login.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _UserData {
  String userName;

  String profile;
}

class _SettingPageState extends State<SettingPage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _UserData _data = _UserData();


////ユーザーネームをdatabaseに保存
//_userReference.setData({
//"name" : name
//});


  @override
  Widget build(BuildContext context) {

    DocumentReference _userReference;
    _userReference = Firestore.instance.collection('users').document(firebaseUser.uid).collection("transaction").document();


    return Scaffold(
        appBar: AppBar(
          title: Text('設定'),
        ),
        body: SafeArea(
            child: Form(
                //グローバルキー。紐づけするためにある。
                key: _formKey,
                child: ListView(
                    padding: const EdgeInsets.all(20.0),
                    children: <Widget>[
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

//                //投稿ボタンが押されたら処理が始まる
//                validator: (value) {
//                  if (value.isEmpty) {
//                    return 'コメントは必須入力です';
//                  }
//                },

                //編集ボタン押した後のコメント欄に元あった文字を表示するのに必要。
                // initialValue: _data.comment,
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
                //initialValue: _data.comment,
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

  Future<String> uploadText(_userReference) async{

    //保存する写真の名前を変更するためにUUIDを生成している
    final String uuid = Uuid().v1();

    //DocumentReference _mainReference;
    //_mainReference = Firestore.instance.collection('users').document(firebaseUser.uid).collection("transaction").document();

    //_imageFileに格納されている画像をfirebaseStorageに保存している。
    //final StorageReference firebaseStorageRef =
    //imageフォルダの中に写真を保存している
    //FirebaseStorage.instance.ref().child('image').child('$uuid.jpeg');
    //final StorageUploadTask task = firebaseStorageRef.putFile(_imageFile);

   // _data.imagePath = uuid + '.jpeg';

    //写真のurlをダウンロードしている
    //var downUrl = await (await task.onComplete).ref.getDownloadURL();

    //urlに写真のURLを格納
    //_data.url = downUrl.toString();

    //print("download url : $_data.url");

    //firebaseDatebaseに保存している
    _userReference.setData({
      "userName": _data.userName,
      "profile": _data.profile,

    });

    //return _data.url;

  }




}

//DocumentReference _userReference;
//_userReference = Firestore.instance.collection('users').document(firebaseUser.uid).collection("transaction").document();
//
////ユーザーネームをdatabaseに保存
//_userReference.setData({
//"name" : name
//});
