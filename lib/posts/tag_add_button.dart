import 'package:flutter/material.dart';

class TagAddButton extends StatelessWidget {
  final VoidCallback onPressed;
  const TagAddButton({
    Key key,
    @required this.onPressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        elevation: 7.0,
        child: Text('タグを追加'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: onPressed);
  }
}
