# GetX 多语言国际化使用指南

## 概述

本项目使用 GetX 框架实现多语言国际化功能，支持中文简体和英文两种语言，可以轻松扩展更多语言。

## 文件结构

```
lib/
├── translations/
│   └── app_translations.dart        # 翻译配置文件
├── controller/
│   └── language_controller.dart     # 语言控制器
├── basics/
│   └── language_utils.dart          # 多语言工具类
└── view/
    ├── settings/
    │   └── language_selection_page.dart  # 语言选择页面
    └── demo/
        └── language_demo_page.dart       # 语言演示页面
```

## 基本使用

### 1. 在 Widget 中使用翻译文本

```dart
// 基本翻译
Text('confirm'.tr)

// 带参数的翻译
Text('welcome_message'.trArgs(['用户名']))

// 复数形式
Text('item_count'.trPlural(count.toString()))
```

### 2. 在代码中检查当前语言

```dart
// 使用工具类
if (LanguageUtils.isChinese()) {
  // 中文逻辑
} else if (LanguageUtils.isEnglish()) {
  // 英文逻辑
}

// 获取当前语言代码
String langCode = LanguageUtils.getCurrentLanguageCode(); // 'zh' 或 'en'
```

### 3. 格式化日期时间

```dart
// 本地化日期时间格式
String formattedDate = LanguageUtils.formatDateTime(DateTime.now());
// 中文: 2024年3月15日 14:30
// 英文: Mar 15, 2024 14:30

// 相对时间
String relativeTime = LanguageUtils.getRelativeTime(someDate);
// 中文: 昨天、本周、本月
// 英文: Yesterday, This Week, This Month
```

### 4. 切换语言

```dart
// 获取语言控制器
final languageController = Get.find<LanguageController>();

// 切换到中文
languageController.changeLanguage('zh', 'CN');

// 切换到英文
languageController.changeLanguage('en', 'US');

// 跳转到语言选择页面
Get.to(() => const LanguageSelectionPage());
```

## 添加新语言

### 1. 在翻译配置中添加语言

编辑 `lib/translations/app_translations.dart`：

```dart
Map<String, Map<String, String>> get keys => {
  'zh_CN': {
    'hello': '你好',
    // ... 其他中文翻译
  },
  'en_US': {
    'hello': 'Hello',
    // ... 其他英文翻译
  },
  'ja_JP': {  // 新增日语
    'hello': 'こんにちは',
    // ... 其他日语翻译
  },
};
```

### 2. 在语言控制器中添加支持

编辑 `lib/controller/language_controller.dart`：

```dart
final List<LanguageModel> supportedLanguages = [
  LanguageModel(
    languageCode: 'zh',
    countryCode: 'CN',
    languageName: '中文简体',
    flag: '🇨🇳',
  ),
  LanguageModel(
    languageCode: 'en',
    countryCode: 'US',
    languageName: 'English',
    flag: '🇺🇸',
  ),
  LanguageModel(  // 新增日语支持
    languageCode: 'ja',
    countryCode: 'JP',
    languageName: '日本語',
    flag: '🇯🇵',
  ),
];
```

### 3. 更新工具类（可选）

如果新语言需要特殊处理，可以在 `lib/basics/language_utils.dart` 中添加相应方法：

```dart
/// 判断是否为日语
static bool isJapanese() {
  return getCurrentLanguageCode() == 'ja';
}
```

## 翻译文本管理

### 命名规范

- 使用下划线分隔的小写字母：`user_name`
- 按功能模块分组：`login_title`, `login_button`
- 错误信息统一前缀：`error_network`, `error_permission`
- 成功信息统一前缀：`success_save`, `success_delete`

### 常用翻译 Key

#### 通用操作
- `confirm` - 确认
- `cancel` - 取消
- `save` - 保存
- `delete` - 删除
- `edit` - 编辑
- `add` - 添加
- `search` - 搜索
- `loading` - 加载中...
- `no_data` - 暂无数据

#### 剪藏功能
- `clip` - 剪藏
- `clips` - 剪藏
- `add_clip` - 添加剪藏
- `clip_list` - 剪藏列表
- `clip_title` - 标题
- `clip_content` - 内容

#### 时间相关
- `today` - 今天
- `yesterday` - 昨天
- `this_week` - 本周
- `this_month` - 本月

## 最佳实践

### 1. 避免硬编码文本

❌ 错误做法：
```dart
Text('保存')  // 硬编码中文
```

✅ 正确做法：
```dart
Text('save'.tr)  // 使用翻译键
```

### 2. 处理长文本

对于较长的文本，建议使用简短的键名：
```dart
'welcome_description': '欢迎使用 Clipora 剪藏应用，这里可以帮助您...',
```

### 3. 参数化翻译

当文本包含变量时，使用参数化翻译：
```dart
// 翻译文件中
'welcome_user': '欢迎，@name！',
'welcome_user': 'Welcome, @name!',

// 使用时
Text('welcome_user'.trArgs([userName]))
```

### 4. 测试多语言

- 确保所有界面都有相应的翻译
- 测试文本在不同语言下的布局效果
- 注意不同语言的文本长度差异

## 注意事项

1. **语言持久化**：语言设置会自动保存到本地存储，应用重启后会恢复用户的语言选择。

2. **系统语言检测**：首次安装时会检测系统语言，支持的语言会自动设置，不支持的语言将默认使用中文。

3. **实时切换**：语言切换后立即生效，无需重启应用。

4. **回退机制**：如果某个翻译不存在，会使用 `fallbackLocale`（中文）作为回退。

5. **性能考虑**：翻译文本会缓存在内存中，不会影响应用性能。

## 演示页面

运行应用后，可以访问 `LanguageDemoPage` 查看多语言功能的演示效果，包括：
- 当前语言显示
- 基本翻译示例
- 时间日期格式化
- 语言切换功能

## 故障排除

### 常见问题

1. **翻译不生效**
   - 检查翻译键是否存在于 `app_translations.dart` 中
   - 确认语言代码格式正确（如：`zh_CN`, `en_US`）

2. **切换语言后部分文本未更新**
   - 确保页面使用了 `Obx()` 包装需要响应的 Widget
   - 检查是否有硬编码文本未使用 `.tr` 方法

3. **系统语言检测失败**
   - 检查设备语言设置
   - 确认该语言是否在支持列表中

有问题请查看相关代码文件或联系开发团队。 