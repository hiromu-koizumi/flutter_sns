import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/other_pages/login_page.dart';

//タブ追加ページ作成途中。アプリ内には組み込まれていない
//上部タブを増やすコードがかけなかった
class TabAddPage extends StatefulWidget {
  @override
  _TabAddPageState createState() => _TabAddPageState();
}

class _TabAddPageState extends State<TabAddPage> {
  TextEditingController myController = TextEditingController();
  String tabName;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: favoritePage(),
    );
  }

  //上タブの表示処理.ユーザーネームを表示させる
  Widget favoritePage() {
    DocumentReference _tabsRef;
    _tabsRef = Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .collection("tabs")
        .document();

    return Container(
        margin: EdgeInsets.all(15),
        padding: EdgeInsets.only(top: 100),
        child: Column(children: <Widget>[
          TextField(
            controller: myController,
            decoration: InputDecoration(
              // hintText: '入力したらタグ追加ボタンを押してね！',
              labelText: 'タブ',
              suffixIcon: IconButton(
                color: Colors.black,
                icon: Icon(Icons.highlight_off),
                iconSize: 20.0,
                onPressed: () {
                  myController.text = "";
                },
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                  elevation: 7.0,
                  child: Text('タブを追加'),
                  textColor: Colors.white,
                  color: Colors.blue,
                  onPressed: () {
                    tabName = myController.text;
                    print(tabName);
                    _tabsRef.setData({"tab": tabName, "time": DateTime.now()});

                    myController.text = "";
                    Navigator.pop(context);
                  }),
            ],
          ),
        ]));
  }
}
