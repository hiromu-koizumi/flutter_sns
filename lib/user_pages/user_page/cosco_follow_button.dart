import 'package:flutter/material.dart';

class CoscoFollowButton extends StatelessWidget {
  final bool isFollow;
  final VoidCallback onPressed;
  const CoscoFollowButton({
    Key key,
    @required this.isFollow,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final followButtonText = isFollow ? Text("フォロー中") : Text("フォローする");
    return RaisedButton(child: followButtonText, onPressed: onPressed);
  }
}
