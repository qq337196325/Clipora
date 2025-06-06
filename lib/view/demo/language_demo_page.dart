import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/language_controller.dart';
import '../../basics/language_utils.dart';
import '../settings/language_selection_page.dart';

class LanguageDemoPage extends StatelessWidget {
  const LanguageDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('app_name'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              Get.to(() => const LanguageSelectionPage());
            },
          ),
        ],
      ),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 当前语言信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'language'.tr,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(languageController.getCurrentLanguageFlag()),
                        const SizedBox(width: 8),
                        Text(languageController.getCurrentLanguageName()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 基本翻译示例
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '基本翻译示例 / Basic Translation Examples',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildTranslationRow('confirm', 'cancel'),
                    _buildTranslationRow('save', 'delete'),
                    _buildTranslationRow('add', 'edit'),
                    _buildTranslationRow('search', 'settings'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 应用功能翻译示例
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '应用功能翻译 / App Features Translation',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildTranslationRow('clips', 'favorites'),
                    _buildTranslationRow('notes', 'add_clip'),
                    _buildTranslationRow('clip_list', 'search_placeholder'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 时间和日期示例
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '时间日期示例 / Date Time Examples',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text('当前时间格式化: ${LanguageUtils.formatDateTime(DateTime.now())}'),
                    const SizedBox(height: 8),
                    Text('相对时间: ${LanguageUtils.getRelativeTime(DateTime.now().subtract(const Duration(days: 1)))}'),
                    const SizedBox(height: 8),
                    Text('${'today'.tr} | ${'yesterday'.tr} | ${'this_week'.tr}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 工具函数示例
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '工具函数示例 / Utility Functions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text('文件大小: ${LanguageUtils.getFileSizeString(1024 * 1024)}'),
                    const SizedBox(height: 8),
                    Text('数量显示: ${LanguageUtils.getCountString(5, 'clip'.tr)}'),
                    const SizedBox(height: 8),
                    Text('语言检测: 是否中文 - ${LanguageUtils.isChinese()}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 切换语言按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => const LanguageSelectionPage());
                },
                icon: const Icon(Icons.language),
                label: Text('切换语言 / Switch Language'),
              ),
            ),
          ],
        ),
      )),
    );
  }
  
  Widget _buildTranslationRow(String key1, String key2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text('$key1: ${key1.tr}'),
          ),
          Expanded(
            child: Text('$key2: ${key2.tr}'),
          ),
        ],
      ),
    );
  }
} 