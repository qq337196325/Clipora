# i18n 完整性检查工具

这个工具集用于检查项目中所有语言的 i18n 文件完整性，确保每个语言都包含中文版本中的所有翻译 key。

## 工具说明

### 1. check_i18n_completeness.dart
基础的完整性检查工具，会在控制台输出详细的缺失信息。

**使用方法：**
```bash
# 在项目根目录运行
dart run tools/check_i18n_completeness.dart

# 或者使用批处理文件（Windows）
tools/check_i18n.bat
```

**输出示例：**
```
🔍 开始检查 i18n 文件完整性...

📋 中文 i18n 基准文件统计:
  home_my_i18n.dart: 95 个 key
  login_i18n.dart: 25 个 key
  theme_i18n.dart: 14 个 key

🌍 发现的其他语言: en_us, ja_jp, ko_kr...

❌ en_us 缺失的翻译:
  📄 theme_i18n.dart (缺失 2 个):
    - i18n_theme_森林主题
    - i18n_theme_海洋主题

✅ ja_jp: 所有文件都完整
```

### 2. generate_i18n_report.dart
生成详细的 JSON 格式报告，包含统计信息和完整度分析。

**使用方法：**
```bash
# 生成默认报告文件 i18n_report.json
dart run tools/generate_i18n_report.dart

# 指定输出文件名
dart run tools/generate_i18n_report.dart my_report.json
```

**输出示例：**
```
📊 i18n 完整性摘要:
  总语言数: 14
  平均完整度: 85.5%
  完全完整的语言: 3
  需要补充的语言: 11

🏆 完整度排行榜:
  1. 🎉 ar_ar: 100.0% (缺失 0 个)
  2. 👍 en_us: 98.5% (缺失 2 个)
  3. ⚠️ ja_jp: 85.2% (缺失 21 个)
```

### 3. check_i18n.bat
Windows 批处理文件，方便快速运行基础检查工具。

## 工作原理

1. **基准设定**：以 `lib/basics/translations/zh_cn/` 目录下的中文 i18n 文件作为基准
2. **Key 提取**：使用正则表达式从 Dart 文件中提取所有的翻译 key
3. **对比检查**：逐个检查其他语言目录中对应文件的 key 完整性
4. **结果输出**：显示缺失的 key 列表或生成详细报告

## 支持的文件格式

工具支持标准的 Dart Map 格式的 i18n 文件：

```dart
const Map<String, String> homeMyI18n = {
  'i18n_my_设置': '设置',
  'i18n_my_应用功能': '应用功能',
  // ...
};
```

## 注意事项

1. **文件结构**：确保所有语言目录的文件结构与中文目录保持一致
2. **Key 格式**：支持单引号和双引号的 key 格式
3. **排除文件**：会自动跳过主文件（如 `zh_cn.dart`）和特殊目录
4. **错误处理**：对于无法读取的文件会显示警告但不会中断检查

## 建议的工作流程

1. **定期检查**：在添加新的翻译 key 后运行检查工具
2. **生成报告**：使用报告工具生成详细的完整度分析
3. **优先处理**：根据完整度排行榜优先处理缺失较多的语言
4. **自动化**：可以将检查工具集成到 CI/CD 流程中

## 扩展建议

- 可以添加自动翻译功能，调用翻译 API 自动补充缺失的翻译
- 可以生成 Excel 或 CSV 格式的报告，方便翻译人员使用
- 可以添加翻译质量检查，比如检查是否有未翻译的中文内容