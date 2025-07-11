import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArticleLoadingView extends StatelessWidget {
  const ArticleLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('i18n_article_正在加载文章'.tr),
        ],
      ),
    );
  }
} 