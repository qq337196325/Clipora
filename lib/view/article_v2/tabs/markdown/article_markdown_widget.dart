import 'package:flutter/material.dart';


class ArticleMarkdownWidget extends StatefulWidget {

  const ArticleMarkdownWidget({
    super.key,
  });

  @override
  State<ArticleMarkdownWidget> createState() => ArticleMarkdownWidgetState();
}

class ArticleMarkdownWidgetState extends State<ArticleMarkdownWidget> with ArticleMarkdownWidgetBLoC {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 确保WebView背景透明
      body: Container(),
    );
  }


}

mixin ArticleMarkdownWidgetBLoC on State<ArticleMarkdownWidget> {

}