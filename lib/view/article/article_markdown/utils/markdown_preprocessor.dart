/// Markdown 本地资源预处理工具
/// 将以 cliporaimages/ 开头的相对路径补全为 file:// 完整路径
class MarkdownPreprocessor {
  // 预编译正则以减少重复创建开销
  static final RegExp _mdLink = RegExp(r'(\()(\s*)(cliporaimages\/)');
  static final RegExp _srcDouble = RegExp(r'(src\s*=\s*")cliporaimages\/');
  static final RegExp _srcSingle = RegExp(r"(src\s*=\s*')cliporaimages\/");
  static final RegExp _hrefDouble = RegExp(r'(href\s*=\s*")cliporaimages\/');
  static final RegExp _hrefSingle = RegExp(r"(href\s*=\s*')cliporaimages\/");

  /// 将 Markdown/HTML 中的 cliporaimages/ 路径补全为以 [localPath] 为根的 file:// 路径
  /// [content] 原始 Markdown 内容
  /// [localPath] 当前文章的本地根路径（如 mhtml 保存目录）
  static String prepareCliporaLocalAssets(String content, String localPath) {
    if (content.isEmpty || !content.contains('cliporaimages/')) return content;
    if (localPath.isEmpty) return content;

    // 构造 file:// 前缀，并确保以 "/" 结尾
    var basePrefix = Uri.file(localPath).toString();
    if (!basePrefix.endsWith('/')) basePrefix = '$basePrefix/';

    var result = content;

    // Markdown/普通链接中的 (cliporaimages/xxx)
    result = result.replaceAllMapped(
      _mdLink,
      (m) => '${m.group(1)}${m.group(2)}${basePrefix}cliporaimages/',
    );

    // HTML 属性：src="cliporaimages/..." 或 src='cliporaimages/...'
    result = result.replaceAllMapped(
      _srcDouble,
      (m) => '${m.group(1)}${basePrefix}cliporaimages/',
    );
    result = result.replaceAllMapped(
      _srcSingle,
      (m) => '${m.group(1)}${basePrefix}cliporaimages/',
    );

    // HTML 属性：href="cliporaimages/..." 或 href='cliporaimages/...'
    result = result.replaceAllMapped(
      _hrefDouble,
      (m) => '${m.group(1)}${basePrefix}cliporaimages/',
    );
    result = result.replaceAllMapped(
      _hrefSingle,
      (m) => '${m.group(1)}${basePrefix}cliporaimages/',
    );

    return result;
  }

  /// 清理文本用于复制/预览：去 HTML 标签、规范空白、合并多余空行
  static String cleanTextForCopy(String content) {
    if (content.isEmpty) return '';
    String cleaned = content.replaceAll(RegExp(r'<[^>]*>'), '');
    cleaned = cleaned
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\n\s*\n'), '\n\n')
        .trim();
    return cleaned;
  }
}