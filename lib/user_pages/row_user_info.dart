import 'package:flutter/material.dart';
import 'package:flutter_cos/follow/user_follow_page.dart';
import 'package:flutter_cos/user_pages/following_followers_number.dart';
import 'package:flutter_cos/user_pages/user_image.dart';
import 'package:flutter_cos/user_pages/user_page/follow_button.dart';

class RowUserInfo extends StatelessWidget {
  final String userId;
  final String userPageOrMyPage;

  const RowUserInfo({
    Key key,
    @required this.userId,
    this.userPageOrMyPage,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        UserImage(userId: userId),

        //中央に配置するために付けている
        Expanded(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: "/FollowPage"),

                          //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
                          builder: (BuildContext context) =>
                              UserFollowPage(userId, "follow"),
                        ),
                      );
                    },
                    child: Column(
                      children: <Widget>[
                        Text('フォロー'),
                        FollowingOrFollowerNumber(
                          userId: userId,
                          followingOrFollowers: "following",
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: "/FollowPage"),

                          //編集ボタンを押したということがわかるように引数documentをもたせている。新規投稿は引数なし。ifを使ってpostpageクラスでifを使って判別。
                          builder: (BuildContext context) =>
                              UserFollowPage(userId, "follower"),
                        ),
                      );
                    },
                    child: Column(
                      children: <Widget>[
                        Text('フォロワー'),
                        FollowingOrFollowerNumber(
                          userId: userId,
                          followingOrFollowers: "followers",
                        )
                      ],
                    ),
                  ),
                ],
              ),
              userPageOrMyPage == "userPage"
                  ? FollowButton(
                      userId: userId,
                    )
                  : Container()
            ],
          ),
        ),
      ],
    );
  }
}
