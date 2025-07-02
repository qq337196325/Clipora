import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../basics/logger.dart';
import '../../controller/article_controller.dart';

class _Language {
  final String name;
  final String code;
  String status; // 'untranslated', 'translating', 'translated', 'failed'

  _Language({
    required this.name,
    required this.code,
    this.status = 'untranslated',
  });
}

class TranslateModal extends StatefulWidget { 
  final int articleId;

  const TranslateModal({
    super.key,
    required this.articleId,
  });

  @override
  State<TranslateModal> createState() => _TranslateModalState(); 
}

class _TranslateModalState extends State<TranslateModal> with TranslateModalBLoC {

  @override
  void initState() {
    super.initState();
    _initializeLanguageStatus();
  }

  /// 初始化语言状态
  Future<void> _initializeLanguageStatus() async {
    // 获取当前语言状态
    _currentLanguageCode = articleController.currentLanguageCode;
    getLogger().d('🌐 TranslateModal 获取当前语言: $_currentLanguageCode');
    
    // 获取所有语言代码
    final languageCodes = _languages.map((lang) => lang.code).toList();
    
    // 批量初始化 ArticleController 中的翻译状态
    await articleController.initializeAllLanguageStatus(languageCodes);
    
    // 更新本地状态（实际上现在本地状态不再使用，但保持一致性）
    if (mounted) {
      setState(() {
        for (int i = 0; i < _languages.length; i++) {
          final status = articleController.getTranslationStatus(_languages[i].code);
          _languages[i].status = status;
        }
      });
    }
  }

  void _translate(int index) {
    final lang = _languages[index];
    articleController.startTranslation(lang.code);
  }

  void _retranslate(int index) {
    final lang = _languages[index];
    articleController.retranslate(lang.code);
  }

  void _switchToLanguage(String code) {
    if (!mounted) return;
    setState(() {
      _currentLanguageCode = code;
    });
    articleController.switchToLanguage(code);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDragHandle(context),
              _buildHeader(context),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    return _buildLanguageItem(context, lang, index);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Container(
      width: 40,
      height: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          'AI 翻译',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '选择要翻译的目标语言',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageItem(BuildContext context, _Language lang, int index) {
    final theme = Theme.of(context);
    final isCurrent = _currentLanguageCode == lang.code;

    return Obx(() {
      // 直接使用 ArticleController 的翻译状态
      final displayStatus = articleController.getTranslationStatus(lang.code);
      
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isCurrent
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isCurrent ? 1.5 : 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lang.name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusWidget(context, displayStatus),
                ],
              ),
              const Spacer(),
              _buildActionButton(context, lang, index, displayStatus),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatusWidget(BuildContext context, String status) {
    final theme = Theme.of(context);
    switch (status) {
      case 'translated':
        return Text(
          '翻译完成',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.primary),
        );
      case 'translating':
        return Row(
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '翻译中...',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        );
      case 'failed':
        return Text(
          '翻译失败',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.error),
        );
      case 'untranslated':
      default:
        return Text(
          '待翻译',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        );
    }
  }

  Widget _buildActionButton(BuildContext context, _Language lang, int index, String displayStatus) {
    final theme = Theme.of(context);
    switch (displayStatus) {
      case 'untranslated':
        return ElevatedButton(
          onPressed: () => _translate(index),
          child: const Text('翻译'),
        );
      case 'translating':
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor:
                theme.colorScheme.onSurface.withOpacity(0.12),
          ),
          child: const Text('翻译'),
        );
      case 'translated':
        return Row(
          children: [
            TextButton(
              onPressed: () => _retranslate(index),
              child: const Text('重新翻译'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _switchToLanguage(lang.code),
              style: _currentLanguageCode == lang.code
                  ? ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                    )
                  : null,
              child: const Text('查看'),
            ),
          ],
        );
      case 'failed':
        return ElevatedButton(
          onPressed: () => _translate(index),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.errorContainer,
            foregroundColor: theme.colorScheme.onErrorContainer,
          ),
          child: const Text('重试'),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}


mixin TranslateModalBLoC on State<TranslateModal> {
  final ArticleController articleController = Get.find<ArticleController>();

  final List<_Language> _languages = [
    _Language(name: '英语', code: 'en-US'),
    _Language(name: '日语', code: 'ja-JP'),
    _Language(name: '韩语', code: 'ko-KR'),
    _Language(name: '法语', code: 'fr-FR'),
    _Language(name: '德语', code: 'de-DE'),
    _Language(name: '西班牙语', code: 'es-ES'),
    _Language(name: '俄语', code: 'ru-RU'),
    _Language(name: '阿拉伯语', code: 'ar-AR'),
    _Language(name: '葡萄牙语', code: 'pt-PT'),
    _Language(name: '意大利语', code: 'it-IT'),
    _Language(name: '荷兰语', code: 'nl-NL'),
    _Language(name: '泰语', code: 'th-TH'),
    _Language(name: '越南语', code: 'vi-VN'),
    _Language(name: '简体中文', code: 'zh-CN'),
    _Language(name: '繁体中文', code: 'zh-TW'),
  ];

  String _currentLanguageCode = 'original'; // 默认为原文，将从ArticleController获取




}
