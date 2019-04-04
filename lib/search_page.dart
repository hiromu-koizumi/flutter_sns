import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/search_result_page.dart';
import 'package:flutter_cos/search_service.dart';
import 'package:flutter_cos/user_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var queryResultSet = [];
  var tempSearchStore = [];

  //textFieldに入力されるたびに呼び出される
  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    //入力された文字をcaptializedValueに代入している。最初の一文字を大文字にして代入している。
    var capitalizedValue = value;

    print("cap$capitalizedValue");

    if (queryResultSet.length == 0 && value.length == 1) {
      //firestoreから入力された1文字目と同じSearchKeyのあるdocumentをqueryResultSetに代入している
      SearchService().searchByName(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          queryResultSet.add(docs.documents[i].data);
          print(docs.documents[i].data);
        }
        print('queryのほう$queryResultSet');
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        //このif文の意味はテキストフィールドに入力された文字とqueryResultSetに保存されている文字が一致していれば
        if (element['userName'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
          print('tempのほう$tempSearchStore');
        }
      });
    }
  }

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //textField以外をタップするとキーボード閉じる機能
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
      FocusScope.of(context).requestFocus(new FocusNode());
    },
     child:  ListView(children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              //()の中になにか入れないとエラーになるから適当に入れてる
              onSubmitted: (s) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: const RouteSettings(name: "/new"),
                      builder: (BuildContext context) =>
                          SearchResultPage(_controller.text)
                      ),
                );
              },
              onChanged: (val) {
                initiateSearch(val);
              },
              controller: _controller,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                  prefixIcon: IconButton(
                    color: Colors.black,
                    icon: Icon(Icons.search),
                    iconSize: 20.0,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            settings: const RouteSettings(name: "/new"),
                            builder: (BuildContext context) => SearchResultPage(
                                _controller.text) //null 編集機能付けるのに必要っぽい
                            ),
                      );
                    },
                  ),
                  suffixIcon: IconButton(
                    color: Colors.black,
                    icon: Icon(Icons.highlight_off),
                    iconSize: 20.0,
                    onPressed: () {
                      _controller.text = "";
                    },
                  ),
                  //      contentPadding: EdgeInsets.only(left: 25.0),
                  hintText: 'キーワード検索',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0))),
            )),
        //SizedBox(height: 10.0),
        GridView.count(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            crossAxisCount: 3,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            primary: false,
            shrinkWrap: true,
            children: tempSearchStore.map((element) {
              return buildResultCard(context, element);
            }).toList())
      ]),
    ));
  }
}

Widget buildResultCard(BuildContext context, data) {
  return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              settings: const RouteSettings(name: "/userPage"),
              builder: (BuildContext context) =>
                  //表示されている名前のユーザーIDをUserPageに渡している
                  UserPage(data['userId'])),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Material(
            child: Image.network(
              (data['photoUrl']),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),borderRadius: BorderRadius.all(Radius.circular(20.0)),
            clipBehavior: Clip.hardEdge,
          ),
//          Container(
//              width: 40.0,
//              height: 40.0,
//              decoration: new BoxDecoration(
//                  shape: BoxShape.circle,
//                  image: new DecorationImage(
//                      fit: BoxFit.fill,
//                      image: new NetworkImage(data['photoUrl'])))),
          Text(data['userName']),
        ],
      ));
}
