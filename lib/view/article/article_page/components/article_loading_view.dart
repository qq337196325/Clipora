import 'package:flutter/material.dart';

class ArticleLoadingView extends StatelessWidget {
  const ArticleLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('正在加载文章...'),
        ],
      ),
    );
  }
} 