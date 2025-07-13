import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../../route/route_name.dart';

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
    
    // 获取所有语言代码（除了原文，因为原文不需要翻译状态管理）
    final languageCodes = _allLanguages
        .where((lang) => lang.code != 'original')
        .map((lang) => lang.code)
        .toList();
    
    // 批量初始化 ArticleController 中的翻译状态
    await articleController.initializeAllLanguageStatus(languageCodes);
    
    getLogger().d('🔄 TranslateModal 状态初始化完成');
  }

  void _translate(int index) async {
    final lang = _languages[index];
    final apiCode = await articleController.startTranslation(lang.code);
    _handleApiCode(apiCode);
  }

  void _retranslate(int index) async {
    final lang = _languages[index];
    final apiCode = await articleController.retranslate(lang.code);
    _handleApiCode(apiCode);
  }

  void _handleApiCode(int apiCode) {
    if (apiCode == 100) {
      if (!mounted) return;
      final theme = Theme.of(context);
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: theme.colorScheme.surface,
            title: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'i18n_article_AI翻译不足'.tr,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              'i18n_article_AI翻译额度已用完提示'.tr,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text('i18n_article_以后再说'.tr),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop(); // Close the translate modal as well
                  context.push('/${RouteName.aiOrderPage}');
                },
                child: Text('i18n_article_前往充值'.tr),
              ),
            ],
          );
        },
      );
    }
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
                child: Obx(() {
                  final languages = _languages; // 动态获取当前应该显示的语言列表
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: languages.length,
                    itemBuilder: (context, index) {
                      final lang = languages[index];
                      return _buildLanguageItem(context, lang, index);
                    },
                  );
                }),
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
          'i18n_article_AI翻译'.tr,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'i18n_article_选择要翻译的目标语言'.tr,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageItem(BuildContext context, _Language lang, int index) {
    final theme = Theme.of(context);

    return Obx(() {
      // 直接使用 ArticleController 的实时状态
      final isCurrent = articleController.currentLanguageCode == lang.code;
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
                  _buildStatusWidget(context, displayStatus, lang.code),
                ],
              ),
              const Spacer(),
              _buildActionButton(context, lang, index, displayStatus, isCurrent),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatusWidget(BuildContext context, String status, [String? languageCode]) {
    final theme = Theme.of(context);
    
    // 原文的特殊处理
    if (languageCode == 'original') {
      return Text(
        'i18n_article_已可用'.tr,
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.primary),
      );
    }
    
    // 其他语言的翻译状态
    switch (status) {
      case 'translated':
        return Text(
          'i18n_article_翻译完成'.tr,
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
              'i18n_article_正在翻译中'.tr,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        );
      case 'failed':
        return Text(
          'i18n_article_翻译失败'.tr,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.error),
        );
      case 'untranslated':
      default:
        return Text(
          'i18n_article_待翻译'.tr,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        );
    }
  }

  Widget _buildActionButton(BuildContext context, _Language lang, int index, String displayStatus, bool isCurrent) {
    final theme = Theme.of(context);
    
    // 检查是否有任何语言正在翻译中（用于并发控制）
    final isAnyTranslating = articleController.isAnyLanguageTranslating;
    final isCurrentTranslating = displayStatus == 'translating';
    
    // 原文的特殊处理 - 只显示查看按钮
    if (lang.code == 'original') {
      return ElevatedButton(
        onPressed: () => _switchToLanguage(lang.code),
        style: isCurrent
            ? ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
              )
            : null,
        child: Text('i18n_article_查看'.tr),
      );
    }
    
    // 其他语言的翻译状态处理
    switch (displayStatus) {
      case 'untranslated':
        return ElevatedButton(
          // 如果有其他语言正在翻译中，则禁用当前翻译按钮
          onPressed: isAnyTranslating ? null : () => _translate(index),
          style: isAnyTranslating 
              ? ElevatedButton.styleFrom(
                  disabledBackgroundColor: theme.colorScheme.onSurface.withOpacity(0.12),
                )
              : null,
          child: Text('i18n_article_翻译'.tr),
        );
      case 'translating':
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor:
                theme.colorScheme.onSurface.withOpacity(0.12),
          ),
          child: Text('i18n_article_翻译'.tr),
        );
      case 'translated':
        return Row(
          children: [
            TextButton(
              // 如果有其他语言正在翻译中，则禁用重新翻译按钮
              onPressed: isAnyTranslating ? null : () => _retranslate(index),
              style: isAnyTranslating 
                  ? TextButton.styleFrom(
                      disabledForegroundColor: theme.colorScheme.onSurface.withOpacity(0.38),
                    )
                  : null,
              child: Text('i18n_article_重新翻译'.tr),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _switchToLanguage(lang.code),
              style: isCurrent
                  ? ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                    )
                  : null,
              child: Text('i18n_article_查看'.tr),
            ),
          ],
        );
      case 'failed':
        return ElevatedButton(
          // 如果有其他语言正在翻译中，则禁用重试按钮
          onPressed: isAnyTranslating ? null : () => _translate(index),
          style: isAnyTranslating 
              ? ElevatedButton.styleFrom(
                  disabledBackgroundColor: theme.colorScheme.onSurface.withOpacity(0.12),
                )
              : ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.errorContainer,
                  foregroundColor: theme.colorScheme.onErrorContainer,
                ),
          child: Text('i18n_article_重试'.tr),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}


mixin TranslateModalBLoC on State<TranslateModal> {
  final ArticleController articleController = Get.find<ArticleController>();

  final List<_Language> _allLanguages = [
    _Language(name: 'i18n_article_原文'.tr, code: 'original'),
    _Language(name: 'i18n_article_英语'.tr, code: 'en-US'),
    _Language(name: 'i18n_article_日语'.tr, code: 'ja-JP'),
    _Language(name: 'i18n_article_韩语'.tr, code: 'ko-KR'),
    _Language(name: 'i18n_article_法语'.tr, code: 'fr-FR'),
    _Language(name: 'i18n_article_德语'.tr, code: 'de-DE'),
    _Language(name: 'i18n_article_西班牙语'.tr, code: 'es-ES'),
    _Language(name: 'i18n_article_俄语'.tr, code: 'ru-RU'),
    _Language(name: 'i18n_article_阿拉伯语'.tr, code: 'ar-AR'),
    _Language(name: 'i18n_article_葡萄牙语'.tr, code: 'pt-PT'),
    _Language(name: 'i18n_article_意大利语'.tr, code: 'it-IT'),
    _Language(name: 'i18n_article_荷兰语'.tr, code: 'nl-NL'),
    _Language(name: 'i18n_article_泰语'.tr, code: 'th-TH'),
    _Language(name: 'i18n_article_越南语'.tr, code: 'vi-VN'),
    _Language(name: 'i18n_article_简体中文'.tr, code: 'zh-CN'),
    _Language(name: 'i18n_article_繁体中文'.tr, code: 'zh-TW'),
  ];

  /// 获取当前应该显示的语言列表
  List<_Language> get _languages {
    final currentLanguage = articleController.currentLanguageCode;
    
    // 如果当前是原文，则不显示原文选项
    if (currentLanguage == 'original') {
      return _allLanguages.where((lang) => lang.code != 'original').toList();
    } else {
      // 如果当前是其他语言，则显示包括原文在内的所有选项
      return _allLanguages;
    }
  }

  String _currentLanguageCode = 'original'; // 默认为原文，将从ArticleController获取




}
