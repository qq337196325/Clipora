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
    
    // 更新本地状态（实际上现在本地状态不再使用，但保持一致性）
    if (mounted) {
      setState(() {
        for (int i = 0; i < _allLanguages.length; i++) {
          // 跳过原文，因为原文不需要翻译状态
          if (_allLanguages[i].code == 'original') continue;
          
          final status = articleController.getTranslationStatus(_allLanguages[i].code);
          _allLanguages[i].status = status;
        }
      });
    }
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
                  'AI翻译不足',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              '系统赠送新用户3次免费AI翻译。您的 AI 翻译额度已用完，充值后可继续使用高质量翻译服务。',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('以后再说'),
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
                child: const Text('前往充值'),
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
        '已可用',
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.primary),
      );
    }
    
    // 其他语言的翻译状态
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
              '预计20秒至2分钟，正在翻译...',
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

  Widget _buildActionButton(BuildContext context, _Language lang, int index, String displayStatus, bool isCurrent) {
    final theme = Theme.of(context);
    
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
        child: const Text('查看'),
      );
    }
    
    // 其他语言的翻译状态处理
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
              style: isCurrent
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

  final List<_Language> _allLanguages = [
    _Language(name: '原文', code: 'original'),
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
