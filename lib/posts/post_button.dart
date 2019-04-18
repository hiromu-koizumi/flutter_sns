import 'package:flutter/material.dart';

class PostButton extends StatelessWidget {
  final VoidCallback onPressed;
  const PostButton({
    Key key,
    @required this.onPressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        elevation: 7.0,
        child: Text('投稿'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: onPressed);
  }
}
