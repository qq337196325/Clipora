import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../basics/logger.dart';
import '../db/article/article_service.dart';


/// 分享内容类型枚举
enum ShareContentType {
  text,
  image,
  file,
  url,
}

/// 分享内容模型
class SharedContent {
  final ShareContentType type;
  final String? text;
  final String? imagePath;
  final String? filePath;
  final String? url;
  final String? title;

  SharedContent({
    required this.type,
    this.text,
    this.imagePath,
    this.filePath,
    this.url,
    this.title,
  });

  @override
  String toString() {
    return 'SharedContent(type: $type, text: $text, imagePath: $imagePath, filePath: $filePath, url: $url, title: $title)';
  }
}

/// 分享服务类
class ShareService extends GetxService {
  static ShareService get instance => Get.find<ShareService>();

  // 分享内容流
  final _sharedContentController = StreamController<SharedContent>.broadcast();
  Stream<SharedContent> get sharedContentStream => _sharedContentController.stream;

  // 订阅
  StreamSubscription? _intentMediaStreamSubscription;
  
  // App Group 标识符
  static const String appGroupId = 'group.com.guanshangyun.clipora';

  @override
  void onInit() {
    super.onInit();
    getLogger().i('ShareService onInit 被调用');
    // 延迟初始化，确保Flutter引擎完全启动
    // 移除不必要的100ms延迟，在onInit中初始化监听器是安全的。
    _initializeShareListeners();
    
    // 初始化Share Extension数据检查
    _initializeShareExtensionListener();
  }

  @override
  void onReady() {
    super.onReady();
    getLogger().i('ShareService onReady 被调用');
    // 在这里检查初始分享内容，确保UI已经准备好
    // _checkInitialShare();
    // 初始分享内容的检查已移至 main.dart 以优化启动流程
    
    // 检查Share Extension的数据
    _checkShareExtensionData();
  }

  /// 初始化分享监听器
  void _initializeShareListeners() {
    try {
      getLogger().i('===== 开始初始化分享监听器 =====');
      
      // 监听所有类型的分享内容 (应用在内存中时)
      // 从v1.6.0+开始，所有类型的分享(包括文本)都通过getMediaStream接收
      _intentMediaStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen(
        (List<SharedMediaFile> value) {
          getLogger().i('🎯 接收到分享内容 (运行时): ${value.length} 个文件');
          for (var file in value) {
            getLogger().i('分享文件详情: path=${file.path}, type=${file.type}, message=${file.message}');
          }
          if (value.isNotEmpty) {
            _handleMediaShare(value);
          }
        },
        onError: (err) {
          getLogger().e('❌ 分享接收错误: $err');
        },
      );

      getLogger().i('✅ 分享监听器初始化完成');
    } catch (e) {
      getLogger().e('❌ 初始化分享监听器时发生错误: $e');
    }
  }

  /// 处理从 main.dart 传递的初始分享内容
  /// 应用冷启动时，由 main.dart 调用此方法来处理分享
  void processInitialShare(List<SharedMediaFile> initialMedia) {
    getLogger().i('===== 开始处理初始分享内容 (由main传递) =====');

    if (initialMedia.isEmpty) {
      getLogger().i('📭 没有发现初始分享内容');
      return;
    }

    getLogger().i('🎉 发现初始分享内容:');
    for (var file in initialMedia) {
      getLogger().i('初始分享文件: path=${file.path}, type=${file.type}, message=${file.message}');
    }
    _handleMediaShare(initialMedia);
    // 处理完成后清除，避免重复处理
    ReceiveSharingIntent.instance.reset();
  }

  /// 处理媒体文件分享 (包括文本、URL、图片、文件等所有类型)
  void _handleMediaShare(List<SharedMediaFile> mediaFiles) {
    getLogger().i('🔄 开始处理 ${mediaFiles.length} 个分享文件');
    getLogger().i('🔄 当前平台: ${Platform.isIOS ? "iOS" : Platform.isAndroid ? "Android" : "Unknown"}');
    
    for (final mediaFile in mediaFiles) {
      SharedContent content;

      getLogger().i('========== 处理单个分享文件 ==========');
      getLogger().i('📄 文件路径: ${mediaFile.path}');
      getLogger().i('📄 文件类型: ${mediaFile.type}');
      getLogger().i('📄 消息内容: ${mediaFile.message}');
      getLogger().i('📄 文件路径长度: ${mediaFile.path.length}');
      getLogger().i('📄 消息是否为空: ${mediaFile.message?.isEmpty ?? 'null'}');
      getLogger().i('📄 处理路径: ${Platform.isIOS ? "iOS标准路径" : "Android标准路径"}');

      print('📄 文件路径: ${mediaFile.path}');
      print('📄 文件类型: ${mediaFile.type}');
      print('📄 消息内容: ${mediaFile.message}');
      
      // iOS额外调试信息
      if (Platform.isIOS) {
        getLogger().i('🍎 iOS特别调试信息:');
        getLogger().i('🍎 mediaFile.path 的详细内容: "${mediaFile.path}"');
        getLogger().i('🍎 mediaFile.message 的详细内容: "${mediaFile.message}"');
        getLogger().i('🍎 mediaFile.type 的详细内容: ${mediaFile.type}');
        getLogger().i('🍎 path包含http检查: ${mediaFile.path.toLowerCase().contains('http')}');
        getLogger().i('🍎 message包含http检查: ${mediaFile.message?.toLowerCase().contains('http') ?? false}');
        
        // 检查所有可能的URL位置
        final allTexts = [mediaFile.path, mediaFile.message].where((t) => t != null && t.isNotEmpty);
        for (final text in allTexts) {
          getLogger().i('🍎 检查文本: "$text"');
          getLogger().i('🍎 URL检查结果: ${_containsUrl(text!)}');
        }
      }

      // 判断分享类型
      if (mediaFile.type == SharedMediaType.text) {
        getLogger().i('🎯 进入文本类型处理分支');
        // 文本类型 - 优先使用message，如果没有则使用path
        final text = mediaFile.message?.isNotEmpty == true ? mediaFile.message! : mediaFile.path;
        getLogger().i('📝 最终使用的文本: ${text.substring(0, text.length > 100 ? 100 : text.length)}${text.length > 100 ? '...' : ''}');

        print('📄 消息内容: ${mediaFile.message}');

        // 检查文本中是否包含URL，而不是要求整个文本必须是URL
        getLogger().i('🔍 准备调用_containsUrl方法检查URL');
        if (_containsUrl(text)) {
          getLogger().i('🔗 文本中包含URL，识别为URL类型');
          content = SharedContent(
            type: ShareContentType.url,
            url: _extractUrl(text),
            text: text,
            title: '分享的链接',
          );
        } else {
          getLogger().i('📝 文本中不包含URL，识别为纯文本类型');
          content = SharedContent(
            type: ShareContentType.text,
            text: text,
            title: '分享的文本',
          );
        }
      } else if (mediaFile.type == SharedMediaType.url) {
        // URL类型 - iOS经常使用这种类型，URL通常在path字段中
        getLogger().i('🔗 进入URL类型处理分支');
        final url = mediaFile.path; // iOS上URL存储在path字段中
        final text = mediaFile.message?.isNotEmpty == true ? mediaFile.message! : url;
        getLogger().i('🔗 URL内容: $url');
        getLogger().i('🔗 文本内容: $text');
        
        content = SharedContent(
          type: ShareContentType.url,
          url: url,
          text: text,
          title: '分享的链接',
        );
      } else if (mediaFile.type == SharedMediaType.image) {
        // 图片类型
        getLogger().i('识别为图片类型: ${mediaFile.path}');
        content = SharedContent(
          type: ShareContentType.image,
          imagePath: mediaFile.path,
          title: '分享的图片',
        );
      } else if (mediaFile.type == SharedMediaType.video) {
        // 视频类型（当作文件处理）
        getLogger().i('识别为视频类型: ${mediaFile.path}');
        content = SharedContent(
          type: ShareContentType.file,
          filePath: mediaFile.path,
          title: '分享的视频',
        );
      } else {
        // 其他文件类型或者未知类型
        getLogger().i('识别为其他文件类型: ${mediaFile.path}');
        
        // iOS平台额外处理逻辑
        if (Platform.isIOS) {
          getLogger().i('🍎 iOS其他类型额外处理');
          
          // 检查所有可能包含文本的字段
          final possibleTexts = [
            mediaFile.path,
            mediaFile.message,
          ].where((text) => text != null && text.isNotEmpty && text.length < 2000);
          
          for (final text in possibleTexts) {
            getLogger().i('🍎 检查可能的文本内容: "${text!.substring(0, text.length > 100 ? 100 : text.length)}..."');
            if (_containsUrl(text)) {
              getLogger().i('🍎 在其他类型中发现URL: ${_extractUrl(text)}');
              content = SharedContent(
                type: ShareContentType.url,
                url: _extractUrl(text),
                text: text,
                title: '分享的链接',
              );
              break;
            }
          }
          
          // 如果没有找到URL，继续原有逻辑
          if (!possibleTexts.any((text) => _containsUrl(text!))) {
            getLogger().i('🍎 iOS其他类型中未发现URL，按原逻辑处理');
          }
        }
        
        // 如果path是文本内容（可能是一些应用传递的纯文本但类型标记错误）
        if (mediaFile.path.length < 500 && !mediaFile.path.contains('/') && !mediaFile.path.contains('\\')) {
          // 可能是文本内容
          if (_containsUrl(mediaFile.path)) {
            content = SharedContent(
              type: ShareContentType.url,
              url: _extractUrl(mediaFile.path),
              text: mediaFile.path,
              title: '分享的链接',
            );
          } else {
            content = SharedContent(
              type: ShareContentType.text,
              text: mediaFile.path,
              title: '分享的文本',
            );
          }
        } else if (_isImageFile(mediaFile.path)) {
          content = SharedContent(
            type: ShareContentType.image,
            imagePath: mediaFile.path,
            title: '分享的图片',
          );
        } else {
          content = SharedContent(
            type: ShareContentType.file,
            filePath: mediaFile.path,
            title: '分享的文件',
          );
        }
      }

      getLogger().i('📤 添加分享内容到流: $content');
      _sharedContentController.add(content);
      
      // 保存到数据库
      _saveSharedContentToDatabase(content, mediaFile.path);
    }
  }

  /// 保存分享内容到数据库
  Future<void> _saveSharedContentToDatabase(SharedContent content, String originalContent) async {
    try {
      getLogger().i('💾 开始保存分享内容到数据库');
      getLogger().i('💾 分享内容类型: ${content.type}');
      getLogger().i('💾 原始内容: ${originalContent.substring(0, originalContent.length > 100 ? 100 : originalContent.length)}...');
      
      // 只处理文本和URL类型的分享内容
      if (content.type != ShareContentType.text && content.type != ShareContentType.url) {
        getLogger().i('🚫 跳过非文本类型的分享内容保存: ${content.type}');
        return;
      }

      // 测试数据库连接
      getLogger().i('🔗 测试数据库连接...');
      try {
        await ArticleService.instance.getAllArticles();
        getLogger().i('✅ 数据库连接正常');
      } catch (e) {
        getLogger().e('❌ 数据库连接测试失败: $e');
        throw e;
      }

      String title = '';
      String url = '';

      if (content.type == ShareContentType.url) {
        getLogger().i('🔗 处理URL类型内容');
        // URL类型，需要解析标题和URL
        final parseResult = _parseSharedContent(originalContent);
        title = parseResult['title'] ?? '分享的链接';
        url = parseResult['url'] ?? content.url ?? '';
        getLogger().i('🔗 解析后的标题: $title');
        getLogger().i('🔗 解析后的URL: $url');
      } else {
        getLogger().i('📝 处理文本类型内容');

        print('📝 11处理文本类型内容: ${content.text}'  );
        print('📝 22处理文本类型内容: ${content.url}'  );
        print('📝 33处理文本类型内容: ${content.type}'  );
        print('📝 33处理文本类型内容: ${content.title}'  );

        // 纯文本类型
        title = _extractTitleFromText(content.text ?? originalContent);
        url = '';
        getLogger().i('📝 提取的标题: $title');
      }

      // 检查是否已存在相同URL的文章（只对URL类型检查）
      if (url.isNotEmpty) {
        getLogger().i('🔍 检查URL是否已存在: $url');
        final existingArticle = await ArticleService.instance.findArticleByUrl(url);
        if (existingArticle != null) {
          getLogger().i('⚠️ 文章已存在，跳过保存: ${existingArticle.title}');
          return;
        }
        getLogger().i('✅ URL不存在，可以保存');
      }

      // 创建并保存文章
      getLogger().i('📝 准备创建文章');
      getLogger().i('📝 标题: $title');
      getLogger().i('📝 URL: $url');
      getLogger().i('📝 原始内容长度: ${originalContent.length}');
      
      final article = await ArticleService.instance.createArticleFromShare(
        title: title,
        url: url,
        originalContent: originalContent,
        excerpt: _generateExcerpt(content.text ?? originalContent),
        tags: ['分享内容'], // 可以根据内容类型添加不同标签
      );

      getLogger().i('✅ 分享内容已保存到数据库: ${article.title}, ID: ${article.id}');

    } catch (e, stackTrace) {
      getLogger().e('❌ 保存分享内容到数据库失败: $e');
      getLogger().e('堆栈跟踪: $stackTrace');
    }
  }

  /// 解析分享内容，提取标题和URL
  Map<String, String> _parseSharedContent(String content) {
    try {
      getLogger().i('🔍 开始解析分享内容: ${content.substring(0, content.length > 100 ? 100 : content.length)}...');
      
      // 从用户提供的示例来看，格式是：标题 + URL
      // 例如：中方刚挂电话，一架专机抵京，特朗普点出三名大将，做好对话准备https://m.toutiaocdn.com/...
      
      // 使用正则表达式匹配URL
      final urlRegex = RegExp(r'(https?://[^\s]+)', caseSensitive: false);
      final urlMatch = urlRegex.firstMatch(content);
      
      if (urlMatch != null) {
        final url = urlMatch.group(1)!;
        final urlStartIndex = urlMatch.start;
        
        getLogger().i('🔍 找到URL: $url');
        getLogger().i('🔍 URL开始位置: $urlStartIndex');
        
        // 提取URL前面的文本作为标题
        final title = content.substring(0, urlStartIndex).trim();
        getLogger().i('🔍 提取的标题: $title');
        
        final result = {
          'title': title.isNotEmpty ? title : '分享的链接',
          'url': url,
        };
        getLogger().i('🔍 解析结果: $result');
        return result;
      }
      
      getLogger().i('🔍 未找到URL，检查是否为纯URL');
      // 如果没有找到URL，可能整个内容就是一个URL
      if (_isUrl(content.trim())) {
        getLogger().i('🔍 识别为纯URL');
        return {
          'title': '分享的链接',
          'url': content.trim(),
        };
      }
      
      getLogger().i('🔍 未识别为URL，当作纯文本处理');
      // 如果都不是，当作纯文本处理
      return {
        'title': _extractTitleFromText(content),
        'url': '',
      };
    } catch (e) {
      getLogger().e('❌ 解析分享内容失败: $e');
      return {
        'title': '分享的内容',
        'url': '',
      };
    }
  }

  /// 从文本中提取标题（取前面部分作为标题）
  String _extractTitleFromText(String text) {
    if (text.isEmpty) return '未命名内容';
    
    // 取前50个字符作为标题，如果有换行符就在第一个换行符处截断
    final firstLineEnd = text.indexOf('\n');
    if (firstLineEnd > 0 && firstLineEnd < 50) {
      return text.substring(0, firstLineEnd).trim();
    }
    
    if (text.length <= 50) {
      return text.trim();
    }
    
    return text.substring(0, 50).trim() + '...';
  }

  /// 生成摘要
  String _generateExcerpt(String content) {
    if (content.isEmpty) return '';
    
    // 取前200个字符作为摘要
    if (content.length <= 200) {
      return content.trim();
    }
    
    return content.substring(0, 200).trim() + '...';
  }

  /// 手动处理分享内容 (测试方法)
  void handleManualShare(String content, ShareContentType type) {
    getLogger().i('🧪 手动测试分享: content=$content, type=$type');
    
    SharedContent sharedContent;
    
    switch (type) {
      case ShareContentType.text:
        sharedContent = SharedContent(
          type: type,
          text: content,
          title: '测试分享的文本',
        );
        break;
      case ShareContentType.url:
        sharedContent = SharedContent(
          type: type,
          url: content,
          text: content,
          title: '测试分享的链接',
        );
        break;
      case ShareContentType.image:
        sharedContent = SharedContent(
          type: type,
          imagePath: content,
          title: '测试分享的图片',
        );
        break;
      case ShareContentType.file:
        sharedContent = SharedContent(
          type: type,
          filePath: content,
          title: '测试分享的文件',
        );
        break;
    }

    getLogger().i('📤 手动添加测试分享内容: $sharedContent');
    _sharedContentController.add(sharedContent);
  }

  /// 判断文本是否包含URL
  bool _containsUrl(String text) {
    getLogger().i('🔍 检查文本是否包含URL: ${text.substring(0, text.length > 100 ? 100 : text.length)}...');
    final urlRegex = RegExp(
      r'https?://[^\s]+',
      caseSensitive: false,
    );
    final hasUrl = urlRegex.hasMatch(text);
    getLogger().i('🔍 URL检查结果: $hasUrl');
    if (hasUrl) {
      final match = urlRegex.firstMatch(text);
      getLogger().i('🔍 找到的URL: ${match?.group(0)}');
    }
    return hasUrl;
  }

  /// 从文本中提取URL
  String _extractUrl(String text) {
    getLogger().i('🔗 从文本中提取URL: ${text.substring(0, text.length > 100 ? 100 : text.length)}...');
    final urlRegex = RegExp(
      r'(https?://[^\s]+)',
      caseSensitive: false,
    );
    final match = urlRegex.firstMatch(text);
    final extractedUrl = match?.group(1) ?? text;
    getLogger().i('🔗 提取的URL: $extractedUrl');
    return extractedUrl;
  }

  /// 判断文本是否为纯URL（严格匹配）
  bool _isUrl(String text) {
    final urlRegex = RegExp(
      r'^(https?|ftp)://[^\s/$.?#].[^\s]*$',
      caseSensitive: false,
    );
    return urlRegex.hasMatch(text.trim());
  }

  /// 判断文件是否为图片
  bool _isImageFile(String path) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final extension = path.toLowerCase().split('.').last;
    return imageExtensions.contains('.$extension');
  }

  /// 清除分享内容 (处理完成后调用)
  void clearSharedContent() {
    try {
      ReceiveSharingIntent.instance.reset();
      getLogger().i('✅ 已清除分享内容');
    } catch (e) {
      getLogger().e('❌ 清除分享内容时出错: $e');
    }
  }

  /// 初始化Share Extension监听器
  void _initializeShareExtensionListener() {
    try {
      getLogger().i('===== 初始化Share Extension监听器 =====');
      
      // 设置定时器，每2秒检查一次Share Extension的数据
      Timer.periodic(Duration(seconds: 2), (timer) {
        _checkShareExtensionData();
      });
      
      getLogger().i('✅ Share Extension监听器初始化完成');
    } catch (e) {
      getLogger().e('❌ 初始化Share Extension监听器失败: $e');
    }
  }

  /// 检查Share Extension的数据
  Future<void> _checkShareExtensionData() async {
    try {
      if (Platform.isIOS) {
        // 在iOS上检查App Group共享数据
        await _checkAppGroupSharedData();
      }
    } catch (e) {
      getLogger().e('❌ 检查Share Extension数据失败: $e');
    }
  }

  /// 检查App Group共享数据
  Future<void> _checkAppGroupSharedData() async {
    try {
      // 获取App Group容器路径
      final appGroupPath = await _getAppGroupPath();
      if (appGroupPath == null) {
        return;
      }

      final sharedDataFile = File('$appGroupPath/SharedData.json');
      if (!await sharedDataFile.exists()) {
        return;
      }

      // 读取共享数据
      final jsonString = await sharedDataFile.readAsString();
      final List<dynamic> sharedDataList = jsonDecode(jsonString);

      if (sharedDataList.isEmpty) {
        return;
      }

      getLogger().i('🎉 发现Share Extension数据: ${sharedDataList.length}个');

      // 处理每个分享项
      for (final item in sharedDataList) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(item);
        await _handleShareExtensionData(data);
      }

      // 清空已处理的数据
      await sharedDataFile.delete();
      getLogger().i('✅ Share Extension数据处理完成并清空');

    } catch (e) {
      getLogger().e('❌ 处理App Group共享数据失败: $e');
    }
  }

  /// 获取App Group路径
  Future<String?> _getAppGroupPath() async {
    try {
      if (Platform.isIOS) {
        // 在iOS上，App Group的路径通常是 /private/var/mobile/Containers/Shared/AppGroup/[GROUP_ID]
        // 但Flutter无法直接访问，需要通过原生代码
        // 这里我们尝试通过已知的路径结构来构建
        final documentsPath = (await getApplicationDocumentsDirectory()).path;
        final appGroupPath = documentsPath.replaceAll('/Documents', '/../../../Shared/AppGroup/$appGroupId');
        
        // 检查路径是否存在
        final directory = Directory(appGroupPath);
        if (await directory.exists()) {
          return appGroupPath;
        }
        
        // 如果上面的路径不存在，尝试其他可能的路径
        final alternativePath = documentsPath.replaceAll('/var/mobile/Containers/Data/Application', '/var/mobile/Containers/Shared/AppGroup') + '/$appGroupId';
        final alternativeDirectory = Directory(alternativePath);
        if (await alternativeDirectory.exists()) {
          return alternativePath;
        }
      }
      return null;
    } catch (e) {
      getLogger().e('❌ 获取App Group路径失败: $e');
      return null;
    }
  }

  /// 处理Share Extension数据
  Future<void> _handleShareExtensionData(Map<String, dynamic> data) async {
    try {
      final String type = data['type'] ?? 'text';
      final String content = data['content'] ?? '';
      final String? fileName = data['fileName'];
      final double? timestamp = data['timestamp'];

      getLogger().i('📦 处理Share Extension数据: type=$type, content=${content.length > 100 ? content.substring(0, 100) + '...' : content}');

      SharedContent sharedContent;

      switch (type) {
        case 'text':
          // iOS Share Extension的文本类型也需要检查URL，与Android保持一致
          getLogger().i('🎯 iOS Share Extension: 进入文本类型处理分支');
          getLogger().i('📝 文本内容: ${content.substring(0, content.length > 100 ? 100 : content.length)}${content.length > 100 ? '...' : ''}');
          
          // 检查文本中是否包含URL，与_handleMediaShare方法保持一致
          if (_containsUrl(content)) {
            getLogger().i('🔗 iOS Share Extension: 文本中包含URL，识别为URL类型');
            sharedContent = SharedContent(
              type: ShareContentType.url,
              url: _extractUrl(content),
              text: content,
              title: '分享的链接',
            );
          } else {
            getLogger().i('📝 iOS Share Extension: 文本中不包含URL，识别为纯文本类型');
            sharedContent = SharedContent(
              type: ShareContentType.text,
              text: content,
              title: '分享的文本',
            );
          }
          break;
        case 'url':
          sharedContent = SharedContent(
            type: ShareContentType.url,
            url: content,
            text: content,
            title: '分享的链接',
          );
          break;
        case 'image':
          sharedContent = SharedContent(
            type: ShareContentType.image,
            imagePath: content,
            title: '分享的图片',
          );
          break;
        case 'video':
        case 'file':
          sharedContent = SharedContent(
            type: ShareContentType.file,
            filePath: content,
            title: fileName ?? '分享的文件',
          );
          break;
        default:
          // 默认情况下也进行URL检测
          getLogger().i('📦 iOS Share Extension: 未知类型，进行URL检测');
          if (_containsUrl(content)) {
            getLogger().i('🔗 iOS Share Extension: 未知类型中包含URL，识别为URL类型');
            sharedContent = SharedContent(
              type: ShareContentType.url,
              url: _extractUrl(content),
              text: content,
              title: '分享的链接',
            );
          } else {
            getLogger().i('📝 iOS Share Extension: 未知类型不包含URL，识别为文本类型');
            sharedContent = SharedContent(
              type: ShareContentType.text,
              text: content,
              title: '分享的内容',
            );
          }
      }

      // 添加到流中
      _sharedContentController.add(sharedContent);

      // 保存到数据库
      await _saveSharedContentToDatabase(sharedContent, content);

      getLogger().i('✅ Share Extension数据处理完成: ${sharedContent.title}');

    } catch (e) {
      getLogger().e('❌ 处理Share Extension数据失败: $e');
    }
  }

  /// 处理URL Scheme打开
  void handleUrlSchemeOpen(String url) {
    getLogger().i('🔗 处理URL Scheme打开: $url');
    
    if (url.startsWith('ShareMedia-com.guanshangyun.clipora://')) {
      getLogger().i('📱 收到Share Extension通知，检查共享数据');
      // 延迟检查，确保数据已经写入
      Future.delayed(Duration(milliseconds: 500), () {
        _checkShareExtensionData();
      });
    }
  }

  @override
  void onClose() {
    getLogger().i('ShareService onClose 被调用');
    _intentMediaStreamSubscription?.cancel();
    _sharedContentController.close();
    super.onClose();
  }
} 