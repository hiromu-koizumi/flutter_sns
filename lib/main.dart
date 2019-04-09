import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cos/other_pages/notice_page.dart';
import 'package:flutter_cos/other_pages/splash_page.dart';
import 'package:flutter_cos/searches/search_page.dart';
import 'package:flutter_cos/other_pages/time_line_page.dart';
import 'package:flutter_cos/user_pages/my_page.dart';

//firebaseに保存されるテキスト。const再代入不可な変数。const変数が指す先のメモリ領域も変更不可
void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cosco',
      routes: <String, WidgetBuilder>{
        //はじめは自動的に'/'の画面に遷移する
        '/': (_) => Splash(),
        '/bottombar': (_) => BottomBar(),
      },
    );
  }
}

//下タブはStatefulWidgetじゃないと呼び出しができなかった
class BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() => _BottomBarState();
}

//下タブ
class _BottomBarState extends State<BottomBar> {
  @override
  build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.search),
            //title: new Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.notifications),
            //title: new Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.face),
            //title: new Text('MyPage'),
          )
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        assert(index >= 0 && index <= 3);
        return CupertinoTabView(
          builder: (BuildContext context) {
            switch (index) {
              case 0:
                return CupertinoTabView(
                  builder: (BuildContext context) => TimeLine(),
                );
                break;
              case 1:
                return CupertinoTabView(
                  builder: (BuildContext context) => SearchPage(),
                );
                break;
              case 2:
                return CupertinoTabView(
                  builder: (BuildContext context) => NoticePage(),
                );
                break;
              case 3:
                return CupertinoTabView(
                  builder: (BuildContext context) => MyPages(),
                );
                break;
            }
            return null;
          },
        );
      },
    );
  }
}
