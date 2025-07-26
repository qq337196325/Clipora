import 'package:flutter/material.dart';


class ArticleWebWidget extends StatefulWidget {

  const ArticleWebWidget({
    super.key,
  });

  @override
  State<ArticleWebWidget> createState() => ArticleWebWidgetState();
}

class ArticleWebWidgetState extends State<ArticleWebWidget> with ArticleWebWidgetBLoC {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 确保WebView背景透明
      body: Container(),
    );
  }


}

mixin ArticleWebWidgetBLoC on State<ArticleWebWidget> {

}