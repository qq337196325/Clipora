import 'package:flutter/material.dart';


class ArticleMhtmlWidget extends StatefulWidget {

  const ArticleMhtmlWidget({
    super.key,
  });

  @override
  State<ArticleMhtmlWidget> createState() => ArticleMhtmlWidgetState();
}

class ArticleMhtmlWidgetState extends State<ArticleMhtmlWidget> with ArticleMhtmlWidgetBLoC {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 确保WebView背景透明
      body: Container(),
    );
  }


}

mixin ArticleMhtmlWidgetBLoC on State<ArticleMhtmlWidget> {

}