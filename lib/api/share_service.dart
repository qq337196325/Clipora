import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:get/get.dart';

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

  @override
  void onInit() {
    super.onInit();
    _initializeShareListeners();
  }

  /// 初始化分享监听器
  void _initializeShareListeners() {
    try {
      debugPrint('正在初始化分享监听器...');
      
      // 监听媒体文件分享 (应用在内存中时) - 在v1.6.0+版本中，所有类型的分享都通过media stream接收
      _intentMediaStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen(
        (List<SharedMediaFile> value) {
          debugPrint('接收到分享内容 (运行时): ${value.map((f) => '${f.path} - ${f.type}').join(", ")}');
          _handleMediaShare(value);
        },
        onError: (err) {
          debugPrint('分享接收错误: $err');
        },
      );

      // 检查应用启动时的分享内容
      _checkInitialShare();
      
      debugPrint('分享监听器初始化完成');
    } catch (e) {
      debugPrint('初始化分享监听器错误: $e');
    }
  }

  /// 检查应用启动时的分享内容
  void _checkInitialShare() {
    // 使用Future.delayed来确保应用完全启动后再检查
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        // 检查初始媒体分享 (应用被关闭时收到的分享) - 在v1.6.0+版本中，包括文本内容
        debugPrint('检查初始分享内容...');
        final List<SharedMediaFile> initialMedia = await ReceiveSharingIntent.instance.getInitialMedia();
        if (initialMedia.isNotEmpty) {
          debugPrint('应用启动时接收到分享: ${initialMedia.map((f) => '${f.path} - ${f.type}').join(", ")}');
          _handleMediaShare(initialMedia);
          // 处理完成后清除
          ReceiveSharingIntent.instance.reset();
        } else {
          debugPrint('没有初始分享内容');
        }
      } catch (e) {
        debugPrint('检查初始分享内容时出错: $e');
      }
    });
  }

  /// 处理媒体文件分享 (包括文本、URL、图片、文件等所有类型)
  void _handleMediaShare(List<SharedMediaFile> mediaFiles) {
    for (final mediaFile in mediaFiles) {
      SharedContent content;
      
      debugPrint('处理分享文件: ${mediaFile.path}, 类型: ${mediaFile.type}, 消息: ${mediaFile.message}');
      
      // 判断分享类型
      if (mediaFile.type == SharedMediaType.text) {
        // 文本类型
        final text = mediaFile.message ?? mediaFile.path;
        if (_isUrl(text)) {
          content = SharedContent(
            type: ShareContentType.url,
            url: text,
            text: text,
            title: '分享的链接',
          );
        } else {
          content = SharedContent(
            type: ShareContentType.text,
            text: text,
            title: '分享的文本',
          );
        }
      } else if (mediaFile.type == SharedMediaType.image) {
        // 图片类型
        content = SharedContent(
          type: ShareContentType.image,
          imagePath: mediaFile.path,
          title: '分享的图片',
        );
      } else if (mediaFile.type == SharedMediaType.video) {
        // 视频类型（当作文件处理）
        content = SharedContent(
          type: ShareContentType.file,
          filePath: mediaFile.path,
          title: '分享的视频',
        );
      } else {
        // 其他文件类型
        if (_isImageFile(mediaFile.path)) {
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

      debugPrint('添加分享内容到流: $content');
      _sharedContentController.add(content);
    }
  }

  /// 手动处理分享内容 (测试方法)
  void handleManualShare(String content, ShareContentType type) {
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

    debugPrint('手动添加测试分享内容: $sharedContent');
    _sharedContentController.add(sharedContent);
  }

  /// 判断文本是否为URL
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
      debugPrint('已清除分享内容');
    } catch (e) {
      debugPrint('清除分享内容时出错: $e');
    }
  }

  @override
  void onClose() {
    _intentMediaStreamSubscription?.cancel();
    _sharedContentController.close();
    super.onClose();
  }
} 