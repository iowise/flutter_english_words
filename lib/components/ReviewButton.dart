import 'package:flutter/material.dart';

class ReviewButton extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text("10 words to review"),
      onPressed: () => print("review started"),
    );
  }
}
