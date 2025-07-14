import 'package:flutter/material.dart' hide kDefaultFontSize;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../basics/config.dart';
import '../../../basics/logger.dart';
import 'article_markdown_controller.dart';
import '../article_page/components/read_theme_widget.dart';


/// 文章控制器
class ArticleReadThemeController extends ArticleMarkdownController  {

  // 字体大小管理
  final RxDouble _fontSize = 16.0.obs;
  double get fontSize => _fontSize.value;

  // 阅读主题管理
  final Rx<ReadingThemeType> _currentReadingTheme = ReadingThemeType.defaultTheme.obs;
  ReadingThemeType get currentReadingTheme => _currentReadingTheme.value;

  // 样式调整管理
  final RxDouble _marginSize = 20.0.obs;
  double get marginSize => _marginSize.value;
  
  final RxDouble _lineHeight = 1.6.obs;
  double get lineHeight => _lineHeight.value;
  
  final RxDouble _letterSpacing = 0.0.obs;
  double get letterSpacing => _letterSpacing.value;
  
  final RxDouble _paragraphSpacing = 16.0.obs;
  double get paragraphSpacing => _paragraphSpacing.value;

  // 存储键名
  static const String _fontSizeStorageKey = 'user_font_size';
  static const String _readingThemeStorageKey = 'user_reading_theme';
  static const String _marginSizeStorageKey = 'user_margin_size';
  static const String _lineHeightStorageKey = 'user_line_height';
  static const String _letterSpacingStorageKey = 'user_letter_spacing';
  static const String _paragraphSpacingStorageKey = 'user_paragraph_spacing';

  @override
  void onInit() {
    super.onInit();
    _loadFontSizeFromStorage();
    _loadReadingThemeFromStorage();
    _loadStyleSettingsFromStorage();
  }

  /// 从存储中加载字体大小
  void _loadFontSizeFromStorage() {
    try {
      final savedFontSize = GetStorage().read<double>(_fontSizeStorageKey);
      if (savedFontSize != null) {
        // 确保字体大小在合理范围内
        final clampedSize = savedFontSize.clamp(kMinFontSize, kMaxFontSize);
        _fontSize.value = clampedSize;
        getLogger().i('📝 从存储加载字体大小: ${clampedSize}px');
      } else {
        // 如果没有保存的设置，使用默认值
        _fontSize.value = kDefaultFontSize;
        getLogger().i('📝 使用默认字体大小: ${kDefaultFontSize}px');
      }
    } catch (e) {
      getLogger().e('❌ 加载字体大小设置失败: $e');
      // 出错时使用默认值
      _fontSize.value = kDefaultFontSize;
    }
  }

  /// 保存字体大小到存储
  void _saveFontSizeToStorage(double fontSize) {
    try {
      GetStorage().write(_fontSizeStorageKey, fontSize);
      getLogger().i('💾 字体大小已保存到存储: ${fontSize}px');
    } catch (e) {
      getLogger().e('❌ 保存字体大小设置失败: $e');
    }
  }

  /// 从存储中加载阅读主题
  void _loadReadingThemeFromStorage() {
    try {
      final savedTheme = GetStorage().read<String>(_readingThemeStorageKey);
      if (savedTheme != null) {
        final themeType = ReadingThemeType.values.firstWhere(
          (theme) => theme.toString() == savedTheme,
          orElse: () => ReadingThemeType.defaultTheme,
        );
        _currentReadingTheme.value = themeType;
        getLogger().i('📝 从存储加载阅读主题: $themeType');
      } else {
        // 如果没有保存的设置，使用默认主题
        _currentReadingTheme.value = ReadingThemeType.defaultTheme;
        getLogger().i('📝 使用默认阅读主题: ${ReadingThemeType.defaultTheme}');
      }
    } catch (e) {
      getLogger().e('❌ 加载阅读主题设置失败: $e');
      // 出错时使用默认主题
      _currentReadingTheme.value = ReadingThemeType.defaultTheme;
    }
  }

  /// 保存阅读主题到存储
  void _saveReadingThemeToStorage(ReadingThemeType themeType) {
    try {
      GetStorage().write(_readingThemeStorageKey, themeType.toString());
      getLogger().i('💾 阅读主题已保存到存储: $themeType');
    } catch (e) {
      getLogger().e('❌ 保存阅读主题设置失败: $e');
    }
  }

  /// 从存储中加载样式设置
  void _loadStyleSettingsFromStorage() {
    try {
      // 加载边距设置
      final savedMarginSize = GetStorage().read<double>(_marginSizeStorageKey);
      if (savedMarginSize != null) {
        _marginSize.value = savedMarginSize.clamp(10.0, 50.0);
        getLogger().i('📝 从存储加载边距设置: ${_marginSize.value}px');
      }

      // 加载行高设置
      final savedLineHeight = GetStorage().read<double>(_lineHeightStorageKey);
      if (savedLineHeight != null) {
        _lineHeight.value = savedLineHeight.clamp(1.2, 2.5);
        getLogger().i('📝 从存储加载行高设置: ${_lineHeight.value}');
      }

      // 加载字距设置
      final savedLetterSpacing = GetStorage().read<double>(_letterSpacingStorageKey);
      if (savedLetterSpacing != null) {
        _letterSpacing.value = savedLetterSpacing.clamp(-2.0, 5.0);
        getLogger().i('📝 从存储加载字距设置: ${_letterSpacing.value}px');
      }

      // 加载段落间距设置
      final savedParagraphSpacing = GetStorage().read<double>(_paragraphSpacingStorageKey);
      if (savedParagraphSpacing != null) {
        _paragraphSpacing.value = savedParagraphSpacing.clamp(8.0, 32.0);
        getLogger().i('📝 从存储加载段落间距设置: ${_paragraphSpacing.value}px');
      }
    } catch (e) {
      getLogger().e('❌ 加载样式设置失败: $e');
    }
  }

  /// 保存样式设置到存储
  void _saveStyleSettingsToStorage() {
    try {
      GetStorage().write(_marginSizeStorageKey, _marginSize.value);
      GetStorage().write(_lineHeightStorageKey, _lineHeight.value);
      GetStorage().write(_letterSpacingStorageKey, _letterSpacing.value);
      GetStorage().write(_paragraphSpacingStorageKey, _paragraphSpacing.value);
      getLogger().i('💾 样式设置已保存到存储');
    } catch (e) {
      getLogger().e('❌ 保存样式设置失败: $e');
    }
  }

  /// 切换阅读主题
  void changeReadingTheme(ReadingThemeType themeType) {
    if (_currentReadingTheme.value != themeType) {
      _currentReadingTheme.value = themeType;
      _saveReadingThemeToStorage(themeType);
      getLogger().i('🎨 阅读主题已切换为: $themeType');
      
      // 通知WebView更新主题
      _updateWebViewTheme(themeType);
      
      // 触发UI更新
      update();
    }
  }

  /// 重置阅读主题
  void resetReadingTheme() {
    changeReadingTheme(ReadingThemeType.defaultTheme);
  }

  /// 获取当前主题配置
  ThemeConfig get currentThemeConfig {
    final themeConfigs = [
      const ThemeConfig(
        type: ReadingThemeType.defaultTheme,
        name: '默认主题',
        description: '经典白底黑字，清晰易读',
        backgroundColor: Colors.white,
        textColor: Colors.black87,
        cardColor: Color(0xFFF5F5F5),
        dividerColor: Color(0xFFE0E0E0),
        icon: Icons.article,
      ),
      const ThemeConfig(
        type: ReadingThemeType.lightTheme,
        name: '浅色主题',
        description: '柔和浅色背景，舒适阅读',
        backgroundColor: Color(0xFFFAFAFA),
        textColor: Color(0xFF424242),
        cardColor: Colors.white,
        dividerColor: Color(0xFFE8E8E8),
        icon: Icons.light_mode,
      ),
      const ThemeConfig(
        type: ReadingThemeType.darkTheme,
        name: '深色主题',
        description: '深色背景，减少眼睛疲劳',
        backgroundColor: Color(0xFF121212),
        textColor: Color(0xFFE0E0E0),
        cardColor: Color(0xFF1E1E1E),
        dividerColor: Color(0xFF424242),
        icon: Icons.dark_mode,
      ),
      const ThemeConfig(
        type: ReadingThemeType.sepiaTheme,
        name: '护眼主题',
        description: '米色背景，模拟纸张质感',
        backgroundColor: Color(0xFFF5F5DC),
        textColor: Color(0xFF3C3C3C),
        cardColor: Color(0xFFFFF8E1),
        dividerColor: Color(0xFFE8E6D9),
        icon: Icons.visibility,
      ),
      const ThemeConfig(
        type: ReadingThemeType.nightTheme,
        name: '夜间主题',
        description: '深蓝灰背景，夜间护眼',
        backgroundColor: Color(0xFF263238),
        textColor: Color(0xFFE5E5E7),
        cardColor: Color(0xFF2E3C43),
        dividerColor: Color(0xFF455A64),
        icon: Icons.nightlight_round,
      ),
      // 新增：墨绿主题
      const ThemeConfig(
        type: ReadingThemeType.inkGreenTheme,
        name: '墨绿主题',
        description: '深墨绿背景，米白色文字，护眼文艺',
        backgroundColor: Color(0xFF223322),
        textColor: Color(0xFFF5F5E0),
        cardColor: Color(0xFF2E4D2E),
        dividerColor: Color(0xFF3C5C3C),
        icon: Icons.eco,
      ),
      // 新增：蓝光护眼主题
      const ThemeConfig(
        type: ReadingThemeType.blueLightTheme,
        name: '蓝光护眼',
        description: '淡蓝灰背景，过滤蓝光，夜间舒适',
        backgroundColor: Color(0xFFE3F2FD),
        textColor: Color(0xFF263238),
        cardColor: Color(0xFFBBDEFB),
        dividerColor: Color(0xFF90CAF9),
        icon: Icons.remove_red_eye,
      ),
      // 新增：极简黑白主题
      const ThemeConfig(
        type: ReadingThemeType.pureBlackTheme,
        name: '极简黑白',
        description: '极简纯黑纯白，专注阅读',
        backgroundColor: Colors.black,
        textColor: Colors.white,
        cardColor: Color(0xFF222222),
        dividerColor: Color(0xFF444444),
        icon: Icons.crop_square,
      ),
      // 新增：仿纸张主题
      const ThemeConfig(
        type: ReadingThemeType.paperTheme,
        name: '仿纸张',
        description: '淡黄纸张，深棕文字，模拟真实书本',
        backgroundColor: Color(0xFFFFFDE7),
        textColor: Color(0xFF5D4037),
        cardColor: Color(0xFFFFF8E1),
        dividerColor: Color(0xFFE8E6D9),
        icon: Icons.menu_book,
      ),
      // 新增：少女粉主题
      const ThemeConfig(
        type: ReadingThemeType.pinkTheme,
        name: '少女粉',
        description: '浅粉色背景，温馨可爱',
        backgroundColor: Color(0xFFFFEBEE),
        textColor: Color(0xFFAD1457),
        cardColor: Color(0xFFF8BBD0),
        dividerColor: Color(0xFFF48FB1),
        icon: Icons.favorite,
      ),
    ];
    
    return themeConfigs.firstWhere(
      (config) => config.type == _currentReadingTheme.value,
      orElse: () => themeConfigs.first,
    );
  }

  /// 更新WebView主题
  Future<void> _updateWebViewTheme(ReadingThemeType themeType) async {
    if (markdownController != null) {
      try {
        final config = currentThemeConfig;
        await markdownController!.evaluateJavascript(source: '''
          (function() {
            try {
              // 更新CSS变量
              document.documentElement.style.setProperty('--background-color', '${_colorToHex(config.backgroundColor)}');
              document.documentElement.style.setProperty('--text-color', '${_colorToHex(config.textColor)}');
              document.documentElement.style.setProperty('--card-color', '${_colorToHex(config.cardColor)}');
              document.documentElement.style.setProperty('--divider-color', '${_colorToHex(config.dividerColor)}');
              
              // 更新body背景色
              document.body.style.backgroundColor = '${_colorToHex(config.backgroundColor)}';
              document.body.style.color = '${_colorToHex(config.textColor)}';
              
              // 更新所有文本元素的颜色
              const textElements = document.querySelectorAll('p, h1, h2, h3, h4, h5, h6, li, blockquote, pre, code, span, div');
              textElements.forEach(element => {
                element.style.color = '${_colorToHex(config.textColor)}';
              });
              
              // 更新代码块背景色
              const codeElements = document.querySelectorAll('pre, code');
              codeElements.forEach(element => {
                element.style.backgroundColor = '${_colorToHex(config.cardColor)}';
              });
              
              // 更新分割线颜色
              const hrElements = document.querySelectorAll('hr');
              hrElements.forEach(element => {
                element.style.borderColor = '${_colorToHex(config.dividerColor)}';
              });
              
              console.log('✅ 主题更新成功: $themeType');
              return true;
            } catch (error) {
              console.error('❌ 更新主题失败:', error);
              return false;
            }
          })();
        ''');
        getLogger().i('✅ WebView主题更新成功: $themeType');
      } catch (e) {
        getLogger().e('❌ 更新WebView主题失败: $e');
      }
    } else {
      getLogger().w('⚠️ WebView控制器未就绪，无法更新主题');
    }
  }

  /// 将Color转换为十六进制字符串
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  /// 调整字体大小
  Future<void> adjustFontSize(double newSize) async {
    // 确保字体大小在合理范围内
    final clampedSize = newSize.clamp(kMinFontSize, kMaxFontSize);

    if (_fontSize.value != clampedSize) {
      _fontSize.value = clampedSize;
      
      // 保存到存储
      _saveFontSizeToStorage(clampedSize);
      
      getLogger().i('📝 字体大小调整为: ${clampedSize}px');

      // 通知WebView更新字体大小
      await _updateWebViewFontSize(clampedSize);
      
      // 触发UI更新
      update();
    }
  }

  /// 增加字体大小
  Future<void> increaseFontSize() async {
    await adjustFontSize(_fontSize.value + kFontSizeStep);
  }

  /// 减少字体大小
  Future<void> decreaseFontSize() async {
    await adjustFontSize(_fontSize.value - kFontSizeStep);
  }

  /// 重置字体大小
  Future<void> resetFontSize() async {
    await adjustFontSize(kDefaultFontSize);
  }

  /// 调整边距大小
  Future<void> adjustMarginSize(double newSize) async {
    final clampedSize = newSize.clamp(10.0, 50.0);
    if (_marginSize.value != clampedSize) {
      _marginSize.value = clampedSize;
      _saveStyleSettingsToStorage();
      getLogger().i('📝 边距大小调整为: ${clampedSize}px');
      await _updateWebViewStyleSettings();
      update();
    }
  }

  /// 调整行高
  Future<void> adjustLineHeight(double newHeight) async {
    final clampedHeight = newHeight.clamp(1.2, 2.5);
    if (_lineHeight.value != clampedHeight) {
      _lineHeight.value = clampedHeight;
      _saveStyleSettingsToStorage();
      getLogger().i('📝 行高调整为: ${clampedHeight}');
      await _updateWebViewStyleSettings();
      update();
    }
  }

  /// 调整字距
  Future<void> adjustLetterSpacing(double newSpacing) async {
    final clampedSpacing = newSpacing.clamp(-2.0, 5.0);
    if (_letterSpacing.value != clampedSpacing) {
      _letterSpacing.value = clampedSpacing;
      _saveStyleSettingsToStorage();
      getLogger().i('📝 字距调整为: ${clampedSpacing}px');
      await _updateWebViewStyleSettings();
      update();
    }
  }

  /// 调整段落间距
  Future<void> adjustParagraphSpacing(double newSpacing) async {
    final clampedSpacing = newSpacing.clamp(8.0, 32.0);
    if (_paragraphSpacing.value != clampedSpacing) {
      _paragraphSpacing.value = clampedSpacing;
      _saveStyleSettingsToStorage();
      getLogger().i('📝 段落间距调整为: ${clampedSpacing}px');
      await _updateWebViewStyleSettings();
      update();
    }
  }

  /// 重置所有样式设置
  Future<void> resetAllStyleSettings() async {
    await adjustFontSize(kDefaultFontSize);
    await adjustMarginSize(20.0);
    await adjustLineHeight(1.6);
    await adjustLetterSpacing(0.0);
    await adjustParagraphSpacing(16.0);
    getLogger().i('🔄 所有样式设置已重置为默认值');
  }

  /// 更新WebView样式设置
  Future<void> _updateWebViewStyleSettings() async {
    if (markdownController != null) {
      try {
        await markdownController!.evaluateJavascript(source: '''
          (function() { 
            try {
              // 更新所有文本元素的样式
              const textElements = document.querySelectorAll('p, h1, h2, h3, h4, h5, h6, li, blockquote, pre, code, span, div');
              textElements.forEach(element => {
                element.style.lineHeight = '${_lineHeight.value}';
                element.style.letterSpacing = '${_letterSpacing.value}px';
              });
              
              // 更新段落间距
              const paragraphElements = document.querySelectorAll('p');
              paragraphElements.forEach(element => {
                element.style.marginBottom = '${_paragraphSpacing.value}px';
              });
              
              // 更新容器边距
              const container = document.querySelector('.markdown-content') || document.body;
              if (container) {
                container.style.padding = '${_marginSize.value}px';
                container.style.padding = '${MediaQuery.of(context).padding.top + 20.0 + _marginSize.value}px';
              }
              
              console.log('✅ 样式设置更新成功');
              return true;
            } catch (error) {
              console.error('❌ 更新样式设置失败:', error);
              return false;
            }
          })();
        ''');
        getLogger().i('✅ WebView样式设置更新成功');
      } catch (e) {
        getLogger().e('❌ 更新WebView样式设置失败: $e');
      }
    } else {
      getLogger().w('⚠️ WebView控制器未就绪，无法更新样式设置');
    }
  }

  /// 更新WebView字体大小
  Future<void> _updateWebViewFontSize(double fontSize) async {
    if (markdownController != null) {
      try {
        await markdownController!.evaluateJavascript(source: '''
          (function() {
            try {
              // 使用新的updateFontSize函数
              if (typeof window.updateFontSize === 'function') {
                return window.updateFontSize(${fontSize});
              }else{
                return false;
              }
            } catch (error) {
              console.error('❌ 更新字体大小失败:', error);
              return false;
            }
          })();
        ''');
        getLogger().i('✅ WebView字体大小更新成功: ${fontSize}px');
      } catch (e) {
        getLogger().e('❌ 更新WebView字体大小失败: $e');
      }
    } else {
      getLogger().w('⚠️ WebView控制器未就绪，无法更新字体大小');
    }
  }

}